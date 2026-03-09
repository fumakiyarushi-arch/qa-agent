QA Report - 2026-03-09 15.12

============================================

EXECUTIVE SUMMARY

| Metric | Count |
|--------|-------|
| Total API Tests | 44 |
| [+] API Passed | 35 |
| [x] API Failed | 9 |
| [=] UI Bugs Found | 1 |
| [#] Total Bugs Created | 6 |
| [@] Linear Tickets | 6 |

============================================

FEATURE TESTING VIDEO RECORDINGS

- [>] Signup Flow: [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/signup-flow.webm)
- [>] Login Flow: [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/login-flow.webm)
- [>] Forgot Password Flow: [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/forgot-password-flow.webm)
- [>] UI Responsive Flow: [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/ui-responsive-flow.webm)

============================================

API TEST RESULTS

Signup API Tests

| Test Case | Expected | Actual | Status | Visual |
|-----------|----------|--------|--------|--------|
| Signup - Valid | 201 | 400 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Signup_-_Valid.png) |
| Signup - Missing Email | 400 | 400 | [+] PASS | - |
| Signup - Missing Password | 400 | 400 | [+] PASS | - |
| Signup - Invalid Email | 400 | 400 | [+] PASS | - |
| Signup - Weak Password | 400 | 400 | [+] PASS | - |
| Signup - Missing Fullname | 400 | 400 | [+] PASS | - |
| Signup - Duplicate Email | 409 | 400 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Signup_-_Duplicate_Email.png) |
| Signup - Invalid Role | 400 | 400 | [+] PASS | - |
| Signup - Invalid Platform | 400 | 400 | [+] PASS | - |
| Signup - Missing Role | 400 | 400 | [+] PASS | - |
| Signup - Missing Platform | 400 | 400 | [+] PASS | - |
| Signup - Missing Mobile Number | 400 | 400 | [+] PASS | - |
| Signup - Missing Country Code | 400 | 400 | [+] PASS | - |
| Signup - Invalid Country Code | 400 | 400 | [+] PASS | - |
| Signup - Invalid Mobile Number Format | 400 | 400 | [+] PASS | - |
| Signup - Password Too Short | 400 | 400 | [+] PASS | - |
| Signup - Password Too Long | 400 | 400 | [+] PASS | - |
| Signup - Special Characters in Name | 400 | 400 | [+] PASS | - |
| Signup - Empty String Fields | 400 | 400 | [+] PASS | - |
| Signup - Whitespace Only Fields | 400 | 400 | [+] PASS | - |
| Signup - XSS Attempt in Fullname | 400 | 400 | [+] PASS | - |

Login API Tests

| Test Case | Expected | Actual | Status | Visual |
|-----------|----------|--------|--------|--------|
| Login - Valid | 200 | 401 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Valid.png) |
| Login - Invalid Email | 401 | 401 | [+] PASS | - |
| Login - Invalid Password | 401 | 401 | [+] PASS | - |
| Login - Missing Email | 400 | 400 | [+] PASS | - |
| Login - Missing Password | 400 | 400 | [+] PASS | - |
| Login - Empty Body | 400 | 400 | [+] PASS | - |
| Login - Email Case Sensitivity | 200 | 401 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Email_Case_Sensitivity.png) |
| Login - Password Case Sensitivity | 401 | 401 | [+] PASS | - |
| Login - Extra Fields | 200 | 401 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Extra_Fields.png) |
| Login - Whitespace in Email | 400 | 400 | [+] PASS | - |
| Login - Whitespace in Password | 401 | 401 | [+] PASS | - |
| Login - Very Long Email | 400 | 400 | [+] PASS | - |
| Login - Very Long Password | 400 | 401 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Very_Long_Password.png) |
| Login - Multiple Failed Attempts | 429 | 401 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Multiple_Failed_Attempts.png) |

Forgot Password API Tests

