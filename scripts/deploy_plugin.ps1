$ErrorActionPreference = "Stop"
$TvIp = if ($env:SAMSUNG_TV_IP) { $env:SAMSUNG_TV_IP } else { "192.168.1.46" }
$baseUrl = "http://${TvIp}:8089"
$headers = @{ "Origin" = $baseUrl; "Content-Type" = "application/json" }

function Exec-TV($cmd, $timeout = 15) {
    $body = @{ cmd = $cmd } | ConvertTo-Json -Compress
    return Invoke-RestMethod -Uri "$baseUrl/exec" -Method Post -Headers $headers -ContentType "application/json" -Body $body -TimeoutSec $timeout
}

$pluginDir = Join-Path (Split-Path -Parent $PSScriptRoot) "plugins\mon-accueil-metrics"
$indexB64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes((Join-Path $pluginDir "index.js")))
$manifestB64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes((Join-Path $pluginDir "manifest.json")))

$deployCmd = @"
mkdir -p /opt/usr/home/owner/share/vetro-plugins/mon-accueil-metrics
echo '$indexB64' | base64 -d > /opt/usr/home/owner/share/vetro-plugins/mon-accueil-metrics/index.js
echo '$manifestB64' | base64 -d > /opt/usr/home/owner/share/vetro-plugins/mon-accueil-metrics/manifest.json
chmod 644 /opt/usr/home/owner/share/vetro-plugins/mon-accueil-metrics/index.js /opt/usr/home/owner/share/vetro-plugins/mon-accueil-metrics/manifest.json
rm -f /opt/usr/home/owner/share/vetro-plugins/starting
"@
$deployCmd = ($deployCmd -replace "`r`n", "`n")

$res = Exec-TV $deployCmd 20
Write-Host "Plugin fichiers deployes : ok=$($res.ok)"

# Redemarrage propre du service Vetro pour recharger le plugin Node.js
$restartCmd = "setsid sh -c 'sleep 1; app_launcher -t vetrotvapp.svc >/dev/null 2>&1 || true; sleep 1; app_launcher -s vetrotvapp.svc >/dev/null 2>&1' >/dev/null 2>&1 </dev/null &"
Exec-TV $restartCmd 10 | Out-Null

Write-Host "Attente redemarrage Vetro (7s)..."
Start-Sleep -Seconds 7

$plugins = Invoke-RestMethod -Uri "$baseUrl/plugins" -Method Get -TimeoutSec 15
$target = $plugins.plugins | Where-Object { $_.id -eq "mon-accueil-metrics" }
Write-Host "safeMode=$($plugins.safeMode), state=$($target.state), errors=$($target.errors), lastError=$($target.lastError)"
if ($plugins.safeMode -or $target.state -ne "running") {
    throw "Le plugin mon-accueil-metrics n'est pas actif (safeMode=$($plugins.safeMode), state=$($target.state))."
}
