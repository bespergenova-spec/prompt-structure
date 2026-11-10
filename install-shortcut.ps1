# Creates a desktop shortcut that opens the planner as a small app window
# (Edge or Chrome in --app mode: no tabs, no address bar).
# Usage: install-shortcut.bat            -> shortcut on the Desktop
#        install-shortcut.bat -Autostart -> also start the planner with Windows
param([switch]$Autostart)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$url  = ([System.Uri](Join-Path $root 'index.html')).AbsoluteUri

$exe = $null
foreach ($name in 'msedge.exe', 'chrome.exe') {
    foreach ($hive in 'HKLM', 'HKCU') {
        $key = "${hive}:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$name"
        $val = (Get-ItemProperty $key -ErrorAction SilentlyContinue).'(default)'
        if ($val -and (Test-Path $val)) { $exe = $val; break }
    }
    if ($exe) { break }
}
if (-not $exe) { throw 'Neither Microsoft Edge nor Google Chrome was found.' }

# Shortcut name "Планер задач" stored as base64 so this file stays ASCII-only
$label = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0J/Qu9Cw0L3QtdGAINC30LDQtNCw0Yc='))
$shell = New-Object -ComObject WScript.Shell

function New-PlannerShortcut($dir) {
    $lnk = $shell.CreateShortcut((Join-Path $dir "$label.lnk"))
    $lnk.TargetPath       = $exe
    $lnk.Arguments        = "--app=$url --window-size=400,680 --window-position=40,40"
    $lnk.WorkingDirectory = $root
    $lnk.IconLocation     = "$exe,0"
    $lnk.Save()
    Write-Host "Created: $($lnk.FullName)"
}

New-PlannerShortcut ([Environment]::GetFolderPath('Desktop'))
if ($Autostart) { New-PlannerShortcut ([Environment]::GetFolderPath('Startup')) }
