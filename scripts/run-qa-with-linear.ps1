# QA Agentic Flow - Comprehensive Test Suite
param(
    [string]$LinearApiKey,
    [string]$TeamId,
    [string]$ProjectId,
    [switch]$SkipLinear
)

$ErrorActionPreference = 'Continue'
Write-Host '========================================' -ForegroundColor Cyan
Write-Host 'QA Agentic Flow - Comprehensive v1' -ForegroundColor Cyan
Write-Host 'Multi-Scenario Testing | Duplicates | Linear' -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan

$envVars = @{}
if (Test-Path '.env.linear') { Get-Content '.env.linear' | ForEach-Object { if ($_ -match '^(.+)=(.+)$') { $envVars[$matches[1]] = $matches[2] } } }

$LinearApiKey = if ($LinearApiKey) { $LinearApiKey } else { $envVars['LINEAR_API_KEY'] }
$TeamId = if ($TeamId) { $TeamId } else { $envVars['LINEAR_TEAM_ID'] }
$ProjectId = if ($ProjectId) { $ProjectId } else { $envVars['LINEAR_PROJECT_ID'] }

$AssigneeId = '1c022279-12c1-47cf-98f4-97d23f9608b8'
$BugLabelId = '7702c998-d45b-47dd-ae06-4439693f8b98'
$useLinear = -not $SkipLinear -and $LinearApiKey -and $TeamId -and $ProjectId

Write-Host ''

function Get-Priority { param([int]$s) if ($s -ge 500) { return 'Urgent' } elseif ($s -ge 400) { return 'High' } return 'Medium' }

function Test-API {
    param([string]$Name, [string]$Url, [string]$Body, [int]$ExpectedStatus, [string]$Scenario)
    $actualStatus = 0
    $responseBody = ""
    try { 
        $ErrorActionPreference = 'Continue'
        $r = Invoke-WebRequest -Uri $Url -Method POST -Headers $Headers -Body $Body -UseBasicParsing -ErrorAction SilentlyContinue
        $actualStatus = [int]$r.StatusCode
        $responseBody = $r.Content
    } catch { 
        if ($_.Exception.Response) {
            $actualStatus = [int]$_.Exception.Response.StatusCode
        }
        $responseBody = $_.Exception.Message
    }
    $success = ($actualStatus -eq $ExpectedStatus)
    $color = if ($success) { 'Green' } else { 'Red' }
    Write-Host "  $Name`: $actualStatus (Expected: $ExpectedStatus)" -ForegroundColor $color
    return @{name=$Name; url=$Url; body=$Body; expected=$ExpectedStatus; actual=$actualStatus; response=$responseBody; success=$success; scenario=$Scenario}
}

