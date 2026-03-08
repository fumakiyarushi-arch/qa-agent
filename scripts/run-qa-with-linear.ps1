# QA Agentic Flow - Full Test Suite (API + UI + Linear + Report)
param(
    [string]$LinearApiKey,
    [string]$TeamId,
    [string]$ProjectId,
    [switch]$SkipLinear
)

$ErrorActionPreference = 'Continue'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host '  QA Agentic Flow - Full Suite v3' -ForegroundColor Cyan
Write-Host '  Signup | Login | ForgotPwd | UI | Linear' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''

# Load env vars
$envVars = @{}
if (Test-Path '.env.linear') {
    Get-Content '.env.linear' | ForEach-Object {
        if ($_ -match '^([^#].+?)=(.+)$') { $envVars[$matches[1].Trim()] = $matches[2].Trim() }
    }
}

$LinearApiKey = if ($LinearApiKey) { $LinearApiKey } else { $envVars['LINEAR_API_KEY'] }
$TeamId       = if ($TeamId)       { $TeamId }       else { $envVars['LINEAR_TEAM_ID'] }
$ProjectId    = if ($ProjectId)    { $ProjectId }    else { $envVars['LINEAR_PROJECT_ID'] }

$AssigneeId = '1c022279-12c1-47cf-98f4-97d23f9608b8'
$BugLabelId = '7702c998-d45b-47dd-ae06-4439693f8b98'
$useLinear  = -not $SkipLinear -and $LinearApiKey -and $TeamId -and $ProjectId

# Ensure output directories exist
@('qa-reports', 'qa-reports/videos', 'qa-reports/screenshots', 'qa-reports/ui-results', 'qa-reports/api-screenshots') | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
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
    $formattedRequest = $RequestBody | ConvertFrom-Json | ConvertTo-Json -Depth 10
    
    $formattedResponse = ""
    try {
        $formattedResponse = $ResponseBody | ConvertFrom-Json | ConvertTo-Json -Depth 10
    } catch {
        $formattedResponse = $ResponseBody
    }
    
    $errorIndicator = @"
<div class="error-banner">
    <div class="error-icon">✗</div>
    <div class="error-text">API TEST FAILED</div>
