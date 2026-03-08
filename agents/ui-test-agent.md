# UI Design Test Agent

## Overview

The UI Design Test Agent is responsible for evaluating the user interface of the application. It ensures that the design follows best practices, is visually consistent, and provides a good user experience.

---

## Responsibilities

The UI Design Test Agent performs the following tasks:

* Analyze the layout and visual structure of UI pages.
* Verify the presence and correctness of key UI elements (buttons, inputs, labels).
* Check for visual consistency (colors, fonts, spacing).
* Evaluate responsiveness and mobile-friendliness.
* Identify UI/UX issues and design flaws.

---

## UI Flow Testing (Manual Only)

The agent performs separate High-Speed recordings for each manual flow:

1. **Signup Page (Manual)**
   - Check input fields: Fullname, Email, Password, Mobile Number, Country Code.
   - **EXCLUDE Social Signup** options (Google, Facebook, etc.).
   - Verify Signup button and validation messages.

2. **Login Page (Manual)**
   - Check input fields: Email, Password.
   - **EXCLUDE Social Login** options (Google, Facebook, etc.).
   - Verify Login button and 'Forgot Password' link.

3. **Forgot Password Page (Manual)**
   - Check input field: Email.
   - Verify 'Send Code' or 'Reset Password' button.

4. **UI Responsive Flow**
   - Perform a dedicated recording of all pages at 375px wide.
   - Verify layout stacking and element visibility.

---

## Input

* **URL**: The base URL or specific page URLs for testing.
* **Design Guidelines**: (Optional) Specific brand or design rules to follow.

---

## Output

* **UI Test Results**: A detailed analysis of each page's design.
* **Design Bug Reports**: Issues related to layout, styling, or usability.
