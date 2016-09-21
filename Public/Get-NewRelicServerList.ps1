function Get-NewRelicServerList {
    [cmdletbinding(DefaultParameterSetName="AllPages")]
    Param
    (
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
            $URI = "https://api.newrelic.com/v2/servers.json?page=$i"
            $result = Invoke-RestMethod -Method Get -Uri $URI -ContentType "application/json" -Headers $headers | Select-Object -ExpandProperty Servers
            if (!$Raw)
                {
                $result = $result | 
                    Select-Object -Property `
                        @{N="ID";E={$_.ID}},`
                        @{N="Name";E={$_.Name}},`
                        @{N="Host";E={$_.Host}},`
                        @{N="Reporting";E={$_.Reporting}},`
                        @{N="HealthStatus";E={$_.health_status}},`
                        @{N="LastReportedAt";E={$_.last_reported_at}},`
                        @{N="CPUPercentage";E={$_.summary.cpu}},`
                        @{N="CPUStolen";E={$_.summary.cpu_stolen}},`
                        @{N="MemoryPercentage";E={$_.summary.memory}},`
                        @{N="MemoryUsed";E={$_.summary.memory_used}},`
                        @{N="MemoryTotal";E={$_.summary.memory_total}},`
                        @{N="DiskIO";E={$_.summary.disk_io}},`
                        @{N="FullestDisk";E={$_.summary.fullest_disk}},`
                        @{N="FullestDiskFree";E={$_.summary.fullest_disk_free}}
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
        $response = Invoke-RestMethod -Method Get -Uri $URI -ContentType "application/json" -Headers $headers | Select-Object -ExpandProperty Servers
        if (!$Raw)
            {
            $response = $response | 
                Select-Object -Property `
                    @{N="ID";E={$_.ID}},`
                    @{N="Name";E={$_.Name}},`
                    @{N="Host";E={$_.Host}},`
                    @{N="Reporting";E={$_.Reporting}},`
                    @{N="HealthStatus";E={$_.health_status}},`
                    @{N="LastReportedAt";E={$_.last_reported_at}},`
                    @{N="CPUPercentage";E={$_.summary.cpu}},`
                    @{N="CPUStolen";E={$_.summary.cpu_stolen}},`
                    @{N="MemoryPercentage";E={$_.summary.memory}},`
                    @{N="MemoryUsed";E={$_.summary.memory_used}},`
                    @{N="MemoryTotal";E={$_.summary.memory_total}},`
                    @{N="DiskIO";E={$_.summary.disk_io}},`
                    @{N="FullestDisk";E={$_.summary.fullest_disk}},`
                    @{N="FullestDiskFree";E={$_.summary.fullest_disk_free}}
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