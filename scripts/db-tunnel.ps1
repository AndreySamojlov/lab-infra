# db-tunnel.ps1 — SSH-туннель к lab Postgres: keepalive + авто-реконнект.
# Запуск: powershell -File scripts\db-tunnel.ps1   (Ctrl+C — остановить)
param(
    [string]$KeyPath   = "$HOME\.ssh\id_ed25519",
    [string]$Remote    = "root@104.248.41.116",
    [int]   $LocalPort = 15432
)

while ($true) {
    Write-Host "[$(Get-Date -Format HH:mm:ss)] tunnel: localhost:$LocalPort -> ${Remote}:5432"
    ssh -i $KeyPath `
        -o ServerAliveInterval=30 `
        -o ServerAliveCountMax=3 `
        -o ExitOnForwardFailure=yes `
        -o ConnectTimeout=10 `
        -N -L "${LocalPort}:127.0.0.1:5432" $Remote
    Write-Host "[$(Get-Date -Format HH:mm:ss)] tunnel dropped (exit $LASTEXITCODE), reconnect in 5s..."
    Start-Sleep -Seconds 5
}
