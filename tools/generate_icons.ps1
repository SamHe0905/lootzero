# Gera os icones do Loot Zero (LZ coin pixel-art) em todas as densidades Android.
# Rode com: powershell -ExecutionPolicy Bypass -File tools\generate_icons.ps1
Add-Type -AssemblyName System.Drawing

# Paleta da marca
$colors = @{
  1 = [System.Drawing.Color]::FromArgb(255, 26, 26, 26)    # ink
  2 = [System.Drawing.Color]::FromArgb(255, 250, 192, 0)   # gold
  3 = [System.Drawing.Color]::FromArgb(255, 255, 224, 102) # highlight
  4 = [System.Drawing.Color]::FromArgb(255, 200, 144, 0)   # gold dark
  5 = [System.Drawing.Color]::FromArgb(255, 110, 63, 184)  # royal purple
}
$skyBlue = [System.Drawing.Color]::FromArgb(255, 92, 148, 252)

# 16x16 design da moeda com LZ central
# 0=fundo (skyBlue), 1=ink, 2=gold, 3=highlight, 4=goldDk, 5=purple (LZ)
$design = @(
  ,@(0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0)
  ,@(0,0,1,1,3,3,2,2,2,2,2,2,1,1,0,0)
  ,@(0,1,3,3,3,2,2,2,2,2,2,4,4,4,1,0)
  ,@(0,1,3,2,2,2,2,2,2,2,2,2,2,4,1,0)
  ,@(1,3,3,2,2,2,2,2,2,2,2,2,2,4,4,1)
  ,@(1,3,2,2,5,2,2,2,5,5,5,5,5,2,4,1)
  ,@(1,3,2,2,5,2,2,2,2,2,2,5,2,2,4,1)
  ,@(1,3,2,2,5,2,2,2,2,2,5,2,2,2,4,1)
  ,@(1,3,2,2,5,2,2,2,2,5,2,2,2,2,4,1)
  ,@(1,3,2,2,5,2,2,2,5,2,2,2,2,2,4,1)
  ,@(1,3,2,2,5,5,5,2,5,5,5,5,5,2,4,1)
  ,@(1,2,2,2,2,2,2,2,2,2,2,2,2,2,4,1)
  ,@(0,1,2,2,2,2,2,2,2,2,2,2,2,4,1,0)
  ,@(0,1,2,4,4,2,2,2,2,2,2,4,4,4,1,0)
  ,@(0,0,1,1,4,4,4,4,4,4,4,4,1,1,0,0)
  ,@(0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0)
)

# Tamanhos por densidade do Android
$sizes = [ordered]@{
  "mipmap-mdpi"    = 48
  "mipmap-hdpi"    = 72
  "mipmap-xhdpi"   = 96
  "mipmap-xxhdpi"  = 144
  "mipmap-xxxhdpi" = 192
}

$baseDir = Join-Path $PSScriptRoot "..\android\app\src\main\res"
$baseDir = (Resolve-Path $baseDir).Path

function Render-Icon([int]$D, [string]$outPath, [bool]$circular) {
  $bmp = New-Object System.Drawing.Bitmap($D, $D)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

  # Fundo azul céu (sky)
  $bgBrush = New-Object System.Drawing.SolidBrush($skyBlue)
  $g.FillRectangle($bgBrush, 0, 0, $D, $D)
  $bgBrush.Dispose()

  # Calcula o tamanho de cada celula da moeda (16x16)
  $cellSize = [Math]::Floor($D / 16)
  if ($cellSize -lt 1) { $cellSize = 1 }
  $coinTotal = $cellSize * 16
  $padding = [Math]::Floor(($D - $coinTotal) / 2)

  # Desenha cada pixel do design
  for ($y = 0; $y -lt 16; $y++) {
    for ($x = 0; $x -lt 16; $x++) {
      $v = $design[$y][$x]
      if ($v -eq 0) { continue }
      $brush = New-Object System.Drawing.SolidBrush($colors[$v])
      $px = $padding + ($x * $cellSize)
      $py = $padding + ($y * $cellSize)
      $g.FillRectangle($brush, $px, $py, $cellSize, $cellSize)
      $brush.Dispose()
    }
  }

  $g.Dispose()
  $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

foreach ($folder in $sizes.Keys) {
  $D = $sizes[$folder]
  $dir = Join-Path $baseDir $folder
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

  $launcher = Join-Path $dir "ic_launcher.png"
  $launcherRound = Join-Path $dir "ic_launcher_round.png"

  Render-Icon $D $launcher $false
  Render-Icon $D $launcherRound $true

  Write-Host "Gerado $launcher ($D x $D)"
}

Write-Host "OK - icones gerados."
