# =============================================
# ROSH REVIEW - COMPRESSION SCRIPT (PowerShell)
# Save as: compress.ps1
# =============================================

$DOWNLOAD_FOLDER = "downlinks"
$COMPRESSED_FOLDER = "downlinks_compressed"
$TARGET_SIZE_MB = 1.0
$TARGET_SIZE_BYTES = $TARGET_SIZE_MB * 1024 * 1024

Add-Type -AssemblyName System.Drawing

if (!(Test-Path $DOWNLOAD_FOLDER)) {
    Write-Host "❌ downlinks folder not found!" -ForegroundColor Red
    exit
}

if (!(Test-Path $COMPRESSED_FOLDER)) {
    New-Item -ItemType Directory -Path $COMPRESSED_FOLDER | Out-Null
}

Write-Host "Scanning for images larger than 1MB..." -ForegroundColor Cyan

$largeImages = Get-ChildItem -Path $DOWNLOAD_FOLDER -Recurse | 
    Where-Object { $_.Extension -match '\.(png|jpg|jpeg|webp)$' -and $_.Length -gt $TARGET_SIZE_BYTES }

if ($largeImages.Count -eq 0) {
    Write-Host "No images larger than 1MB found." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($largeImages.Count) images > 1MB. Starting compression..." -ForegroundColor Cyan

$counter = 0
foreach ($imgFile in $largeImages) {
    try {
        $image = [System.Drawing.Image]::FromFile($imgFile.FullName)
        
        # Calculate new size (reduce dimensions)
        $ratio = 0.78
        $newWidth = [int]($image.Width * $ratio)
        $newHeight = [int]($image.Height * $ratio)
        
        $bitmap = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
        
        $outputPath = Join-Path $COMPRESSED_FOLDER $imgFile.Name   # Same original name
        
        if ($imgFile.Extension -match '\.(jpg|jpeg)$') {
            $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 82)
            $bitmap.Save($outputPath, $encoder, $encoderParams)
        } else {
            $bitmap.Save($outputPath)
        }
        
        $image.Dispose()
        $bitmap.Dispose()
        $graphics.Dispose()
        
        $counter++
        Write-Host "Compressed: $($imgFile.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error compressing $($imgFile.Name): $_" -ForegroundColor Red
    }
}

Write-Host "`n✓ Compression completed! $counter images processed." -ForegroundColor Green
Write-Host "Compressed files saved in: $COMPRESSED_FOLDER (with original names)" -ForegroundColor Cyan