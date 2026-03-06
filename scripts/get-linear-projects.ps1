$headers = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u'
}

$body = @{
    query = "query { teams { nodes { id name key projects { nodes { id name } } } } }"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri 'https://api.linear.app/graphql' -Method POST -Headers $headers -Body $body -UseBasicParsing
    $response.data.teams.nodes | ForEach-Object {
        Write-Host "Team: $($_.name) - ID: $($_.id)"
        $_.projects.nodes | ForEach-Object { Write-Host "  Project: $($_.name) - ID: $($_.id)" }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
