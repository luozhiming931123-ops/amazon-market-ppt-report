param(
  [Parameter(Mandatory = $true)]
  [string]$PptxPath,

  [int]$ExpectedSlides = 0,

  [string[]]$RequiredText = @()
)

$ErrorActionPreference = "Stop"
$RequiredText = @($RequiredText | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

if (!(Test-Path -LiteralPath $PptxPath)) {
  throw "PPTX not found: $PptxPath"
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead($PptxPath)
try {
  $entries = @($zip.Entries)
  $slides = @($entries | Where-Object { $_.FullName -match '^ppt/slides/slide\d+\.xml$' })
  $badSlash = @($entries | Where-Object { $_.FullName -like '*\*' })
  $contentTypes = @($entries | Where-Object { $_.FullName -eq '[Content_Types].xml' })

  if ($contentTypes.Count -ne 1) {
    throw "Missing [Content_Types].xml"
  }
  if ($badSlash.Count -gt 0) {
    throw "PPTX contains backslash zip entries: $($badSlash[0].FullName)"
  }
  if ($ExpectedSlides -gt 0 -and $slides.Count -ne $ExpectedSlides) {
    throw "Expected $ExpectedSlides slides, found $($slides.Count)"
  }

  $allText = New-Object System.Text.StringBuilder
  foreach ($slide in $slides) {
    $reader = New-Object System.IO.StreamReader($slide.Open())
    try {
      $xmlText = $reader.ReadToEnd()
      [xml]$xmlText | Out-Null
      [void]$allText.AppendLine($xmlText)
    } finally {
      $reader.Dispose()
    }
  }

  foreach ($text in $RequiredText) {
    if ($allText.ToString() -notlike "*$text*") {
      throw "Required text not found in slide XML: $text"
    }
  }

  [pscustomobject]@{
    PptxPath = (Resolve-Path -LiteralPath $PptxPath).Path
    Bytes = (Get-Item -LiteralPath $PptxPath).Length
    PackageEntries = $entries.Count
    SlideXmlCount = $slides.Count
    XmlErrors = 0
    BackslashEntries = 0
    RequiredTextChecked = $RequiredText.Count
  }
} finally {
  $zip.Dispose()
}
