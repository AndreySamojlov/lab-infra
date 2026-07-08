# misc-tunnel.ps1 — SSH-туннель к mp-cockpit-web-test: keepalive + авто-реконнект.
# Порт: 8088 (mp-cockpit-web-test). Держится отдельным процессом от прочих
# локальных туннелей (8091/8090/6080) намеренно: ExitOnForwardFailure=yes рвёт
# весь процесс, если хоть один из перечисленных -L не смог забиндиться, поэтому
# объединять порты, которыми управляют разные механизмы, в один процесс нельзя —
# конфликт на одном порту убивал бы туннель и для остальных.
# Запуск: powershell -File scripts\misc-tunnel.ps1   (Ctrl+C — остановить)
param(
    [string]$KeyPath = "$HOME\.ssh\id_ed25519",
    [string]$Remote  = "root@104.248.41.116"
)

while ($true) {
    Write-Host "[$(Get-Date -Format HH:mm:ss)] tunnel: 8088 -> ${Remote}"
    ssh -i $KeyPath `
        -o ServerAliveInterval=30 `
        -o ServerAliveCountMax=3 `
        -o ExitOnForwardFailure=yes `
        -o ConnectTimeout=10 `
        -N -L "8088:127.0.0.1:8088" $Remote
    Write-Host "[$(Get-Date -Format HH:mm:ss)] tunnel dropped (exit $LASTEXITCODE), reconnect in 5s..."
    Start-Sleep -Seconds 5
}
