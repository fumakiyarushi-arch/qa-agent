$Headers = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'lin_api_c9OinLCKxJwtwfsEVUiiIU8zyW0EPWFj1Xk3ZM4u'
}
$Query = @{
    query = 'query { issues(first: 20, filter: { team: { id: { eq: "638a7e02-83d1-412b-b99e-ba5f54e62f03" } } }) { nodes { id identifier title description } } }'
}

$response = Invoke-RestMethod -Uri 'https://api.linear.app/graphql' -Method Post -Headers $Headers -Body ($Query | ConvertTo-Json -Depth 5)
$response.data.issues.nodes | Format-List identifier, title, id
