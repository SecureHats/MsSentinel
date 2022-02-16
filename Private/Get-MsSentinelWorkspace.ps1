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
      [string]$WorkspaceName
  )
      
  try {
    $script:workspace = Get-AzResource -Name $WorkspaceName -ResourceType 'Microsoft.OperationalInsights/workspaces'
    if ($null -eq $workspace) {
      Write-Error "Unable to get Log Analytics workspace"
    }
  }
  catch {
    Write-Error "Unable to get the Log Analytics workspace"
  }
}
