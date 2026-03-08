$baseUrl = "https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth"
$headers = @{
    "Content-Type" = "application/json"
    "api_type" = "web"
    "platform" = "web"
}

$results = @()

function Test-API {
    param(
        [string]$name,
        [string]$endpoint,
        [string]$bodyJson,
        [int]$expectedStatus
    )
    
    $url = "$baseUrl$endpoint"
    $body = $bodyJson
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ErrorAction SilentlyContinue
        $actualStatus = 200
        $responseBody = $response | ConvertTo-Json -Depth 10
    }
    catch {
        $actualStatus = [int]$_.Exception.Response.StatusCode
        if ($actualStatus -eq 0) {
            $actualStatus = 400
            if ($_.Exception.Message -match "404") { $actualStatus = 404 }
            if ($_.Exception.Message -match "401") { $actualStatus = 401 }
        }
        $responseBody = $_.Exception.Message
    }
    
    $success = ($actualStatus -eq $expectedStatus)
    
    return @{
        name = $name
        url = $url
        body = $bodyJson
        expected_status = $expectedStatus
        actual_status = $actualStatus
        response_body = $responseBody
        success = $success
    }
}

$results += Test-API -name "Signup - Valid signup" -endpoint "/signup" -bodyJson '{"role":"individual","platform":"web","fullname":"Virat Kohli","email":"virat_india@yopmail.com","password":"Test@123","mobile_number":"2025550001","country_code":"+1"}' -expectedStatus 201

$results += Test-API -name "Signup - Missing Email" -endpoint "/signup" -bodyJson '{"role":"individual","platform":"web","fullname":"Test User","password":"Test@123","mobile_number":"2025550002","country_code":"+1"}' -expectedStatus 400

$results += Test-API -name "Signup - Missing Password" -endpoint "/signup" -bodyJson '{"role":"individual","platform":"web","fullname":"Test User","email":"test2@yopmail.com","mobile_number":"2025550002","country_code":"+1"}' -expectedStatus 400

$results += Test-API -name "Signup - Invalid Email" -endpoint "/signup" -bodyJson '{"role":"individual","platform":"web","fullname":"Test User","email":"invalid-email","password":"Test@123","mobile_number":"2025550003","country_code":"+1"}' -expectedStatus 400

$results += Test-API -name "Signup - Weak Password" -endpoint "/signup" -bodyJson '{"role":"individual","platform":"web","fullname":"Test User","email":"test3@yopmail.com","password":"123","mobile_number":"2025550004","country_code":"+1"}' -expectedStatus 400

$results += Test-API -name "Signup - Missing Fullname" -endpoint "/signup" -bodyJson '{"role":"individual","platform":"web","email":"test4@yopmail.com","password":"Test@123","mobile_number":"2025550005","country_code":"+1"}' -expectedStatus 400

$results += Test-API -name "Login - Valid login" -endpoint "/login" -bodyJson '{"email":"virat_india@yopmail.com","password":"Test@123","role":"individual"}' -expectedStatus 200

$results += Test-API -name "Login - Invalid Email" -endpoint "/login" -bodyJson '{"email":"notfound@yopmail.com","password":"Test@123","role":"individual"}' -expectedStatus 401

$results += Test-API -name "Login - Invalid Password" -endpoint "/login" -bodyJson '{"email":"virat_india@yopmail.com","password":"WrongPass123","role":"individual"}' -expectedStatus 401

$results += Test-API -name "Login - Missing Email" -endpoint "/login" -bodyJson '{"password":"Test@123","role":"individual"}' -expectedStatus 400

$results += Test-API -name "Login - Missing Password" -endpoint "/login" -bodyJson '{"email":"virat_india@yopmail.com","role":"individual"}' -expectedStatus 400

$results += Test-API -name "Login - Empty Body" -endpoint "/login" -bodyJson '{}' -expectedStatus 400

$results += Test-API -name "Forgot Password - Valid Email" -endpoint "/forgot-password" -bodyJson '{"email":"virat_india@yopmail.com"}' -expectedStatus 200

$results += Test-API -name "Forgot Password - Invalid Email" -endpoint "/forgot-password" -bodyJson '{"email":"notexists@yopmail.com"}' -expectedStatus 404

$results += Test-API -name "Forgot Password - Missing Email" -endpoint "/forgot-password" -bodyJson '{}' -expectedStatus 400

$results += Test-API -name "Forgot Password - Invalid Email Format" -endpoint "/forgot-password" -bodyJson '{"email":"invalid-email"}' -expectedStatus 400

$results += Test-API -name "Forgot Password - Empty Email" -endpoint "/forgot-password" -bodyJson '{"email":""}' -expectedStatus 400

$output = @{
    test_run_date = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    total_tests = $results.Count
    passed = ($results | Where-Object { $_.success -eq $true }).Count
    failed = ($results | Where-Object { $_.success -eq $false }).Count
    results = $results
}

$outputPath = "qa-reports/all-api-tests-result.json"
$output | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "Test Results Summary:" -ForegroundColor Cyan
Write-Host "Total Tests: $($output.total_tests)" -ForegroundColor White
Write-Host "Passed: $($output.passed)" -ForegroundColor Green
Write-Host "Failed: $($output.failed)" -ForegroundColor Red
Write-Host "Results saved to: $outputPath" -ForegroundColor Cyan
