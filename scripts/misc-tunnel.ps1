# misc-tunnel.ps1 — SSH-туннель к прочим локальным сервисам VM: keepalive + авто-реконнект.
# Порты: 8088 (mp-cockpit-web-test), 8091 (job-submit), 8090->8080 (job-browser), 6080 (job-browser VNC).
# Запуск: powershell -File scripts\misc-tunnel.ps1   (Ctrl+C — остановить)
param(
    [string]$KeyPath = "$HOME\.ssh\id_ed25519",
    [string]$Remote  = "root@104.248.41.116"
)

while ($true) {
    Write-Host "[$(Get-Date -Format HH:mm:ss)] tunnel: 8088/8091/8090/6080 -> ${Remote}"
    ssh -i $KeyPath `
        -o ServerAliveInterval=30 `
        -o ServerAliveCountMax=3 `
        -o ExitOnForwardFailure=yes `
        -o ConnectTimeout=10 `
        -N -L "8088:127.0.0.1:8088" -L "8091:127.0.0.1:8091" -L "8090:127.0.0.1:8080" -L "6080:127.0.0.1:6080" $Remote
    Write-Host "[$(Get-Date -Format HH:mm:ss)] tunnel dropped (exit $LASTEXITCODE), reconnect in 5s..."
    Start-Sleep -Seconds 5
}
