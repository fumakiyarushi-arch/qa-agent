# QA Report - 2026-03-09 09.41

---

## 📊 Executive Summary

| Metric | Count |
|--------|-------|
| Total API Tests | 17 |
| ✅ API Passed | 13 |
| ❌ API Failed | 4 |
| 🖥️ UI Bugs Found | 1 |
| 🐛 Total Bugs Created | 5 |
| 📝 Linear Tickets | 0 |

---

## 🎥 Feature Testing Video Recordings

- 🎥 **Signup Flow:** [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/signup-flow.webm)
- 🎥 **Login Flow:** [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/login-flow.webm)
- 🎥 **Forgot Password Flow:** [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/forgot-password-flow.webm)
- 🎥 **UI Responsive Flow:** [Watch Recording](file:///D:/qa-agentic-flow/qa-reports/videos/ui-responsive-flow.webm)

---

## 🧪 API Test Results

### Signup API Tests

| Test Case | Expected | Actual | Status | Visual |
|-----------|----------|--------|--------|--------|
| Signup - Valid | 201 | 400 | ❌ FAIL | [📷 Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Signup_-_Valid.png) |
| Signup - Missing Email | 400 | 400 | ✅ PASS | — |
| Signup - Missing Password | 400 | 400 | ✅ PASS | — |
| Signup - Invalid Email | 400 | 400 | ✅ PASS | — |
| Signup - Weak Password | 400 | 400 | ✅ PASS | — |
| Signup - Missing Fullname | 400 | 400 | ✅ PASS | — |

### Login API Tests

| Test Case | Expected | Actual | Status | Visual |
|-----------|----------|--------|--------|--------|
| Login - Valid | 200 | 401 | ❌ FAIL | [📷 Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Valid.png) |
| Login - Invalid Email | 401 | 401 | ✅ PASS | — |
| Login - Invalid Password | 401 | 401 | ✅ PASS | — |
| Login - Missing Email | 400 | 400 | ✅ PASS | — |
| Login - Missing Password | 400 | 400 | ✅ PASS | — |
| Login - Empty Body | 400 | 400 | ✅ PASS | — |

### Forgot Password API Tests

| Test Case | Expected | Actual | Status | Visual |
|-----------|----------|--------|--------|--------|
| Forgot Password - Valid Email | 200 | 400 | ❌ FAIL | [📷 Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.png) |
| Forgot Password - Invalid Email | 404 | 400 | ❌ FAIL | [📷 Error](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.png) |
| Forgot Password - Missing Email | 400 | 400 | ✅ PASS | — |
| Forgot Password - Invalid Email Format | 400 | 400 | ✅ PASS | — |
| Forgot Password - Empty Email | 400 | 400 | ✅ PASS | — |

---

## 🔴 Failed API Tests - Detailed View

### ❌ Signup - Valid

| Property | Value |
|----------|-------|
| **Scenario** | Valid signup request |
| **Expected Status** | 201 |
| **Actual Status** | 400 |
| **URL** | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/signup |
| **Visual Error Page** | [📷 View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Signup_-_Valid.png) |

**Request Body:**
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

**Response Body:**
```json
The remote server returned an error: (400) Bad Request.
```

### ❌ Login - Valid

| Property | Value |
|----------|-------|
| **Scenario** | Valid login request |
| **Expected Status** | 200 |
| **Actual Status** | 401 |
| **URL** | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/login |
| **Visual Error Page** | [📷 View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Login_-_Valid.png) |

**Request Body:**
```json
{
    "email":  "virat_india@yopmail.com",
    "password":  "Test@123",
    "role":  "individual"
}
```

**Response Body:**
```json
The remote server returned an error: (401) Unauthorized.
```

### ❌ Forgot Password - Valid Email

| Property | Value |
|----------|-------|
| **Scenario** | Valid email for password reset |
| **Expected Status** | 200 |
| **Actual Status** | 400 |
| **URL** | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/forgot-password |
| **Visual Error Page** | [📷 View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.png) |

**Request Body:**
```json
{
    "email":  "virat_india@yopmail.com"
}
```

**Response Body:**
```json
The remote server returned an error: (400) Bad Request.
```

### ❌ Forgot Password - Invalid Email

| Property | Value |
|----------|-------|
| **Scenario** | Non-existent email |
| **Expected Status** | 404 |
| **Actual Status** | 400 |
| **URL** | https://api-stage.swisstrustlayer.com/seal-my-idea/v1/auth/forgot-password |
| **Visual Error Page** | [📷 View Screenshot](file:///D:/qa-agentic-flow/qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.png) |

**Request Body:**
```json
{
    "email":  "notexists@yopmail.com"
}
```

**Response Body:**
```json
The remote server returned an error: (400) Bad Request.
```


---

## 🖥️ UI Test Results (Playwright)

| Flow | UI Bugs Found |
|------|--------------|
| Signup Flow | 0 |
| Login Flow | 1 |
| Forgot Password Flow | 0 |
| UI Responsive Flow | 0 |
| **Total UI Bugs** | **1** |

### UI Bug Details

#### ❌ [Login] No error message shown for invalid credentials

**Description:** Logging in with wrong email/password shows no error feedback.

**Steps to Reproduce:**
```
1. Go to /login
2. Enter wrong email and password
3. Submit
4. No error shown
```
**Screenshot:** [📷 View](file:///D:/qa-agentic-flow/qa-reports/screenshots/login-invalid-creds-1773029404945.png)

---

## 📁 Generated Artifacts

| Directory | Description |
|-----------|-------------|
| `qa-reports/screenshots/` | UI screenshots from Playwright |
| `qa-reports/api-screenshots/` | API error visual pages (PNG/HTML) |
| `qa-reports/videos/` | Video recordings of UI flows |
| `qa-reports/all-tests-result.json` | Complete test results JSON |

---

*Generated by QA Agentic Flow on 2026-03-09 09.41*
