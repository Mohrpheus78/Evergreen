# ***********************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Download Software packages with Evergreen powershell module
# ***********************************************************

<#
.SYNOPSIS
This script downloads software packages if new versions are available.
		
.Description
The script uses the excellent Powershell Evergreen module from Aaron Parker, Bronson Magnan and Trond Eric Haarvarstein. 
To update a software package just launch the Evergreen Software Updater.ps1 script and select the software you want to update.
The selection is stored in a XML file, so you can easily replace the script and you don't have to make your selection again every time.
A new folder for every single package will be created, together with a version file, a download date file and a log file. If a new version is available
the scriot checks the version number and will update the package.

.EXAMPLE

.PARAMETER -noGUI
If you made your selection once, you can run the script with the -noGUI parameter.

.NOTES
Thanks to Trond Eric Haarvarstein, I used some code from his great Automation Framework!
Many thanks to Aaron Parker, Bronson Magnan and Trond Eric Haarvarstein for the module! Thanks to Manuel Winkel for the forms ;-)
https://github.com/aaronparker/Evergreen
You can run this script daily with a scheduled task.
Run as admin!

Version:		1.2
Author:         Dennis Mohrmann <@mohrpheus78>
Creation Date:  2020-11-19
Purpose/Change:	
2020-11-19     Inital version
2021-03-16     Added forms and xml selection
2021-04-07     Changed Evergreen commands because of new Evergreen module 
#>

Param (
		[Parameter(
            HelpMessage='Start the Gui to select the Software',
            ValuefromPipelineByPropertyName = $true
        )]
        [switch]$noGUI
    
)

# Do you run the script as admin?
# ========================================================================================================================================
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

IF ($myWindowsPrincipal.IsInRole($adminRole))
   {
    # OK, runs as admin
    Write-Host "OK, script is running with Admin rights"
    Write-Output ""
   }

else
   {
    # Script doesn't run as admin, stop!
    Write-Host -ForegroundColor Red "Error! Script is NOT running with Admin rights!"
    BREAK
   }
# ========================================================================================================================================

Clear-Host

Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " -------------------------------------------------------- "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " Evergreen Software-Updater (Powered by Evergreen-Module) "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " © D. Mohrmann - S&L Firmengruppe                         "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " -------------------------------------------------------- "
Write-Output ""

Write-Host -ForegroundColor Cyan "Setting Variables"
Write-Output ""

# Variables
$ErrorActionPreference = "SilentlyContinue"
$SoftwareToUpdate = "$PSScriptRoot\Software-to-update.xml"

# General update logfile
IF (!(Test-Path -Path "$PSScriptRoot\_Update Logs")) {New-Item -Path "$PSScriptRoot\_Update Logs" -ItemType Directory}
$Date = $Date = Get-Date -UFormat "%d.%m.%Y"
$UpdateLog = "$PSScriptRoot\_Update Logs\Software Updates $Date.log"

# Import values (selected software) from XML file
if (Test-Path -Path $SoftwareToUpdate) {$SoftwareSelection = Import-Clixml $SoftwareToUpdate}

