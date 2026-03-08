/**
 * QA Agentic Flow - Playwright UI Test Runner v2
 * - Records separate videos per flow
 * - Captures bug screenshots for UI issues
 * - Captures API scenario screenshots (for attaching to Linear API bug cards)
 */

const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const BASE_URL      = 'https://staging.swisstrustlayer.com';
const VIDEO_DIR     = 'qa-reports/videos';
const SCREENSHOT_DIR = 'qa-reports/screenshots';

[VIDEO_DIR, SCREENSHOT_DIR, 'qa-reports/ui-results'].forEach(d => {
  if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
});

const videoMap   = {};
const allUiBugs  = [];
// screenshotMap: maps a test/scenario key -> absolute screenshot path (for API bugs)
const screenshotMap = {};

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────
async function runFlow(flowName, testFn) {
  console.log(`\n▶  [${flowName}] Starting...`);
  const safeFlowName = flowName.toLowerCase().replace(/ /g, '-');
  const videoFile    = path.join(VIDEO_DIR, `${safeFlowName}.webm`);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport:    { width: 1280, height: 800 },
    recordVideo: { dir: path.resolve(VIDEO_DIR), size: { width: 1280, height: 800 } }
  });
  const page = await context.newPage();
  page.setDefaultTimeout(12000);
  const flowBugs = [];

  try {
    await testFn(page, flowBugs);
    console.log(`✅ [${flowName}] Completed. UI Bugs: ${flowBugs.length}`);
  } catch (err) {
    console.error(`❌ [${flowName}] Error: ${err.message.split('\n')[0]}`);
  }

  const videoPath = await page.video()?.path();
  await context.close();
  await browser.close();

  if (videoPath && fs.existsSync(videoPath)) {
    const dest = path.resolve(videoFile);
    try { fs.renameSync(videoPath, dest); } catch(e) { try { fs.copyFileSync(videoPath, dest); } catch(e2) {} }
    videoMap[flowName] = dest;
    console.log(`🎥 [${flowName}] Video saved: ${dest}`);
  }

  allUiBugs.push(...flowBugs);
  return flowBugs;
}

async function screenshot(page, name) {
  const p = path.resolve(SCREENSHOT_DIR, `${name}-${Date.now()}.png`);
  await page.screenshot({ path: p, fullPage: true });
  console.log(`📸 Screenshot saved: ${path.basename(p)}`);
  return p;
}

async function findButton(page, labels) {
  const selectors = [
    'button[type="submit"]',
    ...labels.map(l => `button:has-text("${l}")`),
    'form button'
  ];
  for (const sel of selectors) {
    const el = page.locator(sel).first();
    if (await el.count() > 0) return el;
  }
  return null;
}

