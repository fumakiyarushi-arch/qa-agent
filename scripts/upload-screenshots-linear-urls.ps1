$Headers = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u'
}
$QueryUrl = 'https://api.linear.app/graphql'

$bugs = @{
    "QA-116" = "https://0x0.st/PesV.png"
    "QA-117" = "https://0x0.st/PesW.png"
    "QA-118" = "https://0x0.st/Pes4.png"
    "QA-119" = "https://0x0.st/PesJ.png"
}

# Get issue IDs first
$Query = @{query='query { issues(first: 20, filter: { team: { id: { eq: "638a7e02-83d1-412b-b99e-ba5f54e62f03" } } }) { nodes { id identifier description } } }'}
$res = Invoke-RestMethod -Uri $QueryUrl -Method Post -Headers $Headers -Body ($Query | ConvertTo-Json -Depth 5)

$issueMap = @{}
$descriptionMap = @{}
foreach ($node in $res.data.issues.nodes) {
    if ($node.identifier) {
        $issueMap[$node.identifier] = $node.id
        $descriptionMap[$node.identifier] = $node.description
    }
}

foreach ($key in $bugs.Keys) {
    $issueId = $issueMap[$key]
    if ($issueId) {
        $uploadUrl = $bugs[$key]
        Write-Host "Processing $key ($issueId) with URL: $uploadUrl"
        
        try {
            $newline = "\n"
            $oldDescription = $descriptionMap[$key]
            if ($oldDescription -match "!\[\]") {
                Write-Host "Already has an image, skipping."
                continue
            }
            $bodyText = "Here is the exact screenshot showing the bug evidence:$newline![]($uploadUrl)"
            
            $mutationQuery = "mutation { commentCreate(input: { issueId: `"$issueId`", body: `"$bodyText`" }) { success } }"
            $mutation = @{ query = $mutationQuery }
            
            $mRes = Invoke-RestMethod -Uri $QueryUrl -Method Post -Headers $Headers -Body ($mutation | ConvertTo-Json -Depth 5)
            Write-Host "Linear Comment Result: $($mRes.data.commentCreate.success)"
        } catch {
            Write-Host "Error commenting: $_"
        }
    }
}
Write-Host "Done!"
