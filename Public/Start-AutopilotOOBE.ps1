function Start-AutopilotOOBE {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string]$CustomProfile,
        [switch]$Demo,

        [ValidateSet (
            'GroupTag',
            'AddToGroup',
            'AssignedUser',
            'AssignedComputerName',
            'PostAction',
            'Assign'
        )]
        [string[]]$Disabled,

        [ValidateSet (
            'GroupTag',
            'AddToGroup',
            'AssignedUser',
            'AssignedComputerName',
            'PostAction',
            'Assign',
            'Register',
            'Run',
            'Docs'
        )]
        [string[]]$Hidden,

        [string]$AddToGroup,
        [string[]]$AddToGroupOptions,
        [switch]$Assign,
        [string]$AssignedUser,
        [string]$AssignedUserExample = 'someone@example.com',
        [string]$AssignedComputerName,
        [string]$AssignedComputerNameExample = 'Azure AD Join Only',
        [string]$GroupTag,
        [string[]]$GroupTagOptions,
        [ValidateSet (
            'Quit',
            'Restart',
            'Shutdown',
            'Sysprep',
            'SysprepReboot',
            'SysprepShutdown',
            'GeneralizeReboot',
            'GeneralizeShutdown'
        )]
        [string]$PostAction = 'Quit',
        [ValidateSet (
            'CommandPrompt',
            'PowerShell',
            'PowerShellISE',
            'WindowsExplorer',
            'WindowsSettings',
            'NetworkingWireless',
            'Restart',
            'Shutdown',
            'Sysprep',
            'SysprepReboot',
            'SysprepShutdown',
            'SysprepAudit',
            'EventViewer',
            'GetAutopilotDiagnostics',
            'MDMDiag',
            'MDMDiagAutopilot',
            'MDMDiagAutopilotTPM',
            'UpdateMyDellBios'
        )]
        [string]$Run = 'PowerShell',
        [string]$Docs,
        [string]$Title = 'Autopilot Manual Registration'
    )
    #=======================================================================
    #   Header
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Green "Start-AutopilotOOBE"
    #=======================================================================
    #   Transcript
    #=======================================================================
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Start-Transcript"
    $Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-AutopilotOOBE.log"
    Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
    #   PSGallery
    #=======================================================================
    $PSGalleryIP = (Get-PSRepository -Name PSGallery).InstallationPolicy
    if ($PSGalleryIP -eq 'Untrusted') {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Write-Host -ForegroundColor DarkGray "========================================================================="
    }
    #=======================================================================
    #   Test-AutopilotNetwork
    #=======================================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Verify Date and Time"
    Write-Host -ForegroundColor DarkCyan 'Make sure the Time is set properly in the System BIOS as this can cause issues'
    Get-Date
    Get-TimeZone
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Start-Sleep -Seconds 2
    #=======================================================================
    #   Test-AutopilotNetwork
    #=======================================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test-AutopilotNetwork"
    Write-Host -ForegroundColor DarkCyan 'Required Autopilot network addresses are being tested in a minimized window'
    Write-Host -ForegroundColor DarkCyan 'Use Alt+Tab to view progress'
    Start-Process PowerShell.exe -WindowStyle Minimized -ArgumentList "-NoExit -Command Test-AutopilotNetwork"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Start-Sleep -Seconds 2
    #=======================================================================
    #   Autopilot Registry
    #=======================================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Test-AutopilotRegistry"
    Write-Host -ForegroundColor DarkCyan 'Gathering Autopilot Registration information from the Registry'
    $Global:RegAutoPilot = Get-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\AutoPilot'
    
    Write-Host -ForegroundColor Gray "IsAutoPilotDisabled: $($Global:RegAutoPilot.IsAutoPilotDisabled)"
    Write-Host -ForegroundColor Gray "CloudAssignedForcedEnrollment: $($Global:RegAutoPilot.CloudAssignedForcedEnrollment)"
    Write-Host -ForegroundColor Gray "CloudAssignedTenantDomain: $($Global:RegAutoPilot.CloudAssignedTenantDomain)"
    Write-Host -ForegroundColor Gray "CloudAssignedTenantId: $($Global:RegAutoPilot.CloudAssignedTenantId)"
    Write-Host -ForegroundColor Gray "CloudAssignedTenantUpn: $($Global:RegAutoPilot.CloudAssignedTenantUpn)"
    Write-Host -ForegroundColor Gray "CloudAssignedLanguage: $($Global:RegAutoPilot.CloudAssignedLanguage)"

    if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
        Write-Host -ForegroundColor Gray "TenantId: $($Global:RegAutoPilot.TenantId)"
        Write-Host -ForegroundColor Gray "CloudAssignedMdmId: $($Global:RegAutoPilot.CloudAssignedMdmId)"
        Write-Host -ForegroundColor Gray "AutopilotServiceCorrelationId: $($Global:RegAutoPilot.AutopilotServiceCorrelationId)"
        Write-Host -ForegroundColor Gray "CloudAssignedOobeConfig: $($Global:RegAutoPilot.CloudAssignedOobeConfig)"
        Write-Host -ForegroundColor Gray "CloudAssignedTelemetryLevel: $($Global:RegAutoPilot.CloudAssignedTelemetryLevel)"
        Write-Host -ForegroundColor Gray "IsDevicePersonalized: $($Global:RegAutoPilot.IsDevicePersonalized)"
        Write-Host -ForegroundColor Gray "SetTelemetryLevel_Succeeded_With_Level: $($Global:RegAutoPilot.SetTelemetryLevel_Succeeded_With_Level)"
        Write-Host -ForegroundColor Gray "IsForcedEnrollmentEnabled: $($Global:RegAutoPilot.IsForcedEnrollmentEnabled)"
        Write-Host -ForegroundColor Green "This device has already been Autopilot Registered. Registration will not be enabled"
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Start-Sleep -Seconds 2
    #=======================================================================
    #   Custom Profile
    #=======================================================================
    if ($CustomProfile) {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading AutopilotOOBE Custom Profile $CustomProfile"
    }
    else {
        Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Loading AutopilotOOBE Default Profile"
    }
    Write-Host -ForegroundColor DarkGray "========================================================================="
    #=======================================================================
    #   Profile OSDeploy
    #=======================================================================
    if ($CustomProfile -in 'OSD','OSDeploy','OSDeploy.com') {
        $Title = 'OSDeploy Autopilot Registration'
        $AddToGroup = 'Administrators'
        $AssignedUserExample = 'someone@osdeploy.com'
        $AssignedComputerName = 'OSD-' + ((Get-CimInstance -ClassName Win32_BIOS).SerialNumber).Trim()
        $PostAction = 'Shutdown'
        $Assign = $true
        $Run = 'PowerShell'
        $Docs = 'https://www.osdeploy.com/'
        $Hidden = 'GroupTag'
    }
    #=======================================================================
    #   Profile SeguraOSD
    #=======================================================================
    if ($CustomProfile -match 'SeguraOSD') {
        $Title = 'SeguraOSD Autopilot Registration'
        $GroupTag = 'Twitter'
        $AssignedComputerName = ((Get-CimInstance -ClassName Win32_BIOS).SerialNumber).Trim()
        $PostAction = 'Restart'
        $Assign = $true
        $Run = 'WindowsSettings'
        $Docs = 'https://twitter.com/SeguraOSD'
        $Hidden = 'AddToGroup','AssignedUser'
    }
    #=======================================================================
    #   Profile Baker Hughes
    #=======================================================================
    if ($CustomProfile -eq 'BH') {
        $Title = 'Baker Hughes Autopilot Registration'
        $Assign = $true
        $Hidden = 'AddToGroup','AssignedComputerName','AssignedUser'
        $GroupTag = 'Enterprise'
        $GroupTagOptions = 'Development','Enterprise'
        $Run = 'NetworkingWireless'

        if (!(Get-Module -ListAvailable -Name OSD)) {
            Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Installing OSD PowerShell Module"
            Install-Module OSD -Force -Verbose
            Import-Module OSD -Force
            Write-Host -ForegroundColor DarkGray "========================================================================="
        }
        #if ((Get-MyComputerManufacturer -Brief) -eq 'Dell') {
            #Update-MyDellBios
            #Start-Sleep -Seconds 2
        #}
    }
    #=======================================================================
    #   Profile SoCal
    #=======================================================================
    if ($CustomProfile -eq 'SoCal') {
        $Title = 'SoCal PS User Group Autopilot Registration'
        $Assign = $true
        $Hidden = 'AddToGroup','AssignedComputerName','AssignedUser'
        $GroupTag = 'Enterprise'
        $GroupTagOptions = 'Development','Enterprise','Master'
        $Run = 'NetworkingWireless'
    }
    #=======================================================================
    #   Profile HalfMan
    #=======================================================================
    if ($CustomProfile -eq 'HalfMan') {
        $Title = 'Autopilot Registration'
        $Hidden = 'GroupTag'
        $AddToGroup = 'Azr_crp_ent_modern_workplace_devices'
        $AddToGroupOptions = 'Azr_crp_ent_modern_workplace_devices'
    }
    #=======================================================================
    #   Support
    #=======================================================================
    if ($Global:RegAutoPilot.CloudAssignedForcedEnrollment -eq 1) {
        $Title = 'Autopilot Registration Information'
        $Disabled = 'GroupTag','AddToGroup','AssignedUser','AssignedComputerName','PostAction','Assign'
        $Hidden = 'GroupTag','AddToGroup','AssignedUser','AssignedComputerName','PostAction','Assign','Register'
        $Run = 'MDMDiagAutopilotTPM'
    }
    #=======================================================================
    #   Set Global Variable
    #=======================================================================
    $Global:AutopilotOOBE = @{
        AddToGroup = $AddToGroup
        AddToGroupOptions = $AddToGroupOptions
        Assign = $Assign
        AssignedUser = $AssignedUser
        AssignedUserExample = $AssignedUserExample
        AssignedComputerName = $AssignedComputerName
        AssignedComputerNameExample = $AssignedComputerNameExample
        Disabled = $Disabled
        Demo = $Demo
        GroupTag = $GroupTag
        GroupTagOptions = $GroupTagOptions
        Hidden = $Hidden
        PostAction = $PostAction
        Run = $Run
        Docs = $Docs
        Title = $Title
    }
    #=======================================================================
    #   Launch
    #=======================================================================
    Write-Host -ForegroundColor Cyan "$((Get-Date).ToString('yyyy-MM-dd-HHmmss')) Starting AutopilotOOBE GUI"
    Write-Host -ForegroundColor DarkGray "========================================================================="
    Start-Sleep -Seconds 2
    & "$($MyInvocation.MyCommand.Module.ModuleBase)\Forms\Join-AutopilotOOBE.ps1"
}