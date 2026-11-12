$ErrorActionPreference = "Stop"
$baseUrl = "http://192.168.1.46:8089"
$headers = @{ "Origin" = $baseUrl; "Content-Type" = "application/json" }

function Exec-TV($cmd) {
    $body = @{ cmd = $cmd } | ConvertTo-Json -Compress
    $res = Invoke-RestMethod -Uri "$baseUrl/exec" -Method Post -Headers $headers -ContentType "application/json" -Body $body -TimeoutSec 45
    return $res
}

$htmlPath = "$PSScriptRoot\CustomHomeApp\index.html"
$bytes = [System.IO.File]::ReadAllBytes($htmlPath)
$b64 = [Convert]::ToBase64String($bytes)

Write-Host "Taille HTML : $($bytes.Length) octets, Base64 : $($b64.Length) octets"

# Nettoyage fichier temporaire
Exec-TV "rm -f /tmp/index_dock.b64" | Out-Null

# Envoi par morceaux de 20 000 caracteres
$chunkSize = 20000
$offset = 0
$part = 0

while ($offset -lt $b64.Length) {
    $len = [Math]::Min($chunkSize, $b64.Length - $offset)
    $chunk = $b64.Substring($offset, $len)
    $redir = if ($part -eq 0) { ">" } else { ">>" }
    $cmd = "printf '%s' '$chunk' $redir /tmp/index_dock.b64"
    Write-Host "Envoi morceau $part ($len caracteres)..."
    $r = Exec-TV $cmd
    $offset += $len
    $part++
}

Write-Host "Verification de la taille du fichier temporaire sur la TV..."
$check = Exec-TV "wc -c /tmp/index_dock.b64"
Write-Host "wc -c : $($check.output)"

Write-Host "Decodage Base64 vers /opt/usr/apps/CustomHome/res/wgt/index.html..."
$cfgPath = "$PSScriptRoot\CustomHomeApp\config.xml"
$cfgB64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($cfgPath))
$deployCmd = @"
cat /tmp/index_dock.b64 | base64 -d > /opt/usr/apps/CustomHome/res/wgt/index.html
echo '$cfgB64' | base64 -d > /opt/usr/apps/CustomHome/res/wgt/config.xml
rm -f /tmp/index_dock.b64
chmod -R 755 /opt/usr/apps/CustomHome/res/wgt/icons
chmod 644 /opt/usr/apps/CustomHome/res/wgt/index.html
chmod 644 /opt/usr/apps/CustomHome/res/wgt/config.xml
ls -la /opt/usr/apps/CustomHome/res/wgt/index.html
sync
app_launcher -t CustomHome.Main >/dev/null 2>&1 || true
sleep 0.5
app_launcher -s CustomHome.Main
"@

$res = Exec-TV $deployCmd
Write-Host "Resultat deploiement : $($res | ConvertTo-Json -Compress)"
