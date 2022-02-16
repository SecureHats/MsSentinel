#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function New-MsSentinelWatchlist {
  <#
.Synopsis
   Create a Microsoft Sentinel Watchlist
.DESCRIPTION
   This function can be used to create a Microsoft Sentinel watchlist with content from a csv file.
.PARAMETER WorkspaceName
Enter the Workspace name
.PARAMETER WatchlistName
Enter the displayName of the watchlist
.PARAMETER AliasName
Enter the aliasname for the watchlist
.PARAMETER ItemsSearchKey
Column name used for indexing. The column should contain unique values
.PARAMETER csvFile
Path to the CSV file containing the watchlist content.
.EXAMPLE
   New-MsSentinelWatchlist -WorkspaceName 'MyWorkspace' -WatchlistName 'MyWatchlist' -AliasName 'MyWatchlist' -itemsSearchKey 'Assets'-csvFile "\examples\examples.csv"
#>


  [cmdletbinding(SupportsShouldProcess)]
  param
  (
      [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
      [ValidateNotNullOrEmpty()]
      [string]$WorkspaceName,

      [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 1)]
      [ValidateNotNullOrEmpty()]
      [string]$WatchlistName,

      [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 2)]
      [ValidateNotNullOrEmpty()]
      [string]$AliasName,

      [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 3)]
      [ValidateNotNullOrEmpty()]
      [string]$itemsSearchKey,

      [Parameter(Mandatory = $false, ValueFromPipeline = $false, Position = 4)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { (Test-Path -Path $_) -and ($_.Extension -in '.csv') })]
      [System.IO.FileInfo]$csvFile
  )

  $workspace = Get-AzResource -Name $WorkspaceName -ResourceType 'Microsoft.OperationalInsights/workspaces'

  if ($null -ne $workspace) {
      $apiVersion = '?api-version=2021-09-01-preview'
      $baseUri = '{0}/providers/Microsoft.SecurityInsights' -f $workspace.ResourceId
      $watchlist = '{0}/watchlists/{1}{2}' -f $baseUri, $AliasName, $apiVersion
  }
  else {
      Write-Output "[-] Unable to retrieve log Analytics workspace"
  }

  if ($null -ne $csvFile) {
      try {
          Write-Verbose "[-] Trying to read CSV content"
          $content = Get-Content $csvFile | ConvertFrom-Csv
          if (($content.$itemsSearchKey).count -eq 0) {
              Write-Host "[-] Invalid 'itemsSearchKey' value provided, check the input file for the correct header.`n"
              exit
          }
          else {
              Write-Verbose "[-] Selected CSV file contains $($($content.$itemsSearchKey).count) items"
          }
      }
      catch {
          Write-Error 'Unable to process CSV file'
          exit
      }

      try {
          Write-Verbose "[-] Converting file file content for [$($csvFile.Name)]"
          foreach ($line in [System.IO.File]::ReadLines($csvFile.FullName)) {
              $rawContent += "$line`r`n"
          }
      }
      catch {
          Write-Error "Unable to process file content"
      }
  }

  #Process csv

  $argHash = @{}
  $argHash.properties = @{
      displayName    = "$WatchlistName"
      source         = "$($csvFile.Name)"
      description    = "Watchlist from $($csvFile.Extension) content"
      contentType    = 'text/csv'
      itemsSearchKey = $itemsSearchKey
      rawContent     = "$($rawContent)"
      provider       = 'SecureHats'
  }

  try {
      $result = Invoke-AzRestMethod -Path $watchlist -Method PUT -Payload ($argHash | ConvertTo-Json)
      if ($result.StatusCode -eq 200) {
          Write-Output "[+] Watchlist with alias [$($AliasName)] has been created."
          Write-Output "[+] It can take a while before the results are visible in Log Analytics.`n"
      }
      else {
          Write-Output $result | ConvertFrom-Json
      }
  }
  catch {
      Write-Verbose $_
      Write-Error "Unable to create watchlist with error code: $($_.Exception.Message)" -ErrorAction Stop
  }
  Write-Output "[+] Post any feature requests or issues on https://github.com/SecureHats/SecureHacks/issues`n"
}
