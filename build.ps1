# Flutter Web をビルド
Write-Host "=== Flutter Web Build Start ==="
flutter build web

# ビルドに失敗したら終了
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed. Exiting..."
    exit 1
}

# コピー先ディレクトリ（任意に変更可）
$targetDir = "docs/"

# コピー先ディレクトリを作成（なければ）
if (!(Test-Path $targetDir)) {
    Write-Host "Creating directory: $targetDir"
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# ファイルをコピー（再帰的、上書きあり）
Write-Host "Copying files to $targetDir..."
Copy-Item -Path "build\web\*" -Destination $targetDir -Recurse -Force

# Git操作
Write-Host "=== Git Operations Start ==="

# 日付を取得してコミットメッセージを作成
$commitMessage = "build_$(Get-Date -Format 'yyyyMMdd')"
Write-Host "Commit message: $commitMessage"

# Git add
Write-Host "Running 'git add .'"
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Error "git add failed. Exiting..."
    exit 1
}

# Git commit
Write-Host "Running 'git commit'"
git commit -m "$commitMessage"
if ($LASTEXITCODE -ne 0) {
    Write-Warning "git commit failed. This might be because there are no changes to commit."
}

# Git push
Write-Host "Running 'git push'"
git push
if ($LASTEXITCODE -ne 0) {
    Write-Error "git push failed. Exiting..."
    exit 1
}

Write-Host "=== Script Finished Successfully ==="