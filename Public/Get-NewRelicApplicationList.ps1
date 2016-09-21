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
                        @{N="LastReportedAt";E={"$(Get-Date "$($_.last_reported_at)" -Format G) $([TimeZoneInfo]::Local.BaseUtcOffset.ToString())"}},`
                        @{N="HealthStatus";E={$_.health_status}},`
                        @{N="Throughput";E={$_.application_summary.throughput}},`
                        @{N="ResponseTime";E={$_.application_summary.response_time}},`
                        @{N="ErrorRate";E={$_.application_summary.error_rate}},`
                        @{N="ApdexTarget";E={$_.application_summary.apdex_target}},`
                        @{N="ApdexScore";E={$_.application_summary.apdex_score}},`
                        @{N="HostCount";E={$_.application_summary.host_count}},`
                        @{N="InstanceCount";E={$_.application_summary.instance_count}}
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
                    @{N="LastReportedAt";E={"$(Get-Date "$($_.last_reported_at)" -Format G) $([TimeZoneInfo]::Local.BaseUtcOffset.ToString())"}},`
                    @{N="HealthStatus";E={$_.health_status}},`
                    @{N="Throughput";E={$_.application_summary.throughput}},`
                    @{N="ResponseTime";E={$_.application_summary.response_time}},`
                    @{N="ErrorRate";E={$_.application_summary.error_rate}},`
                    @{N="ApdexTarget";E={$_.application_summary.apdex_target}},`
                    @{N="ApdexScore";E={$_.application_summary.apdex_score}},`
                    @{N="HostCount";E={$_.application_summary.host_count}},`
                    @{N="InstanceCount";E={$_.application_summary.instance_count}}
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