function Start-AutopilotOOBE {
    [CmdletBinding()]
    param (
        [string]$AddToGroup,
        [switch]$Assign,
        [string]$GroupTag,
        [ValidateSet (
            'None',
            'Sysprep',
            'SysprepReboot',
            'SysprepShutdown'
        )]
        [string]$PostAction = 'None',
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
            'MDMDiag',
            'MDMDiagAutopilot',
            'MDMDiagAutopilotTPM'
        )]
        [string]$Run = 'PowerShell',
        [string]$Docs = 'https://docs.microsoft.com/en-us/mem/autopilot/',
        [string]$Title = 'Join Autopilot OOBE'
    )

    $Global:AutopilotOOBE = @{
        AddToGroup = $AddToGroup
        Assign = $Assign
        GroupTag = $GroupTag
        PostAction = $PostAction
        Run = $Run
        Docs = $Docs
        Title = $Title
    }

    & "$($MyInvocation.MyCommand.Module.ModuleBase)\AutopilotOOBE.ps1"
}

New-Alias -Name AutopilotOOBE -Value Start-AutopilotOOBE -Force -ErrorAction SilentlyContinue
Export-ModuleMember -Function Start-AutopilotOOBE -Alias AutopilotOOBE