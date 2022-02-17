#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-MsSentinelWatchlistItems {
    <#
  .Synopsis
    Updates a Microsoft Sentinel Watchlist item
  .DESCRIPTION
    This function can be used to add or remove Microsoft Sentinel Watchlist items
  .PARAMETER WorkspaceName
    Enter the name of the Log Analytics workspace
  .PARAMETER WatchlistAlias
    Enter the name of the Log Analytics workspace
  .EXAMPLE
    Get-MsSentinelWatchlistItems -WorkspaceName 'MyWorkspace' -WatchlistAlias 'MyList'
  #>

    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$WatchlistAlias
    )

    begin {
      $_apiVersion = '2021-09-01-preview'

      $argHash = @{
            workspaceName = $workspaceName
        }
        if ($ResourceGroupName) { $argHash.ResourceGroupName = $ResourceGroupName }

        if (!($context)) { Get-MsSentinelContext }
        Get-MsSentinelWorkspace @argHash
    }
    process {
        if ($null -ne $workspace) {
            $apiVersion = '?api-version={0}' -f $_apiVersion
            $resourcePath = '{0}/watchlists/{1}/watchlistItems{2}' -f $baseUri, $WatchlistAlias, $apiVersion
        }
        else {
            Write-Output "Unable to retrieve Log Analytics workspace [$($WorkspaceName)]"
            break
        }

        try {
            $result = Invoke-AzRestMethod -Path $resourcePath -Method GET

            if ($result.StatusCode -eq 200) {
                $watchlistItems = ($result.Content | ConvertFrom-Json).value.properties
                return $watchlistItems
            } else {
                Write-Error ($result.Content | ConvertFrom-Json).error.Message
            }
        }
        catch {
            Write-Error "Unable to get the resource with error code: $($_.Exception.Message)" -ErrorAction Stop
        }
        Write-Verbose "[+] Post any feature requests or issues on https://github.com/SecureHats/SecureHacks/issues`n"
    }
}
