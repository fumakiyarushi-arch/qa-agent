$envFile = Join-Path $PSScriptRoot "..\.env.linear"
$envContent = Get-Content $envFile -Raw

if ($envContent -match 'LINEAR_API_KEY=(.+)') { $apiKey = $matches[1] } else { $apiKey = $null }
if ($envContent -match 'LINEAR_TEAM_ID=(.+)') { $teamId = $matches[1] } else { $teamId = $null }

if (-not $apiKey) {
    Write-Host "Error: LINEAR_API_KEY not found in .env.linear"
    exit 1
}

$Headers = @{
    'Content-Type' = 'application/json'
    'Authorization' = $apiKey
}
$QueryUrl = 'https://api.linear.app/graphql'

$bugs = @{
    "QA-138" = "qa-reports\api-screenshots\Signup_-_Valid_signup.png"
    "QA-139" = "qa-reports\api-screenshots\Login_-_Valid_login.png"
    "QA-140" = "qa-reports\api-screenshots\Forgot_Password_-_Valid_Email.png"
    "QA-141" = "qa-reports\api-screenshots\Forgot_Password_-_Invalid_Email.png"
    "QA-142" = "qa-reports\screenshots\login-invalid-creds-1772967842881.png"
}

$Query = @{
    query = "query { issues(first: 50, filter: { team: { id: { eq: `"$teamId`" } } }) { nodes { id identifier } } }"
}
$res = Invoke-RestMethod -Uri $QueryUrl -Method Post -Headers $Headers -Body ($Query | ConvertTo-Json -Depth 5)

$issueMap = @{}
foreach ($node in $res.data.issues.nodes) {
    if ($node.identifier) {
        $issueMap[$node.identifier] = $node.id
    }
}

Write-Host "Attached screenshots to Linear issues:"
Write-Host "========================================"

foreach ($key in $bugs.Keys) {
    $issueId = $issueMap[$key]
    if ($issueId) {
        $filePath = $bugs[$key]
        $fullPath = Join-Path (Split-Path $PSScriptRoot -Parent) $filePath
        
        if (-not (Test-Path $fullPath)) {
            Write-Host "$key : FAILED (file not found: $fullPath)"
            continue
        }
        
        Write-Host "Processing $key ($issueId)"
        
        try {
            Write-Host "  Uploading to 0x0.st..."
            $uploadUrl = (curl.exe -s -F "file=@$fullPath" https://0x0.st).Trim()
            Write-Host "  Uploaded to: $uploadUrl"
            
            $commentBody = "Screenshot attached: ![]($uploadUrl)"
            
            $commentMutation = @{
                query = "mutation { commentCreate(input: { issueId: `"$issueId`", body: `"$commentBody`" }) { success } }"
            }
            
            $commentResponse = Invoke-RestMethod -Uri $QueryUrl -Method Post -Headers $Headers -Body ($commentMutation | ConvertTo-Json -Depth 5)
            
            if ($commentResponse.data.commentCreate.success) {
                Write-Host "  $key : SUCCESS"
            } else {
                Write-Host "  $key : FAILED (comment creation)"
            }
            
        } catch {
            Write-Host "  $key : FAILED ($($_.Exception.Message))"
        }
    } else {
        Write-Host "  $key : FAILED (issue not found)"
    }
}

Write-Host "========================================"
Write-Host "Done!"
