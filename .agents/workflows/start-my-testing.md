---
description: Start my testing workflow
---

// turbo-all

# Start My Testing

Executes the main automated QA tests and workflows seamlessly. This includes both the API test suite and visual flows via the browser subagent.

## Workflow Steps

### Step 1: Run Browser Subagents for Visual QA and Video Recording
The agent MUST run the `browser_subagent` tool concurrently for the following flows to record videos and capture bug screenshots:
1. **Signup Flow:** Test manual positive and negative scenarios at https://staging.swisstrustlayer.com/signup. Exclude social buttons.
2. **Login Flow:** Test manual positive and negative scenarios at https://staging.swisstrustlayer.com/login. Exclude social buttons.
3. **Forgot Password Flow:** Test manual positive and negative scenarios at https://staging.swisstrustlayer.com/forgot-password.
4. **UI Responsive Flow:** Resize the window (mobile, tablet) on https://staging.swisstrustlayer.com/ to check for overlapping/broken elements.

### Step 2: Run the QA flow script
// turbo-all
```powershell
powershell.exe -ExecutionPolicy Bypass -File scripts\run-qa-with-linear.ps1
```

### Step 3: Upload Screenshots to Linear
If the browser subagents returned any bug screenshots, attach them to the corresponding newly created Linear Bug tickets.
