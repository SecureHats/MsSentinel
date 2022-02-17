#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Update-MsSentinelWatchlistItems {
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
  This example will remove one or more items from a watchlist matching the watchlist item value
  Update-MsSentinelWatchlistItems -WorkspaceName 'MyWorkspace' -WatchlistAlias 'MyList' -WatchlistItem 'Umbrella' -Remove
  .EXAMPLE
  This example Add or update an existing item in a watchlist matching the watchlist item value
  $itemsKeyValue = @{
        Enabled         = 'True'
        ConnectorName   = 'NewConnector'
        DisplayName     = 'My Connector'
        Provider        = 'Microsoft'
    }
  Update-MsSentinelWatchlistItems -WorkspaceName 'MyWorkspace' -WatchlistAlias 'MyList' -WatchlistItem 'OldConnector' -itemsKeyValue $itemsKeyValue
  #>

    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$WatchlistAlias,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 2)]
        [string]$WatchlistItem,

        # comma separated list
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 3)]
        [psobject]$itemsKeyValue,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 4)]
        [switch]$Remove,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = '2021-09-01-preview'
    )

    begin {
        $argHash = @{
            workspaceName = $workspaceName
        }
        if ($ResourceGroupName) { $argHash.ResourceGroupName = $ResourceGroupName }

        if (!($context)) { Get-MsSentinelContext }
        Get-MsSentinelWorkspace @argHash
        $watchlistItems = Get-MsSentinelWatchlistItems -WorkspaceName $WorkspaceName -WatchlistAlias $WatchlistAlias
    }
    process {
        ### This part breaks when multiple results are found. / Might need to search on SearchKey Column only!
        # if ($null -ne $workspace) {

        #     $WatchlistItemId = ($watchlistItems | Where-Object { $_.itemsKeyValue.psobject.Members.value -like "*$WatchlistItem*" }).watchlistItemId
        #     $apiVersion = '?api-version=2021-09-01-preview'

        #     if (!($WatchlistItemId)) { $WatchlistItemId = (New-Guid).Guid }
        #     $resourcePath = '{0}/watchlists/{1}/watchlistItems/{2}{3}' -f $baseUri, $WatchlistAlias, $WatchlistItemId, $apiVersion
        # }
        else {
            Write-Output "Unable to retrieve Log Analytics workspace [$($WorkspaceName)]"
            break
        }

        try {
            $httpRequest = @{
                Path   = $resourcePath
                Method = 'PUT'
            }

            if ($itemsKeyValue) {
                $payload = @{
                    properties = @{
                        itemsKeyValue = $itemsKeyValue
                    }
                }
                $httpRequest.Payload = ($payload | ConvertTo-Json)
            }

            if ($true -eq $Remove) {
                $httpRequest.method = 'DELETE'
            }
            $result = Invoke-AzRestMethod @httpRequest

            if ($result.StatusCode -eq 200) {
                $watchlistItems = ($result.Content | ConvertFrom-Json).properties
                return $result
            }
            else {
                Write-Error ($result.Content | ConvertFrom-Json).error.Message
            }
        }
        catch {
            Write-Error "Unable to get the resource with error code: $($_.Exception.Message)" -ErrorAction Stop
        }
        Write-Verbose "[+] Post any feature requests or issues on https://github.com/SecureHats/SecureHacks/issues`n"
    }
}