﻿function Get-NewRelicApplicationList {
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
            $URI = "https://api.newrelic.com/v2/applications.json?page=$i"
            $result = Invoke-RestMethod -Method Get -Uri $URI -ContentType "application/json" -Headers $headers | Select-Object -ExpandProperty applications
            $response += $result
            }
        catch
            {
            Write-Error $Error[0]
            }
        }
    until (!$result)
    }
else
    {
    $URI = "https://api.newrelic.com/v2/applications.json?page=$PageNumber"
    $response = Invoke-RestMethod -Method Get -Uri $URI -ContentType "application/json" -Headers $headers | Select-Object -ExpandProperty applications
    }
return $response
}