| Test Case | Expected | Actual | Status | Visual |
|-----------|----------|--------|--------|--------|
| Forgot Password - Valid Email | 200 | 400 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.png) |
| Forgot Password - Invalid Email | 404 | 400 | [x] FAIL | [@ Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.png) |
| Forgot Password - Missing Email | 400 | 400 | [+] PASS | - |
| Forgot Password - Invalid Email Format | 400 | 400 | [+] PASS | - |
| Forgot Password - Empty Email | 400 | 400 | [+] PASS | - |
| Forgot Password - Very Long Email | 400 | 400 | [+] PASS | - |
| Forgot Password - Email with Whitespace | 400 | 400 | [+] PASS | - |
| Forgot Password - Email with Leading Spaces | 400 | 400 | [+] PASS | - |
| Forgot Password - Email with Trailing Spaces | 400 | 400 | [+] PASS | - |

============================================

FAILED API TESTS - DETAILED VIEW

[x] Signup - Valid

| Property | Value |
|----------|-------|
| Scenario | Valid signup request |
| Expected Status | 201 |
| Actual Status | 400 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/signup |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Signup_-_Valid.png) |

Request Body:
```json
{
    "role":  "individual",
    "platform":  "web",
    "fullname":  "Virat Kohli",
    "email":  "virat_india@yopmail.com",
    "password":  "Test@123",
    "mobile_number":  "2025550001",
    "country_code":  "+1"
}
```

Response Body:
```json
The remote server returned an error: (400) Bad Request.
```

[x] Signup - Duplicate Email

| Property | Value |
|----------|-------|
| Scenario | Email already exists |
| Expected Status | 409 |
| Actual Status | 400 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/signup |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Signup_-_Duplicate_Email.png) |

Request Body:
```json
{
    "role":  "individual",
    "platform":  "web",
    "fullname":  "Virat Kohli",
    "email":  "virat_india@yopmail.com",
    "password":  "Test@123",
    "mobile_number":  "2025550099",
    "country_code":  "+1"
}
```

Response Body:
```json
The remote server returned an error: (400) Bad Request.
```

[x] Login - Valid

| Property | Value |
|----------|-------|
| Scenario | Valid login request |
| Expected Status | 200 |
| Actual Status | 401 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/login |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Valid.png) |

Request Body:
```json
{
    "email":  "virat_india@yopmail.com",
    "password":  "Test@123",
    "role":  "individual"
}
```

Response Body:
```json
The remote server returned an error: (401) Unauthorized.
```

[x] Login - Email Case Sensitivity

| Property | Value |
|----------|-------|
| Scenario | Email case sensitivity check |
| Expected Status | 200 |
| Actual Status | 401 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/login |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Email_Case_Sensitivity.png) |

Request Body:
```json
{
    "email":  "VIRAT_INDIA@yopmail.com",
    "password":  "Test@123",
    "role":  "individual"
}
```

Response Body:
```json
The remote server returned an error: (401) Unauthorized.
```

[x] Login - Extra Fields

| Property | Value |
|----------|-------|
| Scenario | Extra fields should be ignored |
| Expected Status | 200 |
| Actual Status | 401 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/login |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Extra_Fields.png) |

Request Body:
```json
{
    "email":  "virat_india@yopmail.com",
    "password":  "Test@123",
    "role":  "individual",
    "extra_field":  "should_be_ignored",
    "another_field":  123
}
```

Response Body:
```json
The remote server returned an error: (401) Unauthorized.
```

[x] Login - Very Long Password

| Property | Value |
|----------|-------|
| Scenario | Password exceeds reasonable length |
| Expected Status | 400 |
| Actual Status | 401 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/login |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Very_Long_Password.png) |

Request Body:
```json
{
    "email":  "virat_india@yopmail.com",
    "password":  "VeryLongPasswordThatExceedsTheMaximumExpectedLength123456789012345678901234567890",
    "role":  "individual"
}
```

Response Body:
```json
The remote server returned an error: (401) Unauthorized.
```

[x] Login - Multiple Failed Attempts

| Property | Value |
|----------|-------|
| Scenario | Rate limiting after multiple attempts |
| Expected Status | 429 |
| Actual Status | 401 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/login |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Multiple_Failed_Attempts.png) |

Request Body:
```json
{
    "email":  "virat_india@yopmail.com",
    "password":  "WrongPass1",
    "role":  "individual"
}
```

Response Body:
```json
The remote server returned an error: (401) Unauthorized.
```

[x] Forgot Password - Valid Email

| Property | Value |
|----------|-------|
| Scenario | Valid email for password reset |
| Expected Status | 200 |
| Actual Status | 400 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/forgot-password |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.png) |

