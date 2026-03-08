# UI Design Test Agent Prompt

## Task

Analyze the provided UI page and assess its design quality, usability, and adherence to modern web standards. Focus on the following key aspects:

### 1. Visual Hierarchy
- Are the primary actions clearly visible (e.g., buttons, calls to action)?
- Is there a clear logical flow from the top to the bottom of the page?
- Are headings, subheadings, and body text appropriately sized and weighted?

### 2. Consistency
- Do the colors, fonts, and spacing align with a cohesive design system?
- Are UI elements like buttons, inputs, and icons used consistently?

### 3. Usability and Accessibility
- Are form labels clearly associated with their inputs?
- Is there sufficient contrast between text and background?
- Are error and success messages clear and helpful?

### 4. Responsiveness
- Does the layout adjust correctly for mobile, tablet, and desktop viewports?
- Are touch targets (buttons, links) large enough for mobile use?

### 5. Manual Flow Scenarios (Pos/Neg)
- **Signup (Manual)**: Capture a FAST recording of negative scenarios (empty submission, weak password, invalid email) and the final positive state ready for submission.
- **Login (Manual)**: Capture a FAST recording showing invalid credentials (401 error) and the final positive state.
- **Forgot Password (Manual)**: Capture a FAST recording showing negative feedback (non-existent email) and the positive state.
- **EXCLUDE SOCIAL**: Explicitly **DO NOT** test or record Google, Facebook, or other social login/signup buttons. Skip those sections entirely.

### 6. UI Responsiveness
- Test all core pages at **375px wide**.
- Verify that elements stack centered and are fully visible.
- Ensure the header doesn't overlap on small screens.

---

## Output Format

Return a structured evaluation in the following format:

### Page: [Page Name]
- **Overall Impression**: (Brief summary)
- **Positive Aspects**: (What's working well)
- **Design Flaws**: (List of specific issues)
- **Usability Issues**: (List of specific issues)
- **Recommendations**: (Actionable steps for improvement)
- **Status**: (PASS / FAIL based on core design principles)
