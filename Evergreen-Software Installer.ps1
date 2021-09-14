﻿# ******************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software packages on your master server/client
# ******************************************************

<#
.SYNOPSIS
This script calls other scripts to install software on a MCS/PVS master server/client or wherever you want. Install scripts have to be in the root folder. 
		
.DESCRIPTION
To install a software package just launch the Installer.ps1 script and select the software you want to install.
The selection is stored in a XML file, so you can easily replace the script and you don't have to make your selection again every time.

.EXAMPLE

.PARAMETER
If you made your selection once, you can run the script with the -noGUI parameter.

.NOTES
Thanks to Trond Eric Haarvarstein, I used some code from his great Automation Framework! Thanks to Manuel Winkel for the forms ;-)
There are no install scripts for VMWare Tools and openJDK yet!
Run as admin!
#>

Param (
		[Parameter(
            HelpMessage='Start without Gui',
            ValuefromPipelineByPropertyName = $true
        )]
        [switch]$noGUI
    
)

# Do you run the script as admin?
# ========================================================================================================================================
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($myWindowsPrincipal.IsInRole($adminRole))
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

Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------------- "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " SuL Software-Installer (Powered by Evergreen-Module) "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " © D. Mohrmann - S&L Firmengruppe                     "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------------- "
Write-Output ""

Write-Host -ForegroundColor Cyan "Setting Variables"
Write-Output ""

# Variables
$SoftwareFolder = ("$PSScriptRoot" + "\" + "Software\")
$ErrorActionPreference = "Continue"
$SoftwareToInstall = "$SoftwareFolder\Software-to-install-$ENV:Computername.xml"

# General install logfile
$Date = $Date = Get-Date -UFormat "%d.%m.%Y"
$InstallLog = "$SoftwareFolder\_Install Logs\General Install $ENV:Computername $Date.log"

# Import values (selected software) from XML file
if (Test-Path -Path $SoftwareToInstall) {$SoftwareSelection = Import-Clixml $SoftwareToInstall}

#Remove-Item $InstallLog*
Start-Transcript $InstallLog | Out-Null


# FUNCTION Logging
#========================================================================================================================================
Function DS_WriteLog {
    
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$true, Position = 0)][ValidateSet("I","S","W","E","-",IgnoreCase = $True)][String]$InformationType,
        [Parameter(Mandatory=$true, Position = 1)][AllowEmptyString()][String]$Text,
        [Parameter(Mandatory=$true, Position = 2)][AllowEmptyString()][String]$LogFile
    )
 
    begin {
    }
 
    process {
     $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss)
 
        if ( $Text -eq "" ) {
            Add-Content $LogFile -value ("") # Write an empty line
        } Else {
         Add-Content $LogFile -value ($DateTime + " " + $InformationType.ToUpper() + " - " + $Text)
        }
    }
 
    end {
    }
}
#========================================================================================================================================

