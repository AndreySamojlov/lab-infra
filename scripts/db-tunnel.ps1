# db-tunnel.ps1 — SSH-туннель к lab Postgres: keepalive + авто-реконнект.
# Запуск: powershell -File scripts\db-tunnel.ps1   (Ctrl+C — остановить)
# Обычно запускается скрыто из Scheduled Task "lab-do-db-tunnel" (при входе в
# систему) — см. RUNBOOK.md. Лог пишется в файл, так как скрытый запуск не
# имеет консоли.
param(
    [string]$KeyPath   = "$HOME\.ssh\id_ed25519",
    [string]$Remote    = "root@104.248.41.116",
    [int]   $LocalPort = 15432,
    [string]$LogPath   = "$HOME\.lab-infra\db-tunnel.log"
)

New-Item -ItemType Directory -Force -Path (Split-Path $LogPath) | Out-Null

function Write-Log {
    param([string]$Message)
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    try {
        Add-Content -Path $LogPath -Value $line
    } catch {
        # logging failure must never take down the tunnel loop
    }
}

while ($true) {
    Write-Log "tunnel: localhost:$LocalPort -> ${Remote}:5432"
    ssh -i $KeyPath `
        -o ServerAliveInterval=30 `
        -o ServerAliveCountMax=3 `
        -o ExitOnForwardFailure=yes `
        -o ConnectTimeout=10 `
        -N -L "${LocalPort}:127.0.0.1:5432" $Remote
    Write-Log "tunnel dropped (exit $LASTEXITCODE), reconnect in 5s..."
    Start-Sleep -Seconds 5
}
