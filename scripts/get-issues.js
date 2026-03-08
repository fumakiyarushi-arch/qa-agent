const https = require('https');

const LINEAR_API_KEY = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u';
const LINEAR_PROJECT_ID = '8c9e1ceb-218a-45fb-ba8b-7e3c4fc9aab8';

function graphqlRequest(query, variables) {
    return new Promise((resolve, reject) => {
        const data = JSON.stringify({ query, variables });
        
        const options = {
            hostname: 'api.linear.app',
            path: '/graphql',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': LINEAR_API_KEY,
                'Content-Length': Buffer.byteLength(data)
            }
        };
        
        const req = https.request(options, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                try {
                    const json = JSON.parse(body);
                    resolve(json);
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

async function main() {
    const query = `
        query GetProjectIssues {
            project(id: "${LINEAR_PROJECT_ID}") {
                issues {
                    nodes {
                        id
                        identifier
                        title
                    }
                }
            }
        }
    `;
    
    const result = await graphqlRequest(query, {});
    console.log(JSON.stringify(result, null, 2));
}

main().catch(console.error);
