function Set-PSNewRelicConfig {
    [cmdletbinding()]
    param(
        [string]$APIKey,
        [string]$Path = "$ModuleRoot\$env:USERNAME-$env:COMPUTERNAME-PSNewRelic.xml"
    )

Switch ($PSBoundParameters.Keys)
    {
    'APIKey'{$Script:PSNewRelic.APIKey = $APIKey}
    }
Function Encrypt {
    param([string]$string)
    if($String -notlike '')
        {
        ConvertTo-SecureString -String $string -AsPlainText -Force
        }
    }
#Write the global variable and the xml
$Script:PSNewRelic | Select -Property @{N='APIKey';E={Encrypt $_.APIKey}} | Export-Clixml -Path $Path -Force
}