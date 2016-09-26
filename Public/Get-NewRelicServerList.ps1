function Get-NewRelicServerList {
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
            $URI = "https://api.newrelic.com/v2/servers.json?page=$i"
            $result = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty Servers
            if (!$Raw)
                {
                $result = $result | 
                    Select-Object -Property `
                        @{N="ID";E={$_.ID}},`
                        @{N="Name";E={$_.Name}},`
                        @{N="Host";E={$_.Host}},`
                        @{N="Reporting";E={$_.Reporting}},`
                        @{N="LastReportedAt";E={"$(Get-Date "$($_.last_reported_at)" -Format G) $([TimeZoneInfo]::Local.BaseUtcOffset.ToString())"}},`
                        @{N="HealthStatus";E={$_.health_status}},`
                        @{N="CPU";E={if($_.summary.cpu){"$($_.summary.cpu)%"}}},`
                        @{N="CPUStolen";E={$_.summary.cpu_stolen}},`
                        @{N="Memory";E={if($_.summary.memory){"$($_.summary.memory)%"}}},`
                        @{N="MemoryUsed";E={if($_.summary.memory_used){"$([math]::round($($_.summary.memory_used / 1GB),2)) GB"}}},`
                        @{N="MemoryTotal";E={if($_.summary.memory_total){"$([math]::round($($_.summary.memory_total / 1GB),2)) GB"}}},`
                        @{N="DiskIO";E={if($_.summary.disk_io){"$($_.summary.disk_io)%"}}},`
                        @{N="FullestDisk";E={if($_.summary.fullest_disk){"$($_.summary.fullest_disk)%"}}},`
                        @{N="FullestDiskFree";E={if($_.summary.fullest_disk_free){"$([math]::round($($_.summary.fullest_disk_free / 1GB),2)) GB"}}}
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
        $URI = "https://api.newrelic.com/v2/servers.json?page=$PageNumber"
        $response = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty Servers
        if (!$Raw)
            {
            $response = $response | 
                Select-Object -Property `
                    @{N="ID";E={$_.ID}},`
                    @{N="Name";E={$_.Name}},`
                    @{N="Host";E={$_.Host}},`
                    @{N="Reporting";E={$_.Reporting}},`
                    @{N="LastReportedAt";E={"$(Get-Date "$($_.last_reported_at)" -Format G) $([TimeZoneInfo]::Local.BaseUtcOffset.ToString())"}},`
                    @{N="HealthStatus";E={$_.health_status}},`
                    @{N="CPU";E={if($_.summary){"$($_.summary.cpu)%"}}},`
                    @{N="CPUStolen";E={$_.summary}},`
                    @{N="Memory";E={if($_.summary){"$($_.summary.memory)%"}}},`
                    @{N="MemoryUsed";E={if($_.summary){"$([math]::round($($_.summary.memory_used / 1GB),2)) GB"}}},`
                    @{N="MemoryTotal";E={if($_.summary){"$([math]::round($($_.summary.memory_total / 1GB),2)) GB"}}},`
                    @{N="DiskIO";E={if($_.summary){"$($_.summary.disk_io)%"}}},`
                    @{N="FullestDisk";E={if($_.summary){"$($_.summary.fullest_disk)%"}}},`
                    @{N="FullestDiskFree";E={if($_.summary){"$([math]::round($($_.summary.fullest_disk_free / 1GB),2)) GB"}}}
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