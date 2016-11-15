function Get-NewRelicSyntheticsMonitorList {
    [cmdletbinding()]
    Param
    (
      [parameter(Mandatory=$false)]
      [switch]
      $Raw,
      [parameter(Mandatory=$false)]
      [ValidateNotNullOrEmpty()]
      [String]
      $AdminAPIKey=$Script:PSNewRelic.AdminAPIKey,
      [parameter(Mandatory=$false)]
      [ValidateNotNullOrEmpty()]
      [String]
      $AccountID=$Script:PSNewRelic.AccountID
    )
$RestParams=@{
    Method = "Get"
    ContentType = "application/json"
    Headers = @{"X-API-Key" = $AdminAPIKey}
    Uri = "https://synthetics.newrelic.com/synthetics/api/v3/monitors"
    }
try
    {
    $response = Invoke-RestMethod @RestParams
    }
catch
    {
    $Error[0]
    }
return $response
}