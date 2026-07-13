param(
  [Parameter(Mandatory = $true)]
  [string]$PptxPath,

  [Parameter(Mandatory = $true)]
  [string]$VisualPlanPath,

  [ValidateSet("Quick Brief", "Competitive Enhanced", "Deep Product Report")]
  [string]$Tier = "Competitive Enhanced",

  [double]$MinVisualSlideRatio = 0.60,

  [switch]$AllowShortTrend
)

$ErrorActionPreference = "Stop"

function Assert-Condition([bool]$Condition, [string]$Message) {
  if (-not $Condition) { throw $Message }
}

function Get-Threshold([string]$Type) {
  switch ($Type) {
    "bar" { return 3 }
    "line" { return 6 }
    "stacked_bar" { return 3 }
    "scatter" { return 6 }
    "heatmap" { return 16 }
    "matrix" { return 16 }
    "funnel" { return 3 }
    "timeline" { return 3 }
    "table" { return 18 }
    default { throw "Unsupported visual type: $Type" }
  }
}

function Get-PlanPointCount($Visual) {
  if ($Visual.type -in @("heatmap", "matrix")) { return [int]$Visual.rows * [int]$Visual.columns }
  if ($Visual.type -eq "table") { return [int]$Visual.rows * [int]$Visual.metrics }
  return [int]$Visual.data_points
}

Assert-Condition (Test-Path -LiteralPath $PptxPath) "PPTX not found: $PptxPath"
Assert-Condition (Test-Path -LiteralPath $VisualPlanPath) "Visual plan not found: $VisualPlanPath"

$plan = Get-Content -LiteralPath $VisualPlanPath -Raw -Encoding UTF8 | ConvertFrom-Json
Assert-Condition ($plan.tier -eq $Tier) "Visual plan tier '$($plan.tier)' does not match requested tier '$Tier'."
Assert-Condition ($null -ne $plan.visuals -and @($plan.visuals).Count -gt 0) "visual_plan must contain visuals."
Assert-Condition ($null -ne $plan.required_roles -and @($plan.required_roles).Count -gt 0) "visual_plan must contain required_roles."

$tierMinimum = @{ "Quick Brief" = 6; "Competitive Enhanced" = 12; "Deep Product Report" = 16 }[$Tier]
$planRoles = @($plan.visuals | ForEach-Object { [string]$_.role } | Sort-Object -Unique)
Assert-Condition ($planRoles.Count -ge $tierMinimum) "$Tier requires at least $tierMinimum distinct visual roles; found $($planRoles.Count)."
foreach ($role in @($plan.required_roles)) {
  Assert-Condition ($planRoles -contains $role) "required_role '$role' is absent from visuals."
}

