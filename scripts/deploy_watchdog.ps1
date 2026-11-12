$baseUrl = "http://192.168.1.46:8089"
$headers = @{ "Origin" = $baseUrl; "Content-Type" = "application/json" }

# Stop any previous daemon
$stopCmd = @'
if [ -f /tmp/custom_home_watchdog.pid ]; then
    kill -9 $(cat /tmp/custom_home_watchdog.pid) 2>/dev/null || true
    rm -f /tmp/custom_home_watchdog.pid
fi
ps -ef | grep -E 'update_metrics|custom_home_watchdog|live_metrics' | grep -v grep | awk '{print $2}' | xargs -r kill -9 2>/dev/null || true
'@

$body = @{ cmd = $stopCmd } | ConvertTo-Json -Compress
Invoke-RestMethod -Uri "$baseUrl/exec" -Method Post -Headers $headers -ContentType "application/json" -Body $body -TimeoutSec 10 | Out-Null
Write-Host "Stopped old daemons."

$daemonSh = @'
IDLE_COUNT=0
PURGE_CMD="app_launcher -k org.tizen.netflix-app; app_launcher -k QmpwflxWdt.CanalPlusLauncher; app_launcher -k org.tizen.primevideo; app_launcher -k MCmYXNxgcu.DisneyPlus; app_launcher -k AprZAARz4r.Jellyfin; app_launcher -k znCs95n93Q.OqeeTV; app_launcher -k tUb3Xq7Lm9.Tube; app_launcher -k 9Ur5IzDKqV.TizenYouTube; app_launcher -k aLlph042JZ.arte; app_launcher -k Ol7HVEXtqh.6play; app_launcher -k RffagId0eC.SfrSport; app_launcher -k bstjKvX6LM.molotov; app_launcher -k kIciSQlYEM.plex; app_launcher -k tCz5WMFzVa.LiveTV; app_launcher -k org.tizen.browser; app_launcher -k com.samsung.tv.cobalt-yt; app_launcher -k com.samsung.tv.home.media; app_launcher -k com.samsung.tv.home.sidebar; app_launcher -k com.samsung.tv.csfs; echo 3 > /proc/sys/vm/drop_caches"

