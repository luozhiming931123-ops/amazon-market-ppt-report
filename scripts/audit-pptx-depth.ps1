param(
  [Parameter(Mandatory = $true)]
  [string]$PptxPath,

  [ValidateSet("QuickBrief", "CompetitiveEnhanced", "DeepProductReport")]
  [string]$Tier = "CompetitiveEnhanced",

  [string[]]$RequiredText = @(),

  [string[]]$CategoryTerms = @(),

  [switch]$WarnOnly
)

$ErrorActionPreference = "Stop"

if (!(Test-Path -LiteralPath $PptxPath)) {
  throw "PPTX not found: $PptxPath"
}

$tierRules = @{
  QuickBrief = @{ MinSlides = 10; MaxSlides = 14; MinVisualTerms = 6; MaxPureTextRatio = 0.25 }
  CompetitiveEnhanced = @{ MinSlides = 18; MaxSlides = 26; MinVisualTerms = 10; MaxPureTextRatio = 0.20 }
  DeepProductReport = @{ MinSlides = 28; MaxSlides = 40; MinVisualTerms = 16; MaxPureTextRatio = 0.20 }
}

$visualTerms = @(
  "容量", "趋势", "TOP ASIN", "竞争", "价格带", "品牌份额", "流量结构",
  "关键词机会", "产品方案", "包装", "适用人群", "评论风险", "定位图",
  "SKU", "年度目标", "季度", "路线图", "附录"
)

$RequiredText = @($RequiredText | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$CategoryTerms = @($CategoryTerms | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead($PptxPath)
try {
  $entries = @($zip.Entries)
  $slides = @($entries | Where-Object { $_.FullName -match '^ppt/slides/slide\d+\.xml$' } | Sort-Object { [int]([regex]::Match($_.FullName, 'slide(\d+)').Groups[1].Value) })
  $badSlash = @($entries | Where-Object { $_.FullName -like '*\*' })
  $allText = New-Object System.Text.StringBuilder
  $slideStats = @()

  foreach ($slide in $slides) {
    $reader = New-Object System.IO.StreamReader($slide.Open())
    try {
      $xmlText = $reader.ReadToEnd()
      [xml]$xmlText | Out-Null
      $texts = @([regex]::Matches($xmlText, '<a:t>(.*?)</a:t>') | ForEach-Object { [System.Net.WebUtility]::HtmlDecode($_.Groups[1].Value) })
      $joined = ($texts -join ' ')
      [void]$allText.AppendLine($joined)
      $slideStats += [pscustomobject]@{
        Slide = [int]([regex]::Match($slide.FullName, 'slide(\d+)').Groups[1].Value)
        TextChars = $joined.Length
        TextRuns = $texts.Count
        Shapes = ([regex]::Matches($xmlText, '<p:sp[ >]')).Count
        HasPrice = ($joined -match '\$|¥|￥')
        HasPercent = ($joined -match '%')
        HasASIN = ($joined -match 'B0[A-Z0-9]{8}|ASIN')
        HasEvidenceTerm = ($joined -match 'BSR|review|评论|traffic|流量|口径|SellerSprite|SIF|ABA')
      }
    } finally {
      $reader.Dispose()
    }
  }

  $text = $allText.ToString()
  $rule = $tierRules[$Tier]
  $errors = New-Object System.Collections.Generic.List[string]
  $warnings = New-Object System.Collections.Generic.List[string]

  if ($badSlash.Count -gt 0) { $errors.Add("PPTX contains backslash zip entries: $($badSlash[0].FullName)") }
  if ($slides.Count -lt $rule.MinSlides -or $slides.Count -gt $rule.MaxSlides) {
    $errors.Add("$Tier expects $($rule.MinSlides)-$($rule.MaxSlides) slides, found $($slides.Count)")
  }

  foreach ($term in $RequiredText) {
    if ($text -notlike "*$term*") { $errors.Add("Required text not found: $term") }
  }
  foreach ($term in $CategoryTerms) {
    if ($text -notlike "*$term*") { $errors.Add("Category term not found: $term") }
  }

  $visualHitCount = @($visualTerms | Where-Object { $text -like "*$_*" }).Count
  if ($visualHitCount -lt $rule.MinVisualTerms) {
    $errors.Add("$Tier expects at least $($rule.MinVisualTerms) visual-topic terms, found $visualHitCount")
  }

  $pureTextSlides = @($slideStats | Where-Object { $_.Shapes -lt 12 -and $_.TextChars -gt 300 }).Count
  $pureTextRatio = if ($slides.Count) { $pureTextSlides / $slides.Count } else { 1 }
  if ($pureTextRatio -gt $rule.MaxPureTextRatio) {
    $warnings.Add(("Pure-text slide ratio {0:P0} exceeds target {1:P0}" -f $pureTextRatio, $rule.MaxPureTextRatio))
  }

  if (@($slideStats | Where-Object HasPrice).Count -lt 2) { $warnings.Add("Few slides contain currency/price evidence.") }
  if (@($slideStats | Where-Object HasASIN).Count -lt 2) { $warnings.Add("Few slides contain ASIN evidence.") }
  if (@($slideStats | Where-Object HasPercent).Count -lt 1) { $warnings.Add("No percentage evidence found.") }
  if (@($slideStats | Where-Object HasEvidenceTerm).Count -lt [Math]::Min(6, $slides.Count)) { $warnings.Add("Few slides contain explicit source/evidence terms.") }

  $result = [pscustomobject]@{
    PptxPath = (Resolve-Path -LiteralPath $PptxPath).Path
    Tier = $Tier
    Bytes = (Get-Item -LiteralPath $PptxPath).Length
    Slides = $slides.Count
    TotalTextChars = ($slideStats | Measure-Object TextChars -Sum).Sum
    AvgTextChars = [math]::Round((($slideStats | Measure-Object TextChars -Average).Average), 0)
    VisualTopicHits = $visualHitCount
    SlidesWithPrice = @($slideStats | Where-Object HasPrice).Count
    SlidesWithASIN = @($slideStats | Where-Object HasASIN).Count
    SlidesWithPercent = @($slideStats | Where-Object HasPercent).Count
    PureTextSlides = $pureTextSlides
    Errors = @($errors)
    Warnings = @($warnings)
  }

  if ($errors.Count -gt 0 -and !$WarnOnly) {
    $result | Format-List | Out-String | Write-Error
    throw "PPTX depth audit failed with $($errors.Count) error(s)."
  }

  $result
} finally {
  $zip.Dispose()
}
