#Requires -Version 5.1
<#
.SYNOPSIS
  Smoke check stack FS-Monitoring (tanpa docker).
  Exit 0 bila semua check lolos, 1 bila ada yang gagal.
#>
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Failed = 0

function Check($Name, [scriptblock]$Test) {
  try {
    $result = & $Test
    if ($result) { Write-Output "PASS: $Name" }
    else { Write-Output "FAIL: $Name"; $script:Failed++ }
  } catch {
    Write-Output "FAIL: $Name ($($_.Exception.Message))"
    $script:Failed++
  }
}

$Compose = Get-Content (Join-Path $Root "docker-compose.yml") -Raw
$Prom = Get-Content (Join-Path $Root "prometheus/prometheus.yml") -Raw

Check "compose: service prometheus/grafana/loki/promtail" {
  ($Compose -match "(?m)^\s{2}prometheus:") -and ($Compose -match "(?m)^\s{2}grafana:") -and
  ($Compose -match "(?m)^\s{2}loki:") -and ($Compose -match "(?m)^\s{2}promtail:")
}
Check "compose: exporter node/nginx/postgres" {
  ($Compose -match "(?m)^\s{2}node-exporter:") -and ($Compose -match "(?m)^\s{2}nginx-exporter:") -and
  ($Compose -match "(?m)^\s{2}postgres-exporter:")
}
Check "compose: port hanya bind loopback" {
  -not ($Compose | Select-String -Pattern '(?m)^\s+-\s+"(?!127\.0\.0\.1:)\d+:\d+"' | Select-Object -First 1)
}
Check "prometheus: 8 scrape jobs" {
  ([regex]::Matches($Prom, "job_name:").Count) -ge 8
}
Check "prometheus: job fs-public + game-inventori + webmail + digiflazz" {
  ($Prom -match 'job_name:\s+"fs-public"') -and ($Prom -match 'job_name:\s+"game-inventori"') -and
  ($Prom -match 'job_name:\s+"webmail"') -and ($Prom -match 'job_name:\s+"fs-digiflazz-service"')
}
Check "prometheus: metrics_path app sesuai (/api/metrics, /metrics)" {
  ($Prom -match 'metrics_path:\s+"/api/metrics"') -and ($Prom -match 'metrics_path:\s+"/metrics"')
}
Check "grafana: 8 dashboard JSON valid" {
  $files = Get-ChildItem (Join-Path $Root "grafana/provisioning/dashboards/*.json")
  if ($files.Count -lt 8) { return $false }
  foreach ($f in $files) {
    try { Get-Content $f.FullName -Raw | ConvertFrom-Json | Out-Null }
    catch { return $false }
  }
  return $true
}
Check "grafana: dashboards.yml + datasources.yml ada" {
  (Test-Path (Join-Path $Root "grafana/provisioning/dashboards/dashboards.yml")) -and
  (Test-Path (Join-Path $Root "grafana/provisioning/datasources/datasources.yml"))
}
Check "loki + promtail config ada" {
  (Test-Path (Join-Path $Root "loki/loki-config.yml")) -and
  (Test-Path (Join-Path $Root "promtail/promtail-config.yml"))
}
Check "Dockerfile custom (prometheus/grafana/loki/promtail) ada" {
  (Test-Path (Join-Path $Root "Dockerfile.prometheus")) -and
  (Test-Path (Join-Path $Root "Dockerfile.grafana")) -and
  (Test-Path (Join-Path $Root "Dockerfile.loki")) -and
  (Test-Path (Join-Path $Root "Dockerfile.promtail"))
}

if ($Failed -gt 0) { Write-Output "$Failed check(s) FAILED"; exit 1 }
Write-Output "Semua smoke check lolos."
