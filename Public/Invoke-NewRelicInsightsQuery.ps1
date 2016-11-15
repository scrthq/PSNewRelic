function Invoke-NewRelicInsightsQuery {
    [cmdletbinding()]
    Param
    (
      [parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $InsightsQuery,
      [parameter(Mandatory=$false)]
      [switch]
      $Raw,
      [parameter(Mandatory=$false)]
      [ValidateNotNullOrEmpty()]
      [String]
      $InsightsQueryKey=$Script:PSNewRelic.InsightsQueryKey,
      [parameter(Mandatory=$false)]
      [ValidateNotNullOrEmpty()]
      [String]
      $AccountID=$Script:PSNewRelic.AccountID
    )
$headers = @{
    "X-Query-Key" = $InsightsQueryKey
    }
$RestParams=@{
    Method = "Get"
    ContentType = "application/json"
    Headers = $headers
    }
try
    {
    $URI = "https://insights-api.newrelic.com/v1/accounts/$AccountID/query?nrql=$InsightsQuery"
    $response = Invoke-RestMethod -Uri $URI @RestParams
    }
catch
    {
    Write-Error $Error[0]
    return
    }
return $response
}