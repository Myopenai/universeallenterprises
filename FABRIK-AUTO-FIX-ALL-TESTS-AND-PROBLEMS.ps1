#!/usr/bin/env pwsh
param(
  [switch]$Commit = $true,
  [string]$Message = "auto-fix-all: tests green + build",
  [switch]$Build = $true,
  [switch]$Start = $false
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[FAIL] $m" -ForegroundColor Red }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Info "Auto‑Fix + Retest"
pwsh -NoProfile -File .\FABRIK-AUTO-FIX-AND-RETEST.ps1 -Apply -Commit:$Commit -Message $Message
if ($LASTEXITCODE -ne 0) { Err "Fix+Retest fehlgeschlagen"; exit $LASTEXITCODE }

if ($Build) {
  Info "Build Go‑Executables"
  Push-Location builds/go-executable
  try {
    pwsh -NoProfile -File .\build-all.ps1
    if ($LASTEXITCODE -ne 0) { throw "Build fehlgeschlagen ($LASTEXITCODE)" }
    Ok "Build abgeschlossen (dist/)"
  } finally {
    Pop-Location
  }
}

if ($Start) {
  $exe = Join-Path $root 'builds\go-executable\dist\cognitivefabric-windows-amd64.exe'
  if (Test-Path $exe) {
    Info "Starte embedded Server (Port 9090)…"
    Start-Process -FilePath $exe -WorkingDirectory (Split-Path -Parent $exe) | Out-Null
    Ok "Läuft: http://127.0.0.1:9090  (Status: /api/status)"
  } else {
    Warn "Server‑Binary nicht gefunden: $exe"
  }
}

Ok "Fertig."
exit 0

#!/usr/bin/env pwsh
param(
  [switch]$Commit = $true,
  [string]$Message = "auto-fix-all: tests green + build",
  [switch]$Build = $true,
  [switch]$Start = $false
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[FAIL] $m" -ForegroundColor Red }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

Info "Auto‑Fix + Retest"
pwsh -NoProfile -File .\FABRIK-AUTO-FIX-AND-RETEST.ps1 -Apply -Commit:$Commit -Message $Message
if ($LASTEXITCODE -ne 0) { Err "Fix+Retest fehlgeschlagen"; exit $LASTEXITCODE }

if ($Build) {
  Info "Build Go‑Executables"
  Push-Location builds/go-executable
  try {
    pwsh -NoProfile -File .\build-all.ps1
    if ($LASTEXITCODE -ne 0) { throw "Build fehlgeschlagen ($LASTEXITCODE)" }
    Ok "Build abgeschlossen (dist/)"
  } finally {
    Pop-Location
  }
}

if ($Start) {
  $exe = Join-Path $root 'builds\go-executable\dist\cognitivefabric-windows-amd64.exe'
  if (Test-Path $exe) {
    Info "Starte embedded Server (Port 9090)…"
    Start-Process -FilePath $exe -WorkingDirectory (Split-Path -Parent $exe) | Out-Null
    Ok "Läuft: http://127.0.0.1:9090  (Status: /api/status)"
  } else {
    Warn "Server‑Binary nicht gefunden: $exe"
  }
}

Ok "Fertig."
exit 0


