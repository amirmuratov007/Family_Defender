$ErrorActionPreference = "Stop"
$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "Heimdall Family Defender.lnk"
$runScript = Join-Path $PSScriptRoot "run-desktop.ps1"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$runScript`""
$shortcut.WorkingDirectory = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$shortcut.IconLocation = "shell32.dll,44"
$shortcut.Description = "Heimdall Family Defender desktop simulator"
$shortcut.Save()
Write-Host "Created shortcut: $shortcutPath"
