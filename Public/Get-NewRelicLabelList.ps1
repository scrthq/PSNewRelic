function Get-NewRelicLabelList {
    [cmdletbinding(DefaultParameterSetName = "AllPages")]
    Param
    (
        [parameter(Mandatory = $false,ParameterSetName = "PageNum")]
        [int]
        $PageNumber = 1,
        [parameter(Mandatory = $false,ParameterSetName = "AllPages")]
        [switch]
        $AllPages = $true,
        [parameter(Mandatory = $false)]
        [switch]
        $Raw,
        [parameter(Mandatory = $false)]
        [String]
        $APIKey = $Script:PSNewRelic.APIKey
    )
    $headers = @{
        "X-Api-Key" = $APIKey
    }
    $body = @{}
    $RestParams = @{
        Method      = "Get"
        ContentType = "application/json"
        Headers     = $headers
    }
    if ($body.Count) {
        $RestParams.Add("Body",$body)
    }
    if ($AllPages) {
        $response = @()
        $i = 0
        do {
            try {
                $i++
                $URI = "https://api.newrelic.com/v2/labels.json?page=$i"
                $result = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty labels
                if (!$Raw) {
                    $result = $result | Select-Object -Property key,category,name,@{N = "applications";E = {$_.links.applications}}
                }
                $response += $result
            }
            catch {
                Write-Error $Error[0]
                return
            }
        }
        until (!$result)
    }
    else {
        try {
            $URI = "https://api.newrelic.com/v2/applications.json?page=$PageNumber"
            $response = Invoke-RestMethod -Uri $URI @RestParams | Select-Object -ExpandProperty applications
            if (!$Raw) {
                $response = $response | Select-Object -Property key,category,name,@{N = "applications";E = {$_.links.applications}}
            }
        }
        catch {
            Write-Error $Error[0]
            return
        }
    }
    return $response
}