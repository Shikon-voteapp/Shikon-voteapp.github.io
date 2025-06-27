# Flutter Web をビルド
Write-Host "=== Flutter Web Build Start ==="
flutter build web

# ビルドに失敗したら終了
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed. Exiting..."
    exit 1
}

# コピー先ディレクトリ（任意に変更可）
$targetDir = "deploy/public/"

# コピー先ディレクトリを作成（なければ）
if (!(Test-Path $targetDir)) {
    Write-Host "Creating directory: $targetDir"
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# ファイルをコピー（再帰的、上書きあり）
Write-Host "Copying files to $targetDir..."
Copy-Item -Path "build\web\*" -Destination $targetDir -Recurse -Force

# deploy.cmdを実行
Write-Host "Executing deploy.cmd..."
Set-Location -Path "deploy"
.\deploy.cmd

Write-Host "=== Build and Copy Complete ==="

Pause
