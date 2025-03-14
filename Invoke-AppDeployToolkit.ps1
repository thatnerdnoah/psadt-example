<#

.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2025 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType
The type of deployment to perform.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive (shows dialogs), Silent (no dialogs), or NonInteractive (dialogs without prompts) mode.

NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru
Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [PSDefaultValue(Help = 'Install', Value = 'Install')]
    [System.String]$DeploymentType,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [PSDefaultValue(Help = 'Interactive', Value = 'Interactive')]
    [System.String]$DeployMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)


##================================================
## MARK: Variables
##================================================

# Grab computer manufacturer for Dell Commmand Update installation
$computerManufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer

$adtSession = @{
    # App variables.
    AppVendor = ''
    AppName = 'PSADT Example Deployment'
    AppVersion = '1.0'
    AppArch = ''
    AppLang = 'EN'
    AppRevision = '01'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.0'
    AppScriptDate = '2025-03-14'
    AppScriptAuthor = 'Noah Thorn'

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = ''
    InstallTitle = ''

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.0.6'
    DeployAppScriptParameters = $PSBoundParameters
}

function Install-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CheckDiskSpace

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Installation tasks here>


    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI installations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
        if ($adtSession.DefaultMspFiles)
        {
            $adtSession.DefaultMspFiles | Start-ADTMsiProcess -Action Patch
        }
    }

    ## <Perform Installation tasks here>
	
	
	# Remove bloat applications
    # Replace strings inside the $BloatApps variable with your own apps. Any apps in this list will be removed.
	Show-ADTInstallationProgress -StatusMessage "Removing Bloat Applications..."
            $BloatApps = @(
            'Microsoft.News',
            'Microsoft.Xbox.TCUI',
            'Microsoft.XboxIdentityProvider',
            'Microsoft.XboxSpeechToTextOverlay',
            'Microsoft.XboxGamingOverlay',
            'Microsoft.GamingApp',
            'Microsoft.GetHelp',
            'Microsoft.BingSearch',
            'Microsoft.MicrosoftSolitaireCollection',
            'Microsoft.OutlookForWindows',
            'Microsoft.WindowsFeedbackHub',
            'Microsoft.YourPhone',
            'Microsoft.BingNews'
            )

            Foreach($BloatApp in $BloatApps){
                Write-Host "Removing " $BloatApp
                Get-AppxPackage -Name "$BloatApp" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            }

    # Microsoft Office
    # Example installation of Microsoft applications
    # Information about deploying Microsoft office can be found here: https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/overview-office-deployment-tool
    Show-ADTInstallationProgress -StatusMessage "Installing Microsoft Office (Base Apps)..."
    Start-ADTProcess -FilePath "$PSScriptRoot\Files\M365\setup.exe" -ErrorAction SilentlyContinue
    

    # Google Chrome
    # Installs Google Chrome and configures master preferences
    Show-ADTInstallationProgress -StatusMessage "Installing Google Chrome..."
    Start-ADTMsiProcess -Action Install -FilePath "$PSScriptRoot\Files\Google Chrome\GoogleChromeStandaloneEnterprise64.msi" -ArgumentList "/qn"
    Copy-ADTFile -Path "$PSScriptRoot\Files\Google Chrome\master_preferences" -Destination "$envProgramFiles\Google\Chrome\application\"
    
	# Firefox
    Show-ADTInstallationProgress -StatusMessage "Installing Firefox..."
    Start-ADTMsiProcess -Action Install -FilePath "$PSScriptRoot\Files\Firefox\FirefoxSetup.msi" -ArgumentList "/qn"
    
	# Adobe Reader
    Show-ADTInstallationProgress -StatusMessage "Installing Adobe Reader..."
	Start-ADTProcess -FilePath "$PSScriptRoot\Files\Adobe Acrobat Reader\AcroRdrDC2200120117_en_US.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES"
    
	# Dell Command Update
    # If installing on a Dell machine, Dell Command Update is a useful application that keeps drivers up-to-date. This will be ignored if you are installing on other hardware.
    Show-ADTInstallationProgress -StatusMessage "Installing Dell Command Update..."
    if ($computerManufacturer -contains "Dell Inc.") {
        try {
            Start-ADTProcess -FilePath "$PSScriptRoot\Files\Dell_Command_Update\Dell-Command-Update-Application_6VFWW_WIN_5.4.0_A00.EXE" -ArgumentList "/S"
        } catch {
            Write-Output "Dell Command Update install failed. Skipping..."
            # Show-InstallationPrompt -Message "Dell Command Update install failed. Skipping..." -ButtonMiddleText "OK" -Timeout 10 -NoWait
        }
    } else {
        Write-Output "Dell Command Update install failed. Skipping..."
        
        # Show-InstallationPrompt -Message "Cannot install Dell Command Update on a non-Dell computer. Skipping..." -ButtonMiddleText "OK" -Timeout 10 -NoWait
    }

    
	# Webex
    Show-ADTInstallationProgress -StatusMessage "Installing Webex..."
    Start-ADTMsiProcess -Action Install -FilePath "$PSScriptRoot\Files\Webex\Webex.msi" -ArgumentList "ACCEPT_EULA=TRUE INSTALL_ROOT=`"C:\Program Files\Cisco Spark`" AUTOSTART_WITH_WINDOWS=false ALLUSERS=1 /qn"
    
	# Zoom
    Show-ADTInstallationProgress -StatusMessage "Installing Zoom..."
    Start-ADTMsiProcess -Action Install -FilePath "$PSScriptRoot\Files\Zoom\ZoomInstallerFull.msi" -ArgumentList "/qn ZNoDesktopShortCut=`"true`" ZConfig=`"kCmdParam_InstallOption=8;nogoogle=1;nofacebook=1;disableloginwithemail=1;enableembedbrowserforsso=1`" ZoomAutoUpdate=`"true`""
    
    # VideoLAN (VLC Media Player)
    Show-ADTInstallationProgress -StatusMessage "Installing VLC..."
    Start-ADTProcess -FilePath "$PSScriptRoot\Files\VideoLAN\vlc-win64.exe" -ArgumentList "/L=1033 /S /NCRC"


    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Installation tasks here>
    

    ## Display a message at the end of the install.
    if (!$adtSession.UseDefaultMsi)
    {
        # Show-ADTInstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait
    }
}

function Uninstall-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Uninstallation tasks here>


    ##================================================
    ## MARK: Uninstall
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI uninstallations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Uninstallation tasks here>


    ##================================================
    ## MARK: Post-Uninstallation
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Uninstallation tasks here>
}

function Repair-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Repair tasks here>


    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI repairs.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Repair tasks here>


    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Repair tasks here>
}


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

# Import the module and instantiate a new session.
try
{
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"))
    {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else
    {
        'PSAppDeployToolkit'
    }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.6' } -Force
    try
    {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

try
{
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process
        {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally
{
    Remove-Module -Name PSAppDeployToolkit* -Force
}