$existingIssues = @()
if ($useLinear) {
    Write-Host '[Check] Existing bugs...' -ForegroundColor Yellow
    $q = @{
        query = "query { issues(filter: { project: { id: { eq: `"$ProjectId`" } } }, first: 100) { nodes { title identifier } } }"
    } | ConvertTo-Json -Depth 5
    try { 
        $r = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers @{'Content-Type'='application/json';'Authorization'=$LinearApiKey} -Body $q -UseBasicParsing
        $existingIssues = ($r.Content | ConvertFrom-Json).data.issues.nodes
        Write-Host "  Found: $($existingIssues.Count)" -ForegroundColor Gray 
    } catch { 
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red 
        $existingIssues = @()
    }
}

Write-Host ''
Write-Host '[Step1] Running API Tests...' -ForegroundColor Yellow

$Headers = @{'Content-Type'='application/json';'api_type'='web';'platform'='web'}
$BaseUrl = 'https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth'

$testResults = @()

Write-Host "`n  === Signup API Tests ===" -ForegroundColor Cyan
$testResults += Test-API -Name "Signup - Valid" -Url "$BaseUrl/signup" -Body '{"role":"individual","platform":"web","fullname":"Virat Kohli","email":"virat_india@yopmail.com","password":"Test@123","mobile_number":"2025550001","country_code":"+1"}' -ExpectedStatus 201 -Scenario "Valid signup request"
$testResults += Test-API -Name "Signup - Missing Email" -Url "$BaseUrl/signup" -Body '{"role":"individual","platform":"web","fullname":"Test User","password":"Test@123","mobile_number":"2025550002","country_code":"+1"}' -ExpectedStatus 400 -Scenario "Missing email field"
$testResults += Test-API -Name "Signup - Missing Password" -Url "$BaseUrl/signup" -Body '{"role":"individual","platform":"web","fullname":"Test User","email":"test2@yopmail.com","mobile_number":"2025550002","country_code":"+1"}' -ExpectedStatus 400 -Scenario "Missing password field"
$testResults += Test-API -Name "Signup - Invalid Email" -Url "$BaseUrl/signup" -Body '{"role":"individual","platform":"web","fullname":"Test User","email":"invalid-email","password":"Test@123","mobile_number":"2025550003","country_code":"+1"}' -ExpectedStatus 400 -Scenario "Invalid email format"
$testResults += Test-API -Name "Signup - Weak Password" -Url "$BaseUrl/signup" -Body '{"role":"individual","platform":"web","fullname":"Test User","email":"test3@yopmail.com","password":"123","mobile_number":"2025550004","country_code":"+1"}' -ExpectedStatus 400 -Scenario "Weak password"
$testResults += Test-API -Name "Signup - Missing Fullname" -Url "$BaseUrl/signup" -Body '{"role":"individual","platform":"web","email":"test4@yopmail.com","password":"Test@123","mobile_number":"2025550005","country_code":"+1"}' -ExpectedStatus 400 -Scenario "Missing fullname field"

Write-Host "`n  === Login API Tests ===" -ForegroundColor Cyan
$testResults += Test-API -Name "Login - Valid" -Url "$BaseUrl/login" -Body '{"email":"virat_india@yopmail.com","password":"Test@123","role":"individual"}' -ExpectedStatus 200 -Scenario "Valid login request"
$testResults += Test-API -Name "Login - Invalid Email" -Url "$BaseUrl/login" -Body '{"email":"notfound@yopmail.com","password":"Test@123","role":"individual"}' -ExpectedStatus 401 -Scenario "Invalid email"
$testResults += Test-API -Name "Login - Invalid Password" -Url "$BaseUrl/login" -Body '{"email":"virat_india@yopmail.com","password":"WrongPass123","role":"individual"}' -ExpectedStatus 401 -Scenario "Invalid password"
$testResults += Test-API -Name "Login - Missing Email" -Url "$BaseUrl/login" -Body '{"password":"Test@123","role":"individual"}' -ExpectedStatus 400 -Scenario "Missing email field"
$testResults += Test-API -Name "Login - Missing Password" -Url "$BaseUrl/login" -Body '{"email":"virat_india@yopmail.com","role":"individual"}' -ExpectedStatus 400 -Scenario "Missing password field"
$testResults += Test-API -Name "Login - Empty Body" -Url "$BaseUrl/login" -Body '{}' -ExpectedStatus 400 -Scenario "Empty request body"

Write-Host "`n  === Forgot Password API Tests ===" -ForegroundColor Cyan
$testResults += Test-API -Name "Forgot Password - Valid Email" -Url "$BaseUrl/forgot-password" -Body '{"email":"virat_india@yopmail.com"}' -ExpectedStatus 200 -Scenario "Valid email for password reset"
$testResults += Test-API -Name "Forgot Password - Invalid Email" -Url "$BaseUrl/forgot-password" -Body '{"email":"notexists@yopmail.com"}' -ExpectedStatus 404 -Scenario "Non-existent email"
$testResults += Test-API -Name "Forgot Password - Missing Email" -Url "$BaseUrl/forgot-password" -Body '{}' -ExpectedStatus 400 -Scenario "Missing email field"
$testResults += Test-API -Name "Forgot Password - Invalid Email Format" -Url "$BaseUrl/forgot-password" -Body '{"email":"invalid-email"}' -ExpectedStatus 400 -Scenario "Invalid email format"
$testResults += Test-API -Name "Forgot Password - Empty Email" -Url "$BaseUrl/forgot-password" -Body '{"email":""}' -ExpectedStatus 400 -Scenario "Empty email field"

$testResults | ConvertTo-Json -Depth 10 | Out-File 'qa-reports/all-tests-result.json' -Enc utf8

Write-Host ''
Write-Host '[Step2] Analyzing + Duplicates...' -ForegroundColor Yellow

$bugs = @()
$PM = @{'Urgent'=1;'High'=2;'Medium'=3}

foreach ($test in $testResults) {
    if (-not $test.success) {
        $p = Get-Priority $test.actual
        $foundDup = $false
        $search = '*' + $test.name + '*HTTP ' + $test.actual + '*'
        foreach ($e in $existingIssues) { 
            if ($e.title -like $search) { 
                $foundDup = $true 
                Write-Host "  [DUPLICATE] $($test.name): $($e.identifier)" -ForegroundColor Yellow 
                break 
            } 
        }
        if (-not $foundDup) {
            $t = '[' + $test.name + '] Bug: HTTP ' + $test.actual + ' - Failed'
            $d = "## Bug Report - $($test.name)

### Summary
The API endpoint is returning HTTP $($test.actual) instead of expected HTTP $($test.expected).

### Reason
$($test.scenario)

### Request
```json
$($test.body)
```

### Response
HTTP Status: $($test.actual)
Response: $($test.response)

### Developer Prompt - Fix This Bug
Please investigate and fix the API endpoint at `$($test.url)`. The endpoint should return HTTP $($test.expected) for this scenario: $($test.scenario).

Check for:
1. Input validation
2. Error handling
3. Required fields validation
4. API request/response format

### Priority: $p
### Severity: High"
            $bugs += @{title=$t; desc=$d; pv=$PM[$p]; p=$p}
            Write-Host "  [NEW] $($test.name): Priority $p" -ForegroundColor Green
        }
    }
}

$passed = ($testResults | Where-Object { $_.success }).Count
$failed = ($testResults | Where-Object { -not $test.success }).Count
Write-Host "  Passed: $passed | Failed: $failed | Total: $($testResults.Count)"

Write-Host ''
Write-Host '[Step3] Creating in Linear...' -ForegroundColor Yellow

$issues = @()
if ($useLinear -and $bugs.Count -gt 0) {
    $reqHeaders = @{'Content-Type'='application/json';'Authorization'=$LinearApiKey}
    
    foreach ($b in $bugs) {
        $descEscaped = $b.desc -replace '"', '\"' -replace "`n", "\n" -replace "`r", ""
        $mutation = @{
            query = "mutation { issueCreate(input:{teamId:`"$TeamId`",projectId:`"$ProjectId`",title:`"$($b.title)`",description:`"$descEscaped`",priority:$($b.pv),assigneeId:`"$AssigneeId`",labelIds:[`"$BugLabelId`"]}){success issue{identifier url}}}"
        } | ConvertTo-Json -Depth 5
        
        try {
            $r = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $mutation -UseBasicParsing
            $result = $r.Content | ConvertFrom-Json
            if ($result.data.issueCreate.success) { 
                $i = $result.data.issueCreate.issue
                $issues += $i
                Write-Host "  [OK] $($i.identifier) | Priority: $($b.p) | Label: Bug" -ForegroundColor Green
            }
        } catch { 
            Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red 
        }
    }
}

Write-Host ''
Write-Host '[Step4] Report...' -ForegroundColor Yellow

$report = '# QA Report - ' + (Get-Date).ToString('yyyy-MM-dd') + '

## Summary
- **Total Tests:** ' + $testResults.Count + '
- **Passed:** ' + $passed + '
- **Failed:** ' + $failed + '
- **New Bugs:** ' + $bugs.Count + '
- **Existing Bugs:** ' + $existingIssues.Count + '

## Test Results
| Test | Expected | Actual | Status |
|------|----------|--------|--------|
'
foreach ($test in $testResults) { 
    $status = if ($test.success) { 'PASS' } else { 'FAIL' }
    $report += '| ' + $test.name + ' | ' + $test.expected + ' | ' + $test.actual + ' | ' + $status + ' |`n'
}

$report += '
## Bugs Created: ' + $bugs.Count + '
'
foreach ($b in $bugs) { 
    $i = $issues[$bugs.IndexOf($b)]; 
    $report += '### ' + $b.title + '
- **Priority:** ' + $b.p + '
- **Description:** ' + $b.desc + '

[' + $i.identifier + '](' + $i.url + ')

' 
}

$report | Out-File 'qa-final-report.md' -Enc utf8
Write-Host '  Saved qa-final-report.md' -ForegroundColor Green

Write-Host ''
Write-Host '========================================' -ForegroundColor Cyan
Write-Host "Complete - Tests:$($testResults.Count) | Passed:$passed | Failed:$failed" -ForegroundColor Cyan
Write-Host "New Bugs: $($bugs.Count) | Duplicates: $($existingIssues.Count)" -ForegroundColor Cyan
if ($issues.Count -gt 0) { Write-Host 'Priority|Label|Assignee OK' -ForegroundColor Green }
Write-Host ''
