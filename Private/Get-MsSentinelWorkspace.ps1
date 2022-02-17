#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function Get-MsSentinelWorkspace {
    <#
    .Synopsis
        Create a Microsoft Sentinel Watchlist
    .DESCRIPTION
        This function can be used to create a Microsoft Sentinel watchlist with content from a csv file.
    .PARAMETER WorkspaceName
    Enter the Workspace name
    .PARAMETER SubscriptionId
    Enter the Subscription Id of the workspace
    .EXAMPLE
        Get-MsSentinelWorkspace -WorkspaceName 'MyWorkspace'
    #>

    [cmdletbinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkspaceName,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 1)]
        [string]$ResourceGroupName
    )

    begin {
        if (!($context)) { Get-MsSentinelContext }
    }
    process {
        try {
            $argHash = @{
                Name         = $WorkspaceName
                ResourceType = 'Microsoft.OperationalInsights/workspaces'
            }

            if ($ResourceGroupName) { $argHash.resourceGroupName = $ResourceGroupName }
            $script:workspace = Get-AzResource @argHash
            $script:baseUri = '{0}/providers/Microsoft.SecurityInsights' -f $workspace.ResourceId
            if ($null -eq $workspace) {
                Write-Output "Unable to get Log Analytics workspace"
                break
            }
        }
        catch {
            Write-Error "Unexpected Error in function [Get-MsSentinelWorkspace]"
        }
    }
}
