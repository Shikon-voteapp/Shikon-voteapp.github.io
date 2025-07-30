# 自動ビルド番号更新スクリプト
Write-Host "=== Auto Version Management Start ==="

# バージョン設定ファイルのパス
$versionConfigPath = "version_config.json"

# バージョン設定ファイルが存在しない場合は作成
if (!(Test-Path $versionConfigPath)) {
    Write-Host "Creating version config file..."
    $defaultConfig = @{
        major = 1
        minor = 0
        patch = 0
        build = 1
        last_build_date = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    $defaultConfig | ConvertTo-Json | Set-Content $versionConfigPath
}

# 現在のバージョン設定を読み込み
$versionConfig = Get-Content $versionConfigPath | ConvertFrom-Json
Write-Host "Current version: $($versionConfig.major).$($versionConfig.minor).$($versionConfig.patch).$($versionConfig.build)"

# 自動的にビルド番号を増やす
$versionConfig.build++
Write-Host "Auto-updating build number to $($versionConfig.major).$($versionConfig.minor).$($versionConfig.patch).$($versionConfig.build)"

# ビルド日時を更新（JST）
$jstTime = (Get-Date).AddHours(9)  # UTC+9 (JST)
$versionConfig.last_build_date = $jstTime.ToString("yyyy-MM-ddTHH:mm:ssZ")

# バージョン設定ファイルを保存
$versionConfig | ConvertTo-Json | Set-Content $versionConfigPath

# pubspec.yamlのバージョンを更新
$pubspecPath = "pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw -Encoding UTF8
$newVersion = "$($versionConfig.major).$($versionConfig.minor).$($versionConfig.patch)+$($versionConfig.build)"
$pubspecContent = $pubspecContent -replace "version: .*", "version: $newVersion"
Set-Content $pubspecPath $pubspecContent -NoNewline -Encoding UTF8

Write-Host "Updated pubspec.yaml version to: $newVersion"

# version_info.dartのハードコードされたバージョンを更新
$versionInfoPath = "lib/utils/version_info.dart"
$versionInfoContent = Get-Content $versionInfoPath -Raw -Encoding UTF8
$versionInfoContent = $versionInfoContent -replace "_version = '[^']*'", "_version = '$($versionConfig.major).$($versionConfig.minor).$($versionConfig.patch)'"
$versionInfoContent = $versionInfoContent -replace "_buildNumber = '[^']*'", "_buildNumber = '$($versionConfig.build)'"
Set-Content $versionInfoPath $versionInfoContent -NoNewline -Encoding UTF8

Write-Host "Updated version_info.dart hardcoded version to: $($versionConfig.major).$($versionConfig.minor).$($versionConfig.patch).$($versionConfig.build)"

# vote_options.dartのデータ更新日時を更新
$voteOptionsPath = "lib/config/vote_options.dart"
$voteOptionsContent = Get-Content $voteOptionsPath -Raw -Encoding UTF8
$buildDate = [DateTime]::Parse($versionConfig.last_build_date)
$formattedDate = "DateTime($($buildDate.Year), $($buildDate.Month), $($buildDate.Day), $($buildDate.Hour), $($buildDate.Minute), 0)"
$voteOptionsContent = $voteOptionsContent -replace "final DateTime dataUpdateDate = DateTime\([^)]+\);", "final DateTime dataUpdateDate = $formattedDate;"
Set-Content $voteOptionsPath $voteOptionsContent -NoNewline -Encoding UTF8

Write-Host "Updated vote_options.dart data update date to: $($buildDate.ToString('yyyy-MM-dd HH:mm')) (JST)"

Write-Host "=== Auto Version Management Complete ==="

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
$commitMessage = "build_$(Get-Date -Format 'yyyyMMdd')_v$newVersion"
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