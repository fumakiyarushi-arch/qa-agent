const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const API_KEY = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u';
const TEAM_ID = '638a7e02-83d1-412b-b99e-ba5f54e62f03';
const QUERY_URL = 'https://api.linear.app/graphql';

const bugs = {
    'QA-138': 'qa-reports/api-screenshots/Signup_-_Valid_signup.png',
    'QA-139': 'qa-reports/api-screenshots/Login_-_Valid_login.png',
    'QA-140': 'qa-reports/api-screenshots/Forgot_Password_-_Valid_Email.png',
    'QA-141': 'qa-reports/api-screenshots/Forgot_Password_-_Invalid_Email.png',
    'QA-142': 'qa-reports/screenshots/login-invalid-creds-1772967842881.png'
};

async function graphqlRequest(query, variables = {}) {
    return new Promise((resolve, reject) => {
        const https = require('https');
        const data = JSON.stringify({ query, variables });
        const req = https.request(QUERY_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': API_KEY
            }
        }, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                try {
                    resolve(JSON.parse(body));
                } catch (e) {
                    reject(e);
                }
            });
        });
        req.on('error', reject);
        req.write(data);
        req.end();
    });
}

function uploadTo0x0(filePath) {
    const result = execSync(`curl.exe -s -F "file=@${filePath}" https://0x0.st`, { encoding: 'utf-8' });
    return result.trim();
}

async function main() {
    console.log('Attached screenshots to Linear issues:');
    console.log('========================================');
    
    const issuesRes = await graphqlRequest(
        `query { issues(first: 50, filter: { team: { id: { eq: "${TEAM_ID}" } } }) { nodes { id identifier } } }`
    );
    
    const issueMap = {};
    for (const node of issuesRes.data.issues.nodes) {
        issueMap[node.identifier] = node.id;
    }
    
    for (const [key, filePath] of Object.entries(bugs)) {
        const issueId = issueMap[key];
        if (!issueId) {
            console.log(`  ${key} : FAILED (issue not found)`);
            continue;
        }
        
        const fullPath = path.resolve(filePath);
        if (!fs.existsSync(fullPath)) {
            console.log(`  ${key} : FAILED (file not found: ${fullPath})`);
            continue;
        }
        
        console.log(`Processing ${key} (${issueId})`);
        
        try {
            console.log(`  Uploading to 0x0.st...`);
            const uploadUrl = uploadTo0x0(fullPath);
            console.log(`  Uploaded to: ${uploadUrl}`);
            
            const commentBody = `Screenshot attached: ![](${uploadUrl})`;
            const commentRes = await graphqlRequest(
                `mutation { commentCreate(input: { issueId: "${issueId}", body: "${commentBody}" }) { success } }`
            );
            
            if (commentRes.data && commentRes.data.commentCreate && commentRes.data.commentCreate.success) {
                console.log(`  ${key} : SUCCESS`);
            } else {
                console.log(`  ${key} : FAILED (comment creation: ${JSON.stringify(commentRes)})`);
            }
        } catch (err) {
            console.log(`  ${key} : FAILED (${err.message})`);
        }
    }
    
    console.log('========================================');
    console.log('Done!');
}

main().catch(console.error);
