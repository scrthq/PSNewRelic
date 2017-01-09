function Invoke-NRQLQuery {
    [cmdletbinding(DefaultParameterSetName="Query")]
    Param
    (
      [parameter(Mandatory=$false)]
      [ValidateSet("Insert","Query")]
      [string]
      $Type="Query",
      [parameter(Mandatory=$true,ParameterSetName="Query")]
      [ValidateNotNullOrEmpty()]
      [string]
      $Query,
      [parameter(Mandatory=$true,ParameterSetName="Insert")]
      [ValidateScript({if([string]::IsNullOrWhiteSpace("$($_.eventType)")){throw "The ObjectsToInsert parameter requires a property of 'eventType' on all objects, as this is how New Relic Insights categorizes them."}else{$true}})]
      [object[]]
      $ObjectsToInsert,
      [parameter(Mandatory=$false)]
      [switch]
      $Raw,
      [parameter(Mandatory=$false,ParameterSetName="Query")]
      [ValidateNotNullOrEmpty()]
      [String]
      $InsightsQueryKey=$Script:PSNewRelic.InsightsQueryKey,
      [parameter(Mandatory=$false,ParameterSetName="Insert")]
      [ValidateNotNullOrEmpty()]
      [String]
      $InsightsInsertKey=$Script:PSNewRelic.InsightsInsertKey,
      [parameter(Mandatory=$false)]
      [ValidateNotNullOrEmpty()]
      [String]
      $AccountID=$Script:PSNewRelic.AccountID
    )
if ($Type -eq "Query")
    {
    $headers = @{
        "X-Query-Key" = $InsightsQueryKey
        }
    $RestParams=@{
        Method = "Get"
        ContentType = "application/json"
        Headers = $headers
        }
    $URI = "https://insights-api.newrelic.com/v1/accounts/$AccountID/query?nrql=$InsightsQuery"
    }
elseif ($Type -eq "Insert")
    {
    $headers = @{
        "X-Insert-Key" = $InsightsInsertKey
        }
    $body = $($ObjectsToInsert | ConvertTo-Json -Depth 2)
    $RestParams=@{
        Method = "Post"
        ContentType = "application/json"
        Headers = $headers
        Body = $body
        }
    $URI = "https://insights-collector.newrelic.com/v1/accounts/$AccountID/events"
    }
try
    {
    $response = Invoke-RestMethod -Uri $URI @RestParams
    }
catch
    {
    Write-Error $Error[0].Exception.Message
    return
    }
return $response
}