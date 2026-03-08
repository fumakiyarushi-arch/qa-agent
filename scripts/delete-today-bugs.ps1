# Delete today's bugs from Linear project
# Project ID: 8c9e1ceb-218a-45fb-ba8b-7e3c4fc9aab8

$apiKey = "lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u"
$projectId = "8c9e1ceb-218a-45fb-ba8b-7e3c4fc9aab8"
$apiUrl = "https://api.linear.app/graphql"

# Calculate the date 24 hours ago
$yesterday = (Get-Date).AddHours(-24).ToString("yyyy-MM-ddTHH:mm:ssZ")

$headers = @{
    "Authorization" = $apiKey
    "Content-Type" = "application/json"
}

# Query for issues created in the last 24 hours in the project
$query = @"
query {
  issues(filter: {
    createdAt: { gte: "-P1D" },
    project: { id: { eq: "$projectId" } }
  }) {
    nodes {
      id
      identifier
      title
      createdAt
    }
  }
}
"@

$body = @{
    query = $query
} | ConvertTo-Json

Write-Host "Querying Linear API for issues created in the last 24 hours..."
Write-Host "Project ID: $projectId"
Write-Host ""

$response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body
$issues = $response.data.issues.nodes

if ($issues.Count -eq 0) {
    Write-Host "No issues found created in the last 24 hours."
    exit 0
}

Write-Host "Found $($issues.Count) issue(s) created today:"
Write-Host ""

$deletedCount = 0

foreach ($issue in $issues) {
    Write-Host "  - [$($issue.identifier)] $($issue.title) (Created: $($issue.createdAt))"
    
    # Delete the issue using issueDelete mutation
    $deleteMutation = @"
mutation {
  issueDelete(id: "$($issue.id)") {
    success
  }
}
"@
    
    $deleteBody = @{
        query = $deleteMutation
    } | ConvertTo-Json
    
    try {
        $deleteResponse = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $deleteBody
        
        if ($deleteResponse.data.issueDelete.success) {
            Write-Host "    -> Deleted successfully"
            $deletedCount++
        } else {
            Write-Host "    -> Failed to delete"
        }
    }
    catch {
        Write-Host "    -> Error: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "========================================="
Write-Host "Total bugs deleted: $deletedCount"
Write-Host "========================================="
