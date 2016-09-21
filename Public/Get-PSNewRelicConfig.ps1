Function Get-PSNewRelicConfig {
    [cmdletbinding(DefaultParameterSetName = 'source')]
    param(
        [parameter(ParameterSetName='source')]
        [ValidateSet("PSNewRelic","PSNewRelic.xml")]
        $Source = "PSNewRelic",

        [parameter(ParameterSetName='path')]
        [parameter(ParameterSetName='source')]
        $Path = "$ModuleRoot\$env:USERNAME-$env:COMPUTERNAME-PSNewRelic.xml"
    )
if($PSCmdlet.ParameterSetName -eq 'source' -and $Source -eq "PSNewRelic" -and -not $PSBoundParameters.ContainsKey('Path'))
    {
    $Script:PSNewRelic
    }
else
    {
    function Decrypt {
        param($String)
        if($String -is [System.Security.SecureString])
            {
            [System.Runtime.InteropServices.marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.marshal]::SecureStringToBSTR(
                    $string))
            }
        }
    Import-Clixml -Path $Path | Select -Property @{N='APIKey';E={Decrypt $_.APIKey}}
    }
}