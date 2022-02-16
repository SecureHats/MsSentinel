#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-MsSentinelWatchlist {
    <#
.Synopsis
   Create a Microsoft Sentinel Watchlist
.DESCRIPTION
   This function can be used to create a Microsoft Sentinel watchlist with content from a csv file.
.PARAMETER WorkspaceName
Enter the Workspace name
.PARAMETER ResourceGroupName
Enter the Workspace name
.PARAMETER AliasName
Enter the aliasname for the watchlist
.EXAMPLE
Returns a watchlist from a workspace
Get-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -AliasName 'MyWatchlist'
.EXAMPLE
Returns all watchlists in a workspace
Get-MsSentinelWatchlist -WorkspaceName 'MyWorkspace'
.EXAMPLE
Returns all watchlists in a workspace in a specific resource group
Get-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -ResourceGroupName 'MyResourceGroup'
#>

    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 1)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]$AliasName,

        [Parameter(Mandatory = $false)]
        [string]$ApiVersion = '2021-09-01-preview'
    )

    begin {
        $argHash = @{
            workspaceName = $workspaceName
        }
        if ($ResourceGroupName) { $argHash.ResourceGroupName = $ResourceGroupName }

        Get-MsSentinelContext
        Get-MsSentinelWorkspace @argHash
    }
    process {
        if ($null -ne $workspace) {
            $_apiVersion = '?api-version={0}' -f $ApiVersion
            $baseUri = '{0}/providers/Microsoft.SecurityInsights' -f $workspace.ResourceId
            $watchlistUri = '{0}/watchlists/{1}{2}' -f $baseUri, $AliasName, $_apiVersion
        }
        else {
            Write-Output "Unable to retrieve Log Analytics workspace [$($WorkspaceName)]"
            break
        }

        try {
            $result = Invoke-AzRestMethod -Path $watchlistUri -Method GET

            if ($result.StatusCode -eq 200) {
                if ($AliasName) {
                    $watchlist = ($result.Content | ConvertFrom-Json).properties
                } else {
                    $watchlist = ($result.Content | ConvertFrom-Json).value.properties
                }
                return $watchlist
            } else {
                Write-Error ($result.Content | ConvertFrom-Json).error.Message
            }
        }
        catch {
            Write-Error "Unable to get the watchlist with error code: $($_.Exception.Message)" -ErrorAction Stop
        }
        Write-Output "`n[+] Post any feature requests or issues on https://github.com/SecureHats/SecureHacks/issues`n"
    }
}
