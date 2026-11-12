param(
    [string]$Cmd = "",
    [string]$File = ""
)
$baseUrl = "http://192.168.1.46:8089"
$headers = @{ "Origin" = $baseUrl; "Content-Type" = "application/json" }
$commandToRun = $Cmd
if ($File -and (Test-Path -LiteralPath $File -ErrorAction SilentlyContinue)) {
    $commandToRun = [System.IO.File]::ReadAllText($File)
}
$body = @{ cmd = $commandToRun } | ConvertTo-Json -Compress
$res = Invoke-RestMethod -Uri "$baseUrl/exec" -Method Post -Headers $headers -ContentType "application/json" -Body $body -TimeoutSec 35
Write-Host $res.output
