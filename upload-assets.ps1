# Upload release assets to GitHub
param(
    [Parameter(Mandatory=$true)]
    [string]$ReleaseTag,
    
    [Parameter(Mandatory=$true)]
    [string]$Win32Zip,
    
    [Parameter(Mandatory=$true)]
    [string]$Win64Zip,
    
    [string]$Owner = "omonien",
    [string]$Repo = "DX.Pdfium4D"
)

# Get GitHub token from environment
$token = $env:GITHUB_TOKEN
if (-not $token) {
    Write-Host "Error: GITHUB_TOKEN environment variable not set" -ForegroundColor Red
    Write-Host "Please set it with: set GITHUB_TOKEN=your_token_here" -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Uploading Release Assets for $ReleaseTag" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    'Authorization' = "Bearer $token"
    'Accept' = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
}

# Get release information by tag
$releaseUrl = "https://api.github.com/repos/$Owner/$Repo/releases/tags/$ReleaseTag"
Write-Host "Fetching release info..." -ForegroundColor Yellow

try {
    $release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers -Method Get
    $releaseId = $release.id
    Write-Host "OK Found release: $($release.name)" -ForegroundColor Green
    Write-Host "  Release ID: $releaseId" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "ERROR Failed to get release information for tag '$ReleaseTag'" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure the release exists on GitHub!" -ForegroundColor Yellow
    exit 1
}

# Files to upload
$files = @(
    @{ Path = $Win32Zip; Name = Split-Path $Win32Zip -Leaf },
    @{ Path = $Win64Zip; Name = Split-Path $Win64Zip -Leaf }
)

$uploadSuccess = $true

foreach ($file in $files) {
    $filePath = $file.Path
    $fileName = $file.Name
    
    if (-not (Test-Path $filePath)) {
        Write-Host "ERROR File not found: $filePath" -ForegroundColor Red
        $uploadSuccess = $false
        continue
    }
    
    # Check if asset already exists and delete it
    $existingAsset = $release.assets | Where-Object { $_.name -eq $fileName }
    if ($existingAsset) {
        Write-Host "Asset '$fileName' already exists, deleting..." -ForegroundColor Yellow
        $deleteUrl = "https://api.github.com/repos/$Owner/$Repo/releases/assets/$($existingAsset.id)"
        try {
            Invoke-RestMethod -Uri $deleteUrl -Headers $headers -Method Delete | Out-Null
            Write-Host "  OK Deleted old asset" -ForegroundColor Green
        }
        catch {
            Write-Host "  WARNING Failed to delete old asset" -ForegroundColor Yellow
        }
    }
    
    $uploadUrl = "https://uploads.github.com/repos/$Owner/$Repo/releases/$releaseId/assets?name=$fileName"
    
    $fileSize = (Get-Item $filePath).Length / 1MB
    Write-Host "Uploading $fileName ($([math]::Round($fileSize, 2)) MB)..." -ForegroundColor Cyan
    
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $filePath))
        $uploadHeaders = $headers.Clone()
        $uploadHeaders['Content-Type'] = 'application/zip'
        
        $response = Invoke-RestMethod -Uri $uploadUrl -Method Post -Headers $uploadHeaders -Body $fileBytes
        Write-Host "OK Successfully uploaded $fileName" -ForegroundColor Green
        Write-Host "  Download URL: $($response.browser_download_url)" -ForegroundColor Gray
        Write-Host ""
    }
    catch {
        Write-Host "ERROR Failed to upload $fileName" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""
        $uploadSuccess = $false
    }
}

Write-Host "========================================" -ForegroundColor Cyan
if ($uploadSuccess) {
    Write-Host "OK All assets uploaded successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Release URL: $($release.html_url)" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}
else {
    Write-Host "ERROR Some uploads failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

