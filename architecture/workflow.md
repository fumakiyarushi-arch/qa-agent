# QA Agentic Workflow

## Overview

The QA Agentic Workflow describes the step-by-step process through which multiple agents collaborate to perform automated API testing.

Each agent in the workflow performs a specific task and passes the results to the next agent.

---

## Step 1 – API Input

The workflow begins when an API endpoint or request information is provided.

Example:

Endpoint: POST /login

Request Parameters:

* email
* password

This information is provided to the Test Case Agent.

---

## Step 2 – Test Case Generation

The Test Case Agent analyzes the API details and generates multiple testing scenarios.

Example test cases:

1. Valid login credentials
2. Invalid password
3. Missing email
4. Empty request body

These test cases ensure the API is tested across different scenarios.

The generated test cases are then sent to the Execution Agent.

---

## Step 3 – API Execution

The Execution Agent performs API requests using the generated test cases.

The agent records API responses including:

* Status code
* Response body
* Error messages

Example response:

Status Code: 500
Message: Internal Server Error

The execution results are passed to the Result Analyzer Agent.

---

## Step 4 – Result Analysis

The Result Analyzer Agent evaluates whether the API response matches the expected behavior.

Example:

Expected Status Code: 200
Actual Status Code: 500

Result: Test Failed

The agent identifies failed test cases and forwards them to the Bug Report Agent.

---

## Step 5 – Bug Report Generation

The Bug Report Agent creates a detailed bug report for each failed test case.

The report includes:

* Bug title
* Steps to reproduce
* Expected result
* Actual result
* Severity level

This report can be shared with the development team for debugging and fixing the issue.

---

## Final Output

The QA Agentic Workflow produces the following outputs:

* Generated API test cases
* API execution results
* Test pass/fail analysis
* Bug reports for detected issues
