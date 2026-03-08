$Headers = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u'
}
$QueryUrl = 'https://api.linear.app/graphql'

$bugs = @{
    "QA-116" = "C:\Users\hp\.gemini\antigravity\brain\ba6d8ee9-ef33-415d-8fb5-cdfa1aea5f44\signup_invalid_email_error_1772895221800.png"
    "QA-117" = "C:\Users\hp\.gemini\antigravity\brain\ba6d8ee9-ef33-415d-8fb5-cdfa1aea5f44\login_negative_invalid_creds_1772895351486.png"
    "QA-118" = "C:\Users\hp\.gemini\antigravity\brain\ba6d8ee9-ef33-415d-8fb5-cdfa1aea5f44\forgot_password_invalid_format_1772902665194.png"
    "QA-119" = "C:\Users\hp\.gemini\antigravity\brain\ba6d8ee9-ef33-415d-8fb5-cdfa1aea5f44\forgot_password_non_existent_user_1772902685427.png"
}

# Get issue IDs first
$Query = @{query='query { issues(first: 20, filter: { team: { id: { eq: "638a7e02-83d1-412b-b99e-ba5f54e62f03" } } }) { nodes { id identifier } } }'}
$res = Invoke-RestMethod -Uri $QueryUrl -Method Post -Headers $Headers -Body ($Query | ConvertTo-Json -Depth 5)

$issueMap = @{}
foreach ($node in $res.data.issues.nodes) {
    if ($node.identifier) {
        $issueMap[$node.identifier] = $node.id
    }
}

foreach ($key in $bugs.Keys) {
    $issueId = $issueMap[$key]
    if ($issueId) {
        $filePath = $bugs[$key]
        Write-Host "Processing $key ($issueId)"
        
        try {
            # Use curl to upload to transfer.sh
            $uploadResult = (curl.exe -s --upload-file $filePath "https://transfer.sh/$key-evidence.png")
            Write-Host "Upload Result: $uploadResult"
            $uploadUrl = $uploadResult.Trim()
            
            if ($uploadUrl -match "^https?://") {
                Write-Host "Uploaded to: $uploadUrl"
                
                $newline = "\n"
                $bodyText = "Here is the exact screenshot showing the bug evidence:$newline$newline![]($uploadUrl)"
                
                $mutationQuery = "mutation { commentCreate(input: { issueId: `"$issueId`", body: `"$bodyText`" }) { success } }"
                $mutation = @{ query = $mutationQuery }
                
                $mRes = Invoke-RestMethod -Uri $QueryUrl -Method Post -Headers $Headers -Body ($mutation | ConvertTo-Json -Depth 5)
                Write-Host "Linear Result: $($mRes.data.commentCreate.success)"
            }
        } catch {
            Write-Host "Error uploading or commenting: $_"
        }
    }
}
Write-Host "Done!"