// ─────────────────────────────────────────────
// FLOW 1: Signup
// ─────────────────────────────────────────────
async function signupFlow(page, bugs) {
  await page.goto(`${BASE_URL}/signup`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  const ss_loaded = await screenshot(page, 'signup-page-loaded');
  screenshotMap['Signup - Valid']          = ss_loaded;
  screenshotMap['Signup - Missing Email']  = ss_loaded;
  screenshotMap['Signup - Missing Password'] = ss_loaded;

  const emailInput    = page.locator('input[type="email"], input[name*="email"], input[placeholder*="email" i]').first();
  const passwordInput = page.locator('input[type="password"]').first();
  const nameInput     = page.locator('input[name*="full" i], input[name*="name" i], input[placeholder*="name" i]').first();

  // Scenario: Invalid email
  if (await emailInput.count() > 0) {
    if (await nameInput.count() > 0) { await nameInput.fill('Test User'); await page.waitForTimeout(200); }
    await emailInput.fill('invalid-email-format');
    if (await passwordInput.count() > 0) await passwordInput.fill('Test@123');
    await page.waitForTimeout(400);
    const btn = await findButton(page, ['Sign Up', 'Register', 'Create Account', 'Continue']);
    if (btn) {
      await btn.click({ force: true });
      await page.waitForTimeout(2000);
    }
    const ss = await screenshot(page, 'signup-invalid-email');
    screenshotMap['Signup - Invalid Email'] = ss;

    const emailError = await page.locator('text=/invalid|valid email|format|not valid/i').count() > 0;
    if (!emailError) {
      bugs.push({
        title: '[Signup] Invalid email format accepted without validation error',
        description: 'Signup form does not show error for "invalid-email-format".',
        steps: '1. Go to /signup\n2. Enter "invalid-email-format"\n3. Submit\n4. No error shown',
        screenshot: ss
      });
    }
  }

  // Scenario: Weak password
  if (await emailInput.count() > 0 && await passwordInput.count() > 0) {
    await emailInput.fill('weakpwd@yopmail.com');
    await passwordInput.fill('123');
    await page.waitForTimeout(400);
    const btn = await findButton(page, ['Sign Up', 'Register', 'Create Account', 'Continue']);
    if (btn) {
      await btn.click({ force: true });
      await page.waitForTimeout(2000);
    }
    const ss = await screenshot(page, 'signup-weak-password');
    screenshotMap['Signup - Weak Password']    = ss;
    screenshotMap['Signup - Missing Fullname'] = ss;

    const pwdError = await page.locator('text=/weak|password|strong|character|minimum/i').count() > 0;
    if (!pwdError) {
      bugs.push({
        title: '[Signup] Weak password accepted without validation warning',
        description: 'Password "123" accepted without weak password warning.',
        steps: '1. Go to /signup\n2. Enter "123" as password\n3. Submit\n4. No password strength error',
        screenshot: ss
      });
    }
  }

  const ss_final = await screenshot(page, 'signup-flow-final');
  // Fallback screenshot for any signup key not yet mapped
  ['Signup - Valid', 'Signup - Missing Email', 'Signup - Missing Password', 'Signup - Invalid Email',
   'Signup - Weak Password', 'Signup - Missing Fullname'].forEach(k => {
    if (!screenshotMap[k]) screenshotMap[k] = ss_final;
  });
}

// ─────────────────────────────────────────────
// FLOW 2: Login
// ─────────────────────────────────────────────
async function loginFlow(page, bugs) {
  await page.goto(`${BASE_URL}/login`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  const ss_loaded = await screenshot(page, 'login-page-loaded');
  screenshotMap['Login - Missing Email']    = ss_loaded;
  screenshotMap['Login - Missing Password'] = ss_loaded;
  screenshotMap['Login - Empty Body']       = ss_loaded;

  const emailInput    = page.locator('input[type="email"], input[name*="email"], input[placeholder*="email" i]').first();
  const passwordInput = page.locator('input[type="password"]').first();

  // Scenario: Valid user login (for finding valid-login API bug screenshot)
  if (await emailInput.count() > 0) {
    await emailInput.fill('virat_india@yopmail.com');
    if (await passwordInput.count() > 0) await passwordInput.fill('Test@123');
    await page.waitForTimeout(400);
    const btn = await findButton(page, ['Login', 'Sign In', 'Log In']);
    if (btn) {
      await btn.click({ force: true });
      await page.waitForTimeout(2500);
    }
    const ss_valid = await screenshot(page, 'login-valid-attempt');
    screenshotMap['Login - Valid'] = ss_valid;
  }

  // Reload page for next scenario
  await page.goto(`${BASE_URL}/login`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1500);

  // Scenario: Invalid credentials
  if (await emailInput.count() > 0) {
    await emailInput.fill('wronguser@yopmail.com');
    if (await passwordInput.count() > 0) await passwordInput.fill('WrongPass999');
    await page.waitForTimeout(400);
    const btn = await findButton(page, ['Login', 'Sign In', 'Log In']);
    if (btn) {
      await btn.click({ force: true });
      await page.waitForTimeout(2500);
    }
    const ss = await screenshot(page, 'login-invalid-creds');
    screenshotMap['Login - Invalid Email']    = ss;
    screenshotMap['Login - Invalid Password'] = ss;

    const hasError = await page.locator('text=/invalid|incorrect|not found|wrong|failed|unauthorized/i').count() > 0;
    if (!hasError) {
      bugs.push({
        title: '[Login] No error message shown for invalid credentials',
        description: 'Logging in with wrong email/password shows no error feedback.',
        steps: '1. Go to /login\n2. Enter wrong email and password\n3. Submit\n4. No error shown',
        screenshot: ss
      });
    }
  }

  const ss_final = await screenshot(page, 'login-flow-final');
  ['Login - Valid', 'Login - Invalid Email', 'Login - Invalid Password',
   'Login - Missing Email', 'Login - Missing Password', 'Login - Empty Body'].forEach(k => {
    if (!screenshotMap[k]) screenshotMap[k] = ss_final;
  });
}

// ─────────────────────────────────────────────
// FLOW 3: Forgot Password
// ─────────────────────────────────────────────
async function forgotPasswordFlow(page, bugs) {
  await page.goto(`${BASE_URL}/forgot-password`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);

  const ss_loaded = await screenshot(page, 'forgot-password-page-loaded');
  screenshotMap['Forgot Password - Missing Email']       = ss_loaded;
  screenshotMap['Forgot Password - Empty Email']         = ss_loaded;

  const emailInput = page.locator('input[type="email"], input[name*="email"], input[placeholder*="email" i]').first();

  // Scenario: Valid email (to capture screenshot for valid email API test)
  if (await emailInput.count() > 0) {
    await emailInput.fill('virat_india@yopmail.com');
    await page.waitForTimeout(400);
    const btn = await findButton(page, ['Send', 'Reset', 'Submit', 'Continue', 'Send Code']);
    if (btn) {
      await btn.click({ force: true });
      await page.waitForTimeout(2000);
    }
    const ss_valid = await screenshot(page, 'forgot-password-valid-email');
    screenshotMap['Forgot Password - Valid Email'] = ss_valid;
  }

  // Reload for next scenario
  await page.goto(`${BASE_URL}/forgot-password`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1500);

  // Scenario: Non-existent email
  if (await emailInput.count() > 0) {
    await emailInput.fill('notexists@yopmail.com');
    await page.waitForTimeout(400);
    const btn = await findButton(page, ['Send', 'Reset', 'Submit', 'Continue', 'Send Code']);
    if (btn) {
      await btn.click({ force: true });
      await page.waitForTimeout(2000);
    }
    const ss_notfound = await screenshot(page, 'forgot-password-nonexistent-email');
    screenshotMap['Forgot Password - Invalid Email'] = ss_notfound;
  }

  // Reload for invalid format
  await page.goto(`${BASE_URL}/forgot-password`, { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(1500);

  // Scenario: Invalid email format
  if (await emailInput.count() > 0) {
    await emailInput.fill('not-a-real-email');
    await page.waitForTimeout(400);
    const btn = await findButton(page, ['Send', 'Reset', 'Submit', 'Continue', 'Send Code']);
    if (btn) {
      await btn.click({ force: true });
      await page.waitForTimeout(2000);
    }
    const ss = await screenshot(page, 'forgot-password-invalid-format');
    screenshotMap['Forgot Password - Invalid Email Format'] = ss;

    const hasError = await page.locator('text=/invalid|valid email|format/i').count() > 0;
    if (!hasError) {
      bugs.push({
        title: '[Forgot Password] Invalid email format not validated',
        description: 'The forgot-password form accepts "not-a-real-email" without an error.',
        steps: '1. Go to /forgot-password\n2. Enter "not-a-real-email"\n3. Submit\n4. No error shown',
        screenshot: ss
      });
    }
  }

  const ss_final = await screenshot(page, 'forgot-password-flow-final');
  ['Forgot Password - Valid Email', 'Forgot Password - Invalid Email', 'Forgot Password - Missing Email',
   'Forgot Password - Invalid Email Format', 'Forgot Password - Empty Email'].forEach(k => {
    if (!screenshotMap[k]) screenshotMap[k] = ss_final;
  });
}

// ─────────────────────────────────────────────
// FLOW 4: UI Responsive
// ─────────────────────────────────────────────
async function uiResponsiveFlow(page, bugs) {
  const pages = [
    { name: 'Root',             path: '/' },
    { name: 'Signup',           path: '/signup' },
    { name: 'Login',            path: '/login' },
    { name: 'Forgot Password',  path: '/forgot-password' }
  ];
  const viewports = [
    { width: 375,  height: 812,  label: 'Mobile' },
    { width: 768,  height: 1024, label: 'Tablet' }
  ];

  for (const vp of viewports) {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    for (const p of pages) {
      await page.goto(`${BASE_URL}${p.path}`, { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(1000);

      const isOverflowing = await page.evaluate(() =>
        document.body.scrollWidth > window.innerWidth
      );

      const ss = await screenshot(page, `responsive-${vp.label.toLowerCase()}-${p.name.toLowerCase().replace(/ /g, '-')}`);
      if (isOverflowing) {
        bugs.push({
          title: `[UI Responsive] Horizontal overflow on ${p.name} at ${vp.label} (${vp.width}px)`,
          description: `${p.name} page has horizontal scroll at ${vp.label} (${vp.width}px) — broken layout.`,
          steps: `1. Open ${BASE_URL}${p.path}\n2. Resize to ${vp.width}px\n3. Horizontal scroll present`,
          screenshot: ss
        });
      }
    }
  }
}

// ─────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────
(async () => {
  const signupBugs  = await runFlow('Signup Flow',          signupFlow);
  const loginBugs   = await runFlow('Login Flow',           loginFlow);
  const forgotBugs  = await runFlow('Forgot Password Flow', forgotPasswordFlow);
  const uiBugs      = await runFlow('UI Responsive Flow',   uiResponsiveFlow);

  const result = {
    videoMap,
    screenshotMap,
    bugs: allUiBugs,
    summary: {
      signup:          signupBugs.length,
      login:           loginBugs.length,
      forgotPassword:  forgotBugs.length,
      uiResponsive:    uiBugs.length,
      total:           allUiBugs.length
    }
  };

  fs.writeFileSync('qa-reports/ui-test-results.json', JSON.stringify(result, null, 2));
  console.log('\n✅ UI Tests complete. Results saved to qa-reports/ui-test-results.json');
  console.log(`📊 Total UI Bugs: ${allUiBugs.length} | Screenshots mapped: ${Object.keys(screenshotMap).length}`);
  console.log(JSON.stringify(result.summary, null, 2));
})();