</div>
"@
    
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
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
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
            width: 60px;
            height: 60px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: bold;
            color: white;
        }
        .error-text {
            font-size: 28px;
            font-weight: 700;
            color: white;
            letter-spacing: 1px;
        }
        .card {
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
            border: 1px solid rgba(255,255,255,0.1);
        }
        .card-header {
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: #888;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .card-header .icon {
            width: 24px;
            height: 24px;
            background: #0d6efd;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        .test-name {
            font-size: 22px;
            font-weight: 600;
            color: #fff;
            margin-bottom: 8px;
        }
        .scenario {
            color: #aaa;
            font-size: 14px;
        }
        .status-comparison {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        .status-box {
            flex: 1;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
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
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: rgba(255,255,255,0.8);
            margin-bottom: 8px;
        }
        .status-code {
            font-size: 36px;
            font-weight: 700;
            color: white;
        }
        .status-label-text {
            font-size: 14px;
            color: rgba(255,255,255,0.9);
            margin-top: 5px;
        }
        .code-block {
            background: #0d1117;
            border-radius: 8px;
            padding: 15px;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', monospace;
            font-size: 13px;
            line-height: 1.5;
            color: #c9d1d9;
            border: 1px solid #30363d;
        }
        .code-block pre { margin: 0; white-space: pre-wrap; word-wrap: break-word; }
        .json-key { color: #79c0ff; }
        .json-string { color: #a5d6ff; }
        .json-number { color: #79c0ff; }
        .json-boolean { color: #ff7b72; }
        .json-null { color: #ff7b72; }
        .timestamp {
            text-align: center;
            color: #666;
            font-size: 12px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        $errorIndicator
        
        <div class="card">
            <div class="card-header">
                <span class="icon">🔍</span>
                Test Details
            </div>
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
            <div class="card-header">
                <span class="icon">📤</span>
                Request Body
            </div>
            <div class="code-block"><pre>$formattedRequest</pre></div>
        </div>
        
        <div class="card">
            <div class="card-header">
                <span class="icon">📥</span>
                Response Body
            </div>
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
# HELPER: Convert HTML to PNG using Playwright
# ─────────────────────────────────────────────
function Convert-HtmlToPng {
    param(
        [string]$HtmlPath,
        [string]$OutputPath
    )
    
    $htmlAbsPath = (Resolve-Path $HtmlPath).Path
    $pngAbsPath = (Resolve-Path (Split-Path $OutputPath -Parent)).Path + '\' + (Split-Path $OutputPath -Leaf)
    
    try {
        node scripts/html-to-png-helper.js $htmlAbsPath $pngAbsPath 2>$null
        if (Test-Path $OutputPath) {
            Write-Host "    Converted to PNG: $(Split-Path $OutputPath -Leaf)" -ForegroundColor Green
            return $OutputPath
        }
    } catch {
        Write-Host "    Playwright conversion failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    Write-Host "    Keeping HTML file as fallback" -ForegroundColor Yellow
    return $HtmlPath
}

# ─────────────────────────────────────────────
# STEP 1: UI FLOWS (Playwright — video + screenshots)
# ─────────────────────────────────────────────
Write-Host '[Step 1/5] Running UI Visual Tests (Playwright)...' -ForegroundColor Yellow
Write-Host '  Flows: Signup | Login | Forgot Password | UI Responsive' -ForegroundColor Gray

$uiResults = @{ bugs = @(); videoMap = @{}; summary = @{ total = 0 } }
$uiResultsFile = 'qa-reports/ui-test-results.json'

if (Test-Path $uiResultsFile) { Remove-Item $uiResultsFile -Force }

node scripts/run-ui-tests.js

if (Test-Path $uiResultsFile) {
    $uiResults = Get-Content $uiResultsFile | ConvertFrom-Json
    Write-Host "  UI Tests done. Bugs found: $($uiResults.summary.total)" -ForegroundColor Green
} else {
    Write-Host '  UI Tests did not produce results file.' -ForegroundColor Red
}

Write-Host ''

# ─────────────────────────────────────────────
# STEP 2: API TESTS
# ─────────────────────────────────────────────
Write-Host '[Step 2/5] Running API Tests...' -ForegroundColor Yellow

$Headers = @{'Content-Type' = 'application/json'; 'api_type' = 'web'; 'platform' = 'web' }
$BaseUrl  = 'https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth'

function Get-Priority { param([int]$s) if ($s -ge 500) { 'Urgent' } elseif ($s -ge 400) { 'High' } else { 'Medium' } }

function Test-API {
    param([string]$Name, [string]$Url, [string]$Body, [int]$ExpectedStatus, [string]$Scenario)
    $actualStatus = 0; $responseBody = ''
    try {
        $r = Invoke-WebRequest -Uri $Url -Method POST -Headers $Headers -Body $Body -UseBasicParsing -ErrorAction SilentlyContinue
        $actualStatus  = [int]$r.StatusCode
        $responseBody  = $r.Content
    } catch {
        if ($_.Exception.Response) { $actualStatus = [int]$_.Exception.Response.StatusCode }
        $responseBody = $_.Exception.Message
    }
    $success = ($actualStatus -eq $ExpectedStatus)
    $color   = if ($success) { 'Green' } else { 'Red' }
    Write-Host "  $Name`: $actualStatus (Expected: $ExpectedStatus)" -ForegroundColor $color
    return @{ name = $Name; url = $Url; body = $Body; expected = $ExpectedStatus; actual = $actualStatus; response = $responseBody; success = $success; scenario = $Scenario }
}

$testResults = @()

Write-Host "`n  === Signup API Tests ===" -ForegroundColor Cyan
$testResults += Test-API "Signup - Valid"           "$BaseUrl/signup" '{"role":"individual","platform":"web","fullname":"Virat Kohli","email":"virat_india@yopmail.com","password":"Test@123","mobile_number":"2025550001","country_code":"+1"}' 201 "Valid signup request"
$testResults += Test-API "Signup - Missing Email"   "$BaseUrl/signup" '{"role":"individual","platform":"web","fullname":"Test User","password":"Test@123","mobile_number":"2025550002","country_code":"+1"}' 400 "Missing email field"
$testResults += Test-API "Signup - Missing Password" "$BaseUrl/signup" '{"role":"individual","platform":"web","fullname":"Test User","email":"test2@yopmail.com","mobile_number":"2025550002","country_code":"+1"}' 400 "Missing password field"
$testResults += Test-API "Signup - Invalid Email"   "$BaseUrl/signup" '{"role":"individual","platform":"web","fullname":"Test User","email":"invalid-email","password":"Test@123","mobile_number":"2025550003","country_code":"+1"}' 400 "Invalid email format"
$testResults += Test-API "Signup - Weak Password"   "$BaseUrl/signup" '{"role":"individual","platform":"web","fullname":"Test User","email":"test3@yopmail.com","password":"123","mobile_number":"2025550004","country_code":"+1"}' 400 "Weak password"
$testResults += Test-API "Signup - Missing Fullname" "$BaseUrl/signup" '{"role":"individual","platform":"web","email":"test4@yopmail.com","password":"Test@123","mobile_number":"2025550005","country_code":"+1"}' 400 "Missing fullname field"

Write-Host "`n  === Login API Tests ===" -ForegroundColor Cyan
$testResults += Test-API "Login - Valid"            "$BaseUrl/login" '{"email":"virat_india@yopmail.com","password":"Test@123","role":"individual"}' 200 "Valid login request"
$testResults += Test-API "Login - Invalid Email"    "$BaseUrl/login" '{"email":"notfound@yopmail.com","password":"Test@123","role":"individual"}' 401 "Invalid email"
$testResults += Test-API "Login - Invalid Password" "$BaseUrl/login" '{"email":"virat_india@yopmail.com","password":"WrongPass123","role":"individual"}' 401 "Invalid password"
$testResults += Test-API "Login - Missing Email"    "$BaseUrl/login" '{"password":"Test@123","role":"individual"}' 400 "Missing email field"
$testResults += Test-API "Login - Missing Password" "$BaseUrl/login" '{"email":"virat_india@yopmail.com","role":"individual"}' 400 "Missing password field"
$testResults += Test-API "Login - Empty Body"       "$BaseUrl/login" '{}' 400 "Empty request body"

Write-Host "`n  === Forgot Password API Tests ===" -ForegroundColor Cyan
$testResults += Test-API "Forgot Password - Valid Email"        "$BaseUrl/forgot-password" '{"email":"virat_india@yopmail.com"}' 200 "Valid email for password reset"
$testResults += Test-API "Forgot Password - Invalid Email"      "$BaseUrl/forgot-password" '{"email":"notexists@yopmail.com"}' 404 "Non-existent email"
$testResults += Test-API "Forgot Password - Missing Email"      "$BaseUrl/forgot-password" '{}' 400 "Missing email field"
$testResults += Test-API "Forgot Password - Invalid Email Format" "$BaseUrl/forgot-password" '{"email":"invalid-email"}' 400 "Invalid email format"
$testResults += Test-API "Forgot Password - Empty Email"        "$BaseUrl/forgot-password" '{"email":""}' 400 "Empty email field"

$testResults | ConvertTo-Json -Depth 10 | Out-File 'qa-reports/all-tests-result.json' -Encoding utf8

$passed = ($testResults | Where-Object { $_.success }).Count
$failed = ($testResults | Where-Object { -not $_.success }).Count
Write-Host "`n  API Results: $passed Passed | $failed Failed | $($testResults.Count) Total`n" -ForegroundColor Cyan

# ─────────────────────────────────────────────
# STEP 3: Generate API Error Screenshots
# ─────────────────────────────────────────────
Write-Host '[Step 3/5] Generating API error screenshots...' -ForegroundColor Yellow

$apiErrorScreenshots = @{}
$apiErrorHtmlFiles = @{}

foreach ($test in $testResults) {
    if (-not $test.success) {
        $testNameSafe = $test.name -replace '[^\w\-]', '_' -replace '_+', '_'
        $htmlPath = "qa-reports\api-screenshots\$testNameSafe.html"
        $pngPath = "qa-reports\api-screenshots\$testNameSafe.png"
        
        New-ApiErrorHtml -TestName $test.name -ExpectedStatus $test.expected -ActualStatus $test.actual -RequestBody $test.body -ResponseBody $test.response -Scenario $test.scenario -OutputPath $htmlPath
        $apiErrorHtmlFiles[$test.name] = $htmlPath
        
        Convert-HtmlToPng -HtmlPath $htmlPath -OutputPath $pngPath
        
        if (Test-Path $pngPath) {
            $apiErrorScreenshots[$test.name] = $pngPath
            Write-Host "  Generated screenshot: $testNameSafe.png" -ForegroundColor Green
        } else {
            $apiErrorScreenshots[$test.name] = $htmlPath
            Write-Host "  Generated HTML fallback: $testNameSafe.html" -ForegroundColor Yellow
        }
    }
}

Write-Host ''

# ─────────────────────────────────────────────
# STEP 4: CHECK DUPLICATES + BUILD BUG LIST
# ─────────────────────────────────────────────
Write-Host '[Step 4/5] Syncing with Linear...' -ForegroundColor Yellow

$existingIssues = @()
if ($useLinear) {
    $q = @{ query = "query { issues(filter: { project: { id: { eq: `"$ProjectId`" } } }, first: 100) { nodes { title identifier } } }" } | ConvertTo-Json -Depth 5
    try {
        $r = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST `
            -Headers @{'Content-Type' = 'application/json'; 'Authorization' = $LinearApiKey } `
            -Body $q -UseBasicParsing
        $existingIssues = ($r.Content | ConvertFrom-Json).data.issues.nodes
        Write-Host "  Existing Linear issues found: $($existingIssues.Count)" -ForegroundColor Gray
    } catch {
        Write-Host "  Could not fetch existing issues: $($_.Exception.Message)" -ForegroundColor Red
    }
}

$PM   = @{ 'Urgent' = 1; 'High' = 2; 'Medium' = 3 }
$bugs = @()

# Build screenshotMap from Playwright output (keyed by test name)
$screenshotMap = @{}
if ($uiResults.screenshotMap) {
    $uiResults.screenshotMap.PSObject.Properties | ForEach-Object {
        $screenshotMap[$_.Name] = $_.Value
    }
    Write-Host "  UI Screenshots mapped: $($screenshotMap.Count)" -ForegroundColor Gray
}

# API bugs - use generated API error screenshots
foreach ($test in $testResults) {
    if (-not $test.success) {
        $p = Get-Priority $test.actual
        $s = if ($p -eq 'Urgent') { 'Critical' } elseif ($p -eq 'High') { 'Major' } else { 'Minor' }
        $isDup = $existingIssues | Where-Object { $_.title -like "*$($test.name)*HTTP $($test.actual)*" }
        if ($isDup) {
            Write-Host "  [DUPLICATE] $($test.name) -> $($isDup.identifier)" -ForegroundColor Yellow
        } else {
            # Use API error screenshot (PNG or HTML fallback)
            $ssPath = $apiErrorScreenshots[$test.name]
            $htmlPath = $apiErrorHtmlFiles[$test.name]
            
            $t = "[API][$($test.name)] Bug: HTTP $($test.actual) returned (expected $($test.expected))"
            
            $formattedReq = $test.body | ConvertFrom-Json | ConvertTo-Json -Depth 10
            $formattedResp = ""
            try { $formattedResp = $test.response | ConvertFrom-Json | ConvertTo-Json -Depth 10 } catch { $formattedResp = $test.response }
            
            $d = "## API Bug Report`n`n**Test:** $($test.name)`n**Scenario:** $($test.scenario)`n`n### Expected vs Actual`n- Expected HTTP: **$($test.expected)**`n- Got HTTP: **$($test.actual)**`n`n### Request`n``````json`n$formattedReq`n```````n`n### Response`n``````$formattedResp`n```````n`n### Priority: $p | Severity: $s`n`n> Bug automatically created by QA Agentic Flow"
            $bugs += @{ title = $t; desc = $d; pv = $PM[$p]; p = $p; screenshot = $ssPath; htmlFile = $htmlPath; type = 'api' }
            Write-Host "  [NEW API BUG] $($test.name) | Priority: $p | Visual Error Page: YES" -ForegroundColor Green
        }
    }
}

# UI bugs from Playwright
if ($uiResults.bugs -and $uiResults.bugs.Count -gt 0) {
    foreach ($uiBug in $uiResults.bugs) {
        $isDup = $existingIssues | Where-Object { $_.title -like "*$($uiBug.title)*" }
        if ($isDup) {
            Write-Host "  [DUPLICATE UI] $($uiBug.title)" -ForegroundColor Yellow
        } else {
            $d = "## UI Bug Report`n`n**Title:** $($uiBug.title)`n`n### Description`n$($uiBug.description)`n`n### Steps to Reproduce`n$($uiBug.steps)`n`n### Visual Evidence`nScreenshot captured during automated testing.`n`n> Bug automatically created by QA Agentic Flow"
            $bugs += @{ title = $uiBug.title; desc = $d; pv = 2; p = 'High'; screenshot = $uiBug.screenshot; type = 'ui' }
            Write-Host "  [NEW UI BUG] $($uiBug.title)" -ForegroundColor Green
        }
    }
}

Write-Host "  Total new bugs to create: $($bugs.Count)`n" -ForegroundColor Cyan

# Create Linear issues
$issues = @()
if ($useLinear -and $bugs.Count -gt 0) {
    $reqHeaders = @{ 'Content-Type' = 'application/json'; 'Authorization' = $LinearApiKey }

    foreach ($b in $bugs) {
        $descEscaped = $b.desc -replace '\\', '\\\\' -replace '"', '\"' -replace "`r`n", '\n' -replace "`n", '\n' -replace "`r", '\n'
        $mutation = @{
            query = "mutation { issueCreate(input:{teamId:`"$TeamId`",projectId:`"$ProjectId`",title:`"$($b.title -replace '"','\"')`",description:`"$descEscaped`",priority:$($b.pv),assigneeId:`"$AssigneeId`",labelIds:[`"$BugLabelId`"]}){success issue{id identifier url}}}"
        } | ConvertTo-Json -Depth 5

        try {
            $r = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $mutation -UseBasicParsing
            $res = $r.Content | ConvertFrom-Json
            if ($res.data.issueCreate.success) {
                $issue = $res.data.issueCreate.issue
                $issues += @{ id = $issue.id; identifier = $issue.identifier; url = $issue.url; bug = $b }
                Write-Host "  [CREATED] $($issue.identifier) | $($b.p) | $($b.type.ToUpper())" -ForegroundColor Green

                # Attach screenshot using Linear's native file upload API
                $attachmentFile = $b.screenshot
                if (-not $attachmentFile -and $b.htmlFile) {
                    $attachmentFile = $b.htmlFile
                }
                
                if ($attachmentFile -and (Test-Path $attachmentFile)) {
                    try {
                        $fileExt = [System.IO.Path]::GetExtension($attachmentFile)
                        $contentType = if ($fileExt -eq '.png') { 'image/png' } elseif ($fileExt -eq '.html') { 'text/html' } else { 'application/octet-stream' }
                        $fileName = [System.IO.Path]::GetFileName($attachmentFile)
                        $fileSize = (Get-Item $attachmentFile).Length

                        $uploadMutation = @{
                            query = "mutation { fileUpload(contentType: `"$contentType`", filename: `"$fileName`", size: $fileSize) { uploadFile { uploadUrl assetUrl headers { key value } } } }"
                        } | ConvertTo-Json -Depth 5
                        $uploadRes  = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $uploadMutation -UseBasicParsing
                        $uploadData = ($uploadRes.Content | ConvertFrom-Json).data.fileUpload.uploadFile

                        if ($uploadData -and $uploadData.uploadUrl) {
                            $putHeaders = @{ 'Content-Type' = $contentType; 'Cache-Control' = 'public, max-age=31536000' }
                            foreach ($h in $uploadData.headers) { $putHeaders[$h.key] = $h.value }
                            $fileBytes = [System.IO.File]::ReadAllBytes($attachmentFile)
                            Invoke-WebRequest -Uri $uploadData.uploadUrl -Method PUT -Headers $putHeaders -Body $fileBytes -UseBasicParsing | Out-Null

                            $assetUrl = $uploadData.assetUrl
                            Write-Host "    📤 Uploaded: $assetUrl" -ForegroundColor Gray

                            $visualLabel = if ($b.type -eq 'api') { "API Error Visual" } else { "UI Screenshot" }
                            $commentBody = "## $visualLabel Evidence

Automatically generated by QA Agentic Flow.

![]($assetUrl)

> Test: $($b.title)"
                            $commentEscaped = $commentBody -replace '\\', '\\\\' -replace '"', '\"'
                            $commentMutation = @{
                                query = "mutation { commentCreate(input:{issueId:`"$($issue.id)`",body:`"$commentEscaped`"}){success}}"
                            } | ConvertTo-Json -Depth 5
                            $cr   = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $commentMutation -UseBasicParsing
                            $cres = $cr.Content | ConvertFrom-Json
                            if ($cres.data.commentCreate.success) {
                                Write-Host "    Screenshot attached to $($issue.identifier)" -ForegroundColor Cyan
                            }
                        }
                    } catch {
                        Write-Host "    Attach error: $($_.Exception.Message.Split([char]10)[0])" -ForegroundColor Yellow
                    }
                }
            }
        } catch {
            Write-Host "  [ERROR creating issue] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# ─────────────────────────────────────────────
# STEP 5: GENERATE ENHANCED QA-Report.md
# ─────────────────────────────────────────────
Write-Host ''
Write-Host '[Step 5/5] Generating Enhanced QA-Report.md...' -ForegroundColor Yellow

$now = (Get-Date).ToString('yyyy-MM-dd HH:mm')
$lines = [System.Collections.Generic.List[string]]::new()

$lines.Add("# QA Report - $now")
$lines.Add('')
$lines.Add('---')
$lines.Add('')
$lines.Add('## 📊 Executive Summary')
$lines.Add('')
$lines.Add("| Metric | Count |")
$lines.Add("|--------|-------|")
$lines.Add("| Total API Tests | $($testResults.Count) |")
$lines.Add("| ✅ API Passed | $passed |")
$lines.Add("| ❌ API Failed | $failed |")
$lines.Add("| 🖥️ UI Bugs Found | $($uiResults.summary.total) |")
$lines.Add("| 🐛 Total Bugs Created | $($bugs.Count) |")
$lines.Add("| 📝 Linear Tickets | $($issues.Count) |")
$lines.Add('')
$lines.Add('---')
$lines.Add('')
$lines.Add('## 🎥 Feature Testing Video Recordings')
$lines.Add('')

$videoSection = @(
    @{ flow = 'Signup Flow';           key = 'Signup Flow' },
    @{ flow = 'Login Flow';            key = 'Login Flow' },
    @{ flow = 'Forgot Password Flow';  key = 'Forgot Password Flow' },
    @{ flow = 'UI Responsive Flow';    key = 'UI Responsive Flow' }
)

foreach ($v in $videoSection) {
    $videoFile = "qa-reports/videos/$($v.key.ToLower().Replace(' ', '-')).webm"
    if (Test-Path $videoFile) {
        $absPath = (Resolve-Path $videoFile).Path
        $lines.Add("- 🎥 **$($v.flow):** [Watch Recording](file:///$($absPath.Replace('\','/')))")
    } else {
        $lines.Add("- 🎥 **$($v.flow):** *(video pending)*")
    }
}

$lines.Add('')
$lines.Add('---')
$lines.Add('')
$lines.Add('## 🧪 API Test Results')
$lines.Add('')

# Signup Tests
$lines.Add('### Signup API Tests')
$lines.Add('')
$lines.Add('| Test Case | Expected | Actual | Status | Visual |')
$lines.Add('|-----------|----------|--------|--------|--------|')
foreach ($t in ($testResults | Where-Object { $_.name -like 'Signup*' })) {
    $st = if ($t.success) { '✅ PASS' } else { '❌ FAIL' }
    $visual = ''
    if (-not $t.success) {
        $ss = $apiErrorScreenshots[$t.name]
        if ($ss -and (Test-Path $ss)) {
            $ssAbs = (Resolve-Path $ss).Path
            $visual = "[📷 Error](file:///$($ssAbs.Replace('\','/')))"
        } else {
            $visual = "❌"
        }
    } else {
        $visual = "—"
    }
    $lines.Add("| $($t.name) | $($t.expected) | $($t.actual) | $st | $visual |")
}

$lines.Add('')
$lines.Add('### Login API Tests')
$lines.Add('')
$lines.Add('| Test Case | Expected | Actual | Status | Visual |')
$lines.Add('|-----------|----------|--------|--------|--------|')
foreach ($t in ($testResults | Where-Object { $_.name -like 'Login*' })) {
    $st = if ($t.success) { '✅ PASS' } else { '❌ FAIL' }
    $visual = ''
    if (-not $t.success) {
        $ss = $apiErrorScreenshots[$t.name]
        if ($ss -and (Test-Path $ss)) {
            $ssAbs = (Resolve-Path $ss).Path
            $visual = "[📷 Error](file:///$($ssAbs.Replace('\','/')))"
        } else {
            $visual = "❌"
        }
    } else {
        $visual = "—"
    }
    $lines.Add("| $($t.name) | $($t.expected) | $($t.actual) | $st | $visual |")
}

$lines.Add('')
$lines.Add('### Forgot Password API Tests')
$lines.Add('')
$lines.Add('| Test Case | Expected | Actual | Status | Visual |')
$lines.Add('|-----------|----------|--------|--------|--------|')
foreach ($t in ($testResults | Where-Object { $_.name -like 'Forgot*' })) {
    $st = if ($t.success) { '✅ PASS' } else { '❌ FAIL' }
    $visual = ''
    if (-not $t.success) {
        $ss = $apiErrorScreenshots[$t.name]
        if ($ss -and (Test-Path $ss)) {
            $ssAbs = (Resolve-Path $ss).Path
            $visual = "[📷 Error](file:///$($ssAbs.Replace('\','/')))"
        } else {
            $visual = "❌"
        }
    } else {
        $visual = "—"
    }
    $lines.Add("| $($t.name) | $($t.expected) | $($t.actual) | $st | $visual |")
}

# Failed API Tests Detail Section
$failedTests = $testResults | Where-Object { -not $_.success }
if ($failedTests.Count -gt 0) {
    $lines.Add('')
    $lines.Add('---')
    $lines.Add('')
    $lines.Add('## 🔴 Failed API Tests - Detailed View')
    $lines.Add('')
    
    foreach ($ft in $failedTests) {
        $formattedReq = ""
        $formattedResp = ""
        try { $formattedReq = $ft.body | ConvertFrom-Json | ConvertTo-Json -Depth 5 } catch { $formattedReq = $ft.body }
        try { $formattedResp = $ft.response | ConvertFrom-Json | ConvertTo-Json -Depth 5 } catch { $formattedResp = $ft.response }
        
        $lines.Add("### ❌ $($ft.name)")
        $lines.Add('')
        $lines.Add("| Property | Value |")
        $lines.Add("|----------|-------|")
        $lines.Add("| **Scenario** | $($ft.scenario) |")
        $lines.Add("| **Expected Status** | $($ft.expected) |")
        $lines.Add("| **Actual Status** | $($ft.actual) |")
        $lines.Add("| **URL** | $($ft.url) |")
        
        $ss = $apiErrorScreenshots[$ft.name]
        if ($ss -and (Test-Path $ss)) {
            $ssAbs = (Resolve-Path $ss).Path
            $lines.Add("| **Visual Error Page** | [📷 View Screenshot](file:///$($ssAbs.Replace('\','/'))) |")
        }
        
        $lines.Add('')
        $lines.Add('**Request Body:**')
        $lines.Add('```json')
        $lines.Add($formattedReq)
        $lines.Add('```')
        $lines.Add('')
        $lines.Add('**Response Body:**')
        $lines.Add('```json')
        $lines.Add($formattedResp)
        $lines.Add('```')
        $lines.Add('')
    }
}

$lines.Add('')
$lines.Add('---')
$lines.Add('')
$lines.Add('## 🖥️ UI Test Results (Playwright)')
$lines.Add('')

if ($uiResults.summary.total -gt 0) {
    $lines.Add("| Flow | UI Bugs Found |")
    $lines.Add("|------|--------------|")
    $lines.Add("| Signup Flow | $($uiResults.summary.signup) |")
    $lines.Add("| Login Flow | $($uiResults.summary.login) |")
    $lines.Add("| Forgot Password Flow | $($uiResults.summary.forgotPassword) |")
    $lines.Add("| UI Responsive Flow | $($uiResults.summary.uiResponsive) |")
    $lines.Add("| **Total UI Bugs** | **$($uiResults.summary.total)** |")
    
    if ($uiResults.bugs -and $uiResults.bugs.Count -gt 0) {
        $lines.Add('')
        $lines.Add('### UI Bug Details')
        $lines.Add('')
        foreach ($uiBug in $uiResults.bugs) {
            $lines.Add("#### ❌ $($uiBug.title)")
            $lines.Add('')
            $lines.Add("**Description:** $($uiBug.description)")
            $lines.Add('')
            $lines.Add("**Steps to Reproduce:**")
            $lines.Add('```')
            $lines.Add($uiBug.steps)
            $lines.Add('```')
            if ($uiBug.screenshot -and (Test-Path $uiBug.screenshot)) {
                $ssAbs = (Resolve-Path $uiBug.screenshot).Path
                $lines.Add("**Screenshot:** [📷 View](file:///$($ssAbs.Replace('\','/')))")
            }
            $lines.Add('')
        }
    }
} else {
    $lines.Add('✅ No UI bugs detected across Signup, Login, Forgot Password, and Responsive flows.')
}

if ($issues.Count -gt 0) {
    $lines.Add('')
    $lines.Add('---')
    $lines.Add('')
    $lines.Add('## 🐛 Bugs Created in Linear')
    $lines.Add('')
    foreach ($iss in $issues) {
        $b = $iss.bug
        $lines.Add("### [$($iss.identifier)]($($iss.url)) - $($b.type.ToUpper())")
        $lines.Add('')
        $lines.Add("| Field | Value |")
        $lines.Add("|-------|-------|")
        $lines.Add("| **Title** | $($b.title) |")
        $lines.Add("| **Priority** | $($b.p) |")
        $lines.Add("| **Type** | $($b.type.ToUpper()) |")
        
        $attachmentFile = $b.screenshot
        if (-not $attachmentFile -and $b.htmlFile) {
            $attachmentFile = $b.htmlFile
        }
        
        if ($attachmentFile -and (Test-Path $attachmentFile)) {
            $ssAbs = (Resolve-Path $attachmentFile).Path
            $ext = [System.IO.Path]::GetExtension($attachmentFile)
            $label = if ($ext -eq '.html') { "Visual Error Page (HTML)" } else { "Screenshot" }
            $lines.Add("| **$label** | [📷 View](file:///$($ssAbs.Replace('\','/'))) |")
        }
        $lines.Add('')
    }
}

$lines.Add('---')
$lines.Add('')
$lines.Add("## 📁 Generated Artifacts")
$lines.Add('')
$lines.Add('| Directory | Description |')
$lines.Add('|-----------|-------------|')
$lines.Add('| `qa-reports/screenshots/` | UI screenshots from Playwright |')
$lines.Add('| `qa-reports/api-screenshots/` | API error visual pages (PNG/HTML) |')
$lines.Add('| `qa-reports/videos/` | Video recordings of UI flows |')
$lines.Add('| `qa-reports/all-tests-result.json` | Complete test results JSON |')
$lines.Add('')
$lines.Add('---')
$lines.Add('')
$lines.Add("*Generated by QA Agentic Flow on $now*")

# Write to QA-Report.md
$lines | Out-File 'QA-Report.md' -Encoding utf8
Write-Host '  ✅ Enhanced QA-Report.md saved successfully!' -ForegroundColor Green

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host "  QA Run Complete!" -ForegroundColor Cyan
Write-Host "  API: $passed Passed | $failed Failed" -ForegroundColor Cyan
Write-Host "  UI Bugs: $($uiResults.summary.total)" -ForegroundColor Cyan
Write-Host "  Linear Tickets Created: $($issues.Count)" -ForegroundColor Cyan
Write-Host "  API Visual Error Pages: $($apiErrorScreenshots.Count)" -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan
Write-Host ''
