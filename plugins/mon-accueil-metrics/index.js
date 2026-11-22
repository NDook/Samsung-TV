'use strict';
var fs = require('fs');
var os = require('os');

var TOTAL_KB_RE = /^MemTotal:\s+(\d+)\s*kB/m;
var AVAIL_KB_RE = /^MemAvailable:\s+(\d+)\s*kB/m;
var THERMAL_RE = /thermal$/;
var BATT_4226_RE = /B4226=.*byte 0x([0-9a-fA-F]{1,2})/;

var TMP_METRICS = '/tmp/custom_home_live_metrics.js';
var WGT_METRICS = '/opt/usr/apps/CustomHome/res/wgt/live_metrics.js';

module.exports = function (ctx) {
    var batteryTimer = null;
    var bootTimer = null;
    var lastBattery = { percent: null, raw: 0, powerStatus: 0, charging: false, updatedAt: 0 };
    var chargingUntil = 0;
    var busyBattery = false;
    var vmTuned = false;
    var tmpLinkReady = false;

    function tryRead(p) {
        try { return fs.readFileSync(p, 'utf8').trim(); } catch (e) { return null; }
    }

    function getIp() {
        try {
            var ifaces = os.networkInterfaces() || {};
            var names = Object.keys(ifaces);
            for (var i = 0; i < names.length; i++) {
                var list = ifaces[names[i]] || [];
                for (var j = 0; j < list.length; j++) {
                    if (list[j].family === 'IPv4' && !list[j].internal) return list[j].address;
                }
            }
        } catch (e) {}
        return '127.0.0.1';
    }

    function readFastMetrics() {
        var mem = tryRead('/proc/meminfo') || '';
        var mTot = TOTAL_KB_RE.exec(mem);
        var mAv = AVAIL_KB_RE.exec(mem);
        var totalMb = mTot ? Math.round(Number(mTot[1]) / 1024) : 1424;
        var availMb = mAv ? Math.round(Number(mAv[1]) / 1024) : 750;

        var upRaw = tryRead('/proc/uptime');
        var uptimeSec = upRaw ? Math.floor(parseFloat(upRaw.split(/\s+/)[0])) : 0;

        var loadRaw = tryRead('/proc/loadavg');
        var loadavg = loadRaw ? loadRaw.split(/\s+/)[0] : '0.30';
        var extcon = tryRead('/sys/devices/platform/tztv_hdmi_sw/extcon/extcon1/state') || '';
        var hdmi3Active = (/^HDMI3=1/m.test(extcon)) ? 1 : 0;
        var hdmi3Plugged = hdmi3Active;

        var temp = null;
        try {
            var soc = '/sys/devices/platform/soc';
            var names = fs.readdirSync(soc).filter(function (n) { return THERMAL_RE.test(n); }).sort();
            for (var i = 0; i < names.length; i++) {
                if (!temp) temp = tryRead(soc + '/' + names[i] + '/temperature');
            }
        } catch (e) {}
        var socTempC = temp ? parseInt(temp, 10) : 52;
        if (socTempC > 1000) socTempC = Math.round(socTempC / 1000);

        return {
            ts: Date.now(),
            battery: lastBattery,
            ram: {
                availableMb: availMb,
                totalMb: totalMb,
                usedMb: Math.max(0, totalMb - availMb),
                freePercent: Math.round((availMb * 100) / totalMb)
            },
            socTempC: socTempC,
            loadavg: loadavg,
            uptimeSec: uptimeSec,
            resolution: '3840 x 2160',
            ip: getIp(),
            hdmi3: { plugged: hdmi3Plugged, active: hdmi3Active }
        };
    }

    function ensureTmpSymlink() {
        if (tmpLinkReady) return Promise.resolve();
        var setupCmd = 'touch ' + TMP_METRICS + ' && chmod 666 ' + TMP_METRICS + ' && (chsmack -a "*" ' + TMP_METRICS + ' 2>/dev/null || true) && ln -sf ' + TMP_METRICS + ' ' + WGT_METRICS;
        return ctx.execute(setupCmd, 4000).then(function (r) {
            if (r && r.exit_code === 0) tmpLinkReady = true;
        }).catch(function () {});
    }

    function writeLiveMetricsJs() {
        var payload = 'window.__TV_METRICS__ = ' + JSON.stringify(readFastMetrics()) + ';\n';
        return ensureTmpSymlink().then(function () {
            if (tmpLinkReady) {
                try {
                    // Écriture en place pour conserver l'inode (chmod 666 + label SMACK *) et éviter toute usure flash eMMC
                    fs.writeFileSync(TMP_METRICS, payload, 'utf8');
                    return null;
                } catch (e) {}
            }
            var b64 = Buffer.from(payload, 'utf8').toString('base64');
            var fallbackCmd = 'echo "' + b64 + '" | base64 -d > ' + TMP_METRICS;
            return ctx.execute(fallbackCmd, 4000);
        });
    }

    function tuneKernelVm() {
        var vmCmd = 'echo 60 > /proc/sys/vm/swappiness 2>/dev/null && echo 80 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null';
        return ctx.execute(vmCmd, 3000).then(function (r) {
            if (r && r.exit_code === 0) vmTuned = true;
        }).catch(function () {});
    }

    function pollBatteryAndWriteJs() {
        if (busyBattery) return;
        busyBattery = true;
        if (!vmTuned) tuneKernelVm();

        // 1 seul appel gdbus (4226, fiable même télécommande en veille) + garde-fou CPU instantané sur GIBBON_MAIN (delta utime+stime sur 1s)
        var cmd = 'echo "B4226=$(gdbus call --system --dest org.projectx.bt_product --object-path /org/projectx/bt_service_product --method org.projectx.bt_product.service_request_product 1 4226 0 "[byte 0x00]" "[byte 0x00]" "[byte 0x00]" "[byte 0x00]" "[byte 0x00]" 2>/dev/null)"; ' +
            'FOCUS=$(aul_test get_status CustomHome.Main 2>/dev/null | grep -o STATUS_FOCUS); ' +
            'if [ "$FOCUS" = "STATUS_FOCUS" ]; then ' +
                'GPID=$(pgrep -x GIBBON_MAIN 2>/dev/null | head -n 1); ' +
                'if [ -n "$GPID" ] && [ -r "/proc/$GPID/stat" ]; then ' +
                    'T1=$(sed "s/.*) //" "/proc/$GPID/stat" 2>/dev/null | awk "{print \\$12+\\$13}"); ' +
                    'sleep 1; ' +
                    'if [ -r "/proc/$GPID/stat" ]; then ' +
                        'T2=$(sed "s/.*) //" "/proc/$GPID/stat" 2>/dev/null | awk "{print \\$12+\\$13}"); ' +
                        'if [ -n "$T1" ] && [ -n "$T2" ] && [ $((T2 - T1)) -ge 40 ]; then kill -9 "$GPID" >/dev/null 2>&1 || true; fi; ' +
                    'fi; ' +
                'fi; ' +
            'fi';

        ctx.execute(cmd, 8000).then(function (r) {
            var out = (r && r.stdout) ? String(r.stdout) : '';
            var now = Date.now();
            var m6 = BATT_4226_RE.exec(out);
            if (m6) {
                var rawVal = parseInt(m6[1], 16);
                if (rawVal > 0) {
                    var adc = (rawVal >> 3) & 0x1F;
                    var pct = Math.max(0, Math.min(100, Math.round((adc * 100) / 31)));
                    var pwr = rawVal & 7;
                    var prevPct = lastBattery.percent;
                    if (prevPct !== null && pct > prevPct) {
                        chargingUntil = now + 20 * 60 * 1000;
                    } else if (prevPct !== null && pct < prevPct) {
                        chargingUntil = 0;
                    }
                    if (pct >= 100 && prevPct === 100 && chargingUntil > now + 120000) {
                        chargingUntil = now + 120000;
                    }
                    lastBattery = {
                        percent: pct,
                        raw: rawVal,
                        powerStatus: pwr,
                        charging: now < chargingUntil,
                        updatedAt: now
                    };
                }
            }
            return writeLiveMetricsJs();
        }).catch(function () {}).then(function () {
            busyBattery = false;
        }, function () {
            busyBattery = false;
        });
    }

    return {
        start: function () {
            tuneKernelVm();
            pollBatteryAndWriteJs();
            bootTimer = setTimeout(pollBatteryAndWriteJs, 5000);
            if (bootTimer.unref) bootTimer.unref();
            batteryTimer = setInterval(pollBatteryAndWriteJs, 60000);
            if (batteryTimer.unref) batteryTimer.unref();
        },
        stop: function () {
            if (bootTimer) clearTimeout(bootTimer);
            bootTimer = null;
            if (batteryTimer) clearInterval(batteryTimer);
            batteryTimer = null;
        },
        status: function () {
            return readFastMetrics();
        },
        route: function (req, res, sub) {
            if (sub === 'metrics' || sub === '') {
                var data = JSON.stringify(readFastMetrics());
                res.writeHead(200, {
                    'Content-Type': 'application/json; charset=utf-8',
                    'Access-Control-Allow-Origin': '*',
                    'Cache-Control': 'no-store'
                });
                res.end(data);
                return true;
            }
            return false;
        }
    };
};
