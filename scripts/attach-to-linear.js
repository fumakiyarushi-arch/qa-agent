const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const https = require('https');
const { LinearClient } = require('@linear/sdk');

const LINEAR_API_KEY = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u';

const client = new LinearClient({ apiKey: LINEAR_API_KEY });

const issues = [
    { issueId: '0bc3b7fa-773c-40cc-aef3-798ffc09eeab', identifier: 'QA-138', screenshot: 'qa-reports/api-screenshots/Signup_-_Valid_signup.png', description: 'Signup - Valid signup' },
    { issueId: '0be62f53-61bc-44f8-b888-f2108d689480', identifier: 'QA-139', screenshot: 'qa-reports/api-screenshots/Login_-_Valid_login.png', description: 'Login - Valid login' },
    { issueId: '1443c1fb-b2ab-47e8-b6de-011ee7342601', identifier: 'QA-140', screenshot: 'qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.png', description: 'Forgot Password - Valid Email' },
    { issueId: '4c804976-4649-4410-894b-0034bc72e449', identifier: 'QA-141', screenshot: 'qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.png', description: 'Forgot Password - Invalid Email' },
    { issueId: 'ec65e4bd-3139-4c9b-92bc-655681814c23', identifier: 'QA-142', screenshot: 'qa-reports/screenshots/login-invalid-creds-1772967842881.png', description: 'Login - Invalid credentials' }
];

function computeSha256(buffer) {
    return crypto.createHash('sha256').update(buffer).digest('hex');
}

async function uploadFileToLinear(filePath) {
    const fileName = path.basename(filePath);
    const fileContent = fs.readFileSync(filePath);
    const mimeType = 'image/png';
    const contentSha256 = computeSha256(fileContent);
    
    console.log(`  Requesting upload URL...`);
    const uploadPayload = await client.fileUpload(mimeType, fileName, fileContent.length);
    
    if (!uploadPayload.success || !uploadPayload.uploadFile) {
        throw new Error("Failed to request upload URL");
    }
    
    const uploadUrl = uploadPayload.uploadFile.uploadUrl;
    const assetUrl = uploadPayload.uploadFile.assetUrl;
    
    console.log(`  Uploading to ${uploadUrl}...`);
    
    return new Promise((resolve, reject) => {
        const urlObj = new URL(uploadUrl);
        
        const options = {
            hostname: urlObj.hostname,
            path: urlObj.pathname + urlObj.search,
            method: 'PUT',
            headers: {
                'Content-Type': mimeType,
                'Content-Length': fileContent.length,
                'x-goog-content-length-range': `0,${fileContent.length}`,
                'x-goog-content-sha256': contentSha256
            }
        };
        
        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    console.log(`  Upload successful!`);
                    resolve(assetUrl);
                } else {
                    reject(new Error(`Upload failed with status ${res.statusCode}: ${body}`));
                }
            });
        });
        
        req.on('error', reject);
        req.write(fileContent);
        req.end();
    });
}

async function createAttachment(issueId, assetUrl, fileName) {
    const result = await client.createAttachment({
        issueId,
        title: 'Screenshot',
        subtitle: fileName,
        url: assetUrl
    });
    
    return result;
}

async function addComment(issueId, screenshotPath) {
    const fileName = path.basename(screenshotPath);
    const body = `📸 Screenshot attached: ${fileName}`;
    
    const result = await client.createComment({
        issueId,
        body
    });
    
    return result;
}

async function main() {
    console.log('Starting Linear attachment process...\n');
    
    for (const issue of issues) {
        console.log(`\nProcessing ${issue.identifier} - ${issue.description}`);
        console.log(`  Screenshot: ${issue.screenshot}`);
        
        if (!fs.existsSync(issue.screenshot)) {
            console.log(`  ❌ Screenshot file not found!`);
            continue;
        }
        
        try {
            console.log(`  Linear Issue ID: ${issue.issueId}`);
            
            const assetUrl = await uploadFileToLinear(issue.screenshot);
            console.log(`  Asset URL: ${assetUrl}`);
            
            console.log(`  Creating attachment...`);
            const attachResult = await createAttachment(issue.issueId, assetUrl, path.basename(issue.screenshot));
            
            if (attachResult.success) {
                console.log(`  ✅ Attachment created successfully!`);
                
                console.log(`  Adding comment...`);
                await addComment(issue.issueId, issue.screenshot);
                console.log(`  ✅ Comment added!`);
            } else {
                console.log(`  ❌ Attachment creation failed!`);
            }
            
        } catch (error) {
            console.log(`  ❌ Error:`, error.message);
        }
    }
    
    console.log('\n\n=== DONE ===');
}

main().catch(console.error);
