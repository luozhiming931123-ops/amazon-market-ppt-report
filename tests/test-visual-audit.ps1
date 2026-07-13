$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$audit = Join-Path $root "scripts/audit-pptx-visuals.ps1"
$goodPlan = Join-Path $root "examples/visual-plan-led-whip-good.json"
$badPlan = Join-Path $root "examples/visual-plan-card-heavy-bad.json"
$functionalPlan = Join-Path $root "examples/functional-semistandard-visual-plan.json"
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("amazon-market-ppt-visual-audit-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $temp | Out-Null

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Add-ZipText($Archive, [string]$Name, [string]$Text) {
  $entry = $Archive.CreateEntry($Name)
  $writer = New-Object System.IO.StreamWriter($entry.Open())
  try { $writer.Write($Text) } finally { $writer.Dispose() }
}

function New-FixturePptx([string]$Path, [bool]$WithVisualTags) {
  $plan = Get-Content -LiteralPath $goodPlan -Raw -Encoding UTF8 | ConvertFrom-Json
  $file = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create)
  $archive = New-Object System.IO.Compression.ZipArchive($file, [System.IO.Compression.ZipArchiveMode]::Create, $false)
  try {
    Add-ZipText $archive "[Content_Types].xml" '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types" />'
    foreach ($slide in 1..18) {
      $visual = @($plan.visuals | Where-Object { [int]$_.slide -eq $slide } | Select-Object -First 1)
      $tag = ""
      if ($WithVisualTags -and $visual.Count -gt 0) {
        $v = $visual[0]
        $tag = "[VISUAL role=$($v.role);type=$($v.type);source=$($v.source);sample=$($v.sample);period=$($v.period);points=$($v.data_points)]"
      }
      $shape = if ($tag) {
        "<p:sp><p:nvSpPr><p:cNvPr id=`"2`" name=`"$tag`" descr=`"$tag`"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr><p:spPr/><p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:r><a:t>Evidence visual</a:t></a:r></a:p></p:txBody></p:sp>"
      } else {
        "<p:sp><p:nvSpPr><p:cNvPr id=`"2`" name=`"Summary card`"/><p:cNvSpPr/><p:nvPr/></p:nvSpPr><p:spPr/><p:txBody><a:bodyPr/><a:lstStyle/><a:p><a:r><a:t>Summary only</a:t></a:r></a:p></p:txBody></p:sp>"
      }
      $xml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?><p:sld xmlns:a=`"http://schemas.openxmlformats.org/drawingml/2006/main`" xmlns:p=`"http://schemas.openxmlformats.org/presentationml/2006/main`"><p:cSld><p:spTree><p:nvGrpSpPr><p:cNvPr id=`"1`" name=`"`"/><p:cNvGrpSpPr/><p:nvPr/></p:nvGrpSpPr><p:grpSpPr/>$shape</p:spTree></p:cSld></p:sld>"
      Add-ZipText $archive ("ppt/slides/slide{0}.xml" -f $slide) $xml
    }
  } finally {
    $archive.Dispose()
    $file.Dispose()
  }
}

try {
  $functional = Get-Content -LiteralPath $functionalPlan -Raw -Encoding UTF8 | ConvertFrom-Json
  if (@($functional.visuals | ForEach-Object { $_.role } | Sort-Object -Unique).Count -lt 12) { throw "Functional-product example must define 12 distinct visual roles." }
  foreach ($visual in @($functional.visuals)) {
    foreach ($field in @("decision_question", "implication", "scope_limit")) {
      if ("$($visual.$field)".Length -lt 8) { throw "Functional-product example is missing a usable '$field'." }
    }
  }

  $good = Join-Path $temp "good.pptx"
  $bad = Join-Path $temp "bad.pptx"
  $missingDecisionPlan = Join-Path $temp "missing-decision.json"
  New-FixturePptx $good $true
  New-FixturePptx $bad $false

  $result = & $audit -PptxPath $good -VisualPlanPath $goodPlan -Tier "Competitive Enhanced"
  if ($result.Result -ne "PASS" -or $result.DistinctVisualRoles -ne 12) { throw "Expected compliant fixture to pass the visual audit." }

  $failedAsExpected = $false
  try { & $audit -PptxPath $bad -VisualPlanPath $goodPlan -Tier "Competitive Enhanced" | Out-Null } catch { $failedAsExpected = $true }
  if (-not $failedAsExpected) { throw "Expected card-heavy fixture to fail the visual audit." }

  $badPlanRejected = $false
  try { & $audit -PptxPath $good -VisualPlanPath $badPlan -Tier "Competitive Enhanced" | Out-Null } catch { $badPlanRejected = $true }
  if (-not $badPlanRejected) { throw "Expected the card-heavy visual plan example to fail the visual audit." }

  $incompletePlan = Get-Content -LiteralPath $goodPlan -Raw -Encoding UTF8 | ConvertFrom-Json
  $incompletePlan.visuals[0].scope_limit = ""
  $incompletePlan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $missingDecisionPlan -Encoding UTF8
  $missingDecisionRejected = $false
  try { & $audit -PptxPath $good -VisualPlanPath $missingDecisionPlan -Tier "Competitive Enhanced" | Out-Null } catch { $missingDecisionRejected = $true }
  if (-not $missingDecisionRejected) { throw "Expected a visual plan without a scope limit to fail the visual audit." }

  [pscustomobject]@{ GoodFixture = "PASS"; CardHeavyFixture = "REJECTED"; BadPlan = "REJECTED"; MissingDecision = "REJECTED"; FunctionalExample = "PASS"; Result = "PASS" }
} finally {
  Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
}