# FUNCTION Logging
#========================================================================================================================================
function gui_mode{
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    # Set the size of your form
    $Form = New-Object system.Windows.Forms.Form
    $Form.ClientSize = New-Object System.Drawing.Point(800,520)
    $Form.text = "Evergreen Software-Updater"
    $Form.TopMost = $false
    $Form.AutoSize = $true

    # Set the font of the text to be used within the form
    $Font = New-Object System.Drawing.Font("Arial",11)
    $Form.Font = $Font

    # Software Headline
    $Headline2 = New-Object system.Windows.Forms.Label
    $Headline2.text = "Select Software to download"
    $Headline2.AutoSize = $true
    $Headline2.width = 25
    $Headline2.height = 10
    $Headline2.location = New-Object System.Drawing.Point(11,4)
    $form.Controls.Add($Headline2)

	# NotePadPlusPlus Checkbox
    $NotePadPlusPlusBox = New-Object system.Windows.Forms.CheckBox
    $NotePadPlusPlusBox.text = "NotePad++"
    $NotePadPlusPlusBox.width = 95
    $NotePadPlusPlusBox.height = 20
    $NotePadPlusPlusBox.autosize = $true
    $NotePadPlusPlusBox.location = New-Object System.Drawing.Point(11,45)
    $form.Controls.Add($NotePadPlusPlusBox)
	$NotePadPlusPlusBox.Checked = $SoftwareSelection.NotePadPlusPlus
	
    # 7Zip Checkbox
    $SevenZipBox = New-Object system.Windows.Forms.CheckBox
    $SevenZipBox.text = "7 Zip"
    $SevenZipBox.width = 95
    $SevenZipBox.height = 20
    $SevenZipBox.autosize = $true
    $SevenZipBox.location = New-Object System.Drawing.Point(11,70)
    $form.Controls.Add($SevenZipBox)
	$SevenZipBox.Checked = $SoftwareSelection.SevenZip

    # AdobeReaderDC Checkbox
    $AdobeReaderDCBoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBoxUpdate.text = "Adobe Reader DC"
    $AdobeReaderDCBoxUpdate.width = 95
    $AdobeReaderDCBoxUpdate.height = 20
    $AdobeReaderDCBoxUpdate.autosize = $true
    $AdobeReaderDCBoxUpdate.location = New-Object System.Drawing.Point(11,95)
    $form.Controls.Add($AdobeReaderDCBoxUpdate)
	$AdobeReaderDCBoxUpdate.Checked = $SoftwareSelection.AdobeReaderDC_MUI

    # BISF Checkbox
    $BISFBox = New-Object system.Windows.Forms.CheckBox
    $BISFBox.text = "BIS-F"
    $BISFBox.width = 95
    $BISFBox.height = 20
    $BISFBox.autosize = $true
    $BISFBox.location = New-Object System.Drawing.Point(11,120)
    $form.Controls.Add($BISFBox)
	$BISFBox.Checked = $SoftwareSelection.BISF
	
	# FSLogix Checkbox
    $FSLogixBox = New-Object system.Windows.Forms.CheckBox
    $FSLogixBox.text = "FSLogix"
    $FSLogixBox.width = 95
    $FSLogixBox.height = 20
    $FSLogixBox.autosize = $true
    $FSLogixBox.location = New-Object System.Drawing.Point(11,145)
    $form.Controls.Add($FSLogixBox)
	$FSLogixBox.Checked = $SoftwareSelection.FSLogix

    # GoogleChrome Checkbox
    $GoogleChromeBox = New-Object system.Windows.Forms.CheckBox
    $GoogleChromeBox.text = "Google Chrome"
    $GoogleChromeBox.width = 95
    $GoogleChromeBox.height = 20
    $GoogleChromeBox.autosize = $true
    $GoogleChromeBox.location = New-Object System.Drawing.Point(11,170)
    $form.Controls.Add($GoogleChromeBox)
	$GoogleChromeBox.Checked = $SoftwareSelection.GoogleChrome

    # Citrix WorkspaceApp_Current_Release Checkbox
    $WorkspaceApp_CRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CRBox.text = "Citrix WorkspaceApp CR"
    $WorkspaceApp_CRBox.width = 95
    $WorkspaceApp_CRBox.height = 20
    $WorkspaceApp_CRBox.autosize = $true
    $WorkspaceApp_CRBox.location = New-Object System.Drawing.Point(11,195)
    $form.Controls.Add($WorkspaceApp_CRBox)
	$WorkspaceApp_CRBox.Checked = $SoftwareSelection.WorkspaceApp_CR

    # Citrix WorkspaceApp_LTSR_Release Checkbox
    $WorkspaceApp_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSRBox.text = "Citrix WorkspaceApp LTSR"
    $WorkspaceApp_LTSRBox.width = 95
    $WorkspaceApp_LTSRBox.height = 20
    $WorkspaceApp_LTSRBox.autosize = $true
    $WorkspaceApp_LTSRBox.location = New-Object System.Drawing.Point(11,220)
    $form.Controls.Add($WorkspaceApp_LTSRBox)
	$WorkspaceApp_LTSRBox.Checked = $SoftwareSelection.WorkspaceApp_LTSR
	
	# Citrix Hypervisor Tools Checkbox
    $Citrix_HypervisorToolsBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_HypervisorToolsBox.text = "Citrix Hypervisor Tools"
    $Citrix_HypervisorToolsBox.width = 95
    $Citrix_HypervisorToolsBox.height = 20
    $Citrix_HypervisorToolsBox.autosize = $true
    $Citrix_HypervisorToolsBox.location = New-Object System.Drawing.Point(11,245)
    $form.Controls.Add($Citrix_HypervisorToolsBox)
	$Citrix_HypervisorToolsBox.Checked = $SoftwareSelection.CitrixHypervisorTools
	
	# VMWareTools Checkbox
    $VMWareToolsBox = New-Object system.Windows.Forms.CheckBox
    $VMWareToolsBox.text = "VMWare Tools"
    $VMWareToolsBox.width = 95
    $VMWareToolsBox.height = 20
    $VMWareToolsBox.autosize = $true
    $VMWareToolsBox.location = New-Object System.Drawing.Point(11,270)
    $form.Controls.Add($VMWareToolsBox)
	$VMWareToolsBox.Checked = $SoftwareSelection.VMWareTools

    # Remote Desktop Manager Checkbox
    $RemoteDesktopManagerBox = New-Object system.Windows.Forms.CheckBox
    $RemoteDesktopManagerBox.text = "Remote Desktop Manager Free"
    $RemoteDesktopManagerBox.width = 95
    $RemoteDesktopManagerBox.height = 20
    $RemoteDesktopManagerBox.autosize = $true
    $RemoteDesktopManagerBox.location = New-Object System.Drawing.Point(11,295)
    $form.Controls.Add($RemoteDesktopManagerBox)
	$RemoteDesktopManagerBox.Checked = $SoftwareSelection.RemoteDesktopManager

    # deviceTRUST CheckBox
    $deviceTRUSTBox = New-Object system.Windows.Forms.CheckBox
    $deviceTRUSTBox.text = "deviceTRUST"
    $deviceTRUSTBox.width = 95
    $deviceTRUSTBox.height = 20
    $deviceTRUSTBox.autosize = $true
    $deviceTRUSTBox.location = New-Object System.Drawing.Point(11,320)
    $form.Controls.Add($deviceTRUSTBox)
	$deviceTRUSTBox.Checked = $SoftwareSelection.deviceTRUST
    
    # KeePass Checkbox
    $KeePassBox = New-Object system.Windows.Forms.CheckBox
    $KeePassBox.text = "KeePass"
    $KeePassBox.width = 95
    $KeePassBox.height = 20
    $KeePassBox.autosize = $true
    $KeePassBox.location = New-Object System.Drawing.Point(11,345)
    $form.Controls.Add($KeePassBox)
	$KeePassBox.Checked = $SoftwareSelection.KeePass

    # mRemoteNG Checkbox
    $mRemoteNGBox = New-Object system.Windows.Forms.CheckBox
    $mRemoteNGBox.text = "mRemoteNG"
    $mRemoteNGBox.width = 95
    $mRemoteNGBox.height = 20
    $mRemoteNGBox.autosize = $true
    $mRemoteNGBox.location = New-Object System.Drawing.Point(11,370)
    $form.Controls.Add($mRemoteNGBox)
	$mRemoteNGBox.Checked = $SoftwareSelection.mRemoteNG
	
	# WinSCP Checkbox
    $WinSCPBox = New-Object system.Windows.Forms.CheckBox
    $WinSCPBox.text = "WinSCP"
    $WinSCPBox.width = 95
    $WinSCPBox.height = 20
    $WinSCPBox.autosize = $true
    $WinSCPBox.location = New-Object System.Drawing.Point(11,395)
    $form.Controls.Add($WinSCPBox)
	$WinSCPBox.Checked = $SoftwareSelection.WinSCP
	
	# Putty Checkbox
    $PuttyBox = New-Object system.Windows.Forms.CheckBox
    $PuttyBox.text = "Putty"
    $PuttyBox.width = 95
    $PuttyBox.height = 20
    $PuttyBox.autosize = $true
    $PuttyBox.location = New-Object System.Drawing.Point(11,420)
    $form.Controls.Add($PuttyBox)
	$PuttyBox.Checked = $SoftwareSelection.Putty

    # MS365 Apps Checkbox
    $MS365AppsBox = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox.text = "Microsoft 365 Apps (64Bit / Semi Annual Channel)"
    $MS365AppsBox.width = 95
    $MS365AppsBox.height = 20
    $MS365AppsBox.autosize = $true
    $MS365AppsBox.location = New-Object System.Drawing.Point(250,45)
    $form.Controls.Add($MS365AppsBox)
	$MS365AppsBox.Checked = $SoftwareSelection.MS365Apps

	# MS Office2019 Checkbox
    $MSOffice2019Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2019Box.text = "Microsoft Office 2019 (64Bit)"
    $MSOffice2019Box.width = 95
    $MSOffice2019Box.height = 20
    $MSOffice2019Box.autosize = $true
    $MSOffice2019Box.location = New-Object System.Drawing.Point(250,70)
    $form.Controls.Add($MSOffice2019Box)
	$MSOffice2019Box.Checked = $SoftwareSelection.MSOffice2019
	
    # MS Edge Checkbox
    $MSEdgeBox = New-Object system.Windows.Forms.CheckBox
    $MSEdgeBox.text = "Microsoft Edge (Stable Channel)"
    $MSEdgeBox.width = 95
    $MSEdgeBox.height = 20
    $MSEdgeBox.autosize = $true
    $MSEdgeBox.location = New-Object System.Drawing.Point(250,95)
    $form.Controls.Add($MSEdgeBox)
	$MSEdgeBox.Checked = $SoftwareSelection.MSEdge

    # MS OneDrive Checkbox
    $MSOneDriveBox = New-Object system.Windows.Forms.CheckBox
    $MSOneDriveBox.text = "Microsoft OneDrive (Machine-Based Install)"
    $MSOneDriveBox.width = 95
    $MSOneDriveBox.height = 20
    $MSOneDriveBox.autosize = $true
    $MSOneDriveBox.location = New-Object System.Drawing.Point(250,120)
    $form.Controls.Add($MSOneDriveBox)
	$MSOneDriveBox.Checked = $SoftwareSelection.MSOneDrive

    # MS Teams Checkbox
    $MSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $MSTeamsBox.text = "Microsoft Teams (Machine-Based Install)"
    $MSTeamsBox.width = 95
    $MSTeamsBox.height = 20
    $MSTeamsBox.autosize = $true
    $MSTeamsBox.location = New-Object System.Drawing.Point(250,145)
    $form.Controls.Add($MSTeamsBox)
	$MSTeamsBox.Checked = $SoftwareSelection.MSTeams
	
	# MS Teams Preview Checkbox
    $MSTeamsPrevBox = New-Object system.Windows.Forms.CheckBox
    $MSTeamsPrevBox.text = "Microsoft Teams Preview (Machine-Based Install)"
    $MSTeamsPrevBox.width = 95
    $MSTeamsPrevBox.height = 20
    $MSTeamsPrevBox.autosize = $true
    $MSTeamsPrevBox.location = New-Object System.Drawing.Point(250,170)
    $form.Controls.Add($MSTeamsPrevBox)
	$MSTeamsPrevBox.Checked = $SoftwareSelection.MSTeamsPrev

    # MS Powershell Checkbox
    $MSPowershellBox = New-Object system.Windows.Forms.CheckBox
    $MSPowershellBox.text = "Microsoft Powershell"
    $MSPowershellBox.width = 95
    $MSPowershellBox.height = 20
    $MSPowershellBox.autosize = $true
    $MSPowershellBox.location = New-Object System.Drawing.Point(250,195)
    $form.Controls.Add($MSPowershellBox)
	$MSPowershellBox.Checked = $SoftwareSelection.MSPowershell
	
	# MS DotNet Checkbox
    $MSDotNetBox = New-Object system.Windows.Forms.CheckBox
    $MSDotNetBox.text = "Microsoft .Net Framework"
    $MSDotNetBox.width = 95
    $MSDotNetBox.height = 20
    $MSDotNetBox.autosize = $true
    $MSDotNetBox.location = New-Object System.Drawing.Point(250,220)
    $form.Controls.Add($MSDotNetBox)
	$MSDotNetBox.Checked = $SoftwareSelection.MSDotNetFramework
	
	# MS SQL Management Studio EN Checkbox
    $MSSQLManagementStudioENBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioENBox.text = "Microsoft SQL Management Studio EN"
    $MSSQLManagementStudioENBox.width = 95
    $MSSQLManagementStudioENBox.height = 20
    $MSSQLManagementStudioENBox.autosize = $true
    $MSSQLManagementStudioENBox.location = New-Object System.Drawing.Point(250,245)
    $form.Controls.Add($MSSQLManagementStudioENBox)
	$MSSQLManagementStudioENBox.Checked = $SoftwareSelection.MSSsmsEN
	
	# MS SQL Management Studio DE Checkbox
    $MSSQLManagementStudioDEBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioDEBox.text = "Microsoft SQL Management Studio DE"
    $MSSQLManagementStudioDEBox.width = 95
    $MSSQLManagementStudioDEBox.height = 20
    $MSSQLManagementStudioDEBox.autosize = $true
    $MSSQLManagementStudioDEBox.location = New-Object System.Drawing.Point(250,270)
    $form.Controls.Add($MSSQLManagementStudioDEBox)
	$MSSQLManagementStudioDEBox.Checked = $SoftwareSelection.MSSsmsDE

    # MS WVD Boot Loader
    $MSWVDBootLoaderBox = New-Object system.Windows.Forms.CheckBox
    $MSWVDBootLoaderBox.text = "Microsoft WVD Boot Loader"
    $MSWVDBootLoaderBox.width = 95
    $MSWVDBootLoaderBox.height = 20
    $MSWVDBootLoaderBox.autosize = $true
    $MSWVDBootLoaderBox.location = New-Object System.Drawing.Point(250,295)
    $form.Controls.Add($MSWVDBootLoaderBox)
	$MSWVDBootLoaderBox.Checked = $SoftwareSelection.MSWVDBootLoader

    # MS WVD Desktop Agent
    $MSWVDDesktopAgentBox = New-Object system.Windows.Forms.CheckBox
    $MSWVDDesktopAgentBox.text = "Microsoft WVD Desktop Agent"
    $MSWVDDesktopAgentBox.width = 95
    $MSWVDDesktopAgentBox.height = 20
    $MSWVDDesktopAgentBox.autosize = $true
    $MSWVDDesktopAgentBox.location = New-Object System.Drawing.Point(250,320)
    $form.Controls.Add($MSWVDDesktopAgentBox)
	$MSWVDDesktopAgentBox.Checked = $SoftwareSelection.MSWVDDesktopAgent
	
	# MS WVD RTC Service for Teams
    $MSWVDRTCServiceBox = New-Object system.Windows.Forms.CheckBox
    $MSWVDRTCServiceBox.text = "Microsoft WVD WebSocket Service for Teams"
    $MSWVDRTCServiceBox.width = 95
    $MSWVDRTCServiceBox.height = 20
    $MSWVDRTCServiceBox.autosize = $true
    $MSWVDRTCServiceBox.location = New-Object System.Drawing.Point(250,345)
    $form.Controls.Add($MSWVDRTCServiceBox)
	$MSWVDRTCServiceBox.Checked = $SoftwareSelection.MSWVDRTCService
	
	# OracleJava8 Checkbox
    $OracleJava8Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8Box.text = "Oracle Java 8"
    $OracleJava8Box.width = 95
    $OracleJava8Box.height = 20
    $OracleJava8Box.autosize = $true
    $OracleJava8Box.location = New-Object System.Drawing.Point(250,370)
    $form.Controls.Add($OracleJava8Box)
	$OracleJava8Box.Checked =  $SoftwareSelection.OracleJava8
	
	# OracleJava8-32Bit Checkbox
    $OracleJava8_32Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8_32Box.text = "Oracle Java 8 - 32 Bit"
    $OracleJava8_32Box.width = 95
    $OracleJava8_32Box.height = 20
    $OracleJava8_32Box.autosize = $true
    $OracleJava8_32Box.location = New-Object System.Drawing.Point(250,395)
    $form.Controls.Add($OracleJava8_32Box)
	$OracleJava8_32Box.Checked =  $SoftwareSelection.OracleJava8_32
	
	# OpenJDK Checkbox
    $OpenJDKBox = New-Object system.Windows.Forms.CheckBox
    $OpenJDKBox.text = "Open JDK"
    $OpenJDKBox.width = 95
    $OpenJDKBox.height = 20
    $OpenJDKBox.autosize = $true
    $OpenJDKBox.location = New-Object System.Drawing.Point(250,420)
    $form.Controls.Add($OpenJDKBox)
	$OpenJDKBox.Checked =  $SoftwareSelection.OpenJDK
	
	# TreeSizeFree Checkbox
    $TreeSizeFreeBox = New-Object system.Windows.Forms.CheckBox
    $TreeSizeFreeBox.text = "TreeSize Free"
    $TreeSizeFreeBox.width = 95
    $TreeSizeFreeBox.height = 20
    $TreeSizeFreeBox.autosize = $true
    $TreeSizeFreeBox.location = New-Object System.Drawing.Point(615,45)
    $form.Controls.Add($TreeSizeFreeBox)
	$TreeSizeFreeBox.Checked =  $SoftwareSelection.TreeSizeFree
	
	# VLCPlayer Checkbox
    $VLCPlayerBox = New-Object system.Windows.Forms.CheckBox
    $VLCPlayerBox.text = "VLC Player"
    $VLCPlayerBox.width = 95
    $VLCPlayerBox.height = 20
    $VLCPlayerBox.autosize = $true
    $VLCPlayerBox.location = New-Object System.Drawing.Point(615,70)
    $form.Controls.Add($VLCPlayerBox)
	$VLCPlayerBox.Checked =  $SoftwareSelection.VLCPlayer
	
	# FileZilla Checkbox
    $FileZillaBox = New-Object system.Windows.Forms.CheckBox
    $FileZillaBox.text = "FileZilla Client"
    $FileZillaBox.width = 95
    $FileZillaBox.height = 20
    $FileZillaBox.autosize = $true
    $FileZillaBox.location = New-Object System.Drawing.Point(615,95)
    $form.Controls.Add($FileZillaBox)
	$FileZillaBox.Checked =  $SoftwareSelection.FileZilla
	
	# Zoom Host Checkbox
    $ZoomVDIBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVDIBox.text = "Zoom VDI Host Installer"
    $ZoomVDIBox.width = 95
    $ZoomVDIBox.height = 20
    $ZoomVDIBox.autosize = $true
    $ZoomVDIBox.location = New-Object System.Drawing.Point(615,120)
    $form.Controls.Add($ZoomVDIBox)
	$ZoomVDIBox.Checked =  $SoftwareSelection.ZoomVDI
	
	# Zoom Citrix client Checkbox
    $ZoomCitrixBox = New-Object system.Windows.Forms.CheckBox
    $ZoomCitrixBox.text = "Zoom Citrix Client"
    $ZoomCitrixBox.width = 95
    $ZoomCitrixBox.height = 20
    $ZoomCitrixBox.autosize = $true
    $ZoomCitrixBox.location = New-Object System.Drawing.Point(615,145)
    $form.Controls.Add($ZoomCitrixBox)
	$ZoomCitrixBox.Checked =  $SoftwareSelection.ZoomCitrix
	
	# Zoom VMWare client Checkbox
    $ZoomVMWareBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVMWareBox.text = "Zoom VMWare Client"
    $ZoomVMWareBox.width = 95
    $ZoomVMWareBox.height = 20
    $ZoomVMWareBox.autosize = $true
    $ZoomVMWareBox.location = New-Object System.Drawing.Point(615,170)
    $form.Controls.Add($ZoomVMWareBox)
	$ZoomVMWareBox.Checked =  $SoftwareSelection.ZoomVMWare
	
		
	# Select Button
    $SelectButton = New-Object system.Windows.Forms.Button
    $SelectButton.text = "Select all"
    $SelectButton.width = 110
    $SelectButton.height = 30
    $SelectButton.location = New-Object System.Drawing.Point(11,470)
    $SelectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $True
		$SevenZipBox.checked = $True
		$AdobeReaderDCBoxUpdate.checked = $True
		$BISFBox.checked = $True
		$FSLogixBox.checked = $True
		$GoogleChromeBox.checked = $True
		$WorkspaceApp_CRBox.checked = $True
		$WorkspaceApp_LTSRBox.checked = $True
		$Citrix_HypervisorToolsBox.checked = $True
		$VMWareToolsBox.checked = $True
		$RemoteDesktopManagerBox.checked = $True
		$deviceTRUSTBox.checked = $True
		$KeePassBox.checked = $True
		$mRemoteNGBox.checked = $True
		$WinSCPBox.checked = $True
		$PuttyBox.checked = $True
		$MS365AppsBox.checked = $True
		$MSOffice2019Box.checked = $True
		$MSEdgeBox.checked = $True
		$MSOneDriveBox.checked = $True
		$MSTeamsBox.checked = $True
		$MSTeamsPrevBox.checked = $True
		$MSPowershellBox.checked = $True
		$MSDotNetBox.checked = $True
		$MSSQLManagementStudioDEBox.checked = $True
		$MSSQLManagementStudioENBox.checked = $True
		$MSWVDDesktopAgentBox.checked = $True
		$MSWVDRTCServiceBox.checked = $True
		$MSWVDBootLoaderBox.checked = $True
		$TreeSizeFreeBox.checked = $True
		$ZoomVDIBox.checked = $True
		$ZoomCitrixBox.checked = $True
		$ZoomVMWareBox.checked = $True
		$VLCPlayerBox.checked = $True
		$FileZillaBox.checked = $True
		$OpenJDKBox.checked = $True
		$OracleJava8Box.checked = $True
		$OracleJava8_32Box.checked = $True
		})
    $form.Controls.Add($SelectButton)
	
	# Unselect Button
    $UnselectButton = New-Object system.Windows.Forms.Button
    $UnselectButton.text = "Unselect all"
    $UnselectButton.width = 110
    $UnselectButton.height = 30
    $UnselectButton.location = New-Object System.Drawing.Point(131,470)
    $UnselectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $False
		$SevenZipBox.checked = $False
		$AdobeReaderDCBoxUpdate.checked = $False
		$BISFBox.checked = $False
		$FSLogixBox.checked = $False
		$GoogleChromeBox.checked = $False
		$WorkspaceApp_CRBox.checked = $False
		$WorkspaceApp_LTSRBox.checked = $False
		$Citrix_HypervisorToolsBox.checked = $False
		$VMWareToolsBox.checked = $False
		$RemoteDesktopManagerBox.checked = $False
		$deviceTRUSTBox.checked = $False
		$KeePassBox.checked = $False
		$mRemoteNGBox.checked = $False
		$WinSCPBox.checked = $False
		$PuttyBox.checked = $False
		$MS365AppsBox.checked = $False
		$MSOffice2019Box.checked = $False
		$MSEdgeBox.checked = $False
		$MSOneDriveBox.checked = $False
		$MSTeamsBox.checked = $False
		$MSTeamsPrevBox.checked = $False
		$MSPowershellBox.checked = $False
		$MSDotNetBox.checked = $False
		$MSSQLManagementStudioDEBox.checked = $False
		$MSSQLManagementStudioENBox.checked = $False
		$MSWVDDesktopAgentBox.checked = $False
		$MSWVDRTCServiceBox.checked = $False
		$MSWVDBootLoaderBox.checked = $False
		$TreeSizeFreeBox.checked = $False
		$ZoomVDIBox.checked = $False
		$ZoomCitrixBox.checked = $False
		$ZoomVMWareBox.checked = $False
		$VLCPlayerBox.checked = $False
		$FileZillaBox.checked = $False
		$OpenJDKBox.checked = $False
		$OracleJava8Box.checked = $False
		$OracleJava8_32Box.checked = $False
		})
    $form.Controls.Add($UnselectButton)

    # OK Button
    $OKButton = New-Object system.Windows.Forms.Button
    $OKButton.text = "OK"
    $OKButton.width = 60
    $OKButton.height = 30
    $OKButton.location = New-Object System.Drawing.Point(271,470)
	#$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $OKButton.Add_Click({		
		$SoftwareSelection = New-Object PSObject
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NotepadPlusPlus" -Value $NotePadPlusPlusBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "SevenZip" -Value $SevenZipBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDC_MUI" -Value $AdobeReaderDCBoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "BISF" -Value $BISFBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FSLogix" -Value $FSLogixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "GoogleChrome" -Value $GoogleChromeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR" -Value $WorkspaceApp_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR" -Value $WorkspaceApp_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixHypervisorTools" -Value $Citrix_HypervisorToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps" -Value $MS365AppsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2019" -Value $MSOffice2019Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePass" -Value $KeePassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "mRemoteNG" -Value $mRemoteNGBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSEdge" -Value $MSEdgeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOneDrive" -Value $MSOneDriveBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeams" -Value $MSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeamsPrev" -Value $MSTeamsPrevBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSPowershell" -Value $MSPowershellBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSDotNetFramework" -Value $MSDotNetBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsEN" -Value $MSSQLManagementStudioENBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsDE" -Value $MSSQLManagementStudioDEBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDDesktopAgent" -Value $MSWVDDesktopAgentBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDRTCService" -Value $MSWVDRTCServiceBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDBootLoader" -Value $MSWVDBootLoaderBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "openJDK" -Value $OpenJDKBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8" -Value $OracleJava8Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8_32" -Value $OracleJava8_32Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "TreeSizeFree" -Value $TreeSizeFreeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVDI" -Value $ZoomVDIBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomCitrix" -Value $ZoomCitrixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVMWare" -Value $ZoomVMWareBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VLCPlayer" -Value $VLCPlayerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FileZilla" -Value $FileZillaBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "deviceTRUST" -Value $deviceTRUSTBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VMWareTools" -Value $VMWareToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RemoteDesktopManager" -Value $RemoteDesktopManagerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinSCP" -Value $WinSCPBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Putty" -Value $PuttyBox.checked -Force
	
	# Export objects to	XML
	$SoftwareSelection | Export-Clixml $SoftwareToUpdate
    $Form.Close()
    })
    $form.Controls.Add($OKButton)

    # Cancel Button
    $CancelButton = New-Object system.Windows.Forms.Button
    $CancelButton.text = "Cancel"
    $CancelButton.width = 80
    $CancelButton.height = 30
    $CancelButton.location = New-Object System.Drawing.Point(341,470)
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $CancelButton.Add_Click({
        #$Script:download = $true
        Write-Host -ForegroundColor Red "Canceled - Nothing happens!"
        $Form.Close()
		[System.Environment]::Exit(0)
    })
    $form.Controls.Add($CancelButton)
	
    # Activate the form
    $Form.Add_Shown({$Form.Activate()})
    [void] $Form.ShowDialog()
}
# ========================================================================================================================================

