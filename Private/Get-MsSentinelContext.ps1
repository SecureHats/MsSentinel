function CheckModules($module) {

    $installedModule = Get-InstalledModule -Name $module -ErrorAction SilentlyContinue

    if ($null -eq $installedModule) {
        Write-Warning "The $module PowerShell module is not found"
        #check for Admin Privleges
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

        if (-not ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
            #Not an Admin, install to current user
            Write-Warning -Message "Can not install the $module module. You are not running as Administrator"
            Write-Warning -Message "Installing $module module to current user Scope"
            Install-Module -Name $module -Scope CurrentUser -Force
            Import-Module -Name $module -Force
        }
        else {
            #Admin, install to all users
            Write-Warning -Message "Installing the $module module to all users"
            Install-Module -Name $module -Repository PSGallery -Force
            Import-Module -Name $module -Repository PSGallery -Force
        }
    }
}

function Get-MsSentinelContext {

    begin {
        CheckModules("Az.Resources")
        CheckModules("Az.OperationalInsights")
    }
    process {
        $context = Get-AzContext

        if (!$context) {
            $null = Connect-AzAccount
            $script:context = Get-AzContext
        }

        $script:SubscriptionId = $context.Subscription.Id
    }
}
