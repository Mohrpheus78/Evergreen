# ******************************************************
# D. Mohrmann, Cancom GmbH, Twitter: @mohrpheus78
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
Run as admin!
Version: 2.18.13
06/24: Changed internet connection check
06/25: Changed internet connection check
06/27: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 at the top of the script
06/29: Errors in MS Edge, pdf24creator and VLC install scripts
06/30: Changed Adobe Reader check if Reader is already installed, changed TreeSize version check
06/30: Changed FileZilla version check
07/04: Suppress error message while removing Teams from run key (if already removed)
07/06: Citrix WorkspaceApp run keys prevented the app from starting at logon (Current Release)
07/27: Changed Citrix WorkspaceApp version check and always install MS Edge WebView updates, changed Adobe DC update check
11/21: Wrong CitrixFiles Run registry key to prevent Citrix Files from lauch automtically
11/22: Added support for PVS Admin Toolkit, no version check if you run with -noGUI parameter
15/12: Minor changes in install scripts
20/12: Added results at the end for documentation (e.g. PVS vDisk properties)
22/12: Syntax error Office scripts
02/01: Addec MS VcRedist packages
03/01: Improved error logging for all scripts, various aother improvements, added SplashScreen
04/01: Load SplashScreen only if available, check for SplashScreen Powershell module and load from GitHub of not present
05/01: Added Foxit Reader, MS SQL MGMT Studio EN and DE, OneDrive Auto Update disabled
11/01: Better error handling if one install script fails
08/02: Improvements for MS Edge, Google Chrome
02/16: No error message if Splashscreen cannot be loaded, improvements for MS Edge, Google Chrome (check scheduled taks even if there is no update)
03/23: Added ShareX
04/11: Added KeePassXC, modified Citrix components scripts
04/21: Added Citrix scripts for VDA and WEM standalone
04/24: Changed Oracle Java version check
04/26: Added $SoftwareToAutoInstall  for PVS Admin Toolkit
05/30: Changed MS Teams notes, changed MS SQL MGMT Studio version check
23/07/18: Added WinRAR
23/07/27: Fixed error in PVS target LTSR script, changed Adobe script
23/10/06: Changed installation path for Citrix products, Better internet connection check
23/10/11: Added MS .NET Desktop Runtime as a requirement for Citrix WorkspaceApp CR
23/10/20: Move FSLogix rules before updating Office
23/10/23: WEM agent checks if WEM cloud service or onPrem is used, VDA and WEM version check
23/11/20: Second internet connection check
23/12/14: Changed Citrix PVS, WEM and VDA scripts to not cancel if selected and no newer version is available
24/01/16: Changed version variable for Citrix WorkspaceApp CR
24/02/08: Added Windows Task in FSLogix install script for Windows Search problem with multi user on Windows Server 2019/2022
24/02/15: Changed detection of WEM agent running on Cloud or on prem
24/03/19: Fixed update check for Citrix WorkspaceApp
24/04/23: Added new Citrix 2402 LTSR components, chaned WEM cloud service detection
24/04/25: Added MS .NET DesktopRuntime 8.4.0 for Remote Desktop Manager
24/05/02: nNw path for Google Chrome scheduled update tasks 
24/06/06: Changed version variable for Citrix WorkspaceApp LTSR
24/07/03: Disabled all Google Chrome update services
24/07/08: Delete Chrome active setup regkeys, corrected error with Chrome install syntax
24/07/19: Added NEW MS Teams 2.x
24/07/24: Added MS openJDK 21
24/07/30: Add MS Teams version environment variable to provision Teams for the user
24/08/26: Added new MS Teams plugin for Citrix WorkspaceApp, added MS .NET Desktop runtime for WSA LTSR
24/08/26: Changed Oracle Java version check
24/09/19: Changed PVS target device version check
24/10/11: Changed WorkspaceApp LTSR .NET Desktop Runtime to version 8.0.10, added Teams 2.0 logon script
24/10/14: Changed Foxit Reader version check, display NEW Teams update question only once, if migrating from old Teams
24/11/06: Changed MS Teams 2 update question
24/11/07: Register MS Teams for all users, including admins, changed Adobe update task check
24/11/19: Better approach to delete/disable OneDrive and Chrome update tasks, check if Windows search failure tasks are present if installing FSLogix
24/11/29: Changed uninstall procedure for MS Teams 2.x if OS is Server 2019 or Windows 10, removed mRemote NG
24/12/16: Changed .NET Desktop Runtime for CR WorkspaceApp to version 8.10
25/01/03: Added VMWare Tools
25/02/05: Added Windows Server 2025 to NEW MS Teamsa as OS, configured MS Teams scheduled task for App-X registration
25/02/12: Citrix PVS client LTSR display name correction
25/02/18: New app design, added MS Office 2024 LTSC
25/02/21: Added Mozilla Firefox
25/02/24: Changed Windows search failure workaround task
25/03/07: Added Firefox de/us language, changed MS Teams App-X registration
25/03/10: Corrected MS Teams App-X registration
25/04/10: Added .NET 9.0 Desktop Runtime (v9.0.4) for Remote Desktop Manager
25/04/14: Added Windows Desktop-Runtime-8.0.11 (for Citrix WorkspaceApp)
25/05/06: Removed Adobe Reader "Try Adobe Acrobat" add and diable AdobeCollabSync
25/06/10: Added uberAgent and deviceTRUST to Citrix VDA current release
25/06/11: Removed Adobe Reader "Try Adobe Acrobat" add and diable AdobeCollabSync
25/06/30: Removed deviceTRUST agent (now part of Citrix VDA)
25/07/31: Added MS .NET 8.0 Desktop Runtime (v8.0.18) for Citrix WorkspaceApp
# Notes
#>


Param (
		[Parameter(
            HelpMessage='Start without Gui',
            ValuefromPipelineByPropertyName = $true
        )]
        [switch]$noGUI,
		
		[Parameter(
			Mandatory = $false
		)]  
		[switch]$SoftwareToAutoInstall
)


# TLS settings
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


# ======================
# Beginning Splashscreen
# ======================

IF (!(Test-Path -Path "$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen\assembly")) {
	try {
		Invoke-WebRequest -Uri https://github.com/Mohrpheus78/Evergreen/raw/main/Software/_SplashScreen.zip -OutFile "$PSScriptRoot\Software\SplashScreen.zip"
	}
	catch {
		Write-Host -ForegroundColor Red "Error downloading SplashScreen (Error: $($Error[0]))"
    }

	IF (Test-Path -Path "$PSScriptRoot\Software\SplashScreen.zip") {
		Expand-Archive -Path "$PSScriptRoot\Software\SplashScreen.zip" -DestinationPath "$ENV:ProgramFiles\WindowsPowershell\Modules"
		Rename-Item -Path "$ENV:ProgramFiles\WindowsPowershell\Modules\_SplashScreen" -NewName "SplashScreen"
	}
}

