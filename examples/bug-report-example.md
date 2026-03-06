# Bug Report Example

## Bug Title

Login API returns Internal Server Error for valid credentials

---

## Description

When a valid email and password are sent to the login API endpoint, the system returns a 500 Internal Server Error instead of a successful login response.

---

## Steps to Reproduce

1. Send a POST request to the /login endpoint.
2. Provide a valid email and password.
3. Execute the API request.

---

## Test Data

{
"email": "virat@yopmail.com",
"password": "123456"
}

---

## Expected Result

The API should return a successful response with a status code of 200 and an authentication token.

---

## Actual Result

The API returns a status code of 500 with the message "Internal Server Error".

---

## Severity

High

---

## Impact

Users are unable to log into the system due to the server error.