Request Body:
```json
{
    "email":  "virat_india@yopmail.com"
}
```

Response Body:
```json
The remote server returned an error: (400) Bad Request.
```

[x] Forgot Password - Invalid Email

| Property | Value |
|----------|-------|
| Scenario | Non-existent email |
| Expected Status | 404 |
| Actual Status | 400 |
| URL | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/forgot-password |
| Visual Error Page | [@ View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.png) |

Request Body:
```json
{
    "email":  "notexists@yopmail.com"
}
```

Response Body:
```json
The remote server returned an error: (400) Bad Request.
```


============================================

UI TEST RESULTS (PLAYWRIGHT)

| Flow | UI Bugs Found |
|------|--------------|
| Signup Flow | 0 |
| Login Flow | 1 |
| Forgot Password Flow | 0 |
| UI Responsive Flow | 0 |
| Total UI Bugs | 1 |

UI Bug Details

[x] [Login] No error message shown for invalid credentials

Description: Logging in with wrong email/password shows no error feedback.

Steps to Reproduce:
```
1. Go to /login
2. Enter wrong email and password
3. Submit
4. No error shown
```
Screenshot: [@ View](file:///D:/qa-agentic-flow/qa-reports/screenshots/login-invalid-creds-1773049209117.png)


============================================

BUGS CREATED IN LINEAR

[QA-147](https://linear.app/swiss-qa-workspace/issue/QA-147/apisignup-duplicate-email-bug-http-400-returned-expected-409) - API

| Field | Value |
|-------|-------|
| Title | [API][Signup - Duplicate Email] Bug: HTTP 400 returned (expected 409) |
| Priority | High |
| Type | API |
| Screenshot | [@ View](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Signup_-_Duplicate_Email.png) |

[QA-148](https://linear.app/swiss-qa-workspace/issue/QA-148/apilogin-email-case-sensitivity-bug-http-401-returned-expected-200) - API

| Field | Value |
|-------|-------|
| Title | [API][Login - Email Case Sensitivity] Bug: HTTP 401 returned (expected 200) |
| Priority | High |
| Type | API |
| Screenshot | [@ View](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Email_Case_Sensitivity.png) |

[QA-149](https://linear.app/swiss-qa-workspace/issue/QA-149/apilogin-extra-fields-bug-http-401-returned-expected-200) - API

| Field | Value |
|-------|-------|
| Title | [API][Login - Extra Fields] Bug: HTTP 401 returned (expected 200) |
| Priority | High |
| Type | API |
| Screenshot | [@ View](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Extra_Fields.png) |

[QA-150](https://linear.app/swiss-qa-workspace/issue/QA-150/apilogin-very-long-password-bug-http-401-returned-expected-400) - API

| Field | Value |
|-------|-------|
| Title | [API][Login - Very Long Password] Bug: HTTP 401 returned (expected 400) |
| Priority | High |
| Type | API |
| Screenshot | [@ View](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Very_Long_Password.png) |

[QA-151](https://linear.app/swiss-qa-workspace/issue/QA-151/apilogin-multiple-failed-attempts-bug-http-401-returned-expected-429) - API

| Field | Value |
|-------|-------|
| Title | [API][Login - Multiple Failed Attempts] Bug: HTTP 401 returned (expected 429) |
| Priority | High |
| Type | API |
| Screenshot | [@ View](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Multiple_Failed_Attempts.png) |

[QA-152](https://linear.app/swiss-qa-workspace/issue/QA-152/login-no-error-message-shown-for-invalid-credentials) - UI

| Field | Value |
|-------|-------|
| Title | [Login] No error message shown for invalid credentials |
| Priority | High |
| Type | UI |
| Screenshot | [@ View](file:///D:/qa-agentic-flow/qa-reports/screenshots/login-invalid-creds-1773049209117.png) |


============================================

GENERATED ARTIFACTS

| Directory | Description |
|-----------|-------------|
| qa-reports/screenshots/ | UI screenshots from Playwright |
| qa-reports/api-screenshots/ | API error visual pages (PNG/HTML) |
| qa-reports/videos/ | Video recordings of UI flows |
| qa-reports/all-tests-result.json | Complete test results JSON |

============================================

Generated by QA Agentic Flow on 2026-03-09 15.12
