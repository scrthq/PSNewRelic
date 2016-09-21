function Get-NewRelicApplicationList {
    [cmdletbinding(DefaultParameterSetName="AllPages")]
    Param
    (
      [parameter(Mandatory=$false)]
      [string]
      $Name,
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
$body = @{}
$RestParams=@{
    Method = "Get"
    ContentType = "application/json"
    Headers = $headers
    }
if ($Name){
    $body.Add("filter[name]",$Name)
    }
if($body.Count)
    {
    $RestParams.Add("Body",$body)
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
            $URI = "https://api.newrelic.com/v2/applications.json?page=$i"
            $result = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty applications
            if(!$Raw)
                {
                $result = $result | 
                    Select-Object -Property `
                        @{N="ID";E={$_.ID}},`
                        @{N="Name";E={$_.Name}},`
                        @{N="Language";E={$_.Language}},`
                        @{N="Reporting";E={$_.Reporting}},`
                        @{N="App_HealthStatus";E={$_.health_status}},`
                        @{N="App_Throughput";E={$_.application_summary.throughput}},`
                        @{N="App_ResponseTime";E={$_.application_summary.response_time}},`
                        @{N="App_ErrorRate";E={$_.application_summary.error_rate}},`
                        @{N="App_ApdexTarget";E={$_.application_summary.apdex_target}},`
                        @{N="App_ApdexScore";E={$_.application_summary.apdex_score}},`
                        @{N="App_HostCount";E={$_.application_summary.host_count}},`
                        @{N="App_InstanceCount";E={$_.application_summary.instance_count}}
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
        $URI = "https://api.newrelic.com/v2/applications.json?page=$PageNumber"
        $response = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty applications
        if(!$Raw)
            {
            $response = $response | 
                Select-Object -Property `
                    @{N="ID";E={$_.ID}},`
                    @{N="Name";E={$_.Name}},`
                    @{N="Language";E={$_.Language}},`
                    @{N="Reporting";E={$_.Reporting}},`
                    @{N="App_HealthStatus";E={$_.health_status}},`
                    @{N="App_Throughput";E={$_.application_summary.throughput}},`
                    @{N="App_ResponseTime";E={$_.application_summary.response_time}},`
                    @{N="App_ErrorRate";E={$_.application_summary.error_rate}},`
                    @{N="App_ApdexTarget";E={$_.application_summary.apdex_target}},`
                    @{N="App_ApdexScore";E={$_.application_summary.apdex_score}},`
                    @{N="App_HostCount";E={$_.application_summary.host_count}},`
                    @{N="App_InstanceCount";E={$_.application_summary.instance_count}}
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