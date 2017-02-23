function Get-NewRelicDeploymentList {
    [cmdletbinding(DefaultParameterSetName="AllPages")]
    Param
    (
      [parameter(Mandatory=$true)]
      [string]
      $ApplicationID,
      [parameter(Mandatory=$false)]
      [string]
      $ApplicationName,
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
$RestParams=@{
    Method = "Get"
    ContentType = "application/json"
    Headers = $headers
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
            $URI = "https://api.newrelic.com/v2/applications/$ApplicationID/deployments.json?page=$i"
            $result = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty deployments
            if(!$Raw)
                {
                $result = $result | 
                    Select-Object -Property `
                        @{N="ID";E={$_.ID}},
                        @{N="Revision";E={$_.revision}},
                        @{N="ChangeLog";E={$_.changelog}},
                        @{N="Description";E={$_.description}},
                        @{N="User";E={$_.user}},
                        @{N="Timestamp";E={[datetime]$_.timestamp}},
                        @{N="ApplicationID";E={$_.links.application}},
                        @{N="ApplicationName";E={if($ApplicationName){$ApplicationName}}}
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
        $URI = "https://api.newrelic.com/v2/applications/$ApplicationID/deployments.json?page=$PageNumber"
        $response = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty applications
        if(!$Raw)
            {
            $response = $response | 
                Select-Object -Property `
                    @{N="ID";E={$_.ID}},
                    @{N="Revision";E={$_.revision}},
                    @{N="ChangeLog";E={$_.changelog}},
                    @{N="Description";E={$_.description}},
                    @{N="User";E={$_.user}},
                    @{N="Timestamp";E={[datetime]$_.timestamp}},
                    @{N="ApplicationID";E={$_.links.application}},
                    @{N="ApplicationName";E={if($ApplicationName){$ApplicationName}}}
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