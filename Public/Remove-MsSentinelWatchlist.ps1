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
        [string]$AliasName
    )

    begin {
        Get-MsSentinelContext
        Get-MsSentinelWorkspace -WorkspaceName $WorkspaceName
    }
    process {
        if ($null -ne $workspace) {
            $apiVersion = '?api-version=2021-09-01-preview'
            $baseUri = '{0}/providers/Microsoft.SecurityInsights' -f $workspace.ResourceId
            $resourcePath = '{0}/watchlists/{1}{2}' -f $baseUri, $AliasName, $apiVersion
        }
        else {
            Write-Output "[-] Unable to to get Log Analytics workspace"
        }

        $_resource = Invoke-AzRestMethod -Path $resourcePath
        if ($null -ne $_resource) {
            try {
                Write-Verbose "[-] Found watchlist with name [$($AliasName)]."
            }
            catch {
                Write-Error 'Unable to retrieve the watchlist'
                exit
            }
        }

        try {
            $result = Invoke-AzRestMethod -Path $resourcePath -Method DELETE
            if ($result.StatusCode -eq 200) {
                Write-Verbose "[-] Resource with name $($AliasName) has been removed."
            }
            else {
                Write-Output $result | ConvertFrom-Json
            }
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to remove the resource with error code: $($_.Exception.Message)" -ErrorAction Stop
        }
        Write-Verbose "[+] Post any feature requests or issues on https://github.com/SecureHats/SecureHacks/issues`n"
    }
}
