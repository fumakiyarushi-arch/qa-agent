# QA Agentic Flow - Create Bugs from Test Results
# Reads test results and creates Linear bugs with screenshots

$ErrorActionPreference = 'Continue'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  Creating Bugs from Test Results' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

# Load env vars from .env.linear
$envVars = @{}
if (Test-Path '.env.linear') {
    Get-Content '.env.linear' | ForEach-Object {
        if ($_ -match '^([^#].+?)=(.+)$') { $envVars[$matches[1].Trim()] = $matches[2].Trim() }
    }
}

$LinearApiKey = $envVars['LINEAR_API_KEY']
$TeamId       = $envVars['LINEAR_TEAM_ID']
$ProjectId    = $envVars['LINEAR_PROJECT_ID']
$AssigneeId   = '1c022279-12c1-47cf-98f4-97d23f9608b8'
$BugLabelId   = '7702c998-d45b-47dd-ae06-4439693f8b98'

if (-not $LinearApiKey -or -not $TeamId -or -not $ProjectId) {
    Write-Host 'ERROR: Linear credentials not found in .env.linear' -ForegroundColor Red
    exit 1
}

# Ensure output directories exist
$apiScreenshotsDir = 'qa-reports\api-screenshots'
if (-not (Test-Path $apiScreenshotsDir)) {
    New-Item -ItemType Directory -Path $apiScreenshotsDir -Force | Out-Null
}

