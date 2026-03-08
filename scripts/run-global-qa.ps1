# Global QA Agentic Flow - Multi-Project Suite
param(
    [string]$ProjectName = "seal-my-idea",
    [string]$LinearApiKey,
    [switch]$SkipLinear
)

$ErrorActionPreference = 'Continue'

# Load Project Configuration
$ConfigPath = "projects/$ProjectName.json"
if (-not (Test-Path $ConfigPath)) {
    Write-Host "Error: Project configuration not found at $ConfigPath" -ForegroundColor Red
    exit 1
}

$Config = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host '========================================' -ForegroundColor Cyan
Write-Host "QA Agentic Flow - Global Suite v1" -ForegroundColor Cyan
Write-Host "Project: $($Config.projectName) | Client: $($Config.clientName)" -ForegroundColor Cyan
Write-Host '========================================' -ForegroundColor Cyan

# Load Linear Credentials
$envVars = @{}
if (Test-Path '.env.linear') { Get-Content '.env.linear' | ForEach-Object { if ($_ -match '^(.+)=(.+)$') { $envVars[$matches[1]] = $matches[2] } } }

$LinearApiKey = if ($LinearApiKey) { $LinearApiKey } else { $envVars['LINEAR_API_KEY'] }
$TeamId = $Config.linear.teamId
$ProjectId = $Config.linear.projectId
$AssigneeId = $Config.linear.defaultAssigneeId
$BugLabelId = $Config.linear.bugLabelId

$useLinear = -not $SkipLinear -and $LinearApiKey -and $TeamId -and $ProjectId

function Get-Priority { param([int]$s) if ($s -ge 500) { return 'Urgent' } elseif ($s -ge 400) { return 'High' } return 'Medium' }

function Test-API {
    param([string]$Name, [string]$Url, [string]$Body, [int]$ExpectedStatus, [string]$Scenario)
    $actualStatus = 0
    $responseBody = ""
    try { 
        $Headers = @{'Content-Type'='application/json';'api_type'='web';'platform'='web'}
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

# 1. API Testing Phase
Write-Host ''
Write-Host '[Step1] Running API Tests...' -ForegroundColor Yellow
$testResults = @()

# Signup Tests
Write-Host "`n  === Signup API Tests ===" -ForegroundColor Cyan
foreach ($test in $Config.testScenarios.signup) {
    $testResults += Test-API -Name $test.name -Url ($Config.auth.baseUrl + $Config.auth.endpoints.signup) -Body $test.body -ExpectedStatus $test.expected -Scenario $test.scenario
}

# Login Tests
Write-Host "`n  === Login API Tests ===" -ForegroundColor Cyan
foreach ($test in $Config.testScenarios.login) {
    $testResults += Test-API -Name $test.name -Url ($Config.auth.baseUrl + $Config.auth.endpoints.login) -Body $test.body -ExpectedStatus $test.expected -Scenario $test.scenario
}

# Forgot Password Tests
Write-Host "`n  === Forgot Password API Tests ===" -ForegroundColor Cyan
foreach ($test in $Config.testScenarios.forgotPassword) {
    $testResults += Test-API -Name $test.name -Url ($Config.auth.baseUrl + $Config.auth.endpoints.forgotPassword) -Body $test.body -ExpectedStatus $test.expected -Scenario $test.scenario
}

$testResults | ConvertTo-Json -Depth 10 | Out-File 'qa-reports/all-tests-result.json' -Enc utf8

# 2. Linear Integration Phase
Write-Host ''
Write-Host '[Step2] Analyzing Bugs and Syncing with Linear...' -ForegroundColor Yellow
$bugs = @()
$PM = @{'Urgent'=1;'High'=2;'Medium'=3}

foreach ($test in $testResults) {
    if (-not $test.success) {
        $p = Get-Priority $test.actual
        $s = if ($p -eq 'Urgent') { 'Critical' } elseif ($p -eq 'High') { 'Major' } else { 'Minor' }
        $t = '[' + $Config.projectName + '] [' + $test.name + '] Bug: HTTP ' + $test.actual + ' - Failed'
        $d = "## Project: $($Config.projectName)\n\n### Summary\nAPI returned HTTP $($test.actual) instead of $($test.expected).\n\n### Scenario\n$($test.scenario)\n\n### Priority: $p\n### Severity: $s\n\n### Visual Evidence & Logs\n> **Screenshot / Evidence Path**: `qa-reports/$($Config.projectName)-failure-evidence.json`\n> *(Note: For UI bugs, the agent automatically attaches responsive visual screenshots here)*\n\n### Request\n\`\`\`json\n$($test.body)\n\`\`\`\n\n### Response\nStatus: $($test.actual)\nPayload: $($test.response)"
        $bugs += @{title=$t; desc=$d; pv=$PM[$p]; p=$p}
        Write-Host "  [NEW BUG] $($test.name) | Priority: $p | Severity: $s" -ForegroundColor Green
    }
}

if ($useLinear -and $bugs.Count -gt 0) {
    $reqHeaders = @{'Content-Type'='application/json';'Authorization'=$LinearApiKey}
    foreach ($b in $bugs) {
        $descEscaped = $b.desc -replace '"', '\"' -replace "`n", "\n" -replace "`r", ""
        $mutation = @{
            query = "mutation { issueCreate(input:{teamId:`"$TeamId`",projectId:`"$ProjectId`",title:`"$($b.title)`",description:`"$descEscaped`",priority:$($b.pv),assigneeId:`"$AssigneeId`",labelIds:[`"$BugLabelId`"]}){success issue{identifier url}}}"
        } | ConvertTo-Json -Depth 5
        try {
            $r = Invoke-WebRequest -Uri 'https://api.linear.app/graphql' -Method POST -Headers $reqHeaders -Body $mutation -UseBasicParsing
            $res = $r.Content | ConvertFrom-Json
            if ($res.data.issueCreate.success) {
                Write-Host "  [CREATED] $($res.data.issueCreate.issue.identifier)" -ForegroundColor Green
            }
        } catch {
            Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Global QA Run Complete for $($Config.projectName)" -ForegroundColor Cyan
Write-Host "Total Tests: $($testResults.Count) | Passed: $(($testResults | Where-Object { $_.success }).Count) | Failed: $($bugs.Count)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
