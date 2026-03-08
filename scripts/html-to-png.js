const { chromium } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

async function convertHtmlToPng() {
    const browser = await chromium.launch();
    const page = await browser.newPage();
    
    const htmlFiles = [
        { html: 'qa-reports/api-screenshots/Signup_-_Valid_signup.html', png: 'qa-reports/api-screenshots/Signup_-_Valid_signup.png' },
        { html: 'qa-reports/api-screenshots/Login_-_Valid_login.html', png: 'qa-reports/api-screenshots/Login_-_Valid_login.png' },
        { html: 'qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.html', png: 'qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.png' },
        { html: 'qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.html', png: 'qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.png' }
    ];
    
    for (const file of htmlFiles) {
        const htmlPath = path.resolve(file.html);
        console.log(`Converting ${htmlPath} to ${file.png}...`);
        
        await page.goto(`file://${htmlPath}`);
        await page.screenshot({ path: file.png, fullPage: true });
        console.log(`Saved: ${file.png}`);
    }
    
    await browser.close();
    console.log('All HTML files converted to PNG!');
}

convertHtmlToPng().catch(console.error);