#copy-item "$PSScriptRoot\Software\_SplashScreen\" "$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen" -Recurse -Force | Out-Null
if (Test-Path -Path "$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen") {

# Add shared_assemblies #
# ===================== #
try {
	[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
	# Mahapps Library
	[System.Reflection.Assembly]::LoadFrom("$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen\assembly\MahApps.Metro.dll")       | out-null
	[System.Reflection.Assembly]::LoadFrom("$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen\assembly\System.Windows.Interactivity.dll") | out-null
	}
catch {
	$SplashScreen = $False
}

# Splash Screen #
# ============= #
if ($Splashscreen -ne $False) {
function close-SplashScreen (){
    $hash.window.Dispatcher.Invoke("Normal",[action]{ $hash.window.close() })
    $Pwshell.EndInvoke($handle) | Out-Null
    #$runspace.Close() | Out-Null
    
}

function Start-SplashScreen{
    $Pwshell.Runspace = $runspace
    $script:handle = $Pwshell.BeginInvoke() 
}


    $hash = [hashtable]::Synchronized(@{})
    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.ApartmentState = "STA"
    $Runspace.ThreadOptions = "ReuseThread"
    $runspace.Open()
    $runspace.SessionStateProxy.SetVariable("hash",$hash) 
    $Pwshell = [PowerShell]::Create()

    $Pwshell.AddScript({
    $xml = [xml]@"
     <Window
	xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	x:Name="WindowSplash" Title="SplashScreen" WindowStyle="None" WindowStartupLocation="CenterScreen"
	Background="DarkRed" ShowInTaskbar ="true" 
	Width="650" Height="350" ResizeMode = "NoResize" >
	
	<Grid>
		<Grid.RowDefinitions>
            <RowDefinition Height="70"/>
            <RowDefinition/>
        </Grid.RowDefinitions>
		
		<Grid Grid.Row="0" x:Name="Header" >	
			<StackPanel Orientation="Horizontal" HorizontalAlignment="Left" VerticalAlignment="Stretch" Margin="20,10,0,0">       
				<Label Content="Software-Installer (Powered by Evergreen-Module)" Margin="5,0,0,0" Foreground="White" Height="50"  FontSize="25"/>
			</StackPanel> 
		</Grid>
        <Grid Grid.Row="1" >
		 	<StackPanel Orientation="Vertical" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5,5,5,5">
				<Label x:Name = "LoadingLabel"  Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="24" Margin = "0,0,0,0"/>
				<Controls:MetroProgressBar IsIndeterminate="True" Foreground="White" HorizontalAlignment="Center" Width="350" Height="20"/>
			</StackPanel>	
        </Grid>
	</Grid>
		
</Window> 
"@
 
 
    $reader = New-Object System.Xml.XmlNodeReader $xml
    $hash.window = [Windows.Markup.XamlReader]::Load($reader)
    $hash.LoadingLabel = $hash.window.FindName("LoadingLabel")
    $hash.Logo = $hash.window.FindName("Logo")
    $hash.Logo.Source="$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen\form\resources\sul-cai-icon.png"
    $hash.LoadingLabel.Content= "© D. Mohrmann - @mohrpheus78"  
    $hash.window.ShowDialog() 
    
}) | Out-Null
}
}


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
	$Form.ClientSize = New-Object System.Drawing.Point(1000,670)
    $Form.text = "Software-Installer"
    $Form.TopMost = $false
    $Form.AutoSize = $true
	$Form.BackColor = [System.Drawing.Color]::White

    # Set the font of the text to be used within the form
    $Font = New-Object System.Drawing.Font("Arial",10)
	$FontBold = New-Object System.Drawing.Font("Arial", 11.5, [System.Drawing.FontStyle]::Bold)
    #$Form.Font = $Font

    # Software Headline
    $Headline2 = New-Object system.Windows.Forms.Label
    $Headline2.text = "Select Software to install"
    $Headline2.AutoSize = $true
    $Headline2.width = 25
    $Headline2.height = 10
    $Headline2.location = New-Object System.Drawing.Point(11,4)
    $form.Controls.Add($Headline2)
	#$FontBold = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
	$Headline2.Font = $FontBold

	# NotePadPlusPlus Checkbox
    $NotePadPlusPlusBox = New-Object system.Windows.Forms.CheckBox
    $NotePadPlusPlusBox.text = "NotePad++"
    $NotePadPlusPlusBox.width = 95
    $NotePadPlusPlusBox.height = 20
	$NotePadPlusPlusBox.Font = $Font
    $NotePadPlusPlusBox.autosize = $true
    $NotePadPlusPlusBox.location = New-Object System.Drawing.Point(11,45)
    $form.Controls.Add($NotePadPlusPlusBox)
	$NotePadPlusPlusBox.Checked =  $SoftwareSelection.NotePadPlusPlus
	
    # 7Zip Checkbox
    $SevenZipBox = New-Object system.Windows.Forms.CheckBox
    $SevenZipBox.text = "7 Zip"
    $SevenZipBox.width = 95
    $SevenZipBox.height = 20
	$SevenZipBox.Font = $Font
    $SevenZipBox.autosize = $true
    $SevenZipBox.location = New-Object System.Drawing.Point(11,70)
    $form.Controls.Add($SevenZipBox)
	$SevenZipBox.Checked =  $SoftwareSelection.SevenZip

    # AdobeReaderDC Checkbox
    $AdobeReaderDCBox = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBox.text = "Adobe Reader DC MUI x86 (only for Base Install)"
    $AdobeReaderDCBox.width = 95
    $AdobeReaderDCBox.height = 20
	$AdobeReaderDCBox.Font = $Font
    $AdobeReaderDCBox.autosize = $true
    $AdobeReaderDCBox.location = New-Object System.Drawing.Point(11,95)
    $form.Controls.Add($AdobeReaderDCBox)
	$AdobeReaderDCBox.Checked =  $SoftwareSelection.AdobeReaderDC
	
	# AdobeReaderDCUpdate Checkbox
    $AdobeReaderDCBoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBoxUpdate.text = "Adobe Reader DC MUI x86 (Updates only)"
    $AdobeReaderDCBoxUpdate.width = 95
    $AdobeReaderDCBoxUpdate.height = 20
	$AdobeReaderDCBoxUpdate.Font = $Font
    $AdobeReaderDCBoxUpdate.autosize = $true
    $AdobeReaderDCBoxUpdate.location = New-Object System.Drawing.Point(11,120)
    $form.Controls.Add($AdobeReaderDCBoxUpdate)
	$AdobeReaderDCBoxUpdate.Checked =  $SoftwareSelection.AdobeReaderDCUpdate
	
	# AdobeReaderDCx64 Checkbox
    $AdobeReaderDCx64Box = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCx64Box.text = "Adobe Reader DC MUI x64 (only for Base Install)"
    $AdobeReaderDCx64Box.width = 95
    $AdobeReaderDCx64Box.height = 20
	$AdobeReaderDCx64Box.Font = $Font
    $AdobeReaderDCx64Box.autosize = $true
    $AdobeReaderDCx64Box.location = New-Object System.Drawing.Point(11,145)
    $form.Controls.Add($AdobeReaderDCx64Box)
	$AdobeReaderDCx64Box.Checked =  $SoftwareSelection.AdobeReaderDCx64
	
	# AdobeReaderDCx64Update Checkbox
    $AdobeReaderDCx64BoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCx64BoxUpdate.text = "Adobe Reader DC MUI x64 Update (Updates only)"
    $AdobeReaderDCx64BoxUpdate.width = 95
    $AdobeReaderDCx64BoxUpdate.height = 20
	$AdobeReaderDCx64BoxUpdate.Font = $Font
    $AdobeReaderDCx64BoxUpdate.autosize = $true
    $AdobeReaderDCx64BoxUpdate.location = New-Object System.Drawing.Point(11,170)
    $form.Controls.Add($AdobeReaderDCx64BoxUpdate)
	$AdobeReaderDCx64BoxUpdate.Checked =  $SoftwareSelection.AdobeReaderDCx64Update
	
	# VMWareTools Checkbox
    $VMWareToolsBox = New-Object system.Windows.Forms.CheckBox
    $VMWareToolsBox.text = "VMWare Tools"
    $VMWareToolsBox.width = 95
    $VMWareToolsBox.height = 20
    $VMWareToolsBox.autosize = $true
	$VMWareToolsBox.Font = $Font
    $VMWareToolsBox.location = New-Object System.Drawing.Point(11,195)
    $form.Controls.Add($VMWareToolsBox)
	$VMWareToolsBox.Checked =  $SoftwareSelection.VMWareTools
	
	# Citrix Hypervisor Tools Checkbox
    $Citrix_HypervisorToolsBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_HypervisorToolsBox.text = "Citrix Hypervisor Tools (Auto Update disabled)"
    $Citrix_HypervisorToolsBox.width = 95
    $Citrix_HypervisorToolsBox.height = 20
    $Citrix_HypervisorToolsBox.autosize = $true
	$Citrix_HypervisorToolsBox.Font = $Font
    $Citrix_HypervisorToolsBox.location = New-Object System.Drawing.Point(11,220)
    $form.Controls.Add($Citrix_HypervisorToolsBox)
	$Citrix_HypervisorToolsBox.Checked = $SoftwareSelection.CitrixHypervisorTools

    # Citrix WorkspaceApp_Current_Release Checkbox
    $WorkspaceApp_CRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CRBox.text = "Citrix WorkspaceApp CR"
    $WorkspaceApp_CRBox.width = 95
    $WorkspaceApp_CRBox.height = 20
    $WorkspaceApp_CRBox.autosize = $true
	$WorkspaceApp_CRBox.Font = $Font
    $WorkspaceApp_CRBox.location = New-Object System.Drawing.Point(11,245)
    $form.Controls.Add($WorkspaceApp_CRBox)
	$WorkspaceApp_CRBox.Checked =  $SoftwareSelection.WorkspaceApp_CR

    # Citrix WorkspaceApp_LTSR_Release Checkbox
    $WorkspaceApp_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSRBox.text = "Citrix WorkspaceApp LTSR"
    $WorkspaceApp_LTSRBox.width = 95
    $WorkspaceApp_LTSRBox.height = 20
    $WorkspaceApp_LTSRBox.autosize = $true
	$WorkspaceApp_LTSRBox.Font = $Font
    $WorkspaceApp_LTSRBox.location = New-Object System.Drawing.Point(11,270)
    $form.Controls.Add($WorkspaceApp_LTSRBox)
	$WorkspaceApp_LTSRBox.Checked =  $SoftwareSelection.WorkspaceApp_LTSR
	
	# Citrix WorkspaceApp_Current_Release_Web Checkbox
    $WorkspaceApp_CR_WebBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CR_WebBox.text = "Citrix WorkspaceApp CR Web (Autostart disabled)"
    $WorkspaceApp_CR_WebBox.width = 95
    $WorkspaceApp_CR_WebBox.height = 20
    $WorkspaceApp_CR_WebBox.autosize = $true
	$WorkspaceApp_CR_WebBox.Font = $Font
    $WorkspaceApp_CR_WebBox.location = New-Object System.Drawing.Point(11,295)
    $form.Controls.Add($WorkspaceApp_CR_WebBox)
	$WorkspaceApp_CR_WebBox.Checked =  $SoftwareSelection.WorkspaceApp_CR_Web

    # Citrix WorkspaceApp_LTSR_Release_Web Checkbox
    $WorkspaceApp_LTSR_WebBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSR_WebBox.text = "Citrix WorkspaceApp LTSR Web (Autostart disabled)"
    $WorkspaceApp_LTSR_WebBox.width = 95
    $WorkspaceApp_LTSR_WebBox.height = 20
    $WorkspaceApp_LTSR_WebBox.autosize = $true
	$WorkspaceApp_LTSR_WebBox.Font = $Font
    $WorkspaceApp_LTSR_WebBox.location = New-Object System.Drawing.Point(11,320)
    $form.Controls.Add($WorkspaceApp_LTSR_WebBox)
	$WorkspaceApp_LTSR_WebBox.Checked =  $SoftwareSelection.WorkspaceApp_LTSR_Web
	
	# Citrix PVS Target Device LTSR Checkbox
    $PVSTargetDevice_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $PVSTargetDevice_LTSRBox.text = "Citrix PVS Target Device LTSR"
    $PVSTargetDevice_LTSRBox.width = 95
    $PVSTargetDevice_LTSRBox.height = 20
    $PVSTargetDevice_LTSRBox.autosize = $true
	$PVSTargetDevice_LTSRBox.Font = $Font
    $PVSTargetDevice_LTSRBox.location = New-Object System.Drawing.Point(11,345)
    $form.Controls.Add($PVSTargetDevice_LTSRBox)
	$PVSTargetDevice_LTSRBox.Checked =  $SoftwareSelection.CitrixPVSTargetDevice_LTSR
	
	# Citrix PVS Target Device CR/Cloud Checkbox
    $PVSTargetDevice_CRBox = New-Object system.Windows.Forms.CheckBox
    $PVSTargetDevice_CRBox.text = "Citrix PVS Target Device CR/Cloud"
    $PVSTargetDevice_CRBox.width = 95
    $PVSTargetDevice_CRBox.height = 20
    $PVSTargetDevice_CRBox.autosize = $true
	$PVSTargetDevice_CRBox.Font = $Font
    $PVSTargetDevice_CRBox.location = New-Object System.Drawing.Point(11,370)
    $form.Controls.Add($PVSTargetDevice_CRBox)
	$PVSTargetDevice_CRBox.Checked =  $SoftwareSelection.CitrixPVSTargetDevice_CR
	
	# Citrix VDA LTSR Checkbox
    $ServerVDA_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_LTSRBox.text = "Citrix Server VDA LTSR"
    $ServerVDA_LTSRBox.width = 95
    $ServerVDA_LTSRBox.height = 20
    $ServerVDA_LTSRBox.Font = $Font
	$ServerVDA_LTSRBox.autosize = $true
    $ServerVDA_LTSRBox.location = New-Object System.Drawing.Point(11,395)
    $form.Controls.Add($ServerVDA_LTSRBox)
	$ServerVDA_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_LTSR
	
	# Citrix VDA CR/Cloud Checkbox
    $ServerVDA_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_CRBox.text = "Citrix Server VDA CR/Cloud"
    $ServerVDA_CRBox.width = 95
    $ServerVDA_CRBox.height = 20
    $ServerVDA_CRBox.autosize = $true
	$ServerVDA_CRBox.Font = $Font
    $ServerVDA_CRBox.location = New-Object System.Drawing.Point(11,420)
    $form.Controls.Add($ServerVDA_CRBox)
	$ServerVDA_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_CR
	
	# Citrix VDA PVS LTSR Checkbox
    $ServerVDA_PVS_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_PVS_LTSRBox.text = "Citrix Server VDA for PVS LTSR"
    $ServerVDA_PVS_LTSRBox.width = 95
    $ServerVDA_PVS_LTSRBox.height = 20
    $ServerVDA_PVS_LTSRBox.autosize = $true
	$ServerVDA_PVS_LTSRBox.Font = $Font
    $ServerVDA_PVS_LTSRBox.location = New-Object System.Drawing.Point(11,445)
    $form.Controls.Add($ServerVDA_PVS_LTSRBox)
	$ServerVDA_PVS_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_PVS_LTSR
	
	# Citrix VDA PVS CR/Cloud Checkbox
    $ServerVDA_PVS_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_PVS_CRBox.text = "Citrix Server VDA for PVS CR/Cloud"
    $ServerVDA_PVS_CRBox.width = 95
    $ServerVDA_PVS_CRBox.height = 20
    $ServerVDA_PVS_CRBox.autosize = $true
	$ServerVDA_PVS_CRBox.Font = $Font
    $ServerVDA_PVS_CRBox.location = New-Object System.Drawing.Point(11,470)
    $form.Controls.Add($ServerVDA_PVS_CRBox)
	$ServerVDA_PVS_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_PVS_CR
	
	# Citrix VDA MCS LTSR Checkbox
    $ServerVDA_MCS_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_MCS_LTSRBox.text = "Citrix Server VDA for MCS LTSR"
    $ServerVDA_MCS_LTSRBox.width = 95
    $ServerVDA_MCS_LTSRBox.height = 20
    $ServerVDA_MCS_LTSRBox.autosize = $true
	$ServerVDA_MCS_LTSRBox.Font = $Font
    $ServerVDA_MCS_LTSRBox.location = New-Object System.Drawing.Point(11,495)
    $form.Controls.Add($ServerVDA_MCS_LTSRBox)
	$ServerVDA_MCS_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_MCS_LTSR
	
	# Citrix VDA MCS CR/Cloud Checkbox
    $ServerVDA_MCS_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_MCS_CRBox.text = "Citrix Server VDA for MCS CR/Cloud"
    $ServerVDA_MCS_CRBox.width = 95
    $ServerVDA_MCS_CRBox.height = 20
    $ServerVDA_MCS_CRBox.autosize = $true
	$ServerVDA_MCS_CRBox.Font = $Font
    $ServerVDA_MCS_CRBox.location = New-Object System.Drawing.Point(11,520)
    $form.Controls.Add($ServerVDA_MCS_CRBox)
	$ServerVDA_MCS_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_MCS_CR
	
	# Citrix WEM Agent Checkbox
    $WEM_Agent_Box = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_Box.text = "Citrix WEM Agent for VDA"
    $WEM_Agent_Box.width = 95
    $WEM_Agent_Box.height = 20
    $WEM_Agent_Box.autosize = $true
	$WEM_Agent_Box.Font = $Font
    $WEM_Agent_Box.location = New-Object System.Drawing.Point(11,545)
    $form.Controls.Add($WEM_Agent_Box)
	$WEM_Agent_Box.Checked =  $SoftwareSelection.CitrixWEM_Agent
	
	# Citrix WEM Agent PVS Checkbox
    $WEM_Agent_PVSBox = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_PVSBox.text = "Citrix WEM Agent for PVS VDA"
    $WEM_Agent_PVSBox.width = 95
    $WEM_Agent_PVSBox.height = 20
    $WEM_Agent_PVSBox.autosize = $true
	$WEM_Agent_PVSBox.Font = $Font
    $WEM_Agent_PVSBox.location = New-Object System.Drawing.Point(11,570)
    $form.Controls.Add($WEM_Agent_PVSBox)
	$WEM_Agent_PVSBox.Checked =  $SoftwareSelection.CitrixWEM_Agent_PVS
	
	# Citrix WEM Agent MCS Checkbox
    $WEM_Agent_MCSBox = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_MCSBox.text = "Citrix WEM Agent for MCS VDA"
    $WEM_Agent_MCSBox.width = 95
    $WEM_Agent_MCSBox.height = 20
    $WEM_Agent_MCSBox.autosize = $true
	$WEM_Agent_MCSBox.Font = $Font
    $WEM_Agent_MCSBox.location = New-Object System.Drawing.Point(11,595)
    $form.Controls.Add($WEM_Agent_MCSBox)
	$WEM_Agent_MCSBox.Checked =  $SoftwareSelection.CitrixWEM_Agent_MCS
	
	# MSEdge Checkbox
    $MSEdgeBox = New-Object system.Windows.Forms.CheckBox
    $MSEdgeBox.text = "Microsoft Edge (Stable Channel)"
    $MSEdgeBox.width = 95
    $MSEdgeBox.height = 20
    $MSEdgeBox.autosize = $true
	$MSEdgeBox.Font = $Font
    $MSEdgeBox.location = New-Object System.Drawing.Point(420,45)
    $form.Controls.Add($MSEdgeBox)
	$MSEdgeBox.Checked =  $SoftwareSelection.MSEdge

    # MSOneDrive Checkbox
    $MSOneDriveBox = New-Object system.Windows.Forms.CheckBox
    $MSOneDriveBox.text = "Microsoft OneDrive (Machine-Based VDI Installer)"
    $MSOneDriveBox.width = 95
    $MSOneDriveBox.height = 20
    $MSOneDriveBox.autosize = $true
	$MSOneDriveBox.Font = $Font
    $MSOneDriveBox.location = New-Object System.Drawing.Point(420,70)
    $form.Controls.Add($MSOneDriveBox)
	$MSOneDriveBox.Checked =  $SoftwareSelection.MSOneDrive

    # MSTeams Checkbox
    $MSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $MSTeamsBox.text = "Microsoft Teams (Machine-Based VDI Installer)"
    $MSTeamsBox.width = 95
    $MSTeamsBox.height = 20
    $MSTeamsBox.autosize = $true
	$MSTeamsBox.Font = $Font
    $MSTeamsBox.location = New-Object System.Drawing.Point(420,95)
    $form.Controls.Add($MSTeamsBox)
	$MSTeamsBox.Checked =  $SoftwareSelection.MSTeams
	
	# MSTeams 2 Checkbox
    $NEWMSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $NEWMSTeamsBox.text = "NEW Microsoft Teams 2.x"
    $NEWMSTeamsBox.width = 95
    $NEWMSTeamsBox.height = 20
    $NEWMSTeamsBox.autosize = $true
	$NEWMSTeamsBox.Font = $Font
    $NEWMSTeamsBox.location = New-Object System.Drawing.Point(420,120)
    $form.Controls.Add($NEWMSTeamsBox)
	$NEWMSTeamsBox.Checked =  $SoftwareSelection.MSTeams2
	
	# MS365 Apps Semi Annual Channel Checkbox
    $MS365AppsBox_SAC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_SAC.text = "Microsoft 365 Apps (x64/Semi Annual Channel)"
    $MS365AppsBox_SAC.width = 95
    $MS365AppsBox_SAC.height = 20
    $MS365AppsBox_SAC.autosize = $true
	$MS365AppsBox_SAC.Font = $Font
    $MS365AppsBox_SAC.location = New-Object System.Drawing.Point(420,145)
    $form.Controls.Add($MS365AppsBox_SAC)
	$MS365AppsBox_SAC.Checked = $SoftwareSelection.MS365Apps_SAC
	
	# MS365 Apps Monthly Enterprise Channel Checkbox
    $MS365AppsBox_MEC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_MEC.text = "Microsoft 365 Apps (x64/Monthly Enterprise Channel)"
    $MS365AppsBox_MEC.width = 95
    $MS365AppsBox_MEC.height = 20
    $MS365AppsBox_MEC.autosize = $true
	$MS365AppsBox_MEC.Font = $Font
    $MS365AppsBox_MEC.location = New-Object System.Drawing.Point(420,170)
    $form.Controls.Add($MS365AppsBox_MEC)
	$MS365AppsBox_MEC.Checked = $SoftwareSelection.MS365Apps_MEC
	
	# MS Office2019 Checkbox
    $MSOffice2019Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2019Box.text = "Microsoft Office 2019 (x64/Perpetual VL)"
    $MSOffice2019Box.width = 95
    $MSOffice2019Box.height = 20
    $MSOffice2019Box.autosize = $true
	$MSOffice2019Box.Font = $Font
    $MSOffice2019Box.location = New-Object System.Drawing.Point(420,195)
    $form.Controls.Add($MSOffice2019Box)
	$MSOffice2019Box.Checked = $SoftwareSelection.MSOffice2019
	
	# MS Office2021 Checkbox
    $MSOffice2021Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2021Box.text = "Microsoft Office 2021 (x64/Perpetual VL)"
    $MSOffice2021Box.width = 95
    $MSOffice2021Box.height = 20
    $MSOffice2021Box.autosize = $true
	$MSOffice2021Box.Font = $Font
    $MSOffice2021Box.location = New-Object System.Drawing.Point(420,220)
    $form.Controls.Add($MSOffice2021Box)
	$MSOffice2021Box.Checked = $SoftwareSelection.MSOffice2021
	
	# MS Office2024 Checkbox
    $MSOffice2024Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2024Box.text = "Microsoft Office 2024 (x64/Perpetual VL)"
    $MSOffice2024Box.width = 95
    $MSOffice2024Box.height = 20
    $MSOffice2024Box.autosize = $true
	$MSOffice2024Box.Font = $Font
    $MSOffice2024Box.location = New-Object System.Drawing.Point(420,245)
    $form.Controls.Add($MSOffice2024Box)
	$MSOffice2024Box.Checked = $SoftwareSelection.MSOffice2024
	
	# MS VcRedist Checkbox
    $VcRedistBox = New-Object system.Windows.Forms.CheckBox
    $VcRedistBox.text = "Microsoft Visual C++ Redistributable"
    $VcRedistBox.width = 95
    $VcRedistBox.height = 20
    $VcRedistBox.autosize = $true
	$VcRedistBox.Font = $Font
    $VcRedistBox.location = New-Object System.Drawing.Point(420,270)
    $form.Controls.Add($VcRedistBox)
	$VcRedistBox.Checked = $SoftwareSelection.VcRedist

    # MS SQL Management Studio EN Checkbox
    $MSSQLManagementStudioENBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioENBox.text = "Microsoft SQL Management Studio EN"
    $MSSQLManagementStudioENBox.width = 95
    $MSSQLManagementStudioENBox.height = 20
    $MSSQLManagementStudioENBox.autosize = $true
	$MSSQLManagementStudioENBox.Font = $Font
    $MSSQLManagementStudioENBox.location = New-Object System.Drawing.Point(420,295)
    $form.Controls.Add($MSSQLManagementStudioENBox)
	$MSSQLManagementStudioENBox.Checked = $SoftwareSelection.MSSsmsEN

    # MS SQL Management Studio DE Checkbox
    $MSSQLManagementStudioDEBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioDEBox.text = "Microsoft SQL Management Studio DE"
    $MSSQLManagementStudioDEBox.width = 95
    $MSSQLManagementStudioDEBox.height = 20
    $MSSQLManagementStudioDEBox.autosize = $true
	$MSSQLManagementStudioDEBox.Font = $Font
    $MSSQLManagementStudioDEBox.location = New-Object System.Drawing.Point(420,320)
    $form.Controls.Add($MSSQLManagementStudioDEBox)
	$MSSQLManagementStudioDEBox.Checked = $SoftwareSelection.MSSsmsDE
	
	# MicrosoftOpenJDK Checkbox
    $MicrosoftOpenJDKBox = New-Object system.Windows.Forms.CheckBox
    $MicrosoftOpenJDKBox.text = "Microsoft OpenJDK 21"
    $MicrosoftOpenJDKBox.width = 95
    $MicrosoftOpenJDKBox.height = 20
    $MicrosoftOpenJDKBox.autosize = $true
	$MicrosoftOpenJDKBox.Font = $Font
    $MicrosoftOpenJDKBox.location = New-Object System.Drawing.Point(420,345)
    $form.Controls.Add($MicrosoftOpenJDKBox)
	$MicrosoftOpenJDKBox.Checked =  $SoftwareSelection.MicrosoftOpenJDK
	
	# BISF Checkbox
    $BISFBox = New-Object system.Windows.Forms.CheckBox
    $BISFBox.text = "BIS-F"
    $BISFBox.width = 95
    $BISFBox.height = 20
    $BISFBox.autosize = $true
	$BISFBox.Font = $Font
    $BISFBox.location = New-Object System.Drawing.Point(420,370)
    $form.Controls.Add($BISFBox)
	$BISFBox.Checked =  $SoftwareSelection.BISF
	
	# FSLogix Checkbox
    $FSLogixBox = New-Object system.Windows.Forms.CheckBox
    $FSLogixBox.text = "FSLogix"
    $FSLogixBox.width = 95
    $FSLogixBox.height = 20
    $FSLogixBox.autosize = $true
	$FSLogixBox.Font = $Font
    $FSLogixBox.location = New-Object System.Drawing.Point(420,395)
    $form.Controls.Add($FSLogixBox)
	$FSLogixBox.Checked =  $SoftwareSelection.FSLogix
	
	# GoogleChrome Checkbox
    $GoogleChromeBox = New-Object system.Windows.Forms.CheckBox
    $GoogleChromeBox.text = "Google Chrome"
    $GoogleChromeBox.width = 95
    $GoogleChromeBox.height = 20
    $GoogleChromeBox.autosize = $true
	$GoogleChromeBox.Font = $Font
    $GoogleChromeBox.location = New-Object System.Drawing.Point(420,420)
    $form.Controls.Add($GoogleChromeBox)
	$GoogleChromeBox.Checked =  $SoftwareSelection.GoogleChrome
	
	# Firefox Checkbox
    $FirefoxBox = New-Object system.Windows.Forms.CheckBox
    $FirefoxBox.text = "Mozilla Firefox"
    $FirefoxBox.width = 95
    $FirefoxBox.height = 20
    $FirefoxBox.autosize = $true
	$FirefoxBox.Font = $Font
    $FirefoxBox.location = New-Object System.Drawing.Point(420,445)
    $form.Controls.Add($FirefoxBox)
	$FirefoxBox.Checked =  $SoftwareSelection.Firefox
<#	
	# Zoom VMWare client Checkbox
    $ZoomVMWareBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVMWareBox.text = "Zoom VMWare Client"
    $ZoomVMWareBox.width = 95
    $ZoomVMWareBox.height = 20
    $ZoomVMWareBox.autosize = $true
	$ZoomVMWareBox.Font = $Font
    $ZoomVMWareBox.location = New-Object System.Drawing.Point(420,195)
    $form.Controls.Add($ZoomVMWareBox)
	$ZoomVMWareBox.Checked =  $SoftwareSelection.ZoomVMWare
#>
    # WinSCP Checkbox
    $WinSCPBox = New-Object system.Windows.Forms.CheckBox
    $WinSCPBox.text = "WinSCP"
    $WinSCPBox.width = 95
    $WinSCPBox.height = 20
    $WinSCPBox.autosize = $true
	$WinSCPBox.Font = $Font
    $WinSCPBox.location = New-Object System.Drawing.Point(420,470)
    $form.Controls.Add($WinSCPBox)
    $WinSCPBox.Checked =  $SoftwareSelection.WinSCP
	
	# Putty Checkbox
    $PuttyBox = New-Object system.Windows.Forms.CheckBox
    $PuttyBox.text = "Putty"
    $PuttyBox.width = 95
    $PuttyBox.height = 20
    $PuttyBox.autosize = $true
	$PuttyBox.Font = $Font
    $PuttyBox.location = New-Object System.Drawing.Point(420,495)
	$form.Controls.Add($PuttyBox)
    $PuttyBox.Checked =  $SoftwareSelection.Putty
	
	<#
	# CiscoWebExDesktop Checkbox
    $CiscoWebExDesktopBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExDesktopBox.text = "Cisco WebEx"
    $CiscoWebExDesktopBox.width = 95
    $CiscoWebExDesktopBox.height = 20
    $CiscoWebExDesktopBox.autosize = $true
	$CiscoWebExDesktopBox.Font = $Font
    $CiscoWebExDesktopBox.location = New-Object System.Drawing.Point(420,320)
    $form.Controls.Add($CiscoWebExDesktopBox)
	$CiscoWebExDesktopBox.Checked =  $SoftwareSelection.CiscoWebExDesktop
	#>
	
	# OracleJava8 Checkbox
    $OracleJava8Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8Box.text = "Oracle Java 8/x64"
    $OracleJava8Box.width = 95
    $OracleJava8Box.height = 20
    $OracleJava8Box.autosize = $true
	$OracleJava8Box.Font = $Font
    $OracleJava8Box.location = New-Object System.Drawing.Point(420,520)
    $form.Controls.Add($OracleJava8Box)
	$OracleJava8Box.Checked =  $SoftwareSelection.OracleJava8
	
	# OracleJava8-32Bit Checkbox
    $OracleJava8_32Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8_32Box.text = "Oracle Java 8/x86"
    $OracleJava8_32Box.width = 95
    $OracleJava8_32Box.height = 20
    $OracleJava8_32Box.autosize = $true
	$OracleJava8_32Box.Font = $Font
    $OracleJava8_32Box.location = New-Object System.Drawing.Point(420,545)
    $form.Controls.Add($OracleJava8_32Box)
	$OracleJava8_32Box.Checked =  $SoftwareSelection.OracleJava8_32
	
	# RemoteDesktopManager Checkbox
    $RemoteDesktopManagerBox = New-Object system.Windows.Forms.CheckBox
    $RemoteDesktopManagerBox.text = "Remote Desktop Manager Free"
    $RemoteDesktopManagerBox.width = 95
    $RemoteDesktopManagerBox.height = 20
    $RemoteDesktopManagerBox.autosize = $true
	$RemoteDesktopManagerBox.Font = $Font
    $RemoteDesktopManagerBox.location = New-Object System.Drawing.Point(420,570)
    $form.Controls.Add($RemoteDesktopManagerBox)
	$RemoteDesktopManagerBox.Checked =  $SoftwareSelection.RemoteDesktopManager
	
	# pdf24Creator Checkbox
    $pdf24CreatorBox = New-Object system.Windows.Forms.CheckBox
    $pdf24CreatorBox.text = "PDF24 Creator"
    $pdf24CreatorBox.width = 95
    $pdf24CreatorBox.height = 20
    $pdf24CreatorBox.autosize = $true
	$pdf24CreatorBox.Font = $Font
    $pdf24CreatorBox.location = New-Object System.Drawing.Point(420,595)
    $form.Controls.Add($pdf24CreatorBox)
	$pdf24CreatorBox.Checked =  $SoftwareSelection.pdf24Creator

	# FoxitReader Checkbox
    $FoxitReaderBox = New-Object system.Windows.Forms.CheckBox
    $FoxitReaderBox.text = "Foxit Reader"
    $FoxitReaderBox.width = 95
    $FoxitReaderBox.height = 20
    $FoxitReaderBox.autosize = $true
	$FoxitReaderBox.Font = $Font
    $FoxitReaderBox.location = New-Object System.Drawing.Point(810,45)
    $form.Controls.Add($FoxitReaderBox)
	$FoxitReaderBox.Checked =  $SoftwareSelection.FoxitReader

	# VLCPlayer Checkbox
    $VLCPlayerBox = New-Object system.Windows.Forms.CheckBox
    $VLCPlayerBox.text = "VLC Player"
    $VLCPlayerBox.width = 95
    $VLCPlayerBox.height = 20
    $VLCPlayerBox.autosize = $true
	$VLCPlayerBox.Font = $Font
    $VLCPlayerBox.location = New-Object System.Drawing.Point(810,70)
    $form.Controls.Add($VLCPlayerBox)
	$VLCPlayerBox.Checked =  $SoftwareSelection.VLCPlayer
	
	# KeePass Checkbox
    $KeePassBox = New-Object system.Windows.Forms.CheckBox
    $KeePassBox.text = "KeePass"
    $KeePassBox.width = 95
    $KeePassBox.height = 20
    $KeePassBox.autosize = $true
	$KeePassBox.Font = $Font
    $KeePassBox.location = New-Object System.Drawing.Point(810,95)
    $form.Controls.Add($KeePassBox)
	$KeePassBox.Checked =  $SoftwareSelection.KeePass
	
	# KeePassXC Checkbox
    $KeePassXCBox = New-Object system.Windows.Forms.CheckBox
    $KeePassXCBox.text = "KeePassXC"
    $KeePassXCBox.width = 95
    $KeePassXCBox.height = 20
    $KeePassXCBox.autosize = $true
	$KeePassXCBox.Font = $Font
    $KeePassXCBox.location = New-Object System.Drawing.Point(810,120)
    $form.Controls.Add($KeePassXCBox)
	$KeePassXCBox.Checked =  $SoftwareSelection.KeePassXC

    # TreeSizeFree Checkbox
    $TreeSizeFreeBox = New-Object system.Windows.Forms.CheckBox
    $TreeSizeFreeBox.text = "TreeSize Free"
    $TreeSizeFreeBox.width = 95
    $TreeSizeFreeBox.height = 20
    $TreeSizeFreeBox.autosize = $true
	$TreeSizeFreeBox.Font = $Font
    $TreeSizeFreeBox.location = New-Object System.Drawing.Point(810,145)
    $form.Controls.Add($TreeSizeFreeBox)
	$TreeSizeFreeBox.Checked =  $SoftwareSelection.TreeSizeFree
	
	# ShareX Checkbox
    $ShareXBox = New-Object system.Windows.Forms.CheckBox
    $ShareXBox.text = "ShareX"
    $ShareXBox.width = 95
    $ShareXBox.height = 20
    $ShareXBox.autosize = $true
	$ShareXBox.Font = $Font
    $ShareXBox.location = New-Object System.Drawing.Point(810,170)
    $form.Controls.Add($ShareXBox)
	$ShareXBox.Checked =  $SoftwareSelection.ShareX
	
	# Greenshot Checkbox
    $GreenshotBox = New-Object system.Windows.Forms.CheckBox
    $GreenshotBox.text = "Greenshot"
    $GreenshotBox.width = 95
    $GreenshotBox.height = 20
    $GreenshotBox.autosize = $true
	$GreenshotBox.Font = $Font
    $GreenshotBox.location = New-Object System.Drawing.Point(810,195)
    $form.Controls.Add($GreenshotBox)
	$GreenshotBox.Checked =  $SoftwareSelection.Greenshot
	
	# ImageGlass Checkbox
    $ImageGlassBox = New-Object system.Windows.Forms.CheckBox
    $ImageGlassBox.text = "ImageGlass"
    $ImageGlassBox.width = 95
    $ImageGlassBox.height = 20
    $ImageGlassBox.autosize = $true
	$ImageGlassBox.Font = $Font
    $ImageGlassBox.location = New-Object System.Drawing.Point(810,220)
    $form.Controls.Add($ImageGlassBox)
	$ImageGlassBox.Checked =  $SoftwareSelection.ImageGlass
	
	# FileZilla Checkbox
    $FileZillaBox = New-Object system.Windows.Forms.CheckBox
    $FileZillaBox.text = "FileZilla Client"
    $FileZillaBox.width = 95
    $FileZillaBox.height = 20
    $FileZillaBox.autosize = $true
	$FileZillaBox.Font = $Font
    $FileZillaBox.location = New-Object System.Drawing.Point(810,245)
    $form.Controls.Add($FileZillaBox)
	$FileZillaBox.Checked =  $SoftwareSelection.FileZilla

	# WinRAR Checkbox
    $WinRARBox = New-Object system.Windows.Forms.CheckBox
    $WinRARBox.text = "WinRAR"
    $WinRARBox.width = 95
    $WinRARBox.height = 20
    $WinRARBox.autosize = $true
	$WinRARBox.Font = $Font
    $WinRARBox.location = New-Object System.Drawing.Point(810,270)
    $form.Controls.Add($WinRARBox)
	$WinRARBox.Checked =  $SoftwareSelection.WinRAR


	<#
	# Zoom Host Checkbox
    $ZoomVDIBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVDIBox.text = "Zoom VDI Host Installer (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",10.5, [System.Drawing.FontStyle]::Strikeout)
    $ZoomVDIBox.Font = $CustomFont
    $ZoomVDIBox.width = 95
    $ZoomVDIBox.height = 20
    $ZoomVDIBox.autosize = $true
    $ZoomVDIBox.location = New-Object System.Drawing.Point(420,570)
    $form.Controls.Add($ZoomVDIBox)
	$ZoomVDIBox.Checked =  $SoftwareSelection.ZoomVDI
	
	# Zoom Citrix client Checkbox
    $ZoomCitrixBox = New-Object system.Windows.Forms.CheckBox
    $ZoomCitrixBox.text = "Zoom Citrix Client (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",10.5, [System.Drawing.FontStyle]::Strikeout)
    $ZoomCitrixBox.Font = $CustomFont
    $ZoomCitrixBox.width = 95
    $ZoomCitrixBox.height = 20
    $ZoomCitrixBox.autosize = $true
    $ZoomCitrixBox.location = New-Object System.Drawing.Point(420,595)
    $form.Controls.Add($ZoomCitrixBox)
	$ZoomCitrixBox.Checked =  $SoftwareSelection.ZoomCitrix
	#>
	
	# Select Button
    $SelectButton = New-Object system.Windows.Forms.Button
    $SelectButton.text = "Select all"
    $SelectButton.width = 110
    $SelectButton.height = 30
	$SelectButton.Font = $Font
    $SelectButton.location = New-Object System.Drawing.Point(11,630)
    $SelectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $True
		$SevenZipBox.checked = $True
		$AdobeReaderDCBox.checked = $True
		$AdobeReaderDCBoxUpdate.checked = $True
		$AdobeReaderDCx64Box.checked = $True
		$AdobeReaderDCx64BoxUpdate.checked = $True
		$BISFBox.checked = $True
		$FSLogixBox.checked = $True
		$GoogleChromeBox.checked = $True
		$FirefoxBox.checked = $True
		$WorkspaceApp_CRBox.checked = $True
		$WorkspaceApp_LTSRBox.checked = $True
		$WorkspaceApp_CR_WebBox.checked = $True
		$WorkspaceApp_LTSR_WebBox.checked = $True
		$Citrix_HypervisorToolsBox.checked = $False
		$KeePassBox.checked = $True
		$KeePassXCBox.checked = $True
		$MSEdgeBox.checked = $True
		$MSOneDriveBox.checked = $True
		$MSTeamsBox.checked = $True
		$NEWMSTeamsBox.checked = $True
		$MS365AppsBox_SAC.checked = $True
		$MS365AppsBox_MEC.checked = $True
		$MSOffice2019Box.checked = $True
		$MSOffice2021Box.checked = $True
		$MSOffice2024Box.checked = $True
		$VcRedistBox.checked = $True
        $MSSQLManagementStudioENBox.checked = $True
        $MSSQLManagementStudioDEBox.checked = $True
		$MicrosoftOpenJDKBox.checked = $True
		$OracleJava8Box.checked = $True
		$OracleJava8_32Box.checked = $True
		$TreeSizeFreeBox.checked = $True
		$ShareXBox.checked = $True
		$VLCPlayerBox.checked = $True
		$FileZillaBox.checked = $True
		$WinRARBoxDe.checked = $True
		$WinRARBoxEn.checked = $True
		$ImageGlassBox.checked = $True
		$GreenshotBox.checked = $True
		$pdf24CreatorBox.checked = $True
        $FoxitReaderBox.checked = $True
		$deviceTRUSTBox.checked = $True
		$VMWareToolsBox.checked = $True
		$RemoteDesktopManagerBox.checked = $True
		#$ZoomVDIBox.checked = $True
		#$ZoomCitrixBox.checked = $True
		#$ZoomVMWareBox.checked = $True
		#$CiscoWebExDesktopBox.checked = $True
		$PVSTargetDevice_LTSRBox.checked = $True
		$PVSTargetDevice_CRBox.checked = $True
		$ServerVDA_LTSRBox.checked = $True
		$ServerVDA_PVS_LTSRBox.checked = $True
		$ServerVDA_CRBox.checked = $True
		$ServerVDA_PVS_CRBox.checked = $True
		$ServerVDA_MCS_LTSRBox.checked = $True
		$ServerVDA_MCS_CRBox.checked = $True
		$WEM_Agent_Box.checked = $True
		$WEM_Agent_PVSBox.checked = $True
		$WEM_Agent_MCSBox.checked = $True
        $PuttyBox.checked = $True
        $WinSCPBox.checked = $True
		})
    $form.Controls.Add($SelectButton)
	
	# Unselect Button
    $UnselectButton = New-Object system.Windows.Forms.Button
    $UnselectButton.text = "Unselect all"
    $UnselectButton.width = 110
    $UnselectButton.height = 30
	$UnSelectButton.Font = $Font
    $UnselectButton.location = New-Object System.Drawing.Point(131,630)
    $UnselectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $False
		$SevenZipBox.checked = $False
		$AdobeReaderDCBox.checked = $False
		$AdobeReaderDCBoxUpdate.checked = $False
		$AdobeReaderDCx64Box.checked = $False
		$AdobeReaderDCx64BoxUpdate.checked = $False
		$BISFBox.checked = $False
		$FSLogixBox.checked = $False
		$GoogleChromeBox.checked = $False
		$FirefoxBox.checked = $False
		$WorkspaceApp_CRBox.checked = $False
		$WorkspaceApp_LTSRBox.checked = $False
		$WorkspaceApp_CR_WebBox.checked = $False
		$WorkspaceApp_LTSR_WebBox.checked = $False
		$Citrix_HypervisorToolsBox.checked = $False
		$KeePassBox.checked = $False
		$KeePassXCBox.checked = $False
		$MSEdgeBox.checked = $False
		$MSOneDriveBox.checked = $False
		$MSTeamsBox.checked = $False
		$NEWMSTeamsBox.checked = $False
		$MS365AppsBox_SAC.checked = $False
		$MS365AppsBox_MEC.checked = $False
		$MSOffice2019Box.checked = $False
		$MSOffice2021Box.checked = $False
		$MSOffice2024Box.checked = $False
		$VcRedistBox.checked = $False
        $MSSQLManagementStudioENBox.checked = $False
        $MSSQLManagementStudioENBox.checked = $False
		$MicrosoftOpenJDKBox.checked = $False
		$OracleJava8Box.checked = $False
		$OracleJava8_32Box.checked = $False
		$TreeSizeFreeBox.checked = $False
		$ShareXBox.checked = $False
		$VLCPlayerBox.checked = $False
		$FileZillaBox.checked = $False
		$WinRARBoxDe.checked = $False
		$WinRARBoxEn.checked = $False
		$ImageGlassBox.checked = $False
		$GreenshotBox.checked = $False
		$pdf24CreatorBox.checked = $False
        $FoxitReaderBox.checked = $False
		$deviceTRUSTBox.checked = $False
		$VMWareToolsBox.checked = $False
		$RemoteDesktopManagerBox.checked = $False
		#$ZoomVDIBox.checked = $False
		#$ZoomCitrixBox.checked = $False
		#$ZoomVMWareBox.checked = $False
		#$CiscoWebExDesktopBox.checked = $False
		$PVSTargetDevice_LTSRBox.checked = $False
		$PVSTargetDevice_CRBox.checked = $False
		$ServerVDA_LTSRBox.checked = $False
		$ServerVDA_PVS_LTSRBox.checked = $False
		$ServerVDA_CRBox.checked = $False
		$ServerVDA_PVS_CRBox.checked = $False
		$ServerVDA_MCS_LTSRBox.checked = $False
		$ServerVDA_MCS_CRBox.checked = $False
		$WEM_Agent_Box.checked = $False
		$WEM_Agent_PVSBox.checked = $False
		$WEM_Agent_MCSBox.checked = $False
        $PuttyBox.checked = $False
        $WinSCPBox.checked = $False
		})
    $form.Controls.Add($UnselectButton)
	
    # OK Button
    $OKButton = New-Object system.Windows.Forms.Button
    $OKButton.text = "OK"
    $OKButton.width = 60
    $OKButton.height = 30
	$OKButton.Font = $Font
    $OKButton.location = New-Object System.Drawing.Point(271,630)
    $OKButton.Add_Click({
		#if (!($SoftwareToInstall)) {$SoftwareSelection = New-Object PSObject}
		$SoftwareSelection = New-Object PSObject
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NotepadPlusPlus" -Value $NotePadPlusPlusBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "SevenZip" -Value $SevenZipBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDC" -Value $AdobeReaderDCBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCUpdate" -Value $AdobeReaderDCBoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCx64" -Value $AdobeReaderDCx64Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCx64Update" -Value $AdobeReaderDCx64BoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "BISF" -Value $BISFBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FSLogix" -Value $FSLogixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "GoogleChrome" -Value $GoogleChromeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Firefox" -Value $FirefoxBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR" -Value $WorkspaceApp_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR" -Value $WorkspaceApp_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR_Web" -Value $WorkspaceApp_CR_WebBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR_Web" -Value $WorkspaceApp_LTSR_WebBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixHypervisorTools" -Value $Citrix_HypervisorToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePass" -Value $KeePassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePassXC" -Value $KeePassXCBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSEdge" -Value $MSEdgeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOneDrive" -Value $MSOneDriveBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeams" -Value $MSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeams2" -Value $NEWMSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_SAC" -Value $MS365AppsBox_SAC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_MEC" -Value $MS365AppsBox_MEC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2019" -Value $MSOffice2019Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2021" -Value $MSOffice2021Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2024" -Value $MSOffice2024Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VcRedist" -Value $VcRedistBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsEN" -Value $MSSQLManagementStudioENBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsDE" -Value $MSSQLManagementStudioDEBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MicrosoftOpenJDK" -Value $MicrosoftOpenJDKBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8" -Value $OracleJava8Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8_32" -Value $OracleJava8_32Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "TreeSizeFree" -Value $TreeSizeFreeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ShareX" -Value $ShareXBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VLCPlayer" -Value $VLCPlayerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FileZilla" -Value $FileZillaBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinRAR" -Value $WinRARBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ImageGlass" -Value $ImageGlassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Greenshot" -Value $GreenshotBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "pdf24Creator" -Value $pdf24CreatorBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FoxitReader" -Value $FoxitReaderBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "deviceTRUST" -Value $deviceTRUSTBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VMWareTools" -Value $VMWareToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RemoteDesktopManager" -Value $RemoteDesktopManagerBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVDI" -Value $ZoomVDIBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomCitrix" -Value $ZoomCitrixBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVMWare" -Value $ZoomVMWareBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExDesktop" -Value $CiscoWebExDesktopBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixPVSTargetDevice_LTSR" -Value $PVSTargetDevice_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixPVSTargetDevice_CR" -Value $PVSTargetDevice_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_LTSR" -Value $ServerVDA_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_PVS_LTSR" -Value $ServerVDA_PVS_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_CR" -Value $ServerVDA_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_PVS_CR" -Value $ServerVDA_PVS_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_MCS_LTSR" -Value $ServerVDA_MCS_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_MCS_CR" -Value $ServerVDA_MCS_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent" -Value $WEM_Agent_Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent_PVS" -Value $WEM_Agent_PVSBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent_MCS" -Value $WEM_Agent_MCSBox.checked -Force
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
	$CancelButton.Font = $Font
    $CancelButton.location = New-Object System.Drawing.Point(341,630)
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

# We open our splash-screen
if ($SplashScreen -ne $False) {
	if (Test-Path -Path "$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen") {
		if ($noGUI -eq $False) {
			Start-SplashScreen
		}
}
# Load Main Panel #
# =============== #

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}


$XamlMainWindow=LoadXaml("$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen\form.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)
# Main Pannel Event #
# ================= #
}


# FUNCTION Check internet access
# ========================================================================================================================================
Function Test-InternetConnection1 {
	param($Website)
	Try {
    (Invoke-WebRequest -Uri $Website -TimeoutSec 1 -UseBasicParsing).StatusCode
	}
	Catch {
    }
}
$InternetAccess1 = Test-InternetConnection1 -Website github.com

IF($internetAccess1 -eq 200) {
	$InternetCheck1 = "True"
}
ELSE {
    $InternetCheck1 = "False"
}

function Test-InternetConnection2 {
    try {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadString("https://github.com")
        return $true
    } catch {
        return $false
    }
}

$InternetAccess2 = Test-InternetConnection2

if ($InternetAccess2) {
    $InternetCheck2 = "True"
} else {
    $InternetCheck2 = "False"
}
# ========================================================================================================================================


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
	Write-Host "Press any key to exit"
	Read-Host
    BREAK
   }
# ========================================================================================================================================


# Is there a newer Evergreen Script version?
# ========================================================================================================================================
if ($noGUI -eq $False) {
	[version]$EvergreenVersion = "2.18.13"
	$WebVersion = ""
	[bool]$NewerVersion = $false
	IF ($InternetCheck1 -eq "True" -or $InternetCheck2 -eq "True") {
		Write-Host -ForegroundColor Green "Internet access is working!"
		Write-Output ""
		start-sleep -seconds 2
		$WebResponseVersion = Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/Mohrpheus78/Evergreen/main/Evergreen-Software%20Installer.ps1"
		If ($WebResponseVersion) {
			[version]$WebVersion = (($WebResponseVersion.tostring() -split "[`r`n]" | select-string "Version:" | Select-Object -First 1) -split ":")[1].Trim()
		}
		If ($WebVersion -gt $EvergreenVersion) {
			$NewerVersion = $true
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Check your internet connection to get updated scripts, server can't reach the GitHub URL!"
		Write-Output ""
		
		$title = ""
		$message = "Do you want to cancel the update? The installer scripts may be outdated!"
		$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"
		$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No"
		$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
		$choice=$host.ui.PromptForChoice($title, $message, $options, 0)

		switch ($choice) {
			0 {
			$answer = 'Yes'       
			}
			1 {
			$answer = 'No'
			}
		}

		if ($answer -eq 'Yes') {
			BREAK
		}
	}
}

# Everything is loaded so we close the splash-screen
if ($Splashscreen -ne $False) {
	if (Test-Path -Path "$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen") {
		if ($noGUI -eq $False) {
			close-SplashScreen
		}
	}
}

Clear-Host

Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " -------------------------------------------------"
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " Software-Installer (Powered by Evergreen-Module) "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " © D. Mohrmann - Cancom GmbH                      "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " -------------------------------------------------"
Write-Output ""


# Variables
Write-Host -ForegroundColor Cyan "Setting Variables"
Write-Output ""
$SoftwareFolder = ("$PSScriptRoot" + "\" + "Software\")
$ErrorActionPreference = "Continue"
$SoftwareToInstall = "$SoftwareFolder\Software-to-install-$ENV:Computername.xml"
IF ($SoftwareToAutoInstall -eq $True) {
	$SoftwareToInstall = "$SoftwareFolder\Software-to-install-$ENV:Computername-Auto.xml"
	}
	
# Check version
if ($noGUI -eq $False) {
Write-Host -Foregroundcolor Cyan "Current script version: $EvergreenVersion"`n
Write-Output ""
Write-Host -Foregroundcolor Cyan "Is there a newer Evergreen Script version?"

If ($NewerVersion -eq $false) {
        # No new version available
        Write-Host -Foregroundcolor Green "OK, script is newest version!"
        Write-Output ""
}
Else {
        # There is a new Evergreen Script Version
        Write-Host -Foregroundcolor Red "Attention! There is a new version $WebVersion of the Evergreen Installer available!"
        Write-Output ""
		$wshell = New-Object -ComObject Wscript.Shell
            $AnswerPending = $wshell.Popup("Do you want to download the new version?",0,"New Version available",32+4)
            If ($AnswerPending -eq "6") {
				$update = @'
                Remove-Item -Path "$PSScriptRoot\Evergreen-Software Installer.ps1" -Force
				IF (!(Test-Path "$SoftwareFolder\MS Teams 2")) {
					New-Item -Path "$SoftwareFolder\MS Teams 2" -ItemType Directory | Out-Null
					}
                Invoke-WebRequest -Uri https://raw.githubusercontent.com/Mohrpheus78/Evergreen/main/Evergreen-Software%20Installer.ps1 -OutFile ("$PSScriptRoot\" + "Evergreen-Software Installer.ps1")
				Invoke-WebRequest -Uri https://raw.githubusercontent.com/Mohrpheus78/Evergreen/refs/heads/main/Software/MS%20Teams%202/NEW%20MS%20Teams%20Settings.ps1 -OutFile ("$SoftwareFolder\MS Teams 2\" + "NEW MS Teams Settings.ps1")
				$TempFolder = "$PSScriptRoot\SoftwareTemp"
				IF (!(Test-Path $TempFolder)) {
					New-Item -Path $TempFolder -ItemType Directory -EA SilentlyContinue | Out-Null
				}
				Invoke-WebRequest -Uri https://github.com/Mohrpheus78/Evergreen/archive/refs/heads/main.zip -OutFile "$TempFolder\Evergreen.zip"
				Expand-Archive -Path "$TempFolder\Evergreen.zip" -DestinationPath $TempFolder

				Get-ChildItem "$TempFolder\Evergreen-main\Software\*.ps1" | Move-Item -Destination $TempFolder -Force
				Get-ChildItem "$TempFolder\*.ps1" | Copy-Item -Destination "$SoftwareFolder" -Force
				IF (!(Test-Path $SoftwareFolder\_SplashScreen)) {
					Move-Item -Path "$TempFolder\Evergreen-main\Software\_SplashScreen" "$SoftwareFolder" -Force
				}	
				Remove-Item -Path $TempFolder -Recurse -Force
                & "$PSScriptRoot\Evergreen-Software Installer.ps1"
'@
                $update > "$PSScriptRoot\UpdateInstaller.ps1"
                & "$PSScriptRoot\UpdateInstaller.ps1"
                BREAK
			}

}
}

# Release notes
$scriptContent = Get-Content -Path "$PSScriptRoot\Evergreen-Software Installer.ps1"
$notesIndex = $scriptContent.IndexOf("# Notes")
# Find index of the line with "# Notes"
$lastLineBeforeNotes = $scriptContent[$notesIndex - 1]
Write-Host -Foregroundcolor Cyan "Last changes: $lastLineBeforeNotes"
Write-Output ""

# General install logfile
$Date = $Date = Get-Date -UFormat "%d.%m.%Y"
$InstallLog = "$SoftwareFolder\_Install Logs\General Install $ENV:Computername $Date.log"

# Import values (selected software) from XML file
if (Test-Path -Path $SoftwareToInstall) {$SoftwareSelection = Import-Clixml $SoftwareToInstall}

#Remove-Item $InstallLog*
Start-Transcript $InstallLog | Out-Null

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
		try {
			& "$SoftwareFolder\Install NotepadPlusPlus.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing NotePadPlusPlus"
			Write-Host -ForegroundColor Red "Error launching script 'Install NotepadPlusPlus': $($Error[0])"
			Write-Output ""
			}
	}

# Install 7-ZIP
IF ($SoftwareSelection.SevenZip -eq $true)
	{
		try {
			& "$SoftwareFolder\Install 7-Zip.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing 7-Zip"
			Write-Host -ForegroundColor Red "Error launching script 'Install 7-Zip': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC MUI
IF ($SoftwareSelection.AdobeReaderDC -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC"
			Write-Host -ForegroundColor Red "Error launching script 'Install Adobe Reader DC': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC MUI Update
IF ($SoftwareSelection.AdobeReaderDCUpdate -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC Update.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC Update"
			Write-Host -ForegroundColor Red "Error launching script 'Install Adobe Reader DC Update': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC x64 MUI
IF ($SoftwareSelection.AdobeReaderDCx64 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC 64 Bit.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC 64 Bit"
			Write-Host -ForegroundColor Red "Error launching script 'Install Adobe Reader DC 64 Bit': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC x64 MUI Update
IF ($SoftwareSelection.AdobeReaderDCx64Update -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC 64 Bit Update.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC 64 Bit Update"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Adobe Reader DC 64 Bit Update': $($Error[0])"
			Write-Output ""
			}
	}

# Install BIS-F
IF ($SoftwareSelection.BISF -eq $true)
	{
		try {
			& "$SoftwareFolder\Install BIS-F.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing BIS-F"
			Write-Host -ForegroundColor Red "Error launching script 'Install BIS-F': $($Error[0])"
			Write-Output ""
			}
	}

# Install FSLogix
IF ($SoftwareSelection.FSLogix -eq $true)
	{
		try {
			& "$SoftwareFolder\Install FSLogix.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing FSLogix"
			Write-Host -ForegroundColor Red "Error launching script 'Install FSLogix': $($Error[0])"
			Write-Output ""
			}
	}

# Install Chrome
IF ($SoftwareSelection.GoogleChrome -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Google Chrome.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Google Chrome"
			Write-Host -ForegroundColor Red "Error launching script 'Install Google Chrome': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Mozilla Firefox
IF ($SoftwareSelection.Firefox -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Mozilla Firefox.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Mozilla Firefox"
			Write-Host -ForegroundColor Red "Error launching script 'Install Mozilla Firefox': $($Error[0])"
			Write-Output ""
			}
	}

# Install WorkspaceApp Current
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WorkspaceApp Current.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WorkspaceApp Current Release"
			Write-Host -ForegroundColor Red "Error launching script 'Install WorkspaceApp Current': $($Error[0])"
			Write-Output ""
			}
	}

# Install WorkspaceApp LTSR
IF ($SoftwareSelection.WorkspaceApp_LTSR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WorkspaceApp LTSR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WorkspaceApp LTSR"
			Write-Host -ForegroundColor Red "Error launching script 'Install WorkspaceApp LTSR': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install WorkspaceApp Current Web
IF ($SoftwareSelection.WorkspaceApp_CR_Web -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WorkspaceApp Current Web.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WorkspaceApp Current Release Web"
			Write-Host -ForegroundColor Red "Error launching script 'Install WorkspaceApp Current Web': $($Error[0])"
			Write-Output ""
			}
	}

# Install WorkspaceApp LTSR Web
IF ($SoftwareSelection.WorkspaceApp_LTSR_Web -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WorkspaceApp LTSR Web.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WorkspaceApp LTSR Web"
			Write-Host -ForegroundColor Red "Error launching script 'Install WorkspaceApp LTSR Web': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix Hypervisor Tools
IF ($SoftwareSelection.CitrixHypervisorTools -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix Hypervisor Tools.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix Hypervisor Tools"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Hypervisor Tools': $($Error[0])"
			Write-Output ""
			}
	}

# Install KeePass
IF ($SoftwareSelection.KeePass -eq $true)
	{
		try {
			& "$SoftwareFolder\Install KeePass.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing KeePass"
			Write-Host -ForegroundColor Red "Error launching script 'Install KeePass': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install KeePassXC
IF ($SoftwareSelection.KeePassXC -eq $true)
	{
		try {
			& "$SoftwareFolder\Install KeePassXC.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing KeePassXC"
			Write-Host -ForegroundColor Red "Error launching script 'Install KeePassXC': $($Error[0])"
			Write-Output ""
			}
	}

# Install MS Edge
IF ($SoftwareSelection.MSEdge -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Edge.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS Edge"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Edge': $($Error[0])"
			Write-Output ""
			}
	}

# Install MS OneDrive
IF ($SoftwareSelection.MSOneDrive -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS OneDrive.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS OneDrive"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS OneDrive': $($Error[0])"
			Write-Output ""
			}
	}

# Install MS Teams
IF ($SoftwareSelection.MSTeams -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Teams.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS Teams"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Teams': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install NEW MS Teams
IF ($SoftwareSelection.MSTeams2 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Teams 2.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "MS Teams 2.x"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Teams': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS 365Apps
IF ($SoftwareSelection.MS365Apps_SAC -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS 365 Apps SAC.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS 365 Apps-Semi Annual Channel"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS 365 Apps SAC': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS 365Apps
IF ($SoftwareSelection.MS365Apps_MEC -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS 365 Apps MEC.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS 365 Apps-Monthly Enterprise Channel"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS 365 Apps MEC': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS Office 2019
IF ($SoftwareSelection.MSOffice2019 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Office 2019.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS Office 2019"
			Write-Host -ForegroundColor Red "Error in launching script 'Install MS Office 2019': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS Office 2021
IF ($SoftwareSelection.MSOffice2021 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Office 2021.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS Office 2021"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Office 2021': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS Office 2024
IF ($SoftwareSelection.MSOffice2024 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Office 2024.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS Office 2024"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Office 2024': $($Error[0])"
			Write-Output ""
			}
	}
	
	
# Install MS VcRedist
IF ($SoftwareSelection.VcRedist -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS VcRedist x86.ps1"
		}
		catch {
			Write-Host -ForegroundColor Red "Installing Microsoft Visual C++ Redistributable packages x86"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x86': $($Error[0])"
			Write-Output ""
		}
		try {
			& "$SoftwareFolder\Install MS VcRedist x64.ps1"
		}
		catch {
			Write-Host -ForegroundColor Red "Installing Microsoft Visual C++ Redistributable packages x64"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x64': $($Error[0])"
			Write-Output ""
		}
	}

# Install MS MS SQL Management Studio EN
IF ($SoftwareSelection.MSSsmsEN -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS SQL MGMT Studio EN.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS SQL MGMT Studio EN"
			Write-Host -ForegroundColor Red "Error  launching script 'Install MS SQL MGMT Studio EN': $($Error[0])"
			Write-Output ""
			}
	}

# Install MS MS SQL Management Studio DE
IF ($SoftwareSelection.MSSsmsDE -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS SQL MGMT Studio DE.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS SQL MGMT Studio DE"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS SQL MGMT Studio DE': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS openJDK 21
IF ($SoftwareSelection.MicrosoftOpenJDK -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS openJDK21.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS openJDK 21"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS openJDK 21': $($Error[0])"
			Write-Output ""
			}
	}

# Install Oracle Java 8
IF ($SoftwareSelection.OracleJava8 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Oracle Java 8 - 64 Bit.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Oracle Java 8 x64"
			Write-Host -ForegroundColor Red "Error launching script 'Install Oracle Java 8 - 64 Bit': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Oracle Java 8 32 Bit
IF ($SoftwareSelection.OracleJava8_32 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Oracle Java 8 - 32 Bit.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Oracle Java 8 x86"
			Write-Host -ForegroundColor Red "Error launching script 'Install Oracle Java 8 - 32 Bit': $($Error[0])"
			Write-Output ""
			}
	}

# Install TreeSizeFree
IF ($SoftwareSelection.TreeSizeFree -eq $true)
	{
		try {
			& "$SoftwareFolder\Install TreeSizeFree.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing TreeSize Free"
			Write-Host -ForegroundColor Red "Error launching script 'Install TreeSizeFree': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install ShareX
IF ($SoftwareSelection.ShareX -eq $true)
	{
		try {
			& "$SoftwareFolder\Install ShareX.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing ShareX"
			Write-Host -ForegroundColor Red "Error launching script 'Install ShareX': $($Error[0])"
			Write-Output ""
			}
	}

# Install VLC Player
IF ($SoftwareSelection.VLCPlayer -eq $true)
	{
		try {
			& "$SoftwareFolder\Install VLC Player.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing VLC Player"
			Write-Host -ForegroundColor Red "Error launching script 'Install VLC Player': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install FileZilla
IF ($SoftwareSelection.FileZilla -eq $true)
	{
		try {
			& "$SoftwareFolder\Install FileZilla.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing FileZilla"
			Write-Host -ForegroundColor Red "Error launching script 'Install FileZilla': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install ImageGlass
IF ($SoftwareSelection.ImageGlass -eq $true)
	{
		try {
			& "$SoftwareFolder\Install ImageGlass.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing ImageGlass"
			Write-Host -ForegroundColor Red "Error launching script 'Install ImageGlass': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Greenshot
IF ($SoftwareSelection.Greenshot -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Greenshot.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Greenshot"
			Write-Host -ForegroundColor Red "Error launching script 'Install Greenshot': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install pdf24Creator
IF ($SoftwareSelection.pdf24Creator -eq $true)
	{
		try {
			& "$SoftwareFolder\Install pdf24Creator.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing pdf24Creator"
			Write-Host -ForegroundColor Red "Error launching script 'Install pdf24Creator': $($Error[0])"
			Write-Output ""
			}
	}

# Install FoxitReader
IF ($SoftwareSelection.FoxitReader -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Foxit Reader.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Foxit Reader"
			Write-Host -ForegroundColor Red "Error launching script 'Install Foxit Reader': $($Error[0])"
			Write-Output ""
			}
	}
	
	
# Install RemoteDesktopManager
IF ($SoftwareSelection.RemoteDesktopManager -eq $true)
	{
		try {
			& "$SoftwareFolder\Install RemoteDesktopManager.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing RemoteDesktopManager"
			Write-Host -ForegroundColor Red "Error launching script 'Install RemoteDesktopManager': $($Error[0])"
			Write-Output ""
			}
	}

<#
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
#>

# Install Citrix PVS Target Device Client
IF ($SoftwareSelection.CitrixPVSTargetDevice_LTSR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix PVS Target Device LTSR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix PVS Target Device LTSR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix PVS Target Device LTSR': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix PVS Target Device Client
IF ($SoftwareSelection.CitrixPVSTargetDevice_CR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix PVS Target Device CR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix PVS Target Device CR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix PVS Target Device CR ': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix Server VDA LTSR
IF ($SoftwareSelection.CitrixServerVDA_LTSR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix Server VDA LTSR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix Server VDA LTSR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA LTSR': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix Server VDA PVS LTSR
IF ($SoftwareSelection.CitrixServerVDA_PVS_LTSR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix Server VDA for PVS LTSR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix Server VDA for PVS LTSR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA for PVS LTSR': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix Server VDA CR/Cloud
IF ($SoftwareSelection.CitrixServerVDA_CR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix Server VDA CR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix Server VDA CR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA CR': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix Server VDA PVS CR/Cloud
IF ($SoftwareSelection.CitrixServerVDA_PVS_CR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix Server VDA for PVS CR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix Server VDA for PVS CR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA for PVS CR': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix Server VDA MCS LTSR
IF ($SoftwareSelection.CitrixServerVDA_MCS_LTSR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix Server VDA for MCS LTSR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix Server VDA for MCS LTSR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA for MCS LTSR': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix Server VDA MCS CR
IF ($SoftwareSelection.CitrixServerVDA_MCS_CR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix Server VDA for MCS CR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix Server VDA for MCS CR"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix Server VDA for MCS CR': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix WEM Agent
IF ($SoftwareSelection.CitrixWEM_Agent -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WEM Agent.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WEM Agent"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix WEM Agent': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix WEM Agent PVS
IF ($SoftwareSelection.CitrixWEM_Agent_PVS -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WEM Agent for PVS.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WEM Agent for PVS"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix WEM Agent for PVS': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix WEM Agent MCS
IF ($SoftwareSelection.CitrixWEM_Agent_MCS -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WEM Agent for MCS.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WEM Agent for MCS"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix WEM Agent for MCS': $($Error[0])"
			Write-Output ""
			}
	}

# Install Putty
IF ($SoftwareSelection.Putty -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Putty.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Putty"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Putty': $($Error[0])"
			Write-Output ""
			}
	}

# Install WinSCP
IF ($SoftwareSelection.WinSCP -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WinSCP.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WinSCP"
			Write-Host -ForegroundColor Red "Error in launching script 'Install WinSCP': $($Error[0])"
			Write-Output ""
			}
	}

# Install WinRAR
IF ($SoftwareSelection.WinRAR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WinRAR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WinSCP"
			Write-Host -ForegroundColor Red "Error in launching script 'Install WinSCP': $($Error[0])"
			Write-Output ""
			}
	}

# Install VMWareTools
IF ($SoftwareSelection.VMWareTools -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS VcRedist x64"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS VcRedist x64"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x64': $($Error[0])"
			Write-Output ""
			}	
		try {
			& "$SoftwareFolder\Install MS VcRedist x86"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS VcRedist x86"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x86': $($Error[0])"
			Write-Output ""
			}	
			& "$SoftwareFolder\Install VMWareTools.ps1"
	}
	
# Stop install log
Stop-Transcript

# Format install log
$Content = Get-Content -Path $InstallLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $InstallLog

Write-Output ""
Write-Host -ForegroundColor Cyan "Finished, please check if selected software is installed!"
$Updates = Get-Content -Path $InstallLog | Select-String -Pattern Installing
$Updates = ($Updates -replace ("Uninstalling","") -replace ("Installing","") | Select-Object -Unique) -join ","
$Updates = "Update" + $Updates
Write-Host -ForegroundColor Yellow "Copy summary for your documentation:"
$Updates
Write-Output ""

if ($noGUI -eq $False) {
    pause}