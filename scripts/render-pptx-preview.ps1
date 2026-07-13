param(
  [Parameter(Mandatory = $true)]
  [string]$PptxPath,

  [Parameter(Mandatory = $true)]
  [string]$OutputDir,

  [int[]]$Slides = @(),

  [int]$Width = 1600,

  [int]$Height = 900
)

$ErrorActionPreference = "Stop"
if (!(Test-Path -LiteralPath $PptxPath)) { throw "PPTX not found: $PptxPath" }
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

try {
  $app = New-Object -ComObject PowerPoint.Application
} catch {
  throw "PowerPoint Desktop is required for PNG preview rendering on this machine. Install PowerPoint Desktop, then rerun this script."
}

$presentation = $null
try {
  $presentation = $app.Presentations.Open((Resolve-Path -LiteralPath $PptxPath).Path, $false, $true, $false)
  $requested = if ($Slides.Count -gt 0) { $Slides } else { 1..$presentation.Slides.Count }
  $exported = @()
  foreach ($index in $requested) {
    if ($index -lt 1 -or $index -gt $presentation.Slides.Count) { throw "Slide $index is outside 1..$($presentation.Slides.Count)." }
    $path = Join-Path $OutputDir ("slide-{0:D2}.png" -f $index)
    $presentation.Slides.Item($index).Export($path, "PNG", $Width, $Height)
    $exported += (Resolve-Path -LiteralPath $path).Path
  }
  [pscustomobject]@{
    PptxPath = (Resolve-Path -LiteralPath $PptxPath).Path
    OutputDir = (Resolve-Path -LiteralPath $OutputDir).Path
    ExportedSlides = $exported
    Width = $Width
    Height = $Height
    Result = "PASS"
  }
} finally {
  if ($presentation) { $presentation.Close() }
  $app.Quit()
  [void][Runtime.InteropServices.Marshal]::ReleaseComObject($app)
}
