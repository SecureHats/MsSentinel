#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}
#requires -version 6.2

function New-MsSentinelxxx {
  <#
.Synopsis
   Create a Microsoft Sentinel Watchlist
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
      [string]$WorkspaceName
  )

  begin {
        Get-MsSentinelContext
        Get-MsSentinelWorkspace
  }
  process {
    if ($null -ne $workspace) {
        $apiVersion = '?api-version=2021-09-01-preview'
        $baseUri = '{0}/providers/Microsoft.SecurityInsights' -f $workspace.ResourceId
        resourcePath = '{0}/watchlists/{1}{2}' -f $baseUri, $AliasName, $apiVersion
    }
    else {
        Write-Output "[-] Unable to "
    }

    if ($null -ne $xxx) {
        try {
            Write-Verbose "[-] Trying to..."
        }
        catch {
            Write-Error 'Unable to...'
            exit
        }
    }

    $argHash = @{}
    $argHash.properties = @{
        displayName    = ""
    }

    try {
        $result = Invoke-AzRestMethod -Path $resourcePath -Method PUT -Payload ($argHash | ConvertTo-Json)
        if ($result.StatusCode -eq 200) {
            Write-Verbose "[-] Resource with name <...> has been created."
        }
        else {
            Write-Output $result | ConvertFrom-Json
        }
    }
    catch {
        Write-Verbose $_
        Write-Error "Unable to create resource with error code: $($_.Exception.Message)" -ErrorAction Stop
    }
      Write-Verbose "[+] Post any feature requests or issues on https://github.com/SecureHats/SecureHacks/issues`n"
  }
}
