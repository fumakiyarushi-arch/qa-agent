const { LinearClient } = require('@linear/sdk');

const LINEAR_API_KEY = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u';
const client = new LinearClient({ apiKey: LINEAR_API_KEY });

async function main() {
  console.log('Fetching Linear issues...\n');
  
  try {
    const result = await client.issues({
      first: 50,
      filter: {
        or: [
          { title: { containsIgnoreCase: 'signup' } },
          { title: { containsIgnoreCase: 'login' } },
          { title: { containsIgnoreCase: 'forgot password' } },
          { title: { containsIgnoreCase: 'forgot-password' } },
          { description: { containsIgnoreCase: 'signup' } },
          { description: { containsIgnoreCase: 'login' } },
          { description: { containsIgnoreCase: 'forgot password' } }
        ]
      }
    });
    
    console.log('=== Linear Issues Related to Signup/Login/Forgot Password ===\n');
    
    if (result.nodes.length === 0) {
      console.log('No issues found matching criteria. Getting recent issues...\n');
      const allIssues = await client.issues({ first: 20 });
      
      for (const issue of allIssues.nodes) {
        console.log(`- ${issue.identifier}: ${issue.title}`);
        console.log(`  Priority: ${issue.priority}`);
        console.log(`  State: ${issue.state?.name}`);
        console.log(`  Created: ${issue.createdAt}`);
        console.log(`  URL: https://linear.app/swiss-qa-workspace/issue/${issue.identifier}`);
        console.log('');
      }
    } else {
      for (const issue of result.nodes) {
        console.log(`- ${issue.identifier}: ${issue.title}`);
        console.log(`  Priority: ${issue.priority}`);
        console.log(`  State: ${issue.state?.name}`);
        console.log(`  Created: ${issue.createdAt}`);
        console.log(`  URL: https://linear.app/swiss-qa-workspace/issue/${issue.identifier}`);
        
        const attachments = await client.attachments({ issueId: issue.id });
        console.log(`  Attachments: ${attachments.nodes.length}`);
        
        const comments = await client.comments({ issueId: issue.id });
        console.log(`  Comments: ${comments.nodes.length}`);
        console.log('');
      }
    }
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

main();
