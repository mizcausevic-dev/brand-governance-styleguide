$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$src = Join-Path $repoRoot "src"
$site = Join-Path $repoRoot "site"
$domain = (Get-Content (Join-Path $repoRoot "CNAME")).Trim()

if (Test-Path $site) {
    Remove-Item -Recurse -Force $site
}

New-Item -ItemType Directory -Path $site | Out-Null
Copy-Item (Join-Path $src "*") $site -Recurse -Force

$robots = @"
User-agent: *
Allow: /
Sitemap: https://$domain/sitemap.xml
"@

Set-Content -Path (Join-Path $site "robots.txt") -Value $robots -NoNewline

$today = Get-Date -Format "yyyy-MM-dd"
$urls = @(
    "https://$domain/",
    "https://$domain/token-system/",
    "https://$domain/pattern-library/",
    "https://$domain/approval-desk/",
    "https://$domain/verification/",
    "https://$domain/docs/"
)

$sitemap = @('<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
foreach ($url in $urls) {
    $sitemap += "  <url><loc>$url</loc><lastmod>$today</lastmod></url>"
}
$sitemap += '</urlset>'
Set-Content -Path (Join-Path $site "sitemap.xml") -Value ($sitemap -join "`n")

Set-Content -Path (Join-Path $site "CNAME") -Value $domain -NoNewline

Write-Output "Built site at $site"

