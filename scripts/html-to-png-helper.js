const { chromium } = require('@playwright/test');
const path = require('path');
const fs = require('fs');

async function convertHtmlToPng(htmlPath, pngPath) {
    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();
    
    try {
        const absoluteHtmlPath = path.resolve(htmlPath);
        await page.setViewportSize({ width: 900, height: 1200 });
        await page.goto(`file://${absoluteHtmlPath}`, { waitUntil: 'networkidle0' });
        await page.screenshot({ path: pngPath, fullPage: true });
        console.log(`Converted: ${pngPath}`);
        return true;
    } catch (err) {
        console.error(`Error converting ${htmlPath}:`, err.message);
        return false;
    } finally {
        await browser.close();
    }
}

const args = process.argv.slice(2);
if (args.length >= 2) {
    convertHtmlToPng(args[0], args[1]);
} else {
    console.error('Usage: node html-to-png-helper.js <htmlPath> <pngPath>');
    process.exit(1);
}