# Call Form
if ($noGUI -eq $False) {
gui_mode
}

# Disable progress bar while downloading
$ProgressPreference = 'SilentlyContinue'

# Install/Update Evergreen module
Write-Host -ForegroundColor Cyan "Installing/updating Evergreen module... please wait"
Write-Output ""
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
IF (!(Test-Path -Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget")) {Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies}
IF (!(Get-Module -ListAvailable -Name Evergreen)) {Install-Module Evergreen -Force | Import-Module Evergreen}
Update-Module Evergreen -force


# Logfile UpdateLog
Start-Transcript $UpdateLog | Out-Null

# Import selection
$SoftwareSelection = Import-Clixml $SoftwareToUpdate
Write-Host -ForegroundColor Cyan "Import selection"
Write-Output ""

# Write-Output "Evergreen Version: $EvergreenVersion" | Out-File $UpdateLog -Append
Write-Host -ForegroundColor Cyan "Starting downloads..."
Write-Output ""

# Download Notepad ++
IF ($SoftwareSelection.NotePadPlusPlus -eq $true) {
$Product = "NotePadPlusPlus"
$PackageName = "NotePadPlusPlus_x64"
$Notepad = Get-EvergreenApp -Name NotepadPlusPlus | Where-Object {$_.Architecture -eq "x64" -and $_.URI -match ".exe"}
$Version = $Notepad.Version
$URL = $Notepad.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available for $Product"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Get-ChildItem "$PSScriptRoot\$Product\" -Exclude lang | Remove-Item -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download Chrome
IF ($SoftwareSelection.GoogleChrome -eq $true) {
$Product = "Google Chrome"
$PackageName = "GoogleChromeStandaloneEnterprise64"
$Chrome = Get-EvergreenApp -Name GoogleChrome | Where-Object {$_.Architecture -eq "x64"}
$Version = $Chrome.Version
$URL = $Chrome.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS Edge
IF ($SoftwareSelection.MSEdge -eq $true) {
$Product = "MS Edge"
$PackageName = "MicrosoftEdgeEnterpriseX64"
$Edge = Get-EvergreenApp -Name MicrosoftEdge | Where-Object {$_.Platform -eq "Windows" -and $_.Channel -eq "stable" -and $_.Architecture -eq "x64" -and $_.Release -eq "Enterprise"}
$Version = $Edge.Version
$URL = $Edge.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue 
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS  | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download VLC Player
IF ($SoftwareSelection.VLCPlayer -eq $true) {
$Product = "VLC Player"
$PackageName = "VLC-Player"
$VLC = Get-EvergreenApp -Name VideoLanVlcPlayer | Where-Object {$_.Platform -eq "Windows"  -and $_.Architecture -eq "x64" -and $_.Type -eq "MSI"}
$Version = $VLC.Version
$URL = $VLC.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product" 
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available" 
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging" 
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download FileZilla Client
IF ($SoftwareSelection.FileZilla -eq $true) {
$Product = "FileZilla"
$PackageName = "FileZilla"
$FileZilla = Get-EvergreenApp -Name FileZilla
$Version = $FileZilla.Version
$URL = $FileZilla.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product" 
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available" 
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging" 
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download BIS-F
IF ($SoftwareSelection.BISF -eq $true) {
$Product = "BIS-F"
$PackageName = "setup-BIS-F"
$BISF = Get-EvergreenApp -Name BISF
$Version = $BISF.Version
$URL = $BISF.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Exclude *.ps1, SubCall -Recurse
Start-Transcript $LogPS
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download WorkspaceApp Current
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true) {
$Product = "WorkspaceApp"
$PackageName = "CitrixWorkspaceApp"
$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Title -like "*Workspace*" -and "*Current*" -and $_.Platform -eq "Windows" -and $_.Title -like "*Current*" }
$Version = $WSA.Version
$URL = $WSA.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\Citrix\$Product\Windows\Current\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
if (!(Test-Path -Path "$PSScriptRoot\Citrix\$Product\Windows\Current")) {New-Item -Path "$PSScriptRoot\Citrix\$Product\Windows\Current" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\Citrix\$Product\Windows\Current\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\Citrix\$Product\Windows\Current\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\Citrix\$Product\Windows\Current" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\Citrix\$Product\Windows\Current\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version Current Release"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\Citrix\$Product\Windows\Current\" + ($Source))
Copy-Item -Path "$PSScriptRoot\Citrix\$Product\Windows\Current\CitrixWorkspaceApp.exe" -Destination "$PSScriptRoot\Citrix\$Product\Windows\Current\CitrixWorkspaceAppWeb.exe" | Out-Null
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download WorkspaceApp LTSR
IF ($SoftwareSelection.WorkspaceApp_LTSR -eq $true) {
$Product = "WorkspaceApp"
$PackageName = "CitrixWorkspaceApp"
$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Title -like "*Workspace*" -and "*LTSR*" -and $_.Platform -eq "Windows" -and $_.Title -like "*LTSR*" }
$Version = $WSA.Version
$URL = $WSA.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\Citrix\$Product\Windows\LTSR\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product LTSR"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\Citrix\$Product\Windows\LTSR")) {New-Item -Path "$PSScriptRoot\Citrix\$Product\Windows\LTSR" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\Citrix\$Product\Windows\LTSR\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\Citrix\$Product\Windows\LTSR\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\Citrix\$Product\Windows\LTSR" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\Citrix\$Product\Windows\LTSR\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version LTSR Release"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\Citrix\$Product\Windows\LTSR\" + ($Source))
Copy-Item -Path "$PSScriptRoot\Citrix\$Product\Windows\LTSR\CitrixWorkspaceApp.exe" -Destination "$PSScriptRoot\Citrix\$Product\Windows\LTSR\CitrixWorkspaceAppWeb.exe" | Out-Null
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download 7-ZIP
IF ($SoftwareSelection.SevenZip -eq $true) {
$Product = "7-Zip"
$PackageName = "7-Zip_x64"
$7Zip = Get-EvergreenApp -Name 7zip | Where-Object {$_.Architecture -eq "x64" -and $_.URI -like "*exe*"}
$Version = $7Zip.Version
$URL = $7Zip.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download Adobe Reader DC MUI Update
IF ($SoftwareSelection.AdobeReaderDC_MUI -eq $true) {
$Product = "Adobe Reader DC MUI"
$PackageName = "Adobe_DC_MUI_Update"
$Adobe = Get-EvergreenApp -Name AdobeAcrobat | Where-Object {$_.Track -eq "DC" -and $_.Product -eq "Reader" -and $_.Language -eq "Multi"}
$Version = $Adobe.Version
$URL = $Adobe.uri
$InstallerType = "msp"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available for $Product"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Include *.msp, *.log, Version.txt, Download* -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source)) 
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download FSLogix
IF ($SoftwareSelection.FSLogix -eq $true) {
$Product = "FSLogix"
$PackageName = "FSLogixAppsSetup"
$FSLogix = Get-EvergreenApp -Name MicrosoftFSLogixApps | Where-Object {$_.Channel -eq "Public"}
$Version = $FSLogix.Version
$URL = $FSLogix.uri
$InstallerType = "zip"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Install\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product\Install")) {New-Item -Path "$PSScriptRoot\$Product\Install" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\Install\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\Install\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product\Install" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Install\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\Install\" + ($Source))
expand-archive -path "$PSScriptRoot\$Product\Install\FSLogixAppsSetup.zip" -destinationpath "$PSScriptRoot\$Product\Install"
Remove-Item -Path "$PSScriptRoot\$Product\Install\FSLogixAppsSetup.zip" -Force
Move-Item -Path "$PSScriptRoot\$Product\Install\x64\Release\*" -Destination "$PSScriptRoot\$Product\Install"
Remove-Item -Path "$PSScriptRoot\$Product\Install\Win32" -Force -Recurse
Remove-Item -Path "$PSScriptRoot\$Product\Install\x64" -Force -Recurse
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS Teams
IF ($SoftwareSelection.MSTeams -eq $true) {
$Product = "MS Teams"
$PackageName = "Teams_windows_x64"
$Teams = Get-EvergreenApp -Name MicrosoftTeams | Where-Object {$_.Architecture -eq "x64" -and $_.Ring -eq "General"}
$Version = $Teams.Version
$URL = $Teams.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS Teams-Preview
IF ($SoftwareSelection.MSTeamsPrev -eq $true) {
$Product = "MS Teams - Preview Release"
$PackageName = "Teams_windows_x64"
$Teams = Get-EvergreenApp -Name MicrosoftTeams | Where-Object {$_.Architecture -eq "x64" -and $_.Ring -eq "Preview"}
$Version = $Teams.Version
$URL = $Teams.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS OneDrive
IF ($SoftwareSelection.MSOneDrive -eq $true) {
$Product = "MS OneDrive"
$PackageName = "OneDriveSetup"
$OneDrive = Get-EvergreenApp -Name MicrosoftOneDrive | Where-Object {$_.Ring -eq "Production" -and $_.Type -eq "Exe"} | Select-Object -First 1
$Version = $OneDrive.Version
$URL = $OneDrive.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS Office365Apps
IF ($SoftwareSelection.MS365Apps -eq $true) {
$Product = "MS 365 Apps-Semi Annual Channel"
$PackageName = "setup"
$MS365Apps = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "Semi-Annual Channel"}
$Version = $MS365Apps.Version
$URL = $MS365Apps.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS Office 2019
IF ($SoftwareSelection.MSOffice2019 -eq $true) {
$Product = "MS Office 2019"
$PackageName = "setup"
$MSOffice2019 = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "Office 2019 Enterprise"}
$Version = $MSOffice2019.Version
$URL = $MSOffice2019.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS Powershell
IF ($SoftwareSelection.MSPowershell -eq $true) {
$Product = "MS Powershell"
$PackageName = "Powershell"
$MSPowershell = Get-EvergreenApp -Name MicrosoftPowerShell | Where-Object {$_.Architecture -eq "x64" -and $_.Release -eq "Stable"}
$Version = $MSPowershell.Version
$URL = $MSPowershell.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS .Net Framework
IF ($SoftwareSelection.MSDotNetFramework -eq $true) {
$Product = "MS DotNet Framework"
$PackageName = "DotNetFramework-runtime"
$MSDotNetFramework = Get-EvergreenApp -Name Microsoft.NET | Where-Object {$_.Architecture -eq "x64" -and $_.Channel -eq "Current"}
$Version = $MSDotNetFramework.Version
$URL = $MSDotNetFramework.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS SQL Management Studio en
IF ($SoftwareSelection.MSSsmsEN -eq $true) {
$Product = "MS SQL Management Studio EN"
$PackageName = "SSMS-Setup-ENU"
$MSSQLManagementStudioEN = Get-EvergreenApp -Name MicrosoftSsms | Where-Object {$_.Language -eq "English"}
$Version = $MSSQLManagementStudioEN.Version
$URL = $MSSQLManagementStudioEN.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS SQL Management Studio de
IF ($SoftwareSelection.MSSsmsDE -eq $true) {
$Product = "MS SQL Management Studio DE"
$PackageName = "SSMS-Setup-DEU"
$MSSQLManagementStudioDE = Get-EvergreenApp -Name MicrosoftSsms | Where-Object {$_.Language -eq "German"}
$Version = $MSSQLManagementStudioDE.Version
$URL = $MSSQLManagementStudioDE.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS WVD Desktop Agent
IF ($SoftwareSelection.MSWVDDesktopAgent -eq $true) {
$Product = "MS WVD Desktop Agent"
$PackageName = "Microsoft.RDInfra.RDAgent.Installer-x64"
$MSWVDDesktopAgent = Get-EvergreenApp -Name MicrosoftWvdInfraAgent
$Version = $MSWVDDesktopAgent.Version
$URL = $MSWVDDesktopAgent.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS WVD Boot Loader
IF ($SoftwareSelection.MSWVDBootLoader -eq $true) {
$Product = "MS WVD Boot Loader"
$MSWVDBootLoader = Get-EvergreenApp -Name MicrosoftWvdBootloader
$PackageName = $MSWVDBootLoader.Filename
$URL = $MSWVDBootLoader.uri
Write-Host -ForegroundColor Yellow "Download $Product"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Write-Host -ForegroundColor Yellow "Starting Download of $Product"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($PackageName))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}


# Download MS WVD WebSocket Service
IF ($SoftwareSelection.MSWVDRTCService -eq $true) {
$Product = "MS WVD RTC Service for Teams"
$PackageName = "MsRdcWebRTCSvc_HostSetup_x64"
$MSWVDRTCService = Get-EvergreenApp -Name MicrosoftWvdRtcService
$Version = $MSWVDRTCService.Version
$URL = $MSWVDRTCService.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download Citrix Hypervisor Tools
IF ($SoftwareSelection.CitrixHypervisorTools -eq $true) {
$Product = "Citrix Hypervisor Tools"
$PackageName = "managementagentx64"
$CitrixTools = Get-EvergreenApp -Name CitrixVMTools | Where-Object {$_.Architecture -eq "x64"} | Select-Object -Last 1
$Version = $CitrixTools.Version
$URL = $CitrixTools.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download VMWareTools
IF ($SoftwareSelection.VMWareTools -eq $true) {
$Product = "VMWare Tools"
$PackageName = "VMWareTools"
$VMWareTools = Get-EvergreenApp -Name VMwareTools | Where-Object {$_.Architecture -eq "x64"}
$Version = $VMWareTools.Version
$URL = $VMWareTools.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download RemoteDesktopManager
IF ($SoftwareSelection.RemoteDesktopManager -eq $true) {
$Product = "RemoteDesktopManager"
$PackageName = "Setup.RemoteDesktopManagerFree"
$URLVersion = "https://remotedesktopmanager.com/de/release-notes/free"
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
$regexAppVersion = "\d\d\d\d.\d.\d\d.\d+"
$webVersion = $webRequest.RawContent | Select-String -Pattern $regexAppVersion -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
$Version = $webVersion.Trim("</td>").Trim("</td>")
$URL = "https://cdn.devolutions.net/download/Setup.RemoteDesktopManagerFree.$Version.msi"
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -UseBasicParsing -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download deviceTRUST
IF ($SoftwareSelection.deviceTRUST -eq $true) {
$Product = "deviceTRUST"
$PackageName = "deviceTRUST"
$URLVersion = "https://docs.devicetrust.com/docs/download/"
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
$regexAppVersion = "<td>\d\d.\d.\d\d\d+</td>"
$webVersion = $webRequest.RawContent | Select-String -Pattern $regexAppVersion -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
$Version = $webVersion.Trim("</td>").Trim("</td>")
$URL = "https://storage.devicetrust.com/download/deviceTRUST-$Version.zip"
$InstallerType = "zip"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -UseBasicParsing -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
expand-archive -path "$PSScriptRoot\$Product\deviceTRUST.zip" -destinationpath "$PSScriptRoot\$Product"
Remove-Item -Path "$PSScriptRoot\$Product\deviceTRUST.zip" -Force
expand-archive -path "$PSScriptRoot\$Product\dtpolicydefinitions-$Version.0.zip" -destinationpath "$PSScriptRoot\$Product\ADMX"
copy-item -Path "$PSScriptRoot\$Product\ADMX\*" -Destination "$PSScriptRoot\ADMX\deviceTRUST" -Force
Remove-Item -Path "$PSScriptRoot\$Product\ADMX" -Force -Recurse
Remove-Item -Path "$PSScriptRoot\$Product\dtpolicydefinitions-$Version.0.zip" -Force
Get-ChildItem -Path "$PSScriptRoot\$Product" | Where Name -like *"x86"* | Remove-Item
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download openJDK
IF ($SoftwareSelection.OpenJDK -eq $true) {
$Product = "open JDK"
$PackageName = "OpenJDK"
$OpenJDK = Get-EvergreenApp -Name OpenJDK | Where-Object {$_.Architecture -eq "x64" -and $_.URI -like "*msi*"} | Sort-Object -Property Version -Descending | Select-Object -First 1
$Version = $OpenJDK.Version
$URL = $OpenJDK.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download OracleJava8
IF ($SoftwareSelection.OracleJava8 -eq $true) {
$Product = "Oracle Java 8"
$PackageName = "Oracle Java 8"
$OracleJava8 = Get-EvergreenApp -Name OracleJava8 | Where-Object {$_.Architecture -eq "x64"}
$Version = $OracleJava8.Version
$Version = $Version -replace ".{4}$"
$URL = $OracleJava8.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download OracleJava8 32-Bit
IF ($SoftwareSelection.OracleJava8_32 -eq $true) {
$Product = "Oracle Java 8 - 32 Bit"
$PackageName = "Oracle Java 8"
$OracleJava8 = Get-EvergreenApp -Name OracleJava8 | Where-Object {$_.Architecture -eq "x86"}
$Version = $OracleJava8.Version
$Version = $Version -replace ".{4}$"
$URL = $OracleJava8.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download KeePass
IF ($SoftwareSelection.KeePass -eq $true) {
$Product = "KeePass"
$PackageName = "KeePass"
$KeePass = Get-EvergreenApp -Name KeePass | Where-Object {$_.URI -like "*exe*"}
$Version = $KeePass.Version
$URL = $KeePass.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download mRemoteNG
IF ($SoftwareSelection.mRemoteNG -eq $true) {
$Product = "mRemoteNG"
$PackageName = "mRemoteNG"
$mRemoteNG = Get-EvergreenApp -Name mRemoteNG | Where-Object {$_.URI -like "*msi*"}
$Version = $mRemoteNG.Version
$URL = $mRemoteNG.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download Tree Size Free
IF ($SoftwareSelection.TreeSizeFree -eq $true) {
$Product = "TreeSizeFree"
$PackageName = "TreeSizeFree"
$TreeSizeFree = Get-EvergreenApp -Name JamTreeSizeFree
$Version = $TreeSizeFree.Version
$URL = $TreeSizeFree.uri
$InstallerType = "exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source)) -EA SilentlyContinue
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download WinSCP
IF ($SoftwareSelection.WinSCP -eq $true) {
$Product = "WinSCP"
$PackageName = "WinSCP"
$WinSCP = Get-EvergreenApp -Name WinSCP
$Version = $WinSCP.Version
$URL = $WinSCP.uri
$InstallerType = "zip"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
expand-archive -path "$PSScriptRoot\$Product\$Source" -destinationpath "$PSScriptRoot\$Product"
Remove-Item -Path "$PSScriptRoot\$Product\$PackageName.zip" -Force
Remove-Item -Path "$PSScriptRoot\$Product\readme.txt" -Force
Remove-Item -Path "$PSScriptRoot\$Product\license.txt" -Force
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download Putty
IF ($SoftwareSelection.Putty -eq $true) {
$Product = "Putty"
$PackageName = "Putty"
$URLVersion = "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
$regexAppVersion = "\(\d\.\d\d\)"
$webVersion = $webRequest.RawContent | Select-String -Pattern $regexAppVersion -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
$Version = $webVersion.Trim("(").Trim(")")
$InstallerType = "exe"
$URL = "https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}

# Stop UpdateLog
Stop-Transcript | Out-Null


# Download Zoom VDI Installer
IF ($SoftwareSelection.ZoomVDI -eq $true) {
$Product = "Zoom VDI Host"
$PackageName = "ZoomInstallerVDI"
$ZoomVDI = Get-EvergreenApp -Name Zoom | Where-Object {$_.Platform -eq "VDI"}
$URLVersion = "https://support.zoom.us/hc/en-us/articles/360041602711"
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
$regexAppVersion = "(\d\.\d\.\d)"
$Version = $webRequest.RawContent | Select-String -Pattern $regexAppVersion -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Descending | Select-Object -First 1
$URL = $ZoomVDI.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download Zoom Citrix client
IF ($SoftwareSelection.ZoomCitrix -eq $true) {
$Product = "Zoom Citrix Client"
$PackageName = "ZoomCitrixHDXMediaPlugin"
$ZoomCitrix = Get-EvergreenApp -Name Zoom | Where-Object {$_.Platform -eq "Citrix"}
$URLVersion = "https://support.zoom.us/hc/en-us/articles/360041602711"
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
$regexAppVersion = "(\d\.\d\.\d)"
$Version = $webRequest.RawContent | Select-String -Pattern $regexAppVersion -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Descending | Select-Object -First 1
$URL = $ZoomCitrix.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download Zoom VMWare client
IF ($SoftwareSelection.ZoomVMWare -eq $true) {
$Product = "Zoom VMWare Client"
$PackageName = "ZoomVMWareMediaPlugin"
$ZoomVMWare = Get-EvergreenApp -Name Zoom | Where-Object {$_.Platform -eq "VMWare"}
$URLVersion = "https://support.zoom.us/hc/en-us/articles/360041602711"
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
$regexAppVersion = "(\d\.\d\.\d)"
$Version = $webRequest.RawContent | Select-String -Pattern $regexAppVersion -AllMatches | ForEach-Object { $_.Matches.Value } | Sort-Object -Descending | Select-Object -First 1
$URL = $ZoomVMWare.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$PSScriptRoot\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor DarkRed "Update available"
IF (!(Test-Path -Path "$PSScriptRoot\$Product")) {New-Item -Path "$PSScriptRoot\$Product" -ItemType Directory | Out-Null}
$LogPS = "$PSScriptRoot\$Product\" + "$Product $Version.log"
Remove-Item "$PSScriptRoot\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$PSScriptRoot\$Product" -Name "Download date $Date" | Out-Null
Set-Content -Path "$PSScriptRoot\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$PSScriptRoot\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}

# Format UpdateLog
$Content = Get-Content -Path $UpdateLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $UpdateLog

if ($noGUI -eq $False) {pause}