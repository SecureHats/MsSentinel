#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Remove-MsSentinelWatchlist {
    <#
  .Synopsis
     Removes a Microsoft Sentinel Watchlist
  .DESCRIPTION
  This function...
  .PARAMETER WorkspaceName
  Enter the...
  .EXAMPLE
     New-MsSentinelxxx -WorkspaceName 'MyWorkspace'
  #>

    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$WatchlistAlias
    )

    begin {
        try {
            if (!($context)) { Get-MsSentinelContext }
            Get-MsSentinelWorkspace -WorkspaceName $WorkspaceName
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    process {
        if ($null -ne $workspace) {
            $apiVersion = '?api-version=2021-09-01-preview'
            $resourcePath = '{0}/watchlists/{1}{2}' -f $baseUri, $WatchlistAlias, $apiVersion
        } else {
            Write-Output "[-] Unable to to get Log Analytics workspace"
        }

        $_resource = Invoke-AzRestMethod -Path $resourcePath

        if ($_resource.StatusCode -eq 200) {
                Write-Verbose "[-] Found watchlist with name [$($WatchlistAlias)]."
        } else {
            Write-Output '[-] Unable to retrieve the watchlist'
            break
        }

        try {
            $result = Invoke-AzRestMethod -Path $resourcePath -Method DELETE
            if ($result.StatusCode -eq 200) {
                Write-Verbose "[-] Resource with name $($WatchlistAlias) has been removed."
            }
            else {
                Write-Output "[-] $(($result.Content | ConvertFrom-Json).error.message)"
            }
        }
        catch {
            Write-Error "[-] Unable to remove the resource with error code: $($_.Exception.Message)" -ErrorAction Stop
        }
        Write-Verbose "[+] Post any feature requests or issues on https://github.com/SecureHats/SecureHacks/issues`n"
    }
}
