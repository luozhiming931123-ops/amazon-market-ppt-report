param(
  [Parameter(Mandatory = $true)]
  [string]$ManifestPath,

  [ValidateSet("QuickBrief", "CompetitiveEnhanced", "DeepProductReport")]
  [string]$Tier = "CompetitiveEnhanced",

  [switch]$WarnOnly
)

$ErrorActionPreference = "Stop"

function Has-Prop($Object, [string]$Name) {
  return $null -ne $Object.PSObject.Properties[$Name]
}

function As-Array($Value) {
  if ($null -eq $Value) { return @() }
  if ($Value -is [array]) { return @($Value) }
  return @($Value)
}

function Require-Fields($Slide, [string[]]$Fields, [System.Collections.Generic.List[string]]$Errors) {
  $present = @(As-Array $Slide.required_fields | ForEach-Object { ([string]$_).ToLowerInvariant() })
  foreach ($field in $Fields) {
    if ($present -notcontains $field.ToLowerInvariant()) {
      $Errors.Add("Slide $($Slide.slide) [$($Slide.visual_type)] missing required field: $field")
    }
  }
}

if (!(Test-Path -LiteralPath $ManifestPath)) {
  throw "Manifest not found: $ManifestPath"
}

$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$slides = @(As-Array $manifest.slides)

$coreVisualTypes = @(
  "keyword_capacity_bar",
  "keyword_trend",
  "top_asin_competitor_matrix",
  "price_band_distribution",
  "price_product_positioning_map",
  "brand_share_chart",
  "traffic_mix_stacked_bars",
  "product_scheme_matrix",
  "review_risk_cluster",
  "keyword_opportunity_matrix",
  "sku_ladder",
  "annual_target_chart",
  "execution_roadmap"
)

$supportVisualTypes = @(
  "cover",
  "one_page_conclusion",
  "data_scope",
  "appendix_data_table",
  "competitor_group_detail",
  "keyword_family_detail",
  "listing_proof_audit",
  "product_teardown",
  "compliance_risk",
  "inventory_launch_plan"
)

$tierRequired = @{
  QuickBrief = @(
    "keyword_capacity_bar",
    "keyword_trend",
    "top_asin_competitor_matrix",
    "price_band_distribution",
    "review_risk_cluster",
    "annual_target_chart"
  )
  CompetitiveEnhanced = $coreVisualTypes
  DeepProductReport = $coreVisualTypes
}

$tierMinimumVisualSlides = @{
  QuickBrief = 6
  CompetitiveEnhanced = 13
  DeepProductReport = 16
}

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if (!(Has-Prop $manifest "version")) { $errors.Add("Missing manifest.version") }
if (!(Has-Prop $manifest "tier")) { $errors.Add("Missing manifest.tier") }
if (!(Has-Prop $manifest "report_context")) { $errors.Add("Missing manifest.report_context") }
if ($manifest.tier -and $manifest.tier -ne $Tier) {
  $warnings.Add("Manifest tier '$($manifest.tier)' differs from requested tier '$Tier'")
}
if ($slides.Count -eq 0) { $errors.Add("Manifest has no slides") }

$allKnownTypes = @($coreVisualTypes + $supportVisualTypes)
$visualSlides = @()

