---
description: Start the automated Seal My Idea QA Agentic Flow with Linear Integration
---

// turbo-all

# Complete QA Agentic Flow with Linear Integration

This workflow executes the 4 native agents in a single run sequence via PowerShell and the AI agent itself, with automatic bug creation in Linear.

## Prerequisites

Before running this workflow, configure your Linear credentials:

1. Create a `.env.linear` file with:
   - `LINEAR_API_KEY`: Your Linear API key (get from Linear Settings > API)
   - `LINEAR_TEAM_ID`: Your Linear team ID (e.g., from URL or API)
   - `LINEAR_PROJECT_ID`: Your Linear project ID

## Workflow Steps

### Step 1: Test Case & Execution Agents

Create reports directory and execute API tests:

```powershell
New-Item -ItemType Directory -Force -Path qa-reports

$Headers = @{
    "Content-Type" = "application/json"
    "api_type" = "web"
    "platform" = "web"
}

$SignupBody = '{"role":"individual", "platform":"web", "fullname":"Virat Kohli", "email":"virat_india@yopmail.com", "password":"Test@123", "mobile_number":"2025550001", "country_code":"+1"}'
$LoginBody = '{"email":"virat_india@yopmail.com", "password":"Test@123", "role":"individual"}'

Write-Host "[Execution Agent] Running Sign Up Test..."
try {
    $response = Invoke-WebRequest -Uri "https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/signup" -Method POST -Headers $Headers -Body $SignupBody -UseBasicParsing
    $result = @{
        status = $response.StatusCode
        body   = ($response.Content | ConvertFrom-Json)
    }
    $result | ConvertTo-Json -Depth 10 | Out-File -FilePath "qa-reports/signup-result.json" -Encoding utf8
} catch {
    @{
        status = [int]$_.Exception.Response.StatusCode
        body   = $_.Exception.Message
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath "qa-reports/signup-result.json" -Encoding utf8
}

Write-Host "[Execution Agent] Running Login Test..."
try {
    $response = Invoke-WebRequest -Uri "https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/login" -Method POST -Headers $Headers -Body $LoginBody -UseBasicParsing
    $result = @{
        status = $response.StatusCode
        body   = ($response.Content | ConvertFrom-Json)
    }
    $result | ConvertTo-Json -Depth 10 | Out-File -FilePath "qa-reports/login-result.json" -Encoding utf8
} catch {
    @{
        status = [int]$_.Exception.Response.StatusCode
        body   = $_.Exception.Message
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath "qa-reports/login-result.json" -Encoding utf8
}
```

### Step 2: Result Analyzer Agent

Read and analyze the test results:

```powershell
$signupResult = Get-Content "qa-reports/signup-result.json" | ConvertFrom-Json
$loginResult = Get-Content "qa-reports/login-result.json" | ConvertFrom-Json
```

### Step 3: Create Bugs in Linear (Automatic)

For each failed test, create an issue in Linear:

