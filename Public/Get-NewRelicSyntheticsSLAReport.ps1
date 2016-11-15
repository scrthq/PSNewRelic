function Get-NewRelicSyntheticsSLAReport {
    [cmdletbinding(DefaultParameterSetName="Weeks")]
    Param
    (
      [parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $MonitorName,
      [parameter(Mandatory=$false,ParameterSetName="Weeks")]
      [ValidateNotNullOrEmpty()]
      [int]
      $CountOfWeeks = 1,
      [parameter(Mandatory=$false,ParameterSetName="Days")]
      [ValidateNotNullOrEmpty()]
      [int]
      $CountOfDays = 1,
      [parameter(Mandatory=$false)]
      [switch]
      $Raw,
      [parameter(Mandatory=$false)]
      [ValidateNotNullOrEmpty()]
      [String]
      $InsightsQueryKey=$Script:PSNewRelic.InsightsQueryKey,
      [parameter(Mandatory=$false)]
      [ValidateNotNullOrEmpty()]
      [String]
      $AccountID=$Script:PSNewRelic.AccountID
    )
if ($CountOfWeeks)
    {
    $Count = $CountOfWeeks
    $Period = "week"
    }
if ($CountOfDays)
    {
    $Count = $CountOfDays
    $Period = "day"
    }
if ($Count -gt 1)
    {
    $Period += "s"
    }
$insightsQuery = "SELECT average(duration), apdex(duration, 7000), percentage(count(*), WHERE result='SUCCESS') FROM SyntheticCheck FACET dateOf(timestamp) SINCE $Count $Period ago WHERE monitorName='$MonitorName'"
if ($CountOfWeeks)
    {
    $insightsQuery += " LIMIT $(($CountOfWeeks * 7) +1)"
    }
$response = Invoke-NewRelicInsightsQuery -InsightsQuery $insightsQuery
if ($Raw)
    {
    return $response
    }
else
    {
    $formatted = @()
    foreach ($item in $response.facets)
        {
        $formatted += $item | 
            Select-Object @{N="date";E={Get-Date $_.name -Format d}},
                          @{N="duration (ms)";E={$_.results[0].average}},
                          @{N="apdex";E={$_.results[1].score}},
                          @{N="# satisfied";E={$_.results[1].s}},
                          @{N="# tolerating";E={$_.results[1].t}},
                          @{N="# frustrated";E={$_.results[1].f}},
                          @{N="# total";E={$_.results[1].count}},
                          @{N="% uptime";E={$_.results[2].result}}
        }
    return $formatted | sort date
    }
}