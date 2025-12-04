Write-Host "== RUN-TESTS-ROOT : Smoke-Checks ==" -ForegroundColor Cyan
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$errors = @()

function Test-RequireFile([string]$p) {
  if (-not (Test-Path $p)) { $script:errors += "FEHLT: $p"; Write-Host "FEHLT: $p" -ForegroundColor Red } else { Write-Host "OK: $p" -ForegroundColor Green }
}

Test-RequireFile "index.html"

$app = Get-ChildItem -Filter "*.html" | Where-Object { $_.Name -like "WHD Applikation*Single-File System TTT.html" } | Select-Object -First 1
if (-not $app) { $errors += "FEHLT: App-HTML (WHD Applikation — Komplettes Single-File System TTT.html)" ; Write-Host "FEHLT: App-HTML" -ForegroundColor Red }
else {
  Write-Host ("OK: {0}" -f $app.Name) -ForegroundColor Green
  $html = Get-Content -LiteralPath $app.FullName -Raw
  # Prüfe präzise auf IDs/Klassen
  $needles = @(
    @{ label = '#tab-dashboard'; pattern = 'id="tab-dashboard"' },
    @{ label = '#tab-guide';     pattern = 'id="tab-guide"' },
    @{ label = '#tab-products';  pattern = 'id="tab-products"' },
    @{ label = 'startup-overlay';pattern = 'id="startup-overlay"' },
    @{ label = 'donation-hint';  pattern = 'class="[^"]*\bdonation-hint\b' },
    @{ label = 'tab-factory';    pattern = 'id="tab-factory"' }
  )
  foreach ($n in $needles) {
    if ($html -notmatch $n.pattern) {
      $errors += "SELECTOR FEHLT: $($n.label)"
      Write-Host ("SELECTOR FEHLT: {0}" -f $n.label) -ForegroundColor Red
    } else {
      Write-Host ("OK selector: {0}" -f $n.label) -ForegroundColor Green
    }
  }
}

if ($errors.Count -eq 0) {
  Write-Host "ALLE TESTS OK" -ForegroundColor Green
  exit 0
} else {
  Write-Host "FEHLER:" -ForegroundColor Red
  $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}

Write-Host "== RUN-TESTS-ROOT : Smoke-Checks ==" -ForegroundColor Cyan
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$errors = @()

function Test-RequireFile([string]$p) {
  if (-not (Test-Path $p)) { $script:errors += "FEHLT: $p"; Write-Host "FEHLT: $p" -ForegroundColor Red } else { Write-Host "OK: $p" -ForegroundColor Green }
}

Test-RequireFile "index.html"

$app = Get-ChildItem -Filter "*.html" | Where-Object { $_.Name -like "WHD Applikation*Single-File System TTT.html" } | Select-Object -First 1
if (-not $app) { $errors += "FEHLT: App-HTML (WHD Applikation — Komplettes Single-File System TTT.html)" ; Write-Host "FEHLT: App-HTML" -ForegroundColor Red }
else {
  Write-Host ("OK: {0}" -f $app.Name) -ForegroundColor Green
  $html = Get-Content -LiteralPath $app.FullName -Raw
  # Prüfe auf IDs und Klassen präzise in HTML
  $needles = @(
    @{ label = '#tab-dashboard'; pattern = 'id="tab-dashboard"' },
    @{ label = '#tab-guide';     pattern = 'id="tab-guide"' },
    @{ label = '#tab-products';  pattern = 'id="tab-products"' },
    @{ label = 'startup-overlay';pattern = 'id="startup-overlay"' },
    @{ label = 'donation-hint';  pattern = 'class="[^"]*\bdonation-hint\b' },
    @{ label = 'tab-factory';    pattern = 'id="tab-factory"' }
  )
  foreach ($n in $needles) {
    if ($html -notmatch $n.pattern) {
      $errors += "SELECTOR FEHLT: $($n.label)"
      Write-Host ("SELECTOR FEHLT: {0}" -f $n.label) -ForegroundColor Red
    } else {
      Write-Host ("OK selector: {0}" -f $n.label) -ForegroundColor Green
    }
  }
}

if ($errors.Count -eq 0) {
  Write-Host "ALLE TESTS OK" -ForegroundColor Green
  exit 0
} else {
  Write-Host "FEHLER:" -ForegroundColor Red
  $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}


