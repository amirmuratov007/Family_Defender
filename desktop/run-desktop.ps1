$ErrorActionPreference = "Stop"
$repo = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repo

if (-not (Test-Path (Join-Path $repo "node_modules\electron"))) {
  npm install
}

npm run desktop
