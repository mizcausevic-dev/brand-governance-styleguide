$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$screenshots = Join-Path $repoRoot "screenshots"
$site = Join-Path $repoRoot "site"
$port = 5488
$process = $null
$stdout = Join-Path $env:TEMP ("brand-governance-styleguide-" + [guid]::NewGuid().ToString() + "-stdout.log")
$stderr = Join-Path $env:TEMP ("brand-governance-styleguide-" + [guid]::NewGuid().ToString() + "-stderr.log")
$edgeCandidates = @(
    "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
)

New-Item -ItemType Directory -Force -Path $screenshots | Out-Null

function Get-EdgePath {
    foreach ($candidate in $edgeCandidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }
    throw "Microsoft Edge was not found."
}

function Wait-ForUrl {
    param([string]$Url)
    for ($i = 0; $i -lt 40; $i++) {
        try {
            Invoke-WebRequest -Uri $Url -UseBasicParsing | Out-Null
            return
        } catch {
            Start-Sleep -Milliseconds 750
        }
    }
    throw "Timed out waiting for $Url"
}

try {
    $process = Start-Process -FilePath "py" `
        -ArgumentList "-3", "-m", "http.server", "$port", "--bind", "127.0.0.1", "--directory", $site `
        -WorkingDirectory $repoRoot `
        -RedirectStandardOutput $stdout `
        -RedirectStandardError $stderr `
        -WindowStyle Hidden `
        -PassThru

    Wait-ForUrl "http://127.0.0.1:$port/"

    $edge = Get-EdgePath
    $targets = @(
        @{ Url = "http://127.0.0.1:$port/"; File = "01-overview-proof.png"; Size = "1600,1800" },
        @{ Url = "http://127.0.0.1:$port/token-system/"; File = "02-token-system-proof.png"; Size = "1600,1600" },
        @{ Url = "http://127.0.0.1:$port/pattern-library/"; File = "03-pattern-library-proof.png"; Size = "1600,1900" },
        @{ Url = "http://127.0.0.1:$port/verification/"; File = "04-verification-proof.png"; Size = "1600,1700" }
    )

    foreach ($target in $targets) {
        & $edge `
            --headless `
            --disable-gpu `
            --hide-scrollbars `
            "--window-size=$($target.Size)" `
            "--screenshot=$(Join-Path $screenshots $target.File)" `
            $target.Url | Out-Null
    }
} finally {
    if ($process -and -not $process.HasExited) {
        Stop-Process -Id $process.Id -Force
    }
    if (Test-Path $stdout) { Remove-Item $stdout -Force }
    if (Test-Path $stderr) { Remove-Item $stderr -Force }
}

