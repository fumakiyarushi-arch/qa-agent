const { LinearClient } = require('@linear/sdk');

const LINEAR_API_KEY = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u';
const client = new LinearClient({ apiKey: LINEAR_API_KEY });

const issues = [
    { identifier: 'QA-138', title: 'Signup - Valid signup', screenshotUrl: 'https://0x0.st/PeTg.png' },
    { identifier: 'QA-139', title: 'Login - Valid login', screenshotUrl: 'https://0x0.st/PeTE.png' },
    { identifier: 'QA-140', title: 'Forgot Password - Valid Email', screenshotUrl: 'https://0x0.st/PeT6.png' },
    { identifier: 'QA-141', title: 'Forgot Password - Invalid Email', screenshotUrl: 'https://0x0.st/PeTI.png' },
    { identifier: 'QA-144', title: 'Login - No error for invalid credentials', screenshotUrl: 'https://0x0.st/PeTS.png' }
];

async function addComment(issueId, identifier, title, screenshotUrl) {
    const body = `📸 **Test Screenshot Attached**

**Bug:** ${title}
**Screenshot:** ${screenshotUrl}

See the QA report for full details.`;

    const result = await client.createComment({
        issueId,
        body
    });
    
    return result;
}

async function main() {
    console.log('Adding screenshot comments to Linear issues...\n');
    
    for (const issue of issues) {
        console.log(`Processing ${issue.identifier} - ${issue.title}...`);
        
        try {
            const issueData = await client.issue(issue.identifier);
            
            if (!issueData) {
                console.log(`  ❌ Issue ${issue.identifier} not found!`);
                continue;
            }
            
            const result = await addComment(issueData.id, issue.identifier, issue.title, issue.screenshotUrl);
            
            if (result.success) {
                console.log(`  ✅ Comment added with screenshot URL!`);
            } else {
                console.log(`  ❌ Failed to add comment:`, result.error);
            }
            
        } catch (error) {
            console.log(`  ❌ Error:`, error.message);
        }
    }
    
    console.log('\n=== DONE ===');
}

main();