foreach ($visual in @($plan.visuals)) {
  foreach ($field in @("slide", "role", "type", "source", "fields", "period", "sample", "data_points", "decision_question", "implication", "scope_limit")) {
    Assert-Condition ($null -ne $visual.$field -and "$($visual.$field)".Length -gt 0) "Visual '$($visual.role)' is missing '$field'."
  }
  foreach ($field in @("decision_question", "implication", "scope_limit")) {
    Assert-Condition ("$($visual.$field)".Length -ge 8) "Visual '$($visual.role)' needs a specific '$field' (8+ characters)."
  }
  Assert-Condition ($visual.source -match "^(data|analysis)/") "Visual '$($visual.role)' source must start with data/ or analysis/."
  Assert-Condition (@($visual.fields).Count -gt 0) "Visual '$($visual.role)' must declare source fields."
  if ($visual.type -in @("heatmap", "matrix")) {
    Assert-Condition ([int]$visual.rows -ge 4 -and [int]$visual.columns -ge 4) "Visual '$($visual.role)' requires at least a 4x4 grid."
  }
  if ($visual.type -eq "table") {
    Assert-Condition ([int]$visual.rows -ge 6 -and [int]$visual.metrics -ge 3) "Table '$($visual.role)' only counts as evidence with 6+ rows and 3+ metrics."
  }
  $threshold = Get-Threshold $visual.type
  $points = Get-PlanPointCount $visual
  if ($visual.type -eq "line" -and $points -lt 12 -and -not $AllowShortTrend) {
    throw "Trend '$($visual.role)' has $points points; require 12 months or rerun with -AllowShortTrend and state the short-period limitation."
  }
  Assert-Condition ($points -ge $threshold) "Visual '$($visual.role)' has $points data points; '$($visual.type)' requires $threshold."
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $PptxPath))
try {
  $slides = @($zip.Entries | Where-Object { $_.FullName -match '^ppt/slides/slide\d+\.xml$' } | Sort-Object FullName)
  Assert-Condition ($slides.Count -gt 0) "No slide XML found in PPTX."
  $namespace = New-Object System.Xml.XmlNamespaceManager (New-Object System.Xml.NameTable)
  $namespace.AddNamespace("p", "http://schemas.openxmlformats.org/presentationml/2006/main")
  $namespace.AddNamespace("a", "http://schemas.openxmlformats.org/drawingml/2006/main")
  $tags = @()
  $pureTextSlides = 0

  foreach ($entry in $slides) {
    $number = [int]([regex]::Match($entry.FullName, 'slide(\d+)\.xml$').Groups[1].Value)
    $reader = New-Object System.IO.StreamReader($entry.Open())
    try { [xml]$xml = $reader.ReadToEnd() } finally { $reader.Dispose() }
    $nodes = @($xml.SelectNodes("//p:cNvPr", $namespace))
    $text = @($xml.SelectNodes("//a:t", $namespace) | ForEach-Object { $_.'#text' }) -join ""
    $visualMatches = @()
    foreach ($node in $nodes) {
      foreach ($candidate in @($node.GetAttribute("name"), $node.GetAttribute("descr"))) {
        if ($candidate -match '\[VISUAL role=([^;\]]+);type=([^;\]]+);source=([^;\]]+);sample=([^;\]]+);period=([^;\]]+);points=(\d+)\]') {
          $visualMatches += [pscustomobject]@{ Slide = $number; Role = $Matches[1]; Type = $Matches[2]; Source = $Matches[3]; Sample = $Matches[4]; Period = $Matches[5]; Points = [int]$Matches[6] }
        }
      }
    }
    $tags += $visualMatches
    if ($visualMatches.Count -eq 0 -and $text.Length -ge 180 -and $nodes.Count -lt 12) { $pureTextSlides += 1 }
  }

  foreach ($visual in @($plan.visuals)) {
    $match = @($tags | Where-Object { $_.Slide -eq [int]$visual.slide -and $_.Role -eq $visual.role -and $_.Type -eq $visual.type })
    Assert-Condition ($match.Count -gt 0) "Missing visual metadata for role '$($visual.role)' on slide $($visual.slide)."
    Assert-Condition ($match[0].Source -eq $visual.source) "Metadata source mismatch for '$($visual.role)' on slide $($visual.slide)."
  }

  $visualSlides = @($tags | ForEach-Object { $_.Slide } | Sort-Object -Unique)
  $ratio = [math]::Round($visualSlides.Count / $slides.Count, 3)
  Assert-Condition ($ratio -ge $MinVisualSlideRatio) "Only $($visualSlides.Count)/$($slides.Count) slides carry evidence visuals ($ratio); require $MinVisualSlideRatio or higher."
  $pureTextRatio = [math]::Round($pureTextSlides / $slides.Count, 3)
  Assert-Condition ($pureTextRatio -le 0.20) "Pure-text slide ratio is $pureTextRatio; maximum is 0.20."

  [pscustomobject]@{
    PptxPath = (Resolve-Path -LiteralPath $PptxPath).Path
    VisualPlanPath = (Resolve-Path -LiteralPath $VisualPlanPath).Path
    Tier = $Tier
    SlideXmlCount = $slides.Count
    DistinctVisualRoles = $planRoles.Count
    TaggedVisualSlides = $visualSlides.Count
    VisualSlideRatio = $ratio
    PureTextSlides = $pureTextSlides
    PureTextRatio = $pureTextRatio
    Result = "PASS"
  }
} finally {
  $zip.Dispose()
}
