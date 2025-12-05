#!/usr/bin/env pwsh
param(
  [string]$Version = '1.0.0'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($msg){ Write-Host "[build] $msg" -ForegroundColor Cyan }
function Warn($msg){ Write-Host "[warn ] $msg" -ForegroundColor Yellow }
function Die($msg){ Write-Host "[fail ] $msg" -ForegroundColor Red; exit 1 }

$root = Resolve-Path "$PSScriptRoot/../.."
Set-Location $PSScriptRoot
Info "Root: $root"

try { $gov = (go version) 2>$null } catch { Die "Go toolchain not found. Install Go 1.22+ and retry." }
Info "Go toolchain: $gov"

$webDir = Join-Path $PSScriptRoot "web"
New-Item -ItemType Directory -Force -Path $webDir | Out-Null

$candidates = @(
  (Join-Path $root 'WHD Applikation — Komplettes Single-File System TTT.html'),
  (Join-Path $root 'index.html'),
  (Join-Path $root 'index.cognitivefabric.html')
)

$srcHtml = $null
foreach ($c in $candidates) { if (Test-Path -LiteralPath $c) { $srcHtml = $c; break } }
if (-not $srcHtml) {
  $list = $candidates -join "`n"
  Die "No index HTML found in root. Expected one of:`n$list"
}

Copy-Item -LiteralPath $srcHtml -Destination (Join-Path $webDir 'index.html') -Force
Info "Embedded index source: $srcHtml"

$dist = Join-Path $PSScriptRoot 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null

$now = (Get-Date -AsUTC).ToString('s') + 'Z'
$ld = "-s -w -X main.version=$Version -X main.buildTime=$now"

$targets = @(
  @{GOOS='windows'; GOARCH='amd64'; EXT='.exe'},
  @{GOOS='linux'  ; GOARCH='amd64'; EXT=''   },
  @{GOOS='darwin' ; GOARCH='arm64'; EXT=''   }
)

foreach ($t in $targets) {
  $env:GOOS  = $t.GOOS
  $env:GOARCH= $t.GOARCH
  $name = "cognitivefabric-$($t.GOOS)-$($t.GOARCH)$($t.EXT)"
  $out  = Join-Path $dist $name
  Info "Building $name ..."
  go build -trimpath -ldflags $ld -o $out .
}

Info "Artifacts:"
Get-ChildItem -File $dist | ForEach-Object { "{0}  {1:N0} bytes" -f $_.Name, $_.Length } | Write-Host
Info "Done."

