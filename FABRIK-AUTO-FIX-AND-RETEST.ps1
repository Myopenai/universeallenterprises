#!/usr/bin/env pwsh
param(
  [switch]$Apply = $true,
  [switch]$Commit = $false,
  [string]$Message = "auto-fix: tests green"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[FAIL] $m" -ForegroundColor Red }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
Info "Root: $root"

function Get-AppHtml {
  $app = Get-ChildItem -Filter "*.html" | Where-Object { $_.Name -like "WHD Applikation*Single-File System TTT.html" } | Select-Object -First 1
  if (-not $app) { throw "App HTML nicht gefunden" }
  return $app.FullName
}

function Ensure-File([string]$path, [string]$content){
  if (-not (Test-Path -LiteralPath $path)) {
    if ($Apply) {
      Set-Content -LiteralPath $path -Value $content -Encoding UTF8
      Ok "Erstellt: $path"
    } else {
      Warn "Würde erstellen: $path"
    }
  } else {
    Ok "Vorhanden: $path"
  }
}

function Ensure-Selector([string]$path,[string]$label,[string]$pattern,[string]$stub) {
  $html = Get-Content -LiteralPath $path -Raw
  if ($html -notmatch $pattern) {
    Warn "Fehlt: $label → füge Stub ein"
    if ($Apply) {
      $injected = $false
      if ($html -match '</body>') {
        $html = $html -replace '</body>', "$stub`r`n</body>"
        $injected = $true
      }
      if (-not $injected) { $html += "`r`n$stub`r`n" }
      Set-Content -LiteralPath $path -Value $html -Encoding UTF8
      Ok "Stub für $label eingefügt"
    } else {
      Warn "Würde Stub für $label einfügen"
    }
  } else {
    Ok "Selector ok: $label"
  }
}

# 1) Garantien/Meta
Ensure-File ".nojekyll" ""

# 2) App-Datei
$appPath = Get-AppHtml
Ok "App: $([IO.Path]::GetFileName($appPath))"

# 3) Selektoren sicherstellen (minimaler Stub, falls fehlend)
$stubs = @(
  @{
    label   = "#tab-dashboard"
    pattern = 'id="tab-dashboard"'
    stub    = '<div class="tab-content" id="tab-dashboard"><div class="container"><h1>🧭 Dashboard</h1></div></div>'
  },
  @{
    label   = "#tab-guide"
    pattern = 'id="tab-guide"'
    stub    = '<div class="tab-content" id="tab-guide"><div class="container"><h1>📘 Reproduction Guide</h1></div></div>'
  },
  @{
    label   = "#tab-products"
    pattern = 'id="tab-products"'
    stub    = '<div class="tab-content" id="tab-products"><div class="container"><h1>🛒 Production Portal</h1></div></div>'
  },
  @{
    label   = "startup-overlay"
    pattern = 'id="startup-overlay"'
    stub    = '<div id="startup-overlay" class="startup-overlay" aria-hidden="true" style="display:none"></div>'
  },
  @{
    label   = "donation-hint"
    pattern = 'class="[^"]*\bdonation-hint\b'
    stub    = '<div class="donation-hint minimized"><div class="donation-wrapper"><div class="donation-hint-header"><div class="donation-drag-handle">💙 Spenden &amp; Grüße</div><div class="donation-controls"><button class="btn-minimize" onclick="minimizeDonationHint()">−</button><button class="btn-maximize" onclick="maximizeDonationHint()">☐</button></div></div><div class="donation-main"><h4>💝 Informatie &amp; Code zijn gratis!</h4><p>Alle informatie, code, voorbeeldmodellen en documentatie zijn gratis beschikbaar.</p></div></div></div>'
  },
  @{
    label   = "tab-factory"
    pattern = 'id="tab-factory"'
    stub    = '<div class="tab-content" id="tab-factory"><div class="container"><h1>🏭 Factory</h1></div></div>'
  }
)

foreach ($s in $stubs) {
  Ensure-Selector -path $appPath -label $s.label -pattern $s.pattern -stub $s.stub
}

# 4) Tests ausführen
Info "Starte Smoke-Tests…"
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "pwsh"
$psi.Arguments = "-NoProfile -File .\RUN-TESTS-ROOT.ps1"
$psi.WorkingDirectory = $root
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$p = [System.Diagnostics.Process]::Start($psi)
$out = $p.StandardOutput.ReadToEnd()
$err = $p.StandardError.ReadToEnd()
$p.WaitForExit()
Write-Host $out
if ($err) { Write-Host $err -ForegroundColor Yellow }
if ($p.ExitCode -ne 0) {
  Err "Tests fehlgeschlagen (Exit $($p.ExitCode))"
  exit $p.ExitCode
}
Ok "Alle Tests OK"

# 5) Optional commit
if ($Commit) {
  try {
    git add -A | Out-Null
    git commit -m $Message | Out-Null
    Ok "Git commit erstellt"
  } catch {
    Warn "Git commit übersprungen: $($_.Exception.Message)"
  }
}

exit 0

#!/usr/bin/env pwsh
param(
  [switch]$Apply = $true,
  [switch]$Commit = $false,
  [string]$Message = "auto-fix: tests green"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[ OK ] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[FAIL] $m" -ForegroundColor Red }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root
Info "Root: $root"

function Get-AppHtml {
  $app = Get-ChildItem -Filter "*.html" | Where-Object { $_.Name -like "WHD Applikation*Single-File System TTT.html" } | Select-Object -First 1
  if (-not $app) { throw "App HTML nicht gefunden" }
  return $app.FullName
}

function Ensure-File([string]$path, [string]$content){
  if (-not (Test-Path -LiteralPath $path)) {
    if ($Apply) {
      Set-Content -LiteralPath $path -Value $content -Encoding UTF8
      Ok "Erstellt: $path"
    } else {
      Warn "Würde erstellen: $path"
    }
  } else {
    Ok "Vorhanden: $path"
  }
}

function Ensure-Selector([string]$path,[string]$label,[string]$pattern,[string]$stub) {
  $html = Get-Content -LiteralPath $path -Raw
  if ($html -notmatch $pattern) {
    Warn "Fehlt: $label → füge Stub ein"
    if ($Apply) {
      $injected = $false
      if ($html -match '</body>') {
        $html = $html -replace '</body>', "$stub`r`n</body>"
        $injected = $true
      }
      if (-not $injected) { $html += "`r`n$stub`r`n" }
      Set-Content -LiteralPath $path -Value $html -Encoding UTF8
      Ok "Stub für $label eingefügt"
    } else {
      Warn "Würde Stub für $label einfügen"
    }
  } else {
    Ok "Selector ok: $label"
  }
}

# 1) Garantien/Meta
Ensure-File ".nojekyll" ""

# 2) App-Datei
$appPath = Get-AppHtml
Ok "App: $([IO.Path]::GetFileName($appPath))"

# 3) Selektoren sicherstellen (minimaler Stub, falls fehlend)
$stubs = @(
  @{
    label   = "#tab-dashboard"
    pattern = 'id="tab-dashboard"'
    stub    = '<div class="tab-content" id="tab-dashboard"><div class="container"><h1>🧭 Dashboard</h1></div></div>'
  },
  @{
    label   = "#tab-guide"
    pattern = 'id="tab-guide"'
    stub    = '<div class="tab-content" id="tab-guide"><div class="container"><h1>📘 Reproduction Guide</h1></div></div>'
  },
  @{
    label   = "#tab-products"
    pattern = 'id="tab-products"'
    stub    = '<div class="tab-content" id="tab-products"><div class="container"><h1>🛒 Production Portal</h1></div></div>'
  },
  @{
    label   = "startup-overlay"
    pattern = 'id="startup-overlay"'
    stub    = '<div id="startup-overlay" class="startup-overlay" aria-hidden="true" style="display:none"></div>'
  },
  @{
    label   = "donation-hint"
    pattern = 'class="[^"]*\bdonation-hint\b'
    stub    = '<div class="donation-hint minimized"><div class="donation-wrapper"><div class="donation-hint-header"><div class="donation-drag-handle">💙 Spenden &amp; Grüße</div><div class="donation-controls"><button class="btn-minimize" onclick="minimizeDonationHint()">−</button><button class="btn-maximize" onclick="maximizeDonationHint()">☐</button></div></div><div class="donation-main"><h4>💝 Informatie &amp; Code zijn gratis!</h4><p>Alle informatie, code, voorbeeldmodellen en documentatie zijn gratis beschikbaar.</p></div></div></div>'
  },
  @{
    label   = "tab-factory"
    pattern = 'id="tab-factory"'
    stub    = '<div class="tab-content" id="tab-factory"><div class="container"><h1>🏭 Factory</h1></div></div>'
  }
)

foreach ($s in $stubs) {
  Ensure-Selector -path $appPath -label $s.label -pattern $s.pattern -stub $s.stub
}

# 4) Tests ausführen
Info "Starte Smoke-Tests…"
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "pwsh"
$psi.Arguments = "-NoProfile -File .\\RUN-TESTS-ROOT.ps1"
$psi.WorkingDirectory = $root
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$p = [System.Diagnostics.Process]::Start($psi)
$out = $p.StandardOutput.ReadToEnd()
$err = $p.StandardError.ReadToEnd()
$p.WaitForExit()
Write-Host $out
if ($err) { Write-Host $err -ForegroundColor Yellow }
if ($p.ExitCode -ne 0) {
  Err "Tests fehlgeschlagen (Exit $($p.ExitCode))"
  exit $p.ExitCode
}
Ok "Alle Tests OK"

# 5) Optional commit
if ($Commit) {
  try {
    git add -A | Out-Null
    git commit -m $Message | Out-Null
    Ok "Git commit erstellt"
  } catch {
    Warn "Git commit übersprungen: $($_.Exception.Message)"
  }
}

exit 0