foreach ($slide in $slides) {
  foreach ($prop in @("slide", "title", "visual_type")) {
    if (!(Has-Prop $slide $prop) -or [string]::IsNullOrWhiteSpace([string]$slide.$prop)) {
      $errors.Add("Slide entry missing required property: $prop")
    }
  }

  if ($slide.visual_type -and ($allKnownTypes -notcontains $slide.visual_type)) {
    $errors.Add("Slide $($slide.slide) uses unknown visual_type: $($slide.visual_type)")
  }

  if ($coreVisualTypes -contains $slide.visual_type -or @("competitor_group_detail","keyword_family_detail","listing_proof_audit","product_teardown","compliance_risk","inventory_launch_plan") -contains $slide.visual_type) {
    $visualSlides += $slide
    foreach ($prop in @("chart_kind", "data_source", "data_basis", "required_fields", "business_implication")) {
      if (!(Has-Prop $slide $prop) -or (@(As-Array $slide.$prop).Count -eq 0) -or [string]::IsNullOrWhiteSpace(([string]($slide.$prop -join ",")))) {
        $errors.Add("Slide $($slide.slide) [$($slide.visual_type)] missing visual property: $prop")
      }
    }
  }

  switch ($slide.visual_type) {
    "keyword_capacity_bar" { Require-Fields $slide @("keyword", "search_volume") $errors }
    "keyword_trend" { Require-Fields $slide @("keyword", "period", "search_volume") $errors }
    "top_asin_competitor_matrix" { Require-Fields $slide @("asin", "brand", "price", "rating", "reviews") $errors }
    "price_band_distribution" { Require-Fields $slide @("price", "price_band", "asin_count") $errors }
    "price_product_positioning_map" { Require-Fields $slide @("price", "product_scheme", "positioning") $errors }
    "brand_share_chart" {
      $fields = @(As-Array $slide.required_fields | ForEach-Object { ([string]$_).ToLowerInvariant() })
      $hasSales = ($fields -contains "sales_amount") -or ($fields -contains "sales_units")
      $hasFallback = (Has-Prop $slide "fallback_label") -and ![string]::IsNullOrWhiteSpace([string]$slide.fallback_label)
      if (!$hasSales -and !$hasFallback) {
        $errors.Add("Slide $($slide.slide) [brand_share_chart] must include sales_amount/sales_units or fallback_label")
      }
    }
    "traffic_mix_stacked_bars" {
      Require-Fields $slide @("asin", "natural_keywords") $errors
      $fields = @(As-Array $slide.required_fields | ForEach-Object { ([string]$_).ToLowerInvariant() })
      if (!(($fields -contains "ad_keywords") -or ($fields -contains "video_keywords") -or ($fields -contains "brand_keywords"))) {
        $errors.Add("Slide $($slide.slide) [traffic_mix_stacked_bars] needs ad_keywords, video_keywords, or brand_keywords")
      }
    }
    "product_scheme_matrix" { Require-Fields $slide @("asin", "product_scheme", "core_attributes") $errors }
    "review_risk_cluster" { Require-Fields $slide @("review_signal", "root_cause", "opportunity") $errors }
    "keyword_opportunity_matrix" { Require-Fields $slide @("keyword", "demand", "competition", "action") $errors }
    "sku_ladder" { Require-Fields $slide @("sku_role", "price", "target_user") $errors }
    "annual_target_chart" { Require-Fields $slide @("quarter", "units", "asp", "revenue") $errors }
    "execution_roadmap" { Require-Fields $slide @("quarter", "workstream", "milestone", "risk") $errors }
  }
}

foreach ($visualType in $tierRequired[$Tier]) {
  if (@($slides | Where-Object { $_.visual_type -eq $visualType }).Count -eq 0) {
    $errors.Add("$Tier missing required visual_type: $visualType")
  }
}

if ($visualSlides.Count -lt $tierMinimumVisualSlides[$Tier]) {
  $errors.Add("$Tier expects at least $($tierMinimumVisualSlides[$Tier]) visual slides, found $($visualSlides.Count)")
}

if ($Tier -eq "DeepProductReport") {
  $deepTypes = @("competitor_group_detail","keyword_family_detail","listing_proof_audit","product_teardown","compliance_risk","inventory_launch_plan")
  $deepCount = @($slides | Where-Object { $deepTypes -contains $_.visual_type }).Count
  if ($deepCount -lt 3) {
    $errors.Add("DeepProductReport expects at least 3 deep/support visual slides, found $deepCount")
  }
}

$result = [pscustomobject]@{
  ManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
  Tier = $Tier
  Slides = $slides.Count
  VisualSlides = $visualSlides.Count
  CoreVisualTypesPresent = @($coreVisualTypes | Where-Object { $type = $_; @($slides | Where-Object { $_.visual_type -eq $type }).Count -gt 0 }).Count
  Errors = @($errors)
  Warnings = @($warnings)
}

if ($errors.Count -gt 0 -and !$WarnOnly) {
  $result | Format-List | Out-String | Write-Error
  throw "Visual manifest validation failed with $($errors.Count) error(s)."
}

$result
