# QA Testing Entry Point Script
# Runs the full QA test suite for Signup, Login, Forgot Password, and UI Responsive flows

param(
    [string]$LinearApiKey,
    [string]$TeamId,
    [string]$ProjectId,
    [switch]$SkipLinear
)

$ErrorActionPreference = 'Continue'

# Display nice header
Write-Host ''
Write-Host '╔══════════════════════════════════════════════════════════════╗' -ForegroundColor Cyan
Write-Host '║                    QA TESTING SUITE                           ║' -ForegroundColor Cyan
Write-Host '╠══════════════════════════════════════════════════════════════╣' -ForegroundColor Cyan
Write-Host '║  Testing Features:                                           ║' -ForegroundColor Cyan
Write-Host '║    1. Signup Flow (Manual UI test)                           ║' -ForegroundColor Cyan
Write-Host '║    2. Login Flow (Manual UI test)                             ║' -ForegroundColor Cyan
Write-Host '║    3. Forgot Password Flow (Manual UI test)                  ║' -ForegroundColor Cyan
Write-Host '║    4. UI Responsive Flow (Mobile/Tablet)                     ║' -ForegroundColor Cyan
Write-Host '║    5. All API Tests (Signup, Login, Forgot Password)          ║' -ForegroundColor Cyan
Write-Host '╠══════════════════════════════════════════════════════════════╣' -ForegroundColor Cyan
Write-Host '║  After testing:                                               ║' -ForegroundColor Cyan
Write-Host '║    - Creates bugs in Linear with screenshots                 ║' -ForegroundColor Cyan
Write-Host '║    - Generates/updates QA-Report.md                          ║' -ForegroundColor Cyan
Write-Host '╚══════════════════════════════════════════════════════════════╝' -ForegroundColor Cyan
Write-Host ''

# Display progress message
Write-Host '[START] Initializing QA Test Suite...' -ForegroundColor Yellow
Write-Host ''

# Build arguments for the internal script
$scriptArgs = @()

if ($LinearApiKey) {
    $scriptArgs += @('-LinearApiKey', $LinearApiKey)
}

if ($TeamId) {
    $scriptArgs += @('-TeamId', $TeamId)
}

if ($ProjectId) {
    $scriptArgs += @('-ProjectId', $ProjectId)
}

if ($SkipLinear) {
    $scriptArgs += '-SkipLinear'
}

# Call the existing run-qa-with-linear.ps1 script
Write-Host '[RUN] Executing QA tests via run-qa-with-linear.ps1...' -ForegroundColor Yellow
Write-Host ''

$scriptPath = Join-Path $PSScriptRoot 'run-qa-with-linear.ps1'

if (-not (Test-Path $scriptPath)) {
    Write-Host "[ERROR] Could not find run-qa-with-linear.ps1 at: $scriptPath" -ForegroundColor Red
    exit 1
}

& $scriptPath @scriptArgs

$exitCode = $LASTEXITCODE

Write-Host ''
Write-Host '[COMPLETE] QA Test Suite finished!' -ForegroundColor Green
Write-Host ''

exit $exitCode
