# =============================================
# ROSH REVIEW - DOWNLOAD SCRIPT (PowerShell)
# Save as: rosh_download.ps1
# =============================================

$TARGET_FOLDER = "F:\delete\del\rosh2024Q3000OnlinePart\rosh2024Q3000"
$DOWNLOAD_FOLDER = "downlinks"
$LINK_FILE = "link.txt"

# Create folder if not exists
if (!(Test-Path $DOWNLOAD_FOLDER)) { New-Item -ItemType Directory -Path $DOWNLOAD_FOLDER | Out-Null }

# Regex to extract image links
$regex = [regex]::new('https://roshreview\.imgix\.net/[^\s"''<>]*?\.(png|jpg|jpeg|gif|webp)(?=\?|$|["''\s<>])', 'IgnoreCase')

Write-Host "Step 1: Extracting links from HTML files..." -ForegroundColor Cyan

$allLinks = @()
Get-ChildItem -Path $TARGET_FOLDER -Recurse -Filter *.html | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $matches = $regex.Matches($content)
        foreach ($m in $matches) {
            $allLinks += $m.Value
        }
    }
}

$uniqueLinks = $allLinks | Sort-Object -Unique
$uniqueLinks | Out-File -FilePath $LINK_FILE -Encoding utf8

Write-Host "✓ $($uniqueLinks.Count) unique links saved to $LINK_FILE" -ForegroundColor Green

# ====================== FAST PARALLEL DOWNLOAD ======================
Write-Host "`nStep 2: Starting fast parallel download..." -ForegroundColor Cyan

if (!(Test-Path $LINK_FILE)) {
    Write-Host "❌ link.txt not found!" -ForegroundColor Red
    exit
}

$urls = Get-Content $LINK_FILE | Where-Object { $_ -match '^http' }

$DOWNLOAD_FOLDER | ForEach-Object { if (!(Test-Path $_)) { New-Item -ItemType Directory -Path $_ | Out-Null } }

$maxThreads = 20

$urls | ForEach-Object -Parallel {
    $url = $_
    $folder = $using:DOWNLOAD_FOLDER

    try {
        $filename = [System.IO.Path]::GetFileName(($url -split '\?')[0])
        $filename = [System.Web.HttpUtility]::UrlDecode($filename)
        $filename = $filename -replace '[<>:"/\\|?*]', '_'

        if ([string]::IsNullOrEmpty($filename) -or $filename -notmatch '\.') {
            $filename = "image_$(Get-Random).png"
        }

        $destination = Join-Path $folder $filename
        $counter = 1
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($filename)
        $ext = [System.IO.Path]::GetExtension($filename)

        while (Test-Path $destination) {
            $destination = Join-Path $folder "$($baseName)_$counter$ext"
            $counter++
        }

        Invoke-WebRequest -Uri $url -OutFile $destination -TimeoutSec 30 -UseBasicParsing
        Write-Host "Downloaded: $filename" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed: $($url.Substring(0, [Math]::Min(80, $url.Length)))..." -ForegroundColor Yellow
    }
} -ThrottleLimit $maxThreads -AsJob | Wait-Job | Receive-Job

Write-Host "`n✓ Download completed! Files saved in '$DOWNLOAD_FOLDER' folder" -ForegroundColor Green
Write-Host "You can now run compress.ps1 if you want to compress large images." -ForegroundColor Cyan