```powershell
$envVars = @{}
Get-Content ".env.linear" | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        $envVars[$matches[1]] = $matches[2]
    }
}

$LinearApiKey = $envVars['LINEAR_API_KEY']
$TeamId = $envVars['LINEAR_TEAM_ID']
$ProjectId = $envVars['LINEAR_PROJECT_ID']

if ($signupResult.status -ne 200 -and $signupResult.status -ne 201) {
    $title = "[Signup API] Bug: HTTP $($signupResult.status) - Bad Request"
    $description = "## Bug Report - Sign Up API

**Severity:** High
**Status Code:** $($signupResult.status)

### Request
\`\`\`json
$SignupBody
\`\`\`

### Response
$($signupResult.body)

### Steps to Reproduce
1. Send POST request to `/seal-my-idea/v1/auth/signup`
2. Observe HTTP $($signupResult.status) response

### Expected Result
- HTTP 201 Created on successful signup

### Actual Result
- HTTP $($signupResult.status) returned

---
*Created automatically by QA Agentic Flow*"

    & "scripts/create-linear-bug.ps1" -LinearApiKey $LinearApiKey -TeamId $TeamId -ProjectId $ProjectId -Title $title -Description $description -Priority "High"
}

if ($loginResult.status -ne 200) {
    $title = "[Login API] Bug: HTTP $($loginResult.status) - Unauthorized"
    $description = "## Bug Report - Login API

**Severity:** High
**Status Code:** $($loginResult.status)

### Request
\`\`\`json
$LoginBody
\`\`\`

### Response
$($loginResult.body)

### Steps to Reproduce
1. Send POST request to `/seal-my-idea/v1/auth/login`
2. Observe HTTP $($loginResult.status) response

### Expected Result
- HTTP 200 OK on successful login

### Actual Result
- HTTP $($loginResult.status) returned

---
*Created automatically by QA Agentic Flow*"

    & "scripts/create-linear-bug.ps1" -LinearApiKey $LinearApiKey -TeamId $TeamId -ProjectId $ProjectId -Title $title -Description $description -Priority "High"
}
```

### Step 5: UI Flow Testing (Separate & Fast)

The agent performs **4 separate High-Speed UI recordings** for each core feature. **Social Login/Signup must be EXCLUDED.**

1. **Signup Flow Audit Recording**
   - URL: `https://staging.swisstrustlayer.com/signup`
   - Capture: Negative (Empty, Weak PW, Invalid Email) + Positive entry.
   - Recording Name: `signup_fast_pos_neg_{TIMESTAMP}`

2. **Login Flow Audit Recording**
   - URL: `https://staging.swisstrustlayer.com/login`
   - Capture: Negative (Invalid Credentials, Missing PW) + Positive entry.
   - Recording Name: `login_fast_pos_neg_{TIMESTAMP}`

3. **Forgot Password Flow Audit Recording**
   - URL: `https://staging.swisstrustlayer.com/forgot-password`
   - Capture: Negative (Invalid format, non-existent user) + Positive entry.
   - Recording Name: `forgot_password_fast_pos_neg_{TIMESTAMP}`

4. **UI Responsive Audit Recording**
   - URL: `https://staging.swisstrustlayer.com/` (Navigating to all 4 pages at 375px wide)
   - Capture: Layout stacking and header behavior on mobile.
   - Recording Name: `responsive_fast_check_{TIMESTAMP}`

### Step 6: Generate Multi-Feature QA-Report.md

The Result Analyzer Agent updates `QA-Report.md` using the new `qa-report-template.md`. Each section will have its own dedicated video path.

---

## 🎥 Video Speed Requirement
To ensure production-level speed:
- Use direct navigate/type/click without delays.
- Do not perform any social login interactions.
- Recording should only capture the manual interaction flow.

---

## Final Goal

The agent will deliver a report with **4 dedicated videos**:
1. **Manual Signup Flow Audit**
2. **Manual Login Flow Audit**
3. **Manual Forgot Password Flow Audit**
4. **UI Response Flow Audit (All Pages)**

---

## 🐞 Linear Integration
For every failure (API or UI), a high-priority bug is created in Linear with:
- Summary of the expected vs actual data.
- **Concrete Proof**: An exact screenshot of the error state (404, 400, validation overlay) automatically captured and directly embedded in the ticket comments.
- The specific JSON Request/Response payload.
- Direct link to the issue in the final report.

---

## Priority Mapping

| Severity | Linear Priority |
|----------|-----------------|
| Critical | Urgent (1) |
| High     | High (2) |
| Medium   | Medium (3) |
| Low      | Low (4) |

---

## Usage

1. Configure `.env.linear` with your Linear credentials
2. Run the workflow:
   ```powershell
   powershell -File scripts/run-qa-with-linear.ps1
   ```

Or run the combined PowerShell script directly.
