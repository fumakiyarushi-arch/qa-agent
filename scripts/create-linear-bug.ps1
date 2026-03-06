# Linear Bug Integration Script
# Creates bugs in Linear automatically from QA test failures

param(
    [Parameter(Mandatory=$true)]
    [string]$LinearApiKey,

    [Parameter(Mandatory=$true)]
    [string]$TeamId,

    [Parameter(Mandatory=$true)]
    [string]$ProjectId,

    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$Description,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Low", "Medium", "High", "Urgent")]
    [string]$Priority = "Medium"
)

$PriorityMap = @{
    "Urgent" = 1
    "High"   = 2
    "Medium" = 3
    "Low"    = 4
}

$priorityValue = $PriorityMap[$Priority]

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = $LinearApiKey
}

# 1. Check if the bug already exists to avoid duplicates
$checkQuery = @"
query CheckExisting {
  issues(filter: { team: { id: { eq: "$TeamId" } }, title: { eq: "$Title" } }, first: 1) {
    nodes {
      id
      identifier
      url
      state {
        name
      }
    }
  }
}
"@

$checkBody = @{ query = $checkQuery } | ConvertTo-Json -Depth 5

try {
    $checkResponse = Invoke-RestMethod -Uri "https://api.linear.app/graphql" `
                                       -Method POST `
                                       -Headers $headers `
                                       -Body $checkBody `
                                       -UseBasicParsing

    $existingNodes = $checkResponse.data.issues.nodes
    if ($existingNodes -and $existingNodes.Count -gt 0) {
        $existing = $existingNodes[0]
        Write-Host "SKIP: Bug already exists in Linear (State: $($existing.state.name))"
        Write-Host "Issue ID: $($existing.identifier)"
        Write-Host "URL: $($existing.url)"
        exit 0
    }
} catch {
    Write-Host "WARNING: Failed to check for existing bugs. Proceeding to create..."
}

# 2. Create the bug if it doesn't exist
$query = @"
mutation CreateIssue {
  issueCreate(input: {
    teamId: "$TeamId"
    projectId: "$ProjectId"
    title: "$Title"
    description: "$Description"
    priority: $priorityValue
  }) {
    success
    issue {
      id
      identifier
      title
      url
    }
  }
}
"@

$body = @{ query = $query } | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.linear.app/graphql" `
                                   -Method POST `
                                   -Headers $headers `
                                   -Body $body `
                                   -UseBasicParsing

    if ($response.data.issueCreate.success) {
        $issue = $response.data.issueCreate.issue
        Write-Host "SUCCESS: Bug created in Linear"
        Write-Host "Issue ID: $($issue.identifier)"
        Write-Host "URL: $($issue.url)"
        return $issue
    } else {
        Write-Host "ERROR: Failed to create issue in Linear"
        exit 1
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)"
    exit 1
}
