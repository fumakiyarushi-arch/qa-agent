# QA Report - 2026-03-08

## Summary
- **Total Tests:** 17
- **Passed:** 13
- **Failed:** 0
- **New Bugs:** 4
- **Existing Bugs:** 0

## Test Results
| Test | Expected | Actual | Status |
|------|----------|--------|--------|
| Signup - Valid | 201 | 400 | FAIL |`n| Signup - Missing Email | 400 | 400 | PASS |`n| Signup - Missing Password | 400 | 400 | PASS |`n| Signup - Invalid Email | 400 | 400 | PASS |`n| Signup - Weak Password | 400 | 400 | PASS |`n| Signup - Missing Fullname | 400 | 400 | PASS |`n| Login - Valid | 200 | 401 | FAIL |`n| Login - Invalid Email | 401 | 401 | PASS |`n| Login - Invalid Password | 401 | 401 | PASS |`n| Login - Missing Email | 400 | 400 | PASS |`n| Login - Missing Password | 400 | 400 | PASS |`n| Login - Empty Body | 400 | 400 | PASS |`n| Forgot Password - Valid Email | 200 | 400 | FAIL |`n| Forgot Password - Invalid Email | 404 | 400 | FAIL |`n| Forgot Password - Missing Email | 400 | 400 | PASS |`n| Forgot Password - Invalid Email Format | 400 | 400 | PASS |`n| Forgot Password - Empty Email | 400 | 400 | PASS |`n
## Bugs Created: 4
### [Signup - Valid] Bug: HTTP 400 - Failed
- **Priority:** High
- **Description:** ## Bug Report - Signup - Valid

### Summary
The API endpoint is returning HTTP 400 instead of expected HTTP 201.

### Reason
Valid signup request

### Request
`json
{"role":"individual","platform":"web","fullname":"Virat Kohli","email":"virat_india@yopmail.com","password":"Test@123","mobile_number":"2025550001","country_code":"+1"}
`

### Response
HTTP Status: 400
Response: The remote server returned an error: (400) Bad Request.

### Developer Prompt - Fix This Bug
Please investigate and fix the API endpoint at $(System.Collections.Hashtable.url). The endpoint should return HTTP 201 for this scenario: Valid signup request.

Check for:
1. Input validation
2. Error handling
3. Required fields validation
4. API request/response format

### Priority: High
### Severity: Major

[QA-124](https://linear.app/swiss-qa-workspace/issue/QA-124/signup-valid-bug-http-400-failed)

### [Login - Valid] Bug: HTTP 401 - Failed
- **Priority:** High
- **Description:** ## Bug Report - Login - Valid

### Summary
The API endpoint is returning HTTP 401 instead of expected HTTP 200.

### Reason
Valid login request

### Request
`json
{"email":"virat_india@yopmail.com","password":"Test@123","role":"individual"}
`

### Response
HTTP Status: 401
Response: The remote server returned an error: (401) Unauthorized.

### Developer Prompt - Fix This Bug
Please investigate and fix the API endpoint at $(System.Collections.Hashtable.url). The endpoint should return HTTP 200 for this scenario: Valid login request.

Check for:
1. Input validation
2. Error handling
3. Required fields validation
4. API request/response format

### Priority: High
### Severity: Major

[QA-125](https://linear.app/swiss-qa-workspace/issue/QA-125/login-valid-bug-http-401-failed)

### [Forgot Password - Valid Email] Bug: HTTP 400 - Failed
- **Priority:** High
- **Description:** ## Bug Report - Forgot Password - Valid Email

### Summary
The API endpoint is returning HTTP 400 instead of expected HTTP 200.

### Reason
Valid email for password reset

### Request
`json
{"email":"virat_india@yopmail.com"}
`

### Response
HTTP Status: 400
Response: The remote server returned an error: (400) Bad Request.

### Developer Prompt - Fix This Bug
Please investigate and fix the API endpoint at $(System.Collections.Hashtable.url). The endpoint should return HTTP 200 for this scenario: Valid email for password reset.

Check for:
1. Input validation
2. Error handling
3. Required fields validation
4. API request/response format

### Priority: High
### Severity: Major

[QA-126](https://linear.app/swiss-qa-workspace/issue/QA-126/forgot-password-valid-email-bug-http-400-failed)

### [Forgot Password - Invalid Email] Bug: HTTP 400 - Failed
- **Priority:** High
- **Description:** ## Bug Report - Forgot Password - Invalid Email

### Summary
The API endpoint is returning HTTP 400 instead of expected HTTP 404.

### Reason
Non-existent email

### Request
`json
{"email":"notexists@yopmail.com"}
`

### Response
HTTP Status: 400
Response: The remote server returned an error: (400) Bad Request.

### Developer Prompt - Fix This Bug
Please investigate and fix the API endpoint at $(System.Collections.Hashtable.url). The endpoint should return HTTP 404 for this scenario: Non-existent email.

Check for:
1. Input validation
2. Error handling
3. Required fields validation
4. API request/response format

### Priority: High
### Severity: Major

[QA-127](https://linear.app/swiss-qa-workspace/issue/QA-127/forgot-password-invalid-email-bug-http-400-failed)


