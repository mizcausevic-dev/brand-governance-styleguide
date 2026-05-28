$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$site = Join-Path $repoRoot "site"

$expected = @(
    "index.html",
    "styles.css",
    "token-system\index.html",
    "pattern-library\index.html",
    "approval-desk\index.html",
    "verification\index.html",
    "docs\index.html",
    "robots.txt",
    "sitemap.xml",
    "CNAME"
)

foreach ($relative in $expected) {
    $full = Join-Path $site $relative
    if (-not (Test-Path $full)) {
        throw "Missing expected file: $relative"
    }
}

Write-Output "Smoke check passed for $site"

