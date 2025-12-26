# ============================================================================
# BUILD SCRIPT - Optimized builds untuk Chrome dan Android
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CafeSync Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Clean previous builds
Write-Host "[1/4] Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Get dependencies
Write-Host "[2/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Build for Web (Chrome) - Optimized
Write-Host "[3/4] Building for Web (Chrome) - Optimized..." -ForegroundColor Yellow
flutter build web --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Build for Android - Optimized APK
Write-Host "[4/4] Building for Android - Optimized APK..." -ForegroundColor Yellow
flutter build apk --release --shrink --split-per-abi
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output locations:" -ForegroundColor Cyan
Write-Host "  Web: build\web\" -ForegroundColor White
Write-Host "  Android: build\app\outputs\flutter-apk\" -ForegroundColor White
Write-Host ""

# Show file sizes
Write-Host "File sizes:" -ForegroundColor Cyan
$webSize = (Get-ChildItem -Path "build\web" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
$apkFiles = Get-ChildItem -Path "build\app\outputs\flutter-apk\*.apk"
Write-Host "  Web build: $([math]::Round($webSize, 2)) MB" -ForegroundColor White
foreach ($apk in $apkFiles) {
    $apkSize = $apk.Length / 1MB
    Write-Host "  $($apk.Name): $([math]::Round($apkSize, 2)) MB" -ForegroundColor White
}