# ─────────────────────────────────────────────
# HELPER: Create API Error HTML Page
# ─────────────────────────────────────────────
function New-ApiErrorHtml {
    param(
        [string]$TestName,
        [int]$ExpectedStatus,
        [int]$ActualStatus,
        [string]$RequestBody,
        [string]$ResponseBody,
        [string]$Scenario,
        [string]$OutputPath
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $formattedRequest = ""
    $formattedResponse = ""
    
    try { $formattedRequest = $RequestBody | ConvertFrom-Json | ConvertTo-Json -Depth 10 } catch { $formattedRequest = $RequestBody }
    try { $formattedResponse = $ResponseBody | ConvertFrom-Json | ConvertTo-Json -Depth 10 } catch { $formattedResponse = $ResponseBody }
    
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Error: $TestName</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            min-height: 100vh;
            padding: 30px;
            color: #eee;
        }
        .container { max-width: 900px; margin: 0 auto; }
        .error-banner {
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            border-radius: 12px;
            padding: 25px;
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 25px;
            box-shadow: 0 10px 30px rgba(220, 53, 69, 0.4);
        }
        .error-icon {
            width: 60px; height: 60px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px; font-weight: bold; color: white;
        }
        .error-text { font-size: 28px; font-weight: 700; color: white; letter-spacing: 1px; }
        .card {
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
            border: 1px solid rgba(255,255,255,0.1);
        }
        .card-header {
            font-size: 14px; text-transform: uppercase;
            letter-spacing: 1.5px; color: #888;
            margin-bottom: 15px;
            display: flex; align-items: center; gap: 10px;
        }
        .card-header .icon {
            width: 24px; height: 24px;
            background: #0d6efd;
            border-radius: 6px;
            display: flex; align-items: center; justify-content: center; font-size: 14px;
        }
        .test-name { font-size: 22px; font-weight: 600; color: #fff; margin-bottom: 8px; }
        .scenario { color: #aaa; font-size: 14px; }
        .status-comparison { display: flex; gap: 20px; margin-bottom: 20px; }
        .status-box {
            flex: 1; padding: 20px; border-radius: 10px; text-align: center;
        }
        .status-expected {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
        }
        .status-actual {
            background: linear-gradient(135deg, #dc3545 0%, #e74c3c 100%);
            box-shadow: 0 4px 15px rgba(220, 53, 69, 0.3);
        }
        .status-label {
            font-size: 12px; text-transform: uppercase;
            letter-spacing: 1px; color: rgba(255,255,255,0.8); margin-bottom: 8px;
        }
        .status-code { font-size: 36px; font-weight: 700; color: white; }
        .status-label-text { font-size: 14px; color: rgba(255,255,255,0.9); margin-top: 5px; }
        .code-block {
            background: #0d1117; border-radius: 8px; padding: 15px;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 13px; line-height: 1.5;
            color: #c9d1d9; border: 1px solid #30363d;
        }
        .code-block pre { margin: 0; white-space: pre-wrap; word-wrap: break-word; }
        .timestamp { text-align: center; color: #666; font-size: 12px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="error-banner">
            <div class="error-icon">✗</div>
            <div class="error-text">API TEST FAILED</div>
        </div>
        
        <div class="card">
            <div class="card-header"><span class="icon">🔍</span>Test Details</div>
            <div class="test-name">$TestName</div>
            <div class="scenario">$Scenario</div>
        </div>
        
        <div class="status-comparison">
            <div class="status-box status-expected">
                <div class="status-label">✓ Expected</div>
                <div class="status-code">$ExpectedStatus</div>
                <div class="status-label-text">Expected HTTP Status</div>
            </div>
            <div class="status-box status-actual">
                <div class="status-label">✗ Actual</div>
                <div class="status-code">$ActualStatus</div>
                <div class="status-label-text">Received HTTP Status</div>
            </div>
        </div>
        
        <div class="card">
            <div class="card-header"><span class="icon">📤</span>Request Body</div>
            <div class="code-block"><pre>$formattedRequest</pre></div>
        </div>
        
        <div class="card">
            <div class="card-header"><span class="icon">📥</span>Response Body</div>
            <div class="code-block"><pre>$formattedResponse</pre></div>
        </div>
        
        <div class="timestamp">Generated: $timestamp</div>
    </div>
</body>
</html>
"@
    
    $html | Out-File $OutputPath -Encoding utf8
    return $OutputPath
}

# ─────────────────────────────────────────────
# HELPER: Convert HTML to PNG using Puppeteer
# ─────────────────────────────────────────────
function Convert-HtmlToPng {
    param(
        [string]$HtmlPath,
        [string]$OutputPath
    )
    
    $puppeteerScript = @"
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

async function convert() {
    const browser = await puppeteer.launch({
        headless: 'new',
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 900, height: 1200 });
    await page.goto('file://' + process.argv[2], { waitUntil: 'networkidle0' });
    await page.screenshot({ path: process.argv[3], fullPage: true });
    await browser.close();
}
convert().catch(console.error);
"@
    
    $scriptPath = "qa-reports\_html_to_png_temp.js"
    $puppeteerScript | Out-File $scriptPath -Encoding utf8
    
    try {
        node $scriptPath $HtmlPath $OutputPath 2>$null
    } catch {
        Write-Host "    Puppeteer not available, keeping HTML file" -ForegroundColor Yellow
    }
    
    if (Test-Path $scriptPath) { Remove-Item $scriptPath -Force }
    
    return $OutputPath
}

# ─────────────────────────────────────────────
# HELPER: Create Linear Issue with Attachment
# ─────────────────────────────────────────────
function New-LinearBugWithAttachment {
    param(
        [string]$Title,
        [string]$Description,
        [string]$AttachmentPath,
        [int]$Priority = 2,
        [string]$Type = 'api'
    )
    
    $reqHeaders = @{
        'Content-Type' = 'application/json'
        'Authorization' = $LinearApiKey
    }
    
    $descEscaped = $Description -replace '\\', '\\\\' -replace '"', '\"' -replace "`r`n", '\n' -replace "`n", '\n' -replace "`r", '\n'
    
    $mutation = @{
        query = "mutation { issueCreate(input:{teamId:`"$TeamId`",projectId:`"$ProjectId`",title:`"$($Title -replace '"','\"')`",description:`"$descEscaped`",priority:$Priority,assigneeId:`"$AssigneeId`",labelIds:[`"$BugLabelId`"]}){success issue{id identifier url}}}"
    } | ConvertTo-Json -Depth 5
    
    try {
        $r = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $mutation -UseBasicParsing
        $res = $r.Content | ConvertFrom-Json
        
        if ($res.data.issueCreate.success) {
            $issue = $res.data.issueCreate.issue
            Write-Host "    [CREATED] $($issue.identifier) - $($issue.url)" -ForegroundColor Green
            
            # Attach screenshot if available
            if ($AttachmentPath -and (Test-Path $AttachmentPath)) {
                try {
                    $fileExt = [System.IO.Path]::GetExtension($AttachmentPath)
                    $contentType = if ($fileExt -eq '.png') { 'image/png' } elseif ($fileExt -eq '.html') { 'text/html' } else { 'application/octet-stream' }
                    $fileName = [System.IO.Path]::GetFileName($AttachmentPath)
                    $fileSize = (Get-Item $AttachmentPath).Length
                    
                    $uploadMutation = @{
                        query = "mutation { fileUpload(contentType: `"$contentType`", filename: `"$fileName`", size: $fileSize) { uploadFile { uploadUrl assetUrl headers { key value } } } }"
                    } | ConvertTo-Json -Depth 5
                    
                    $uploadRes = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $uploadMutation -UseBasicParsing
                    $uploadData = ($uploadRes.Content | ConvertFrom-Json).data.fileUpload.uploadFile
                    
                    if ($uploadData -and $uploadData.uploadUrl) {
                        $putHeaders = @{ 'Content-Type' = $contentType; 'Cache-Control' = 'public, max-age=31536000' }
                        foreach ($h in $uploadData.headers) { $putHeaders[$h.key] = $h.value }
                        $fileBytes = [System.IO.File]::ReadAllBytes($AttachmentPath)
                        Invoke-WebRequest -Uri $uploadData.uploadUrl -Method PUT -Headers $putHeaders -Body $fileBytes -UseBasicParsing | Out-Null
                        
                        $assetUrl = $uploadData.assetUrl
                        
                        $visualLabel = if ($Type -eq 'api') { "API Error Visual" } else { "UI Screenshot" }
                        $commentBody = "## $visualLabel Evidence

Automatically generated by QA Agentic Flow.

![]($assetUrl)

> Bug automatically created from test results"
                        $commentEscaped = $commentBody -replace '\\', '\\\\' -replace '"', '\"'
                        $commentMutation = @{
                            query = "mutation { commentCreate(input:{issueId:`"$($issue.id)`",body:`"$commentEscaped`"}){success}}"
                        } | ConvertTo-Json -Depth 5
                        
                        $cr = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $commentMutation -UseBasicParsing
                        $cres = $cr.Content | ConvertFrom-Json
                        if ($cres.data.commentCreate.success) {
                            Write-Host "    Screenshot attached to $($issue.identifier)" -ForegroundColor Cyan
                        }
                    }
                } catch {
                    Write-Host "    Attach error: $($_.Exception.Message.Split([char]10)[0])" -ForegroundColor Yellow
                }
            }
            
            return @{ identifier = $issue.identifier; url = $issue.url }
        }
    } catch {
        Write-Host "    ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $null
}

# ─────────────────────────────────────────────
# STEP 1: Process API Test Results
# ─────────────────────────────────────────────
Write-Host '[Step 1/2] Processing API Test Results...' -ForegroundColor Yellow

$apiResultsFile = 'qa-reports\all-api-tests-result.json'
if (-not (Test-Path $apiResultsFile)) {
    Write-Host "ERROR: API results file not found: $apiResultsFile" -ForegroundColor Red
    exit 1
}

$apiResults = Get-Content $apiResultsFile | ConvertFrom-Json
$failedApiTests = $apiResults.results | Where-Object { -not $_.success }

Write-Host "  Total API tests: $($apiResults.total_tests)"
Write-Host "  Failed API tests: $($failedApiTests.Count)"
Write-Host ''

$apiIssues = @()
foreach ($test in $failedApiTests) {
    $testNameSafe = $test.name -replace '[^\w\-]', '_' -replace '_+', '_'
    $htmlPath = "$apiScreenshotsDir\$testNameSafe.html"
    $pngPath = "$apiScreenshotsDir\$testNameSafe.png"
    
    Write-Host "  Processing: $($test.name)" -ForegroundColor Cyan
    Write-Host "    Expected: $($test.expected_status) | Actual: $($test.actual_status)" -ForegroundColor Gray
    
    # Create HTML error page
    New-ApiErrorHtml -TestName $test.name -ExpectedStatus $test.expected_status -ActualStatus $test.actual_status -RequestBody $test.body -ResponseBody $test.response_body -Scenario "API Test" -OutputPath $htmlPath
    Write-Host "    HTML saved: $htmlPath" -ForegroundColor Gray
    
    # Convert to PNG
    Convert-HtmlToPng -HtmlPath $htmlPath -OutputPath $pngPath
    
    $attachmentFile = $pngPath
    if (-not (Test-Path $pngPath)) {
        $attachmentFile = $htmlPath
        Write-Host "    Using HTML fallback" -ForegroundColor Yellow
    } else {
        Write-Host "    PNG saved: $pngPath" -ForegroundColor Green
    }
    
    # Create Linear bug
    $title = "[API][$($test.name)] Bug: HTTP $($test.actual_status) returned (expected $($test.expected_status))"
    
    $formattedReq = ""
    $formattedResp = ""
    try { $formattedReq = $test.body | ConvertFrom-Json | ConvertTo-Json -Depth 10 } catch { $formattedReq = $test.body }
    try { $formattedResp = $test.response_body | ConvertFrom-Json | ConvertTo-Json -Depth 10 } catch { $formattedResp = $test.response_body }
    
    $description = "## API Bug Report

**Test:** $($test.name)

### Expected vs Actual
- Expected HTTP: **$($test.expected_status)**
- Got HTTP: **$($test.actual_status)**

### Request
``````json
$formattedReq
```````

### Response
``````json
$formattedResp
```````

### Priority: High | Severity: Major

> Bug automatically created by QA Agentic Flow from test results"
    
    $issue = New-LinearBugWithAttachment -Title $title -Description $description -AttachmentPath $attachmentFile -Priority 2 -Type 'api'
    
    if ($issue) {
        $apiIssues += $issue
    }
    
    Write-Host ''
}

Write-Host "  API bugs created: $($apiIssues.Count)"
Write-Host ''

# ─────────────────────────────────────────────
# STEP 2: Process UI Test Results
# ─────────────────────────────────────────────
Write-Host '[Step 2/2] Processing UI Test Results...' -ForegroundColor Yellow

$uiResultsFile = 'qa-reports\ui-test-results.json'
if (-not (Test-Path $uiResultsFile)) {
    Write-Host "WARNING: UI results file not found: $uiResultsFile" -ForegroundColor Yellow
} else {
    $uiResults = Get-Content $uiResultsFile | ConvertFrom-Json
    
    $uiBugs = @()
    if ($uiResults.bugs -and $uiResults.bugs.Count -gt 0) {
        Write-Host "  Total UI bugs: $($uiResults.bugs.Count)"
        Write-Host ''
        
        foreach ($uiBug in $uiResults.bugs) {
            Write-Host "  Processing: $($uiBug.title)" -ForegroundColor Cyan
            
            $description = "## UI Bug Report

**Title:** $($uiBug.title)

### Description
$($uiBug.description)

### Steps to Reproduce
$($uiBug.steps)

### Visual Evidence
Screenshot captured during automated testing.

> Bug automatically created by QA Agentic Flow from test results"
            
            $issue = New-LinearBugWithAttachment -Title $uiBug.title -Description $description -AttachmentPath $uiBug.screenshot -Priority 2 -Type 'ui'
            
            if ($issue) {
                $uiIssues += $issue
            }
            
            Write-Host ''
        }
        
        Write-Host "  UI bugs created: $($uiIssues.Count)"
    } else {
        Write-Host "  No UI bugs to create"
    }
}

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────
Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  Bug Creation Complete!' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host "  API bugs created: $($apiIssues.Count)" -ForegroundColor Green
Write-Host "  UI bugs created: $($uiIssues.Count)" -ForegroundColor Green
Write-Host ''

if ($apiIssues.Count -gt 0 -or $uiIssues.Count -gt 0) {
    Write-Host '  Linear Issue URLs:' -ForegroundColor Cyan
    foreach ($issue in $apiIssues) {
        Write-Host "    API: $($issue.url)" -ForegroundColor White
    }
    if ($uiIssues) {
        foreach ($issue in $uiIssues) {
            Write-Host "    UI: $($issue.url)" -ForegroundColor White
        }
    }
}

Write-Host ''
