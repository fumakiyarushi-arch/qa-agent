# API Input Example

## Overview

This example demonstrates how an API input is provided to the QA Agentic Flow System.

The system uses this input to generate test cases and perform automated testing.

---

## API Endpoint

POST /login

---

## Request Parameters

| Parameter | Type   | Description        |
| --------- | ------ | ------------------ |
| email     | String | User email address |
| password  | String | User password      |

---

## Example Request

{
"email": "[user@example.com](mailto:user@example.com)",
"password": "123456"
}

---

## Expected Response

Status Code: 200

Response Body:

{
"token": "generated-auth-token"
}

---

## Possible Error Response

Status Code: 401

Response Body:

{
"error": "Invalid credentials"
}

---

## Purpose of This Example

This API input will be processed by the Test Case Agent to generate different testing scenarios such as:

* Valid login test
* Invalid password test
* Missing email field
* Empty request body