update_metrics() {
    OUT="/opt/usr/apps/CustomHome/res/wgt/live_metrics.js"
    RAW_GDBUS=$(gdbus call --system --dest org.projectx.bt_product --object-path /org/projectx/bt_service_product --method org.projectx.bt_product.service_request_product 1 4226 0 "[byte 0x00]" "[byte 0x00]" "[byte 0x00]" "[byte 0x00]" "[byte 0x00]" 2>/dev/null)
    HEX_BYTE=$(echo "$RAW_GDBUS" | sed -n 's/.*byte 0x\([0-9a-fA-F][0-9a-fA-F]*\).*/\1/p')
    BATT_PCT=97
    BATT_RAW=244
    if [ -n "$HEX_BYTE" ]; then
        BATT_RAW=$(printf "%d" "0x$HEX_BYTE" 2>/dev/null || echo 244)
        if [ "$BATT_RAW" -gt 0 ]; then
            ADC=$(( (BATT_RAW >> 3) & 31 ))
            BATT_PCT=$(( (ADC * 100 + 15) / 31 ))
            [ "$BATT_PCT" -gt 100 ] && BATT_PCT=100
        fi
    fi

    MEM_TOTAL_KB=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    MEM_AVAIL_KB=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
    TOTAL_MB=$(( MEM_TOTAL_KB / 1024 ))
    AVAIL_MB=$(( MEM_AVAIL_KB / 1024 ))
    USED_MB=$(( TOTAL_MB - AVAIL_MB ))
    FREE_PCT=$(( (AVAIL_MB * 100) / TOTAL_MB ))

    SOC_TEMP=$(cat /sys/devices/platform/soc/*.thermal/temperature 2>/dev/null | head -n 1)
    [ -z "$SOC_TEMP" ] && SOC_TEMP=45

    LOAD_AVG=$(awk '{print $1}' /proc/loadavg)
    UPTIME_SEC=$(awk '{printf "%d", $1}' /proc/uptime)
    IP_ADDR=$(ip -4 -o addr show wlan0 2>/dev/null | awk '{split($4,a,"/"); print a[1]}' | head -n 1)
    [ -z "$IP_ADDR" ] && IP_ADDR="192.168.1.46"
    TS_NOW=$(date +%s)

    HDMI_FILE="/sys/devices/platform/tztv_hdmi_sw/extcon/extcon1/state"
    H3_PLUGGED=0
    H3_ACTIVE=0
    if [ -f "$HDMI_FILE" ]; then
        grep -q '^HDMI3=1' "$HDMI_FILE" && H3_ACTIVE=1
        H3_PLUGGED=$H3_ACTIVE
    fi

    echo "window.__TV_METRICS__ = {\"ts\":${TS_NOW}000,\"battery\":{\"percent\":${BATT_PCT},\"raw\":${BATT_RAW}},\"ram\":{\"availableMb\":${AVAIL_MB},\"totalMb\":${TOTAL_MB},\"usedMb\":${USED_MB},\"freePercent\":${FREE_PCT}},\"socTempC\":${SOC_TEMP},\"loadavg\":\"${LOAD_AVG}\",\"uptimeSec\":${UPTIME_SEC},\"resolution\":\"3840 x 2160\",\"ip\":\"${IP_ADDR}\",\"hdmi3\":{\"plugged\":${H3_PLUGGED},\"active\":${H3_ACTIVE}}};" > "${OUT}.tmp"
    mv -f "${OUT}.tmp" "$OUT"
}

update_metrics

echo $$ > /tmp/custom_home_watchdog.pid

while true; do
    sleep 10
    update_metrics

    if [ -f /tmp/purge_ram.trigger ]; then
        rm -f /tmp/purge_ram.trigger
        eval "$PURGE_CMD" >/dev/null 2>&1 || true
        IDLE_COUNT=0
        update_metrics
        continue
    fi

    CH_STATUS=$(aul_test get_status CustomHome.Main 2>/dev/null | grep -o 'STATUS_FOCUS' || true)

    if [ "$CH_STATUS" = "STATUS_FOCUS" ]; then
        IDLE_COUNT=$(( IDLE_COUNT + 1 ))
        if [ "$IDLE_COUNT" -ge 12 ]; then
            IDLE_COUNT=0
            eval "$PURGE_CMD" >/dev/null 2>&1 || true
            update_metrics
        fi
    else
        IDLE_COUNT=0
    fi
done
'@

$b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($daemonSh -replace "`r`n", "`n")))
$startCmd = "setsid sh -c `"echo $b64 | base64 -d | sh`" >/dev/null 2>&1 </dev/null &"

$body2 = @{ cmd = $startCmd } | ConvertTo-Json -Compress
$res2 = Invoke-RestMethod -Uri "$baseUrl/exec" -Method Post -Headers $headers -ContentType "application/json" -Body $body2 -TimeoutSec 10
Write-Host "Started watchdog daemon."

Start-Sleep -Seconds 3

# Verify status
$verifyCmd = @'
echo "=== PID FILE ==="
cat /tmp/custom_home_watchdog.pid 2>/dev/null || echo "No pid file"
echo "=== PROCESS ==="
ps -ef | grep -E 'custom_home_watchdog|base64' | grep -v grep || true
echo "=== LIVE METRICS CONTENT ==="
cat /opt/usr/apps/CustomHome/res/wgt/live_metrics.js
'@

$body3 = @{ cmd = $verifyCmd } | ConvertTo-Json -Compress
$res3 = Invoke-RestMethod -Uri "$baseUrl/exec" -Method Post -Headers $headers -ContentType "application/json" -Body $body3 -TimeoutSec 10
Write-Host "Verification result:`n$($res3.output)"
