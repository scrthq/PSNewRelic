function Set-PSNewRelicConfig {
    [cmdletbinding()]
    param(
        [string]$AccountID,
        [string]$APIKey,
        [string]$AdminAPIKey,
        [string]$InsightsInsertKey,
        [string]$InsightsQueryKey,
        [string]$Path = "$ModuleRoot\$env:USERNAME-$env:COMPUTERNAME-PSNewRelic.xml"
    )

Switch ($PSBoundParameters.Keys)
    {
    'AccountID'{$Script:PSNewRelic.AccountID = $AccountID}
    'APIKey'{$Script:PSNewRelic.APIKey = $APIKey}
    'AdminAPIKey'{$Script:PSNewRelic.AdminAPIKey = $AdminAPIKey}
    'InsightsInsertKey'{$Script:PSNewRelic.InsightsInsertKey = $InsightsInsertKey}
    'InsightsQueryKey'{$Script:PSNewRelic.InsightsQueryKey = $InsightsQueryKey}
    }
Function Encrypt {
    param([string]$string)
    if($String -notlike '')
        {
        ConvertTo-SecureString -String $string -AsPlainText -Force
        }
    }
#Write the global variable and the xml
$Script:PSNewRelic | Select -Property @{N="AccountID";E={Encrypt $_.AccountID}},@{N='APIKey';E={Encrypt $_.APIKey}},@{N='AdminAPIKey';E={Encrypt $_.AdminAPIKey}},@{N='InsightsInsertKey';E={Encrypt $_.InsightsInsertKey}},@{N='InsightsQueryKey';E={Encrypt $_.InsightsQueryKey}} | Export-Clixml -Path $Path -Force
}