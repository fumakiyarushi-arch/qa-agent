# QA Report - 2026-03-06

## Summary
- **Total Tests:** 17
- **Passed:** 13
- **Failed:** 0
- **New Bugs:** 0
- **Existing Bugs:** 4

## Test Results
| Test | Expected | Actual | Status |
|------|----------|--------|--------|
| Signup - Valid | 201 | 400 | FAIL |`n| Signup - Missing Email | 400 | 400 | PASS |`n| Signup - Missing Password | 400 | 400 | PASS |`n| Signup - Invalid Email | 400 | 400 | PASS |`n| Signup - Weak Password | 400 | 400 | PASS |`n| Signup - Missing Fullname | 400 | 400 | PASS |`n| Login - Valid | 200 | 401 | FAIL |`n| Login - Invalid Email | 401 | 401 | PASS |`n| Login - Invalid Password | 401 | 401 | PASS |`n| Login - Missing Email | 400 | 400 | PASS |`n| Login - Missing Password | 400 | 400 | PASS |`n| Login - Empty Body | 400 | 400 | PASS |`n| Forgot Password - Valid Email | 200 | 400 | FAIL |`n| Forgot Password - Invalid Email | 404 | 400 | FAIL |`n| Forgot Password - Missing Email | 400 | 400 | PASS |`n| Forgot Password - Invalid Email Format | 400 | 400 | PASS |`n| Forgot Password - Empty Email | 400 | 400 | PASS |`n
## Bugs Created: 0