# FUNCTION GUI
# ========================================================================================================================================
function gui_mode{
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

	# Set the size of your form
    $Form = New-Object system.Windows.Forms.Form
    #$Form.ClientSize = New-Object System.Drawing.Point(820,650)
	$Form.ClientSize = New-Object System.Drawing.Point(700,640)
    $Form.text = "SuL Software-Installer"
    $Form.TopMost = $false
    $Form.AutoSize = $true

    # Set the font of the text to be used within the form
    $Font = New-Object System.Drawing.Font("Arial",11)
    $Form.Font = $Font

    # Software Headline
    $Headline2 = New-Object system.Windows.Forms.Label
    $Headline2.text = "Select Software to install"
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
	$NotePadPlusPlusBox.Checked =  $SoftwareSelection.NotePadPlusPlus
	
    # 7Zip Checkbox
    $SevenZipBox = New-Object system.Windows.Forms.CheckBox
    $SevenZipBox.text = "7 Zip"
    $SevenZipBox.width = 95
    $SevenZipBox.height = 20
    $SevenZipBox.autosize = $true
    $SevenZipBox.location = New-Object System.Drawing.Point(11,70)
    $form.Controls.Add($SevenZipBox)
	$SevenZipBox.Checked =  $SoftwareSelection.SevenZip

    # AdobeReaderDC Checkbox
    $AdobeReaderDCBox = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBox.text = "Adobe Reader DC-MUI (only for Base Install)"
    $AdobeReaderDCBox.width = 95
    $AdobeReaderDCBox.height = 20
    $AdobeReaderDCBox.autosize = $true
    $AdobeReaderDCBox.location = New-Object System.Drawing.Point(11,95)
    $form.Controls.Add($AdobeReaderDCBox)
	$AdobeReaderDCBox.Checked =  $SoftwareSelection.AdobeReaderDC
	
	# AdobeReaderDCUpdate Checkbox
    $AdobeReaderDCBoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBoxUpdate.text = "Adobe Reader DC-MUI Update (Updates only)"
    $AdobeReaderDCBoxUpdate.width = 95
    $AdobeReaderDCBoxUpdate.height = 20
    $AdobeReaderDCBoxUpdate.autosize = $true
    $AdobeReaderDCBoxUpdate.location = New-Object System.Drawing.Point(11,120)
    $form.Controls.Add($AdobeReaderDCBoxUpdate)
	$AdobeReaderDCBoxUpdate.Checked =  $SoftwareSelection.AdobeReaderDCUpdate

    # BISF Checkbox
    $BISFBox = New-Object system.Windows.Forms.CheckBox
    $BISFBox.text = "BIS-F"
    $BISFBox.width = 95
    $BISFBox.height = 20
    $BISFBox.autosize = $true
    $BISFBox.location = New-Object System.Drawing.Point(11,145)
    $form.Controls.Add($BISFBox)
	$BISFBox.Checked =  $SoftwareSelection.BISF
	
	# FSLogix Checkbox
    $FSLogixBox = New-Object system.Windows.Forms.CheckBox
    $FSLogixBox.text = "FSLogix"
    $FSLogixBox.width = 95
    $FSLogixBox.height = 20
    $FSLogixBox.autosize = $true
    $FSLogixBox.location = New-Object System.Drawing.Point(11,170)
    $form.Controls.Add($FSLogixBox)
	$FSLogixBox.Checked =  $SoftwareSelection.FSLogix

    # GoogleChrome Checkbox
    $GoogleChromeBox = New-Object system.Windows.Forms.CheckBox
    $GoogleChromeBox.text = "Google Chrome"
    $GoogleChromeBox.width = 95
    $GoogleChromeBox.height = 20
    $GoogleChromeBox.autosize = $true
    $GoogleChromeBox.location = New-Object System.Drawing.Point(11,195)
    $form.Controls.Add($GoogleChromeBox)
	$GoogleChromeBox.Checked =  $SoftwareSelection.GoogleChrome

    # Citrix WorkspaceApp_Current_Release Checkbox
    $WorkspaceApp_CRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CRBox.text = "Citrix WorkspaceApp CR"
    $WorkspaceApp_CRBox.width = 95
    $WorkspaceApp_CRBox.height = 20
    $WorkspaceApp_CRBox.autosize = $true
    $WorkspaceApp_CRBox.location = New-Object System.Drawing.Point(11,220)
    $form.Controls.Add($WorkspaceApp_CRBox)
	$WorkspaceApp_CRBox.Checked =  $SoftwareSelection.WorkspaceApp_CR

    # Citrix WorkspaceApp_LTSR_Release Checkbox
    $WorkspaceApp_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSRBox.text = "Citrix WorkspaceApp LTSR"
    $WorkspaceApp_LTSRBox.width = 95
    $WorkspaceApp_LTSRBox.height = 20
    $WorkspaceApp_LTSRBox.autosize = $true
    $WorkspaceApp_LTSRBox.location = New-Object System.Drawing.Point(11,245)
    $form.Controls.Add($WorkspaceApp_LTSRBox)
	$WorkspaceApp_LTSRBox.Checked =  $SoftwareSelection.WorkspaceApp_LTSR
	
	# Citrix WorkspaceApp_Current_Release_Web Checkbox
    $WorkspaceApp_CR_WebBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CR_WebBox.text = "Citrix WorkspaceApp CR Web (Autostart disabled)"
    $WorkspaceApp_CR_WebBox.width = 95
    $WorkspaceApp_CR_WebBox.height = 20
    $WorkspaceApp_CR_WebBox.autosize = $true
    $WorkspaceApp_CR_WebBox.location = New-Object System.Drawing.Point(11,270)
    $form.Controls.Add($WorkspaceApp_CR_WebBox)
	$WorkspaceApp_CR_WebBox.Checked =  $SoftwareSelection.WorkspaceApp_CR_Web

    # Citrix WorkspaceApp_LTSR_Release_Web Checkbox
    $WorkspaceApp_LTSR_WebBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSR_WebBox.text = "Citrix WorkspaceApp LTSR Web (Autostart disabled)"
    $WorkspaceApp_LTSR_WebBox.width = 95
    $WorkspaceApp_LTSR_WebBox.height = 20
    $WorkspaceApp_LTSR_WebBox.autosize = $true
    $WorkspaceApp_LTSR_WebBox.location = New-Object System.Drawing.Point(11,295)
    $form.Controls.Add($WorkspaceApp_LTSR_WebBox)
	$WorkspaceApp_LTSR_WebBox.Checked =  $SoftwareSelection.WorkspaceApp_LTSR_Web
	
	# Citrix Hypervisor Tools Checkbox
    $Citrix_HypervisorToolsBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_HypervisorToolsBox.text = "Citrix Hypervisor Tools (Auto Update disabled)"
    $Citrix_HypervisorToolsBox.width = 95
    $Citrix_HypervisorToolsBox.height = 20
    $Citrix_HypervisorToolsBox.autosize = $true
    $Citrix_HypervisorToolsBox.location = New-Object System.Drawing.Point(11,320)
    $form.Controls.Add($Citrix_HypervisorToolsBox)
	$Citrix_HypervisorToolsBox.Checked = $SoftwareSelection.CitrixHypervisorTools
	
	# Citrix PVS Target Device LTSR Checkbox
    $PVSTargetDevice_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $PVSTargetDevice_LTSRBox.text = "Citrix PVS Target Device LTSR"
    $PVSTargetDevice_LTSRBox.width = 95
    $PVSTargetDevice_LTSRBox.height = 20
    $PVSTargetDevice_LTSRBox.autosize = $true
    $PVSTargetDevice_LTSRBox.location = New-Object System.Drawing.Point(11,345)
    $form.Controls.Add($PVSTargetDevice_LTSRBox)
	$PVSTargetDevice_LTSRBox.Checked =  $SoftwareSelection.CitrixPVSTargetDevice_LTSR
	
	# Citrix PVS Target Device CR/Cloud Checkbox
    $PVSTargetDevice_CRBox = New-Object system.Windows.Forms.CheckBox
    $PVSTargetDevice_CRBox.text = "Citrix PVS Target Device CR/Cloud"
    $PVSTargetDevice_CRBox.width = 95
    $PVSTargetDevice_CRBox.height = 20
    $PVSTargetDevice_CRBox.autosize = $true
    $PVSTargetDevice_CRBox.location = New-Object System.Drawing.Point(11,370)
    $form.Controls.Add($PVSTargetDevice_CRBox)
	$PVSTargetDevice_CRBox.Checked =  $SoftwareSelection.CitrixPVSTargetDevice_CR
	
	# Citrix VDA PVS LTSR Checkbox
    $ServerVDA_PVS_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_PVS_LTSRBox.text = "Citrix Server VDA for PVS LTSR"
    $ServerVDA_PVS_LTSRBox.width = 95
    $ServerVDA_PVS_LTSRBox.height = 20
    $ServerVDA_PVS_LTSRBox.autosize = $true
    $ServerVDA_PVS_LTSRBox.location = New-Object System.Drawing.Point(11,395)
    $form.Controls.Add($ServerVDA_PVS_LTSRBox)
	$ServerVDA_PVS_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_PVS_LTSR
	
	# Citrix VDA PVS CR/Cloud Checkbox
    $ServerVDA_PVS_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_PVS_CRBox.text = "Citrix Server VDA for PVS CR/Cloud"
    $ServerVDA_PVS_CRBox.width = 95
    $ServerVDA_PVS_CRBox.height = 20
    $ServerVDA_PVS_CRBox.autosize = $true
    $ServerVDA_PVS_CRBox.location = New-Object System.Drawing.Point(11,420)
    $form.Controls.Add($ServerVDA_PVS_CRBox)
	$ServerVDA_PVS_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_PVS_CR
	
	# Citrix VDA MCS LTSR Checkbox
    $ServerVDA_MCS_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_MCS_LTSRBox.text = "Citrix Server VDA for MCS LTSR"
    $ServerVDA_MCS_LTSRBox.width = 95
    $ServerVDA_MCS_LTSRBox.height = 20
    $ServerVDA_MCS_LTSRBox.autosize = $true
    $ServerVDA_MCS_LTSRBox.location = New-Object System.Drawing.Point(11,445)
    $form.Controls.Add($ServerVDA_MCS_LTSRBox)
	$ServerVDA_MCS_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_MCS_LTSR
	
	# Citrix VDA MCS CR/Cloud Checkbox
    $ServerVDA_MCS_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_MCS_CRBox.text = "Citrix Server VDA for MCS CR/Cloud"
    $ServerVDA_MCS_CRBox.width = 95
    $ServerVDA_MCS_CRBox.height = 20
    $ServerVDA_MCS_CRBox.autosize = $true
    $ServerVDA_MCS_CRBox.location = New-Object System.Drawing.Point(11,470)
    $form.Controls.Add($ServerVDA_MCS_CRBox)
	$ServerVDA_MCS_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_MCS_CR
	
	# Citrix WEM Agent PVS Checkbox
    $WEM_Agent_PVSBox = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_PVSBox.text = "Citrix WEM Agent for PVS (Cloud)"
    $WEM_Agent_PVSBox.width = 95
    $WEM_Agent_PVSBox.height = 20
    $WEM_Agent_PVSBox.autosize = $true
    $WEM_Agent_PVSBox.location = New-Object System.Drawing.Point(11,495)
    $form.Controls.Add($WEM_Agent_PVSBox)
	$WEM_Agent_PVSBox.Checked =  $SoftwareSelection.CitrixWEM_Agent_PVS
	
	# Citrix WEM Agent MCS Checkbox
    $WEM_Agent_MCSBox = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_MCSBox.text = "Citrix WEM Agent for MCS (Cloud)"
    $WEM_Agent_MCSBox.width = 95
    $WEM_Agent_MCSBox.height = 20
    $WEM_Agent_MCSBox.autosize = $true
    $WEM_Agent_MCSBox.location = New-Object System.Drawing.Point(11,520)
    $form.Controls.Add($WEM_Agent_MCSBox)
	$WEM_Agent_MCSBox.Checked =  $SoftwareSelection.CitrixWEM_Agent_MCS
	
	# Citrix Files Checkbox
    $CitrixFilesBox = New-Object system.Windows.Forms.CheckBox
    $CitrixFilesBox.text = "Citrix Files (Autostart disabled)"
    $CitrixFilesBox.width = 95
    $CitrixFilesBox.height = 20
    $CitrixFilesBox.autosize = $true
    $CitrixFilesBox.location = New-Object System.Drawing.Point(11,545)
    $form.Controls.Add($CitrixFilesBox)
	$CitrixFilesBox.Checked =  $SoftwareSelection.CitrixCitrixFiles

	# MSEdge Checkbox
    $MSEdgeBox = New-Object system.Windows.Forms.CheckBox
    $MSEdgeBox.text = "Microsoft Edge (Stable Channel)"
    $MSEdgeBox.width = 95
    $MSEdgeBox.height = 20
    $MSEdgeBox.autosize = $true
    $MSEdgeBox.location = New-Object System.Drawing.Point(390,45)
    $form.Controls.Add($MSEdgeBox)
	$MSEdgeBox.Checked =  $SoftwareSelection.MSEdge

    # MSOneDrive Checkbox
    $MSOneDriveBox = New-Object system.Windows.Forms.CheckBox
    $MSOneDriveBox.text = "Microsoft OneDrive (Machine-Based VDI Installer)"
    $MSOneDriveBox.width = 95
    $MSOneDriveBox.height = 20
    $MSOneDriveBox.autosize = $true
    $MSOneDriveBox.location = New-Object System.Drawing.Point(390,70)
    $form.Controls.Add($MSOneDriveBox)
	$MSOneDriveBox.Checked =  $SoftwareSelection.MSOneDrive

    # MSTeams Checkbox
    $MSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $MSTeamsBox.text = "Microsoft Teams (Machine-Based VDI Installer)"
    $MSTeamsBox.width = 95
    $MSTeamsBox.height = 20
    $MSTeamsBox.autosize = $true
    $MSTeamsBox.location = New-Object System.Drawing.Point(390,95)
    $form.Controls.Add($MSTeamsBox)
	$MSTeamsBox.Checked =  $SoftwareSelection.MSTeams
	
	# MSTeams Preview Checkbox
    $MSTeamsPrevBox = New-Object system.Windows.Forms.CheckBox
    $MSTeamsPrevBox.text = "Microsoft Teams Preview (Machine-Based Install)"
    $MSTeamsPrevBox.width = 95
    $MSTeamsPrevBox.height = 20
    $MSTeamsPrevBox.autosize = $true
    $MSTeamsPrevBox.location = New-Object System.Drawing.Point(390,120)
    $form.Controls.Add($MSTeamsPrevBox)
	$MSTeamsPrevBox.Checked =  $SoftwareSelection.MSTeamsPrev
	
	# MS365Apps Preview Checkbox
    $MS365AppsBox = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox.text = "Microsoft 365 Apps/Office 2019 (64Bit / Semi Annual Channel)"
    $MS365AppsBox.width = 95
    $MS365AppsBox.height = 20
    $MS365AppsBox.autosize = $true
    $MS365AppsBox.location = New-Object System.Drawing.Point(390,145)
    $form.Controls.Add($MS365AppsBox)
	$MS365AppsBox.Checked =  $SoftwareSelection.MS365Apps

	# Zoom Host Checkbox
    $ZoomVDIBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVDIBox.text = "Zoom VDI Host Installer"
    $ZoomVDIBox.width = 95
    $ZoomVDIBox.height = 20
    $ZoomVDIBox.autosize = $true
    $ZoomVDIBox.location = New-Object System.Drawing.Point(390,170)
    $form.Controls.Add($ZoomVDIBox)
	$ZoomVDIBox.Checked =  $SoftwareSelection.ZoomVDI
	
	# Zoom Citrix client Checkbox
    $ZoomCitrixBox = New-Object system.Windows.Forms.CheckBox
    $ZoomCitrixBox.text = "Zoom Citrix Client"
    $ZoomCitrixBox.width = 95
    $ZoomCitrixBox.height = 20
    $ZoomCitrixBox.autosize = $true
    $ZoomCitrixBox.location = New-Object System.Drawing.Point(390,195)
    $form.Controls.Add($ZoomCitrixBox)
	$ZoomCitrixBox.Checked =  $SoftwareSelection.ZoomCitrix
	
<#	
	# Zoom VMWare client Checkbox
    $ZoomVMWareBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVMWareBox.text = "Zoom VMWare Client"
    $ZoomVMWareBox.width = 95
    $ZoomVMWareBox.height = 20
    $ZoomVMWareBox.autosize = $true
    $ZoomVMWareBox.location = New-Object System.Drawing.Point(390,195)
    $form.Controls.Add($ZoomVMWareBox)
	$ZoomVMWareBox.Checked =  $SoftwareSelection.ZoomVMWare
#>

    # TreeSizeFree Checkbox
    $TreeSizeFreeBox = New-Object system.Windows.Forms.CheckBox
    $TreeSizeFreeBox.text = "TreeSize Free"
    $TreeSizeFreeBox.width = 95
    $TreeSizeFreeBox.height = 20
    $TreeSizeFreeBox.autosize = $true
    $TreeSizeFreeBox.location = New-Object System.Drawing.Point(390,220)
    $form.Controls.Add($TreeSizeFreeBox)
	$TreeSizeFreeBox.Checked =  $SoftwareSelection.TreeSizeFree
	
	# OracleJava8 Checkbox
    $OracleJava8Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8Box.text = "Oracle Java 8"
    $OracleJava8Box.width = 95
    $OracleJava8Box.height = 20
    $OracleJava8Box.autosize = $true
    $OracleJava8Box.location = New-Object System.Drawing.Point(390,245)
    $form.Controls.Add($OracleJava8Box)
	$OracleJava8Box.Checked =  $SoftwareSelection.OracleJava8
	
	# OracleJava8-32Bit Checkbox
    $OracleJava8_32Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8_32Box.text = "Oracle Java 8 - 32 Bit"
    $OracleJava8_32Box.width = 95
    $OracleJava8_32Box.height = 20
    $OracleJava8_32Box.autosize = $true
    $OracleJava8_32Box.location = New-Object System.Drawing.Point(390,270)
    $form.Controls.Add($OracleJava8_32Box)
	$OracleJava8_32Box.Checked =  $SoftwareSelection.OracleJava8_32
	
	# deviceTRUST Checkbox
    $deviceTRUSTBox = New-Object system.Windows.Forms.CheckBox
    $deviceTRUSTBox.text = "deviceTRUST"
    $deviceTRUSTBox.width = 95
    $deviceTRUSTBox.height = 20
    $deviceTRUSTBox.autosize = $true
    $deviceTRUSTBox.location = New-Object System.Drawing.Point(390,295)
    $form.Controls.Add($deviceTRUSTBox)
	$deviceTRUSTBox.Checked =  $SoftwareSelection.deviceTRUST
	
	# CiscoWebExDesktop Checkbox
    $CiscoWebExDesktopBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExDesktopBox.text = "Cisco WebEx"
    $CiscoWebExDesktopBox.width = 95
    $CiscoWebExDesktopBox.height = 20
    $CiscoWebExDesktopBox.autosize = $true
    $CiscoWebExDesktopBox.location = New-Object System.Drawing.Point(390,320)
    $form.Controls.Add($CiscoWebExDesktopBox)
	$CiscoWebExDesktopBox.Checked =  $SoftwareSelection.CiscoWebExDesktop
	
	# KeePass Checkbox
    $KeePassBox = New-Object system.Windows.Forms.CheckBox
    $KeePassBox.text = "KeePass"
    $KeePassBox.width = 95
    $KeePassBox.height = 20
    $KeePassBox.autosize = $true
    $KeePassBox.location = New-Object System.Drawing.Point(390,345)
    $form.Controls.Add($KeePassBox)
	$KeePassBox.Checked =  $SoftwareSelection.KeePass

    # mRemoteNG Checkbox
    $mRemoteNGBox = New-Object system.Windows.Forms.CheckBox
    $mRemoteNGBox.text = "mRemoteNG"
    $mRemoteNGBox.width = 95
    $mRemoteNGBox.height = 20
    $mRemoteNGBox.autosize = $true
    $mRemoteNGBox.location = New-Object System.Drawing.Point(390,370)
    $form.Controls.Add($mRemoteNGBox)
	$mRemoteNGBox.Checked =  $SoftwareSelection.mRemoteNG
	
	# RemoteDesktopManager Checkbox
    $RemoteDesktopManagerBox = New-Object system.Windows.Forms.CheckBox
    $RemoteDesktopManagerBox.text = "Remote Desktop Manager Free"
    $RemoteDesktopManagerBox.width = 95
    $RemoteDesktopManagerBox.height = 20
    $RemoteDesktopManagerBox.autosize = $true
    $RemoteDesktopManagerBox.location = New-Object System.Drawing.Point(390,395)
    $form.Controls.Add($RemoteDesktopManagerBox)
	$RemoteDesktopManagerBox.Checked =  $SoftwareSelection.RemoteDesktopManager
	
	# VLCPlayer Checkbox
    $VLCPlayerBox = New-Object system.Windows.Forms.CheckBox
    $VLCPlayerBox.text = "VLC Player"
    $VLCPlayerBox.width = 95
    $VLCPlayerBox.height = 20
    $VLCPlayerBox.autosize = $true
    $VLCPlayerBox.location = New-Object System.Drawing.Point(390,420)
    $form.Controls.Add($VLCPlayerBox)
	$VLCPlayerBox.Checked =  $SoftwareSelection.VLCPlayer
	
	# FileZilla Checkbox
    $FileZillaBox = New-Object system.Windows.Forms.CheckBox
    $FileZillaBox.text = "FileZilla Client"
    $FileZillaBox.width = 95
    $FileZillaBox.height = 20
    $FileZillaBox.autosize = $true
    $FileZillaBox.location = New-Object System.Drawing.Point(390,445)
    $form.Controls.Add($FileZillaBox)
	$FileZillaBox.Checked =  $SoftwareSelection.FileZilla
	
	# ImageGlass Checkbox
    $ImageGlassBox = New-Object system.Windows.Forms.CheckBox
    $ImageGlassBox.text = "ImageGlass"
    $ImageGlassBox.width = 95
    $ImageGlassBox.height = 20
    $ImageGlassBox.autosize = $true
    $ImageGlassBox.location = New-Object System.Drawing.Point(390,470)
    $form.Controls.Add($ImageGlassBox)
	$ImageGlassBox.Checked =  $SoftwareSelection.ImageGlass
	
	# Greenshot Checkbox
    $GreenshotBox = New-Object system.Windows.Forms.CheckBox
    $GreenshotBox.text = "Greenshot"
    $GreenshotBox.width = 95
    $GreenshotBox.height = 20
    $GreenshotBox.autosize = $true
    $GreenshotBox.location = New-Object System.Drawing.Point(390,495)
    $form.Controls.Add($GreenshotBox)
	$GreenshotBox.Checked =  $SoftwareSelection.Greenshot

    # Putty Checkbox
    $PuttyBox = New-Object system.Windows.Forms.CheckBox
    $PuttyBox.text = "Putty"
    $PuttyBox.width = 95
    $PuttyBox.height = 20
    $PuttyBox.autosize = $true
    $PuttyBox.location = New-Object System.Drawing.Point(390,520)
	# $PuttyBox.location = New-Object System.Drawing.Point(770,45)
    $form.Controls.Add($PuttyBox)
    $PuttyBox.Checked =  $SoftwareSelection.Putty

    # WinSCP Checkbox
    $WinSCPBox = New-Object system.Windows.Forms.CheckBox
    $WinSCPBox.text = "WinSCP"
    $WinSCPBox.width = 95
    $WinSCPBox.height = 20
    $WinSCPBox.autosize = $true
    $WinSCPBox.location = New-Object System.Drawing.Point(390,545)
    $form.Controls.Add($WinSCPBox)
    $WinSCPBox.Checked =  $SoftwareSelection.WinSCP
	
	
	# Select Button
    $SelectButton = New-Object system.Windows.Forms.Button
    $SelectButton.text = "Select all"
    $SelectButton.width = 110
    $SelectButton.height = 30
    $SelectButton.location = New-Object System.Drawing.Point(11,590)
    $SelectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $True
		$SevenZipBox.checked = $True
		$AdobeReaderDCBox.checked = $True
		$AdobeReaderDCBoxUpdate.checked = $True
		$BISFBox.checked = $True
		$FSLogixBox.checked = $True
		$GoogleChromeBox.checked = $True
		$WorkspaceApp_CRBox.checked = $True
		$WorkspaceApp_LTSRBox.checked = $True
		$WorkspaceApp_CR_WebBox.checked = $True
		$WorkspaceApp_LTSR_WebBox.checked = $True
		$Citrix_HypervisorToolsBox.checked = $False
		$KeePassBox.checked = $True
		$mRemoteNGBox.checked = $True
		$MSEdgeBox.checked = $True
		$MSOneDriveBox.checked = $True
		$MSTeamsBox.checked = $True
		$MSTeamsPrevBox.checked = $True
		$MS365AppsBox.checked = $True
		$OracleJava8Box.checked = $True
		$OracleJava8_32Box.checked = $True
		$TreeSizeFreeBox.checked = $True
		$VLCPlayerBox.checked = $True
		$FileZillaBox.checked = $True
		$ImageGlassBox.checked = $True
		$GreenshotBox.checked = $True
		$deviceTRUSTBox.checked = $True
		$RemoteDesktopManagerBox.checked = $True
		$ZoomVDIBox.checked = $True
		$ZoomCitrixBox.checked = $True
		$ZoomVMWareBox.checked = $True
		$CiscoWebExDesktopBox.checked = $True
		$PVSTargetDevice_LTSRBox.checked = $True
		$PVSTargetDevice_CRBox.checked = $True
		$ServerVDA_PVS_LTSRBox.checked = $True
		$ServerVDA_PVS_CRBox.checked = $True
		$ServerVDA_MCS_LTSRBox.checked = $True
		$ServerVDA_MCS_CRBox.checked = $True
		$WEM_Agent_PVSBox.checked = $True
		$WEM_Agent_MCS_PVSBox.checked = $True
		$CitrixFilesBox.checked = $True
        $PuttyBox.checked = $True
        $WinSCPBox.checked = $True
		})
    $form.Controls.Add($SelectButton)
	
	# Unselect Button
    $UnselectButton = New-Object system.Windows.Forms.Button
    $UnselectButton.text = "Unselect all"
    $UnselectButton.width = 110
    $UnselectButton.height = 30
    $UnselectButton.location = New-Object System.Drawing.Point(131,590)
    $UnselectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $False
		$SevenZipBox.checked = $False
		$AdobeReaderDCBox.checked = $False
		$AdobeReaderDCBoxUpdate.checked = $False
		$BISFBox.checked = $False
		$FSLogixBox.checked = $False
		$GoogleChromeBox.checked = $False
		$WorkspaceApp_CRBox.checked = $False
		$WorkspaceApp_LTSRBox.checked = $False
		$WorkspaceApp_CR_WebBox.checked = $False
		$WorkspaceApp_LTSR_WebBox.checked = $False
		$Citrix_HypervisorToolsBox.checked = $False
		$KeePassBox.checked = $False
		$mRemoteNGBox.checked = $False
		$MSEdgeBox.checked = $False
		$MSOneDriveBox.checked = $False
		$MSTeamsBox.checked = $False
		$MSTeamsPrevBox.checked = $False
		$MS365AppsBox.checked = $False
		$OracleJava8Box.checked = $False
		$OracleJava8_32Box.checked = $False
		$TreeSizeFreeBox.checked = $False
		$VLCPlayerBox.checked = $False
		$FileZillaBox.checked = $False
		$ImageGlassBox.checked = $False
		$GreenshotBox.checked = $False
		$deviceTRUSTBox.checked = $False
		$RemoteDesktopManagerBox.checked = $False
		$ZoomVDIBox.checked = $False
		$ZoomCitrixBox.checked = $False
		$ZoomVMWareBox.checked = $False
		$CiscoWebExDesktopBox.checked = $False
		$PVSTargetDevice_LTSRBox.checked = $False
		$PVSTargetDevice_CRBox.checked = $False
		$ServerVDA_PVS_LTSRBox.checked = $False
		$ServerVDA_PVS_CRBox.checked = $False
		$ServerVDA_MCS_LTSRBox.checked = $False
		$ServerVDA_MCS_CRBox.checked = $False
		$WEM_Agent_PVSBox.checked = $False
		$WEM_Agent_MCS_PVSBox.checked = $False
		$CitrixFilesBox.checked = $False
        $PuttyBox.checked = $False
        $WinSCPBox.checked = $False
		})
    $form.Controls.Add($UnselectButton)
	
    # OK Button
    $OKButton = New-Object system.Windows.Forms.Button
    $OKButton.text = "OK"
    $OKButton.width = 60
    $OKButton.height = 30
    $OKButton.location = New-Object System.Drawing.Point(271,590)
    $OKButton.Add_Click({
		#if (!($SoftwareToInstall)) {$SoftwareSelection = New-Object PSObject}
		$SoftwareSelection = New-Object PSObject
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NotepadPlusPlus" -Value $NotePadPlusPlusBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "SevenZip" -Value $SevenZipBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDC" -Value $AdobeReaderDCBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCUpdate" -Value $AdobeReaderDCBoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "BISF" -Value $BISFBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FSLogix" -Value $FSLogixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "GoogleChrome" -Value $GoogleChromeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR" -Value $WorkspaceApp_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR" -Value $WorkspaceApp_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR_Web" -Value $WorkspaceApp_CR_WebBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR_Web" -Value $WorkspaceApp_LTSR_WebBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixHypervisorTools" -Value $Citrix_HypervisorToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePass" -Value $KeePassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "mRemoteNG" -Value $mRemoteNGBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSEdge" -Value $MSEdgeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOneDrive" -Value $MSOneDriveBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeams" -Value $MSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeamsPrev" -Value $MSTeamsPrevBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps" -Value $MS365AppsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8" -Value $OracleJava8Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8_32" -Value $OracleJava8_32Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "TreeSizeFree" -Value $TreeSizeFreeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VLCPlayer" -Value $VLCPlayerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FileZilla" -Value $FileZillaBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ImageGlass" -Value $ImageGlassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Greenshot" -Value $GreenshotBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "deviceTRUST" -Value $deviceTRUSTBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RemoteDesktopManager" -Value $RemoteDesktopManagerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVDI" -Value $ZoomVDIBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomCitrix" -Value $ZoomCitrixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVMWare" -Value $ZoomVMWareBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExDesktop" -Value $CiscoWebExDesktopBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixPVSTargetDevice_LTSR" -Value $PVSTargetDevice_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixPVSTargetDevice_CR" -Value $PVSTargetDevice_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_PVS_LTSR" -Value $ServerVDA_PVS_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_PVS_CR" -Value $ServerVDA_PVS_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_MCS_LTSR" -Value $ServerVDA_MCS_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_MCS_CR" -Value $ServerVDA_MCS_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent_PVS" -Value $WEM_Agent_PVSBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent_MCS" -Value $WEM_Agent_MCS_PVSBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixCitrixFiles" -Value $CitrixFilesBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Putty" -Value $PuttyBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinSCP" -Value $WinSCPBox.checked -Force
	
	# Export objects to	XML
	$SoftwareSelection | Export-Clixml $SoftwareToInstall
    $Form.Close()
	})
    $form.Controls.Add($OKButton)

    # Cancel Button
    $CancelButton = New-Object system.Windows.Forms.Button
    $CancelButton.text = "Cancel"
    $CancelButton.width = 80
    $CancelButton.height = 30
    $CancelButton.location = New-Object System.Drawing.Point(341,590)
    $CancelButton.Add_Click({
        Write-Host -ForegroundColor Red "Canceled - Nothing happens"
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


# Import selection
$SoftwareSelection = Import-Clixml $SoftwareToInstall
Write-Host -ForegroundColor Cyan "Import selection"
Write-Output ""

# Call software install scripts

# Install Notepad ++
IF ($SoftwareSelection.NotePadPlusPlus -eq $true)
	{
		& "$SoftwareFolder\Install NotepadPlusPlus.ps1"
	}

# Install 7-ZIP
IF ($SoftwareSelection.SevenZip -eq $true)
	{
		& "$SoftwareFolder\Install 7-Zip.ps1"
	}
	
# Install Adobe Reader DC MUI
IF ($SoftwareSelection.AdobeReaderDC -eq $true)
	{
		& "$SoftwareFolder\Install Adobe Reader DC.ps1"
	}
	
# Install Adobe Reader DC MUI Update
IF ($SoftwareSelection.AdobeReaderDCUpdate -eq $true)
	{
		& "$SoftwareFolder\Install Adobe Reader DC Update.ps1"
	}

# Install BIS-F
IF ($SoftwareSelection.BISF -eq $true)
	{
		& "$SoftwareFolder\Install BIS-F.ps1"
	}

# Install FSLogix
IF ($SoftwareSelection.FSLogix -eq $true)
	{
		& "$SoftwareFolder\Install FSLogix.ps1"
	}

# Install Chrome
IF ($SoftwareSelection.GoogleChrome -eq $true)
	{
		& "$SoftwareFolder\Install Google Chrome.ps1"
	}

# Install WorkspaceApp Current
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true)
	{
		& "$SoftwareFolder\Install WorkspaceApp Current.ps1"
	}

# Install WorkspaceApp LTSR
IF ($SoftwareSelection.WorkspaceApp_LTSR -eq $true)
	{
		& "$SoftwareFolder\Install WorkspaceApp LTSR.ps1"
	}
	
# Install WorkspaceApp Current Web
IF ($SoftwareSelection.WorkspaceApp_CR_Web -eq $true)
	{
		& "$SoftwareFolder\Install WorkspaceApp Current Web.ps1"
	}

# Install WorkspaceApp LTSR Web
IF ($SoftwareSelection.WorkspaceApp_LTSR_Web -eq $true)
	{
		& "$SoftwareFolder\Install WorkspaceApp LTSR Web.ps1"
	}
	
# Install Citrix Hypervisor Tools
IF ($SoftwareSelection.CitrixHypervisorTools -eq $true)
	{
		& "$SoftwareFolder\Install Citrix Hypervisor Tools.ps1"
	}

# Install KeePass
IF ($SoftwareSelection.KeePass -eq $true)
	{
		& "$SoftwareFolder\Install KeePass.ps1"
	}

# Install mRemoteNG
IF ($SoftwareSelection.mRemoteNG -eq $true)
	{
		& "$SoftwareFolder\Install mRemoteNG.ps1"
	}

# Install MS Edge
IF ($SoftwareSelection.MSEdge -eq $true)
	{
		& "$SoftwareFolder\Install MS Edge.ps1"
	}

# Install MS OneDrive
IF ($SoftwareSelection.MSOneDrive -eq $true)
	{
		& "$SoftwareFolder\Install MS OneDrive.ps1"
	}

# Install MS Teams
IF ($SoftwareSelection.MSTeams -eq $true)
	{
		& "$SoftwareFolder\Install MS Teams.ps1"
	}

# Install MS Teams Preview
IF ($SoftwareSelection.MSTeamsPrev -eq $true)
	{
		& "$SoftwareFolder\Install MS Teams-Preview.ps1"
	}
	
# Install MS 365Apps
IF ($SoftwareSelection.MS365Apps -eq $true)
	{
		& "$SoftwareFolder\Install MS 365 Apps.ps1"
	}

# Install Oracle Java 8
IF ($SoftwareSelection.OracleJava8 -eq $true)
	{
		& "$SoftwareFolder\Install Oracle Java 8.ps1"
	}
	
# Install Oracle Java 8 32 Bit
IF ($SoftwareSelection.OracleJava8_32 -eq $true)
	{
		& "$SoftwareFolder\Install Oracle Java 8 - 32Bit.ps1"
	}

# Install TreeSizeFree
IF ($SoftwareSelection.TreeSizeFree -eq $true)
	{
		& "$SoftwareFolder\Install TreeSizeFree.ps1"
	}

# Install VLC Player
IF ($SoftwareSelection.VLCPlayer -eq $true)
	{
		& "$SoftwareFolder\Install VLC Player.ps1"
	}
	
# Install FileZilla
IF ($SoftwareSelection.FileZilla -eq $true)
	{
		& "$SoftwareFolder\Install FileZilla.ps1"
	}
	
# Install ImageGlass
IF ($SoftwareSelection.ImageGlass -eq $true)
	{
		& "$SoftwareFolder\Install ImageGlass.ps1"
	}
	
# Install Greenshot
IF ($SoftwareSelection.Greenshot -eq $true)
	{
		& "$SoftwareFolder\Install Greenshot.ps1"
	}
	
# Install deviceTRUST
IF ($SoftwareSelection.deviceTRUST -eq $true)
	{
		& "$SoftwareFolder\Install deviceTRUST.ps1"
	}
	
# Install RemoteDesktopManager
IF ($SoftwareSelection.RemoteDesktopManager -eq $true)
	{
		& "$SoftwareFolder\Install RemoteDesktopManager.ps1"
	}
	
# Install Zoom VDI Host
IF ($SoftwareSelection.ZoomVDI -eq $true)
	{
		& "$SoftwareFolder\Install Zoom VDI Host.ps1"
	}
	
# Install Zoom Citrix Client
IF ($SoftwareSelection.ZoomCitrix -eq $true)
	{
		& "$SoftwareFolder\Install Zoom Citrix Client.ps1"
	}
	
# Install Zoom VMWare Client
IF ($SoftwareSelection.ZoomVMWare -eq $true)
	{
		& "$SoftwareFolder\Install Zoom VMWare Client.ps1"
	}
	
# Install CiscoWebExDesktop PlugIn
IF ($SoftwareSelection.CiscoWebExDesktop -eq $true)
	{
		& "$SoftwareFolder\Install Cisco WebEx Desktop.ps1"
	}
	
# Install Citrix PVS Target Device Client
IF ($SoftwareSelection.CitrixPVSTargetDevice_LTSR -eq $true)
	{
		& "$SoftwareFolder\Install Citrix PVS Target Device LTSR.ps1"
	}

# Install Citrix PVS Target Device Client
IF ($SoftwareSelection.CitrixPVSTargetDevice_CR -eq $true)
	{
		& "$SoftwareFolder\Install Citrix PVS Target Device CR.ps1"
	}

# Install Citrix Server VDA PVS LTSR
IF ($SoftwareSelection.CitrixServerVDA_PVS_LTSR -eq $true)
	{
		& "$SoftwareFolder\Install Citrix Server VDA for PVS LTSR.ps1"
	}
	
# Install Citrix Server VDA PVS CR
IF ($SoftwareSelection.CitrixServerVDA_PVS_CR -eq $true)
	{
		& "$SoftwareFolder\Install Citrix Server VDA for PVS CR.ps1"
	}
	
# Install Citrix Server VDA MCS LTSR
IF ($SoftwareSelection.CitrixServerVDA_MCS_LTSR -eq $true)
	{
		& "$SoftwareFolder\Install Citrix Server VDA for MCS LTSR.ps1"
	}
	
# Install Citrix Server VDA MCS CR
IF ($SoftwareSelection.CitrixServerVDA_MCS_CR -eq $true)
	{
		& "$SoftwareFolder\Install Citrix Server VDA for MCS CR.ps1"
	}

# Install Citrix WEM Agent PVS
IF ($SoftwareSelection.CitrixWEM_Agent_PVS -eq $true)
	{
		& "$SoftwareFolder\Install Citrix WEM Agent for PVS.ps1"
	}
	
# Install Citrix WEM Agent MCS
IF ($SoftwareSelection.CitrixWEM_Agent_MCS -eq $true)
	{
		& "$SoftwareFolder\Install Citrix WEM Agent for MCS.ps1"
	}

# Install Citrix Files
IF ($SoftwareSelection.CitrixCitrixFiles -eq $true)
	{
		& "$SoftwareFolder\Install Citrix Files.ps1"
	}

# Install Putty
IF ($SoftwareSelection.Putty -eq $true)
	{
		& "$SoftwareFolder\Install Putty.ps1"
	}

# Install WinSCP
IF ($SoftwareSelection.WinSCP -eq $true)
	{
		& "$SoftwareFolder\Install WinSCP.ps1"
	}
	
# Stop install log
Stop-Transcript

# Format install log
$Content = Get-Content -Path $InstallLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $InstallLog

Write-Output ""
Write-Host -ForegroundColor Cyan "Finished, please check if selected software is installed!" 
Write-Output ""

if ($noGUI -eq $False) {
    pause}