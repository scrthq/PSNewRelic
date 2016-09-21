function Get-NewRelicApplicationHostList {
    [cmdletbinding(DefaultParameterSetName="AllPages")]
    Param
    (
      [parameter(Mandatory=$true)]
      [String]
      $ApplicationID,
      [parameter(Mandatory=$false,ParameterSetName="PageNum")]
      [int]
      $PageNumber=1,
      [parameter(Mandatory=$false,ParameterSetName="AllPages")]
      [switch]
      $AllPages=$true,
      [parameter(Mandatory=$false)]
      [switch]
      $Raw,
      [parameter(Mandatory=$false)]
      [String]
      $APIKey=$Script:PSNewRelic.APIKey
    )
$headers = @{
    "X-Api-Key" = $APIKey
    }
if ($AllPages)
    {
    $response = @()
    $i=0
    do
        {
        try
            {
            $i++
            $URI = "https://api.newrelic.com/v2/applications/$ApplicationID/hosts.json?page=$i"
            $result = Invoke-RestMethod -Method Get -Uri $URI -ContentType "application/json" -Headers $headers | Select-Object -ExpandProperty application_hosts
            if (!$Raw)
                {
                $result = $result |
                    Select-Object -Property `
                        @{N="Host_ID";E={$_.ID}},`
                        @{N="Host_Name";E={$_.Language}},`
                        @{N="App_Name";E={$_.Name}},`
                        @{N="App_Language";E={$_.Language}},`
                        @{N="App_HealthStatus";E={$_.health_status}},`
                        @{N="App_Throughput";E={$_.application_summary.throughput}},`
                        @{N="App_ResponseTime";E={$_.application_summary.response_time}},`
                        @{N="App_ErrorRate";E={$_.application_summary.error_rate}},`
                        @{N="App_ApdexScore";E={$_.application_summary.apdex_score}}
                }
            $response += $result
            }
        catch
            {
            Write-Error $Error[0]
            return
            }
        }
    until (!$result)
    }
else
    {
    try
        {
        $URI = "https://api.newrelic.com/v2/applications/$ApplicationID/hosts.json?page=$PageNumber"
        $response = Invoke-RestMethod -Method Get -Uri $URI -ContentType "application/json" -Headers $headers | Select-Object -ExpandProperty application_hosts
        if (!$Raw)
            {
            $response = $response |
                Select-Object -Property `
                    @{N="Host_ID";E={$_.ID}},`
                    @{N="Host_Name";E={$_.Language}},`
                    @{N="App_Name";E={$_.Name}},`
                    @{N="App_Language";E={$_.Language}},`
                    @{N="App_HealthStatus";E={$_.health_status}},`
                    @{N="App_Throughput";E={$_.application_summary.throughput}},`
                    @{N="App_ResponseTime";E={$_.application_summary.response_time}},`
                    @{N="App_ErrorRate";E={$_.application_summary.error_rate}},`
                    @{N="App_ApdexScore";E={$_.application_summary.apdex_score}}
            }
        }
    catch
        {
        Write-Error $Error[0]
        return
        }
    }
return $response
}