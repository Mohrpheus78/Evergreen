# ***************************************************************************
# D. Mohrmann, Cancom GmbH BU S&L, Twitter: @mohrpheus78
# Download Software packages with Evergreen powershell module
# ***************************************************************************

<#
.SYNOPSIS
This script downloads software packages if new versions are available.
		
.DESCRIPTION
The script uses the excellent Powershell Evergreen module from Aaron Parker, Bronson Magnan and Trond Eric Haarvarstein. 
To update a software package just switch from 0 to 1 in the section "Select software to download".
A new folder for every single package will be created, together with a Version file, a download date file and a log file. IF a new version is available the scriot checks
the version number and will update the package.

.NOTES
Many thanks to Aaron Parker, Bronson Magnan and Trond Eric Haarvarstein for the module!
https://github.com/aaronparker/Evergreen
Run as admin!
Version: 2.11.6
06/24: Changed internet connection check
06/25: Changed internet connection check
06/27: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 at the top of the script
07/04: Changed Adobe Reader update source (Evergreen)
07/25: Changed version check from pdf24Creator
07/27: Wrong URL for pdf24Creator, please remove all files from pdf24Creator folder before launching Updater again! Changed Citrix WorkspaceApp version check and always install MS Edge WebView updates, changed Adobe DC update check
11/21: Changed RemoteDesktopManager URL
11/22: Improved download check for alle apps, warning if app download fails
12/06: Changed MS SMSS to Nevergreen to get the current version, changed download url https://aka.ms/ssmsfullsetup
12/07: Office downloads corrected, better improved expand archive deviceTRUST and FSLogix, copy ADMX files to subfolder _ADMX
12/08: If -noGUI switch is used, there is no update check
12/13: Wrong download path for Citrix WorkspaceApp CR, Added Cisco WebEx VDI
15/12: Wrong download path for Citrix Files
02/01: Office download error, FoxIt-Reader version not found
02/01: Added MS Visual Redistributable packages
04/01: Added SplashScreen, check for SplashScreen Powershell module and load from GitHub of not present
05/01: Foxit Reader had wrong file extensionm changed to msi
11/01: Changed MS Visual Redistributable download url
02/16: No error message if Splashscreen cannot be loaded
03/23: Added ShareX
04/11: Added KeepassXC
04/24: Changed Oracle Java version check
04/26: Delete Office download data older 40 days, changed regex for Cisco WebEx VDI
05/30: Changed regex for pdf24Creator, changed WinSCP download type, changed PuTTY source to Evergreen
06/13: Changed RemoteDesktopManager URL, added MS EdgeWebView2 to Citrix WorkspaceApp LTSR
06/29: Changed Filezilla URL because of error 403
23/07/17: Added WinRAR de and en
23/09/04: Citrix Files corrected
23/09/11: WinRAR corrected 
23/09/18: Chrome corrected
23/09/29: MS Teams corrected
23/10/06: Better internet connection check
23/10/08: Changed Citrix VM Tools (not in Evergreen anymore), added Citrix XenCenter
23/10/11: Added MS .NET Desktop Runtime as a requirement for Citrix WorkspaceApp CR
23/11/20: Second internet connection check
23/11/22: Added MS .NET Desktop Runtime 6.0.20 as a requirement for Citrix WorkspaceApp CR
23/12/05: Fixed FSLogix download and expand archive error
24/01/23: Version check for XenCenter and Citrix VM Tools corrected
24/02/15: New FSLogix version
24/04/10: Changed MS Teams classic
24/04/25: Added MS .NET DesktopRuntime 8.4.0 for Remote Desktop Manager
24/05/02: Fixed KeePass, 7-Zip and OneDrive
24/07/22: Fixed Citrix WorkspaceApp, Sharefile, 7-Zip and VLC Player, added NEW MS Teams 2.x
24/07/23: Fixed FileZilla, replaced openJDK with Microsoft openJDK 
24/07/23: Added Zoom VDI client and Citrix HDX plugin, added ControlUp console and ControlUp DX client for Windows
24/08/26: Changed Citrix WorkspaceApp LTSR (.NET Desktop runtime)
24/09/12: Fix for Chrome version bug, version now provided by PatchmyPC
24/10/11: Changed WorkspaceApp LTSR .NET Desktop Runtime to version 8.0.10, added Teams 2.0 logon script
24/11/07: Changed CiscoWebEx, currently not available
#>


Param (
		[Parameter(
            HelpMessage='Start the Gui to select the Software',
            ValuefromPipelineByPropertyName = $true
        )]
        [switch]$noGUI
    
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

# =======================================================================
#                        Add shared_assemblies                          #
# =======================================================================

try {
	[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
	# Mahapps Library
	[System.Reflection.Assembly]::LoadFrom("$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen\assembly\MahApps.Metro.dll")       | out-null
	[System.Reflection.Assembly]::LoadFrom("$ENV:ProgramFiles\WindowsPowershell\Modules\SplashScreen\assembly\System.Windows.Interactivity.dll") | out-null
}
catch {
	$SplashScreen = $False
}

# =======================================================================
#                            Splash Screen                              #
# =======================================================================
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
				<Label Content="Software-Updater (Powered by Evergreen-Module)" Margin="5,0,0,0" Foreground="White" Height="50"  FontSize="25"/>
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

# FUNCTION Download progress
#========================================================================================================================================

function Get-FileFromWeb {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$URL,
  
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$File 
    )
    Begin {
        function Show-Progress {
            param (
                # Enter total value
                [Parameter(Mandatory)]
                [Single]$TotalValue,
        
                # Enter current value
                [Parameter(Mandatory)]
                [Single]$CurrentValue,
        
                # Enter custom progresstext
                [Parameter(Mandatory)]
                [string]$ProgressText,
        
                # Enter value suffix
                [Parameter()]
                [string]$ValueSuffix,
        
                # Enter bar lengh suffix
                [Parameter()]
                [int]$BarSize = 40,

                # show complete bar
                [Parameter()]
                [switch]$Complete
            )
            
            # calc %
            $percent = $CurrentValue / $TotalValue
            $percentComplete = $percent * 100
            if ($ValueSuffix) {
                $ValueSuffix = " $ValueSuffix" # add space in front
            }
            if ($psISE) {
                Write-Progress "$ProgressText $CurrentValue$ValueSuffix of $TotalValue$ValueSuffix" -id 0 -percentComplete $percentComplete            
            }
            else {
                # build progressbar with string function
                $curBarSize = $BarSize * $percent
                $progbar = ""
                $progbar = $progbar.PadRight($curBarSize,[char]9608)
                $progbar = $progbar.PadRight($BarSize,[char]9617)
        
                if (!$Complete.IsPresent) {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($CurrentValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"
                }
                else {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($TotalValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"                    
                }                
            }   
        }
    }
    Process {
        try {
            $storeEAP = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
        
            # invoke request
            $request = [System.Net.HttpWebRequest]::Create($URL)
            $response = $request.GetResponse()
  
            if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
                throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'."
            }
  
            if($File -match '^\.\\') {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") ($File -Split '^\.')[1]
            }
            
            if($File -and !(Split-Path $File)) {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") $File
            }

            if ($File) {
                $fileDirectory = $([System.IO.Path]::GetDirectoryName($File))
                if (!(Test-Path($fileDirectory))) {
                    [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
                }
            }

            [long]$fullSize = $response.ContentLength
            $fullSizeMB = $fullSize / 1024 / 1024
  
            # define buffer
            [byte[]]$buffer = new-object byte[] 1048576
            [long]$total = [long]$count = 0
  
            # create reader / writer
            $reader = $response.GetResponseStream()
            $writer = new-object System.IO.FileStream $File, "Create"
  
            # start download
            $finalBarCount = 0 #show final bar only one time
            do {
          
                $count = $reader.Read($buffer, 0, $buffer.Length)
          
                $writer.Write($buffer, 0, $count)
              
                $total += $count
                $totalMB = $total / 1024 / 1024
          
                if ($fullSize -gt 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "Downloading $($File.Name)" -ValueSuffix "MB"
                }

                if ($total -eq $fullSize -and $count -eq 0 -and $finalBarCount -eq 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "Downloading $($File.Name)" -ValueSuffix "MB" -Complete
                    $finalBarCount++
                    #Write-Host "$finalBarCount"
                }

            } while ($count -gt 0)
        }
  
        catch {
        
            $ExeptionMsg = $_.Exception.Message
            Write-Host "Download breaks with error : $ExeptionMsg"
        }
  
        finally {
            # cleanup
            if ($reader) { $reader.Close() }
            if ($writer) { $writer.Flush(); $writer.Close() }
        
            $ErrorActionPreference = $storeEAP
            [GC]::Collect()
        }    
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
    $Form.ClientSize = New-Object System.Drawing.Point(970,560)
    $Form.text = "Software-Updater"
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
    $AdobeReaderDCBoxUpdate.text = "Adobe Reader DC MUI x86"
    $AdobeReaderDCBoxUpdate.width = 95
    $AdobeReaderDCBoxUpdate.height = 20
    $AdobeReaderDCBoxUpdate.autosize = $true
    $AdobeReaderDCBoxUpdate.location = New-Object System.Drawing.Point(11,95)
    $form.Controls.Add($AdobeReaderDCBoxUpdate)
	$AdobeReaderDCBoxUpdate.Checked = $SoftwareSelection.AdobeReaderDC_MUI
	
	# AdobeReaderDCx64 Checkbox
    $AdobeReaderDCx64BoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCx64BoxUpdate.text = "Adobe Reader DC MUI x64"
    $AdobeReaderDCx64BoxUpdate.width = 95
    $AdobeReaderDCx64BoxUpdate.height = 20
    $AdobeReaderDCx64BoxUpdate.autosize = $true
    $AdobeReaderDCx64BoxUpdate.location = New-Object System.Drawing.Point(11,120)
    $form.Controls.Add($AdobeReaderDCx64BoxUpdate)
	$AdobeReaderDCx64BoxUpdate.Checked = $SoftwareSelection.AdobeReaderDCx64_MUI

    # BISF Checkbox
    $BISFBox = New-Object system.Windows.Forms.CheckBox
    $BISFBox.text = "BIS-F"
    $BISFBox.width = 95
    $BISFBox.height = 20
    $BISFBox.autosize = $true
    $BISFBox.location = New-Object System.Drawing.Point(11,145)
    $form.Controls.Add($BISFBox)
	$BISFBox.Checked = $SoftwareSelection.BISF
	
	# FSLogix Checkbox
    $FSLogixBox = New-Object system.Windows.Forms.CheckBox
    $FSLogixBox.text = "FSLogix"
    $FSLogixBox.width = 95
    $FSLogixBox.height = 20
    $FSLogixBox.autosize = $true
    $FSLogixBox.location = New-Object System.Drawing.Point(11,170)
    $form.Controls.Add($FSLogixBox)
	$FSLogixBox.Checked = $SoftwareSelection.FSLogix

    # GoogleChrome Checkbox
    $GoogleChromeBox = New-Object system.Windows.Forms.CheckBox
    $GoogleChromeBox.text = "Google Chrome"
    $GoogleChromeBox.width = 95
    $GoogleChromeBox.height = 20
    $GoogleChromeBox.autosize = $true
    $GoogleChromeBox.location = New-Object System.Drawing.Point(11,195)
    $form.Controls.Add($GoogleChromeBox)
	$GoogleChromeBox.Checked = $SoftwareSelection.GoogleChrome

    # Citrix WorkspaceApp_Current_Release Checkbox
    $WorkspaceApp_CRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CRBox.text = "Citrix WorkspaceApp CR"
    $WorkspaceApp_CRBox.width = 95
    $WorkspaceApp_CRBox.height = 20
    $WorkspaceApp_CRBox.autosize = $true
    $WorkspaceApp_CRBox.location = New-Object System.Drawing.Point(11,220)
    $form.Controls.Add($WorkspaceApp_CRBox)
	$WorkspaceApp_CRBox.Checked = $SoftwareSelection.WorkspaceApp_CR

    # Citrix WorkspaceApp_LTSR_Release Checkbox
    $WorkspaceApp_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSRBox.text = "Citrix WorkspaceApp LTSR"
    $WorkspaceApp_LTSRBox.width = 95
    $WorkspaceApp_LTSRBox.height = 20
    $WorkspaceApp_LTSRBox.autosize = $true
    $WorkspaceApp_LTSRBox.location = New-Object System.Drawing.Point(11,245)
    $form.Controls.Add($WorkspaceApp_LTSRBox)
	$WorkspaceApp_LTSRBox.Checked = $SoftwareSelection.WorkspaceApp_LTSR
	
	# Citrix VM Tools Checkbox
    $Citrix_VMToolsBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_VMToolsBox.text = "Citrix VM Tools (Windows)"
    $Citrix_VMToolsBox.width = 95
    $Citrix_VMToolsBox.height = 20
    $Citrix_VMToolsBox.autosize = $true
    $Citrix_VMToolsBox.location = New-Object System.Drawing.Point(11,270)
    $form.Controls.Add($Citrix_VMToolsBox)
	$Citrix_VMToolsBox.Checked = $SoftwareSelection.CitrixVMTools
	
	# Citrix XenCenter Checkbox
    $Citrix_XenCenterBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_XenCenterBox.text = "Citrix XenCenter"
	$Citrix_XenCenterBox.width = 95
    $Citrix_XenCenterBox.height = 20
    $Citrix_XenCenterBox.autosize = $true
    $Citrix_XenCenterBox.location = New-Object System.Drawing.Point(11,295)
    $form.Controls.Add($Citrix_XenCenterBox)
	$Citrix_XenCenterBox.Checked = $SoftwareSelection.CitrixXenCenter
	
	# Sharefile Checkbox
    $SharefileBox = New-Object system.Windows.Forms.CheckBox
    $SharefileBox.text = "Citrix Sharefile"
    $SharefileBox.width = 95
    $SharefileBox.height = 20
    $SharefileBox.autosize = $true
    $SharefileBox.location = New-Object System.Drawing.Point(11,320)
    $form.Controls.Add($SharefileBox)
	$SharefileBox.Checked = $SoftwareSelection.Sharefile
	
	# VMWareTools Checkbox
    $VMWareToolsBox = New-Object system.Windows.Forms.CheckBox
    $VMWareToolsBox.text = "VMWare Tools"
    $VMWareToolsBox.width = 95
    $VMWareToolsBox.height = 20
    $VMWareToolsBox.autosize = $true
    $VMWareToolsBox.location = New-Object System.Drawing.Point(11,345)
    $form.Controls.Add($VMWareToolsBox)
	$VMWareToolsBox.Checked = $SoftwareSelection.VMWareTools

    # Remote Desktop Manager Checkbox
    $RemoteDesktopManagerBox = New-Object system.Windows.Forms.CheckBox
    $RemoteDesktopManagerBox.text = "Remote Desktop Manager Free"
    $RemoteDesktopManagerBox.width = 95
    $RemoteDesktopManagerBox.height = 20
    $RemoteDesktopManagerBox.autosize = $true
    $RemoteDesktopManagerBox.location = New-Object System.Drawing.Point(11,370)
    $form.Controls.Add($RemoteDesktopManagerBox)
	$RemoteDesktopManagerBox.Checked = $SoftwareSelection.RemoteDesktopManager

    # mRemoteNG Checkbox
    $mRemoteNGBox = New-Object system.Windows.Forms.CheckBox
    $mRemoteNGBox.text = "mRemoteNG"
    $mRemoteNGBox.width = 95
    $mRemoteNGBox.height = 20
    $mRemoteNGBox.autosize = $true
    $mRemoteNGBox.location = New-Object System.Drawing.Point(11,395)
    $form.Controls.Add($mRemoteNGBox)
	$mRemoteNGBox.Checked = $SoftwareSelection.mRemoteNG
	
	# WinSCP Checkbox
    $WinSCPBox = New-Object system.Windows.Forms.CheckBox
    $WinSCPBox.text = "WinSCP"
    $WinSCPBox.width = 95
    $WinSCPBox.height = 20
    $WinSCPBox.autosize = $true
    $WinSCPBox.location = New-Object System.Drawing.Point(11,420)
    $form.Controls.Add($WinSCPBox)
	$WinSCPBox.Checked = $SoftwareSelection.WinSCP
	
	# Putty Checkbox
    $PuttyBox = New-Object system.Windows.Forms.CheckBox
    $PuttyBox.text = "Putty"
    $PuttyBox.width = 95
    $PuttyBox.height = 20
    $PuttyBox.autosize = $true
    $PuttyBox.location = New-Object System.Drawing.Point(11,445)
    $form.Controls.Add($PuttyBox)
	$PuttyBox.Checked = $SoftwareSelection.Putty

    # MS365 Apps Semi Annual Channel Checkbox
    $MS365AppsBox_SAC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_SAC.text = "Microsoft 365 Apps (x64/Semi Annual Channel)"
    $MS365AppsBox_SAC.width = 95
    $MS365AppsBox_SAC.height = 20
    $MS365AppsBox_SAC.autosize = $true
    $MS365AppsBox_SAC.location = New-Object System.Drawing.Point(250,45)
    $form.Controls.Add($MS365AppsBox_SAC)
	$MS365AppsBox_SAC.Checked = $SoftwareSelection.MS365Apps_SAC
	
	# MS365 Apps Monthly Enterprise Channel Checkbox
    $MS365AppsBox_MEC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_MEC.text = "Microsoft 365 Apps (x64/Monthly Enterprise Channel)"
    $MS365AppsBox_MEC.width = 95
    $MS365AppsBox_MEC.height = 20
    $MS365AppsBox_MEC.autosize = $true
    $MS365AppsBox_MEC.location = New-Object System.Drawing.Point(250,70)
    $form.Controls.Add($MS365AppsBox_MEC)
	$MS365AppsBox_MEC.Checked = $SoftwareSelection.MS365Apps_MEC

	# MS Office2019 Checkbox
    $MSOffice2019Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2019Box.text = "Microsoft Office 2019 (x64/Perpetual VL)"
    $MSOffice2019Box.width = 95
    $MSOffice2019Box.height = 20
    $MSOffice2019Box.autosize = $true
    $MSOffice2019Box.location = New-Object System.Drawing.Point(250,95)
    $form.Controls.Add($MSOffice2019Box)
	$MSOffice2019Box.Checked = $SoftwareSelection.MSOffice2019
	
	# MS Office2021 Checkbox
    $MSOffice2021Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2021Box.text = "Microsoft Office 2021 (x64/Perpetual VL)"
    $MSOffice2021Box.width = 95
    $MSOffice2021Box.height = 20
    $MSOffice2021Box.autosize = $true
    $MSOffice2021Box.location = New-Object System.Drawing.Point(250,120)
    $form.Controls.Add($MSOffice2021Box)
	$MSOffice2021Box.Checked = $SoftwareSelection.MSOffice2021
	
	# MS Sysinternals Checkbox
    $MSSysinternalsBox = New-Object system.Windows.Forms.CheckBox
    $MSSysinternalsBox.text = "Microsoft Sysinternals Suite"
    $MSSysinternalsBox.width = 95
    $MSSysinternalsBox.height = 20
    $MSSysinternalsBox.autosize = $true
    $MSSysinternalsBox.location = New-Object System.Drawing.Point(250,145)
    $form.Controls.Add($MSSysinternalsBox)
	$MSSysinternalsBox.Checked = $SoftwareSelection.MSSysinternals
	
    # MS Edge Checkbox
    $MSEdgeBox = New-Object system.Windows.Forms.CheckBox
    $MSEdgeBox.text = "Microsoft Edge (Stable Channel)"
    $MSEdgeBox.width = 95
    $MSEdgeBox.height = 20
    $MSEdgeBox.autosize = $true
    $MSEdgeBox.location = New-Object System.Drawing.Point(250,170)
    $form.Controls.Add($MSEdgeBox)
	$MSEdgeBox.Checked = $SoftwareSelection.MSEdge

    # MS OneDrive Checkbox
    $MSOneDriveBox = New-Object system.Windows.Forms.CheckBox
    $MSOneDriveBox.text = "Microsoft OneDrive (Machine-Based Install)"
    $MSOneDriveBox.width = 95
    $MSOneDriveBox.height = 20
    $MSOneDriveBox.autosize = $true
    $MSOneDriveBox.location = New-Object System.Drawing.Point(250,195)
    $form.Controls.Add($MSOneDriveBox)
	$MSOneDriveBox.Checked = $SoftwareSelection.MSOneDrive

    # MS Teams Checkbox
    $MSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $MSTeamsBox.text = "Microsoft Teams (Machine-Based Install)"
    $MSTeamsBox.width = 95
    $MSTeamsBox.height = 20
    $MSTeamsBox.autosize = $true
    $MSTeamsBox.location = New-Object System.Drawing.Point(250,220)
    $form.Controls.Add($MSTeamsBox)
	$MSTeamsBox.Checked = $SoftwareSelection.MSTeams
	
	# NEW MS Teams Checkbox
    $NEWMSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $NEWMSTeamsBox.text = "Microsoft Teams 2.x (Boostrapper MSIX)"
    $NEWMSTeamsBox.width = 95
    $NEWMSTeamsBox.height = 20
    $NEWMSTeamsBox.autosize = $true
    $NEWMSTeamsBox.location = New-Object System.Drawing.Point(250,245)
    $form.Controls.Add($NEWMSTeamsBox)
	$NEWMSTeamsBox.Checked = $SoftwareSelection.NEWMSTeams
	
	 # MS Powershell Checkbox
    $MSPowershellBox = New-Object system.Windows.Forms.CheckBox
    $MSPowershellBox.text = "Microsoft Powershell"
    $MSPowershellBox.width = 95
    $MSPowershellBox.height = 20
    $MSPowershellBox.autosize = $true
    $MSPowershellBox.location = New-Object System.Drawing.Point(250,270)
    $form.Controls.Add($MSPowershellBox)
	$MSPowershellBox.Checked = $SoftwareSelection.MSPowershell
	
	# MS DotNet Checkbox
    $MSDotNetBox = New-Object system.Windows.Forms.CheckBox
    $MSDotNetBox.text = "Microsoft .Net Desktop Runtime"
    $MSDotNetBox.width = 95
    $MSDotNetBox.height = 20
    $MSDotNetBox.autosize = $true
    $MSDotNetBox.location = New-Object System.Drawing.Point(250,295)
    $form.Controls.Add($MSDotNetBox)
	$MSDotNetBox.Checked = $SoftwareSelection.MSDotNetDesktopRuntime
	
	# MS SQL Management Studio EN Checkbox
    $MSSQLManagementStudioENBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioENBox.text = "Microsoft SQL Management Studio EN"
    $MSSQLManagementStudioENBox.width = 95
    $MSSQLManagementStudioENBox.height = 20
    $MSSQLManagementStudioENBox.autosize = $true
    $MSSQLManagementStudioENBox.location = New-Object System.Drawing.Point(250,320)
    $form.Controls.Add($MSSQLManagementStudioENBox)
	$MSSQLManagementStudioENBox.Checked = $SoftwareSelection.MSSsmsEN
	
	# MS SQL Management Studio DE Checkbox
    $MSSQLManagementStudioDEBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioDEBox.text = "Microsoft SQL Management Studio DE"
    $MSSQLManagementStudioDEBox.width = 95
    $MSSQLManagementStudioDEBox.height = 20
    $MSSQLManagementStudioDEBox.autosize = $true
    $MSSQLManagementStudioDEBox.location = New-Object System.Drawing.Point(250,345)
    $form.Controls.Add($MSSQLManagementStudioDEBox)
	$MSSQLManagementStudioDEBox.Checked = $SoftwareSelection.MSSsmsDE
	
	# MS VcRedist Checkbox
    $VcRedistBox = New-Object system.Windows.Forms.CheckBox
    $VcRedistBox.text = "Microsoft Visual C++ Redistributable"
    $VcRedistBox.width = 95
    $VcRedistBox.height = 20
    $VcRedistBox.autosize = $true
    $VcRedistBox.location = New-Object System.Drawing.Point(250,370)
    $form.Controls.Add($VcRedistBox)
	$VcRedistBox.Checked = $SoftwareSelection.VcRedist
	
	# MicrosoftOpenJDK Checkbox
    $MicrosoftOpenJDKBox = New-Object system.Windows.Forms.CheckBox
    $MicrosoftOpenJDKBox.text = "Microsoft OpenJDK 21"
    $MicrosoftOpenJDKBox.width = 95
    $MicrosoftOpenJDKBox.height = 20
    $MicrosoftOpenJDKBox.autosize = $true
    $MicrosoftOpenJDKBox.location = New-Object System.Drawing.Point(250,395)
    $form.Controls.Add($MicrosoftOpenJDKBox)
	$MicrosoftOpenJDKBox.Checked =  $SoftwareSelection.MicrosoftOpenJDK
	
	# OracleJava8 x64 Checkbox
    $OracleJava8Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8Box.text = "Oracle Java 8/x64"
    $OracleJava8Box.width = 95
    $OracleJava8Box.height = 20
    $OracleJava8Box.autosize = $true
    $OracleJava8Box.location = New-Object System.Drawing.Point(250,420)
    $form.Controls.Add($OracleJava8Box)
	$OracleJava8Box.Checked =  $SoftwareSelection.OracleJava8
	
	# OracleJava8 x86 Checkbox
    $OracleJava8_32Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8_32Box.text = "Oracle Java 8/x86"
    $OracleJava8_32Box.width = 95
    $OracleJava8_32Box.height = 20
    $OracleJava8_32Box.autosize = $true
    $OracleJava8_32Box.location = New-Object System.Drawing.Point(250,445)
    $form.Controls.Add($OracleJava8_32Box)
	$OracleJava8_32Box.Checked =  $SoftwareSelection.OracleJava8_32
	
	# deviceTRUST CheckBox
    $deviceTRUSTBox = New-Object system.Windows.Forms.CheckBox
    $deviceTRUSTBox.text = "deviceTRUST"
    $deviceTRUSTBox.width = 95
    $deviceTRUSTBox.height = 20
    $deviceTRUSTBox.autosize = $true
    $deviceTRUSTBox.location = New-Object System.Drawing.Point(685,45)
    $form.Controls.Add($deviceTRUSTBox)
	$deviceTRUSTBox.Checked = $SoftwareSelection.deviceTRUST
		
	# VLCPlayer Checkbox
    $VLCPlayerBox = New-Object system.Windows.Forms.CheckBox
    $VLCPlayerBox.text = "VLC Player"
    $VLCPlayerBox.width = 95
    $VLCPlayerBox.height = 20
    $VLCPlayerBox.autosize = $true
    $VLCPlayerBox.location = New-Object System.Drawing.Point(685,70)
    $form.Controls.Add($VLCPlayerBox)
	$VLCPlayerBox.Checked =  $SoftwareSelection.VLCPlayer
	
	# FileZilla Checkbox
    $FileZillaBox = New-Object system.Windows.Forms.CheckBox
    $FileZillaBox.text = "FileZilla Client"
    $FileZillaBox.width = 95
    $FileZillaBox.height = 20
    $FileZillaBox.autosize = $true
    $FileZillaBox.location = New-Object System.Drawing.Point(685,95)
    $form.Controls.Add($FileZillaBox)
	$FileZillaBox.Checked =  $SoftwareSelection.FileZilla
	
	# KeePass Checkbox
    $KeePassBox = New-Object system.Windows.Forms.CheckBox
    $KeePassBox.text = "KeePass"
    $KeePassBox.width = 95
    $KeePassBox.height = 20
    $KeePassBox.autosize = $true
    $KeePassBox.location = New-Object System.Drawing.Point(685,120)
    $form.Controls.Add($KeePassBox)
	$KeePassBox.Checked = $SoftwareSelection.KeePass
	
	# KeePassXC Checkbox
    $KeePassXCBox = New-Object system.Windows.Forms.CheckBox
    $KeePassXCBox.text = "KeePassXC"
    $KeePassXCBox.width = 95
    $KeePassXCBox.height = 20
    $KeePassXCBox.autosize = $true
    $KeePassXCBox.location = New-Object System.Drawing.Point(685,145)
    $form.Controls.Add($KeePassXCBox)
	$KeePassXCBox.Checked = $SoftwareSelection.KeePassXC
	
	# IGEL Universal Management Suite Checkbox
    $IGELUniversalManagementSuiteBox = New-Object system.Windows.Forms.CheckBox
    $IGELUniversalManagementSuiteBox.text = "IGEL Universal Management Suite"
    $IGELUniversalManagementSuiteBox.width = 95
    $IGELUniversalManagementSuiteBox.height = 20
    $IGELUniversalManagementSuiteBox.autosize = $true
    $IGELUniversalManagementSuiteBox.location = New-Object System.Drawing.Point(685,170)
    $form.Controls.Add($IGELUniversalManagementSuiteBox)
	$IGELUniversalManagementSuiteBox.Checked = $SoftwareSelection.IGELUniversalManagementSuite
	
	# pdf24Creator Checkbox
    $pdf24CreatorBox = New-Object system.Windows.Forms.CheckBox
    $pdf24CreatorBox.text = "pdf24Creator"
    $pdf24CreatorBox.width = 95
    $pdf24CreatorBox.height = 20
    $pdf24CreatorBox.autosize = $true
    $pdf24CreatorBox.location = New-Object System.Drawing.Point(685,195)
    $form.Controls.Add($pdf24CreatorBox)
	$pdf24CreatorBox.Checked =  $SoftwareSelection.pdf24Creator
	
	# FoxItReader Checkbox
    $FoxItReaderBox = New-Object system.Windows.Forms.CheckBox
    $FoxItReaderBox.text = "FoxIt PDF Reader"
    $FoxItReaderBox.width = 95
    $FoxItReaderBox.height = 20
    $FoxItReaderBox.autosize = $true
    $FoxItReaderBox.location = New-Object System.Drawing.Point(685,220)
    $form.Controls.Add($FoxItReaderBox)
	$FoxItReaderBox.Checked =  $SoftwareSelection.FoxItReader
	
	# ImageGlass Checkbox
    $ImageGlassBox = New-Object system.Windows.Forms.CheckBox
    $ImageGlassBox.text = "ImageGlass"
    $ImageGlassBox.width = 95
    $ImageGlassBox.height = 20
    $ImageGlassBox.autosize = $true
    $ImageGlassBox.location = New-Object System.Drawing.Point(685,245)
    $form.Controls.Add($ImageGlassBox)
	$ImageGlassBox.Checked =  $SoftwareSelection.ImageGlass
	
	# ShareX Checkbox
    $ShareXBox = New-Object system.Windows.Forms.CheckBox
    $ShareXBox.text = "ShareX"
    $ShareXBox.width = 95
    $ShareXBox.height = 20
    $ShareXBox.autosize = $true
    $ShareXBox.location = New-Object System.Drawing.Point(685,270)
    $form.Controls.Add($ShareXBox)
	$ShareXBox.Checked =  $SoftwareSelection.ShareX
	
	# Cisco WebEx VDI Plugin Checkbox
    $CiscoWebExVDIBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExVDIBox.text = "Cisco WebEx VDI Plugin"
	$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    $CiscoWebExVDIBox.Font = $CustomFont
    $CiscoWebExVDIBox.width = 95
    $CiscoWebExVDIBox.height = 20
    $CiscoWebExVDIBox.autosize = $true
    $CiscoWebExVDIBox.location = New-Object System.Drawing.Point(685,295)
    $form.Controls.Add($CiscoWebExVDIBox)
	$CiscoWebExVDIBox.Checked =  $SoftwareSelection.CiscoWebExVDI
	
	# WinRAR Checkbox
    $WinRARBox = New-Object system.Windows.Forms.CheckBox
    $WinRARBox.text = "WinRAR (de/en)"
    $WinRARBox.width = 95
    $WinRARBox.height = 20
    $WinRARBox.autosize = $true
    $WinRARBox.location = New-Object System.Drawing.Point(685,320)
    $form.Controls.Add($WinRARBox)
	$WinRARBox.Checked =  $SoftwareSelection.WinRAR
	
	# Greenshot Checkbox
    $GreenshotBox = New-Object system.Windows.Forms.CheckBox
    $GreenshotBox.text = "Greenshot"
    $GreenshotBox.width = 95
    $GreenshotBox.height = 20
    $GreenshotBox.autosize = $true
    $GreenshotBox.location = New-Object System.Drawing.Point(685,345)
    $form.Controls.Add($GreenshotBox)
	$GreenshotBox.Checked =  $SoftwareSelection.Greenshot
	
	# TreeSizeFree Checkbox
    $TreeSizeFreeBox = New-Object system.Windows.Forms.CheckBox
    $TreeSizeFreeBox.text = "TreeSize Free for Client OS"
    $TreeSizeFreeBox.width = 95
    $TreeSizeFreeBox.height = 20
    $TreeSizeFreeBox.autosize = $true
    $TreeSizeFreeBox.location = New-Object System.Drawing.Point(685,370)
    $form.Controls.Add($TreeSizeFreeBox)
	$TreeSizeFreeBox.Checked =  $SoftwareSelection.TreeSizeFree
	
	# ControlUpConsole Checkbox
    $ControlUpConsoleBox = New-Object system.Windows.Forms.CheckBox
    $ControlUpConsoleBox.text = "ControlUp Console"
    $ControlUpConsoleBox.width = 95
    $ControlUpConsoleBox.height = 20
    $ControlUpConsoleBox.autosize = $true
    $ControlUpConsoleBox.location = New-Object System.Drawing.Point(685,395)
    $form.Controls.Add($ControlUpConsoleBox)
	$ControlUpConsoleBox.Checked =  $SoftwareSelection.ControlUpConsole
	
	# ControlUpRemoteDX Checkbox
    $ControlUpRemoteDXBox = New-Object system.Windows.Forms.CheckBox
    $ControlUpRemoteDXBox.text = "ControlUp DX client"
    $ControlUpRemoteDXBox.width = 95
    $ControlUpRemoteDXBox.height = 20
    $ControlUpRemoteDXBox.autosize = $true
    $ControlUpRemoteDXBox.location = New-Object System.Drawing.Point(685,420)
    $form.Controls.Add($ControlUpRemoteDXBox)
	$ControlUpRemoteDXBox.Checked =  $SoftwareSelection.ControlUpRemoteDX
	
	<#
	# Cisco WebEx Desktop Checkbox
    $CiscoWebExDesktopBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExDesktopBox.text = "Cisco WebEx Desktop"
    $CiscoWebExDesktopBox.width = 95
    $CiscoWebExDesktopBox.height = 20
    $CiscoWebExDesktopBox.autosize = $true
    $CiscoWebExDesktopBox.location = New-Object System.Drawing.Point(250,420)
    $form.Controls.Add($CiscoWebExDesktopBox)
	$CiscoWebExDesktopBox.Checked =  $SoftwareSelection.CiscoWebExDesktop
	#>
	
	# Zoom Host Checkbox
    $ZoomVDIBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVDIBox.text = "Zoom VDI Host Installer"
	#$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    #$ZoomVDIBox.Font = $CustomFont
    $ZoomVDIBox.width = 95
    $ZoomVDIBox.height = 20
    $ZoomVDIBox.autosize = $true
    $ZoomVDIBox.location = New-Object System.Drawing.Point(685,445)
    $form.Controls.Add($ZoomVDIBox)
	$ZoomVDIBox.Checked =  $SoftwareSelection.ZoomVDI
	
	# Zoom Citrix client Checkbox
    $ZoomCitrixBox = New-Object system.Windows.Forms.CheckBox
    $ZoomCitrixBox.text = "Zoom Citrix HDX Media Plugin"
	#$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    #$ZoomCitrixBox.Font = $CustomFont
    $ZoomCitrixBox.width = 95
    $ZoomCitrixBox.height = 20
    $ZoomCitrixBox.autosize = $true
    $ZoomCitrixBox.location = New-Object System.Drawing.Point(685,470)
    $form.Controls.Add($ZoomCitrixBox)
	$ZoomCitrixBox.Checked =  $SoftwareSelection.ZoomCitrix
	
	
	<#
	# Zoom VMWare client Checkbox
    $ZoomVMWareBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVMWareBox.text = "Zoom VMWare Client (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    $ZoomVMWareBox.Font = $CustomFont
    $ZoomVMWareBox.width = 95
    $ZoomVMWareBox.height = 20
    $ZoomVMWareBox.autosize = $true
    $ZoomVMWareBox.location = New-Object System.Drawing.Point(685,295)
    $form.Controls.Add($ZoomVMWareBox)
	$ZoomVMWareBox.Checked =  $SoftwareSelection.ZoomVMWare
	#>
		
	# Select Button
    $SelectButton = New-Object system.Windows.Forms.Button
    $SelectButton.text = "Select all"
    $SelectButton.width = 110
    $SelectButton.height = 30
    $SelectButton.location = New-Object System.Drawing.Point(11,510)
    $SelectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $True
		$SevenZipBox.checked = $True
		$AdobeReaderDCBoxUpdate.checked = $True
		$AdobeReaderDCx64BoxUpdate.checked = $True
		$BISFBox.checked = $True
		$FSLogixBox.checked = $True
		$GoogleChromeBox.checked = $True
		$WorkspaceApp_CRBox.checked = $True
		$WorkspaceApp_LTSRBox.checked = $True
		$Citrix_VMToolsBox.checked = $True
		$Citrix_XenCenterBox.checked = $True
		$SharefileBox.checked = $True
		$VMWareToolsBox.checked = $True
		$RemoteDesktopManagerBox.checked = $True
		$deviceTRUSTBox.checked = $True
		$KeePassBox.checked = $True
		$KeePassBoxXC.checked = $True
		$IGELUniversalManagementSuiteBox.checked = $True
		$mRemoteNGBox.checked = $True
		$WinSCPBox.checked = $True
		$PuttyBox.checked = $True
		$MS365AppsBox_SAC.checked = $True
		$MS365AppsBox_MEC.checked = $True
		$MSOffice2019Box.checked = $True
		$MSOffice2021Box.checked = $True
		$MSEdgeBox.checked = $True
		$MSOneDriveBox.checked = $True
		$MSTeamsBox.checked = $True
		$NEWMSTeamsBox.checked = $True
		$MSPowershellBox.checked = $True
		$MSDotNetBox.checked = $True
		$MSSQLManagementStudioDEBox.checked = $True
		$MSSQLManagementStudioENBox.checked = $True
		$VcRedistBox.checked = $True
		$MSSysinternalsBox.checked = $True
		$MSWVDDesktopAgentBox.checked = $True
		$MSWVDRTCServiceBox.checked = $True
		$MSWVDBootLoaderBox.checked = $True
		$TreeSizeFreeBox.checked = $True
		$ControlUpConsoleBox.checked = $True
		$ControlUpConsoleBox.checked = $True
		$ZoomVDIBox.checked = $False
		$ZoomCitrixBox.checked = $False
		#$ZoomVMWareBox.checked = $False
		$VLCPlayerBox.checked = $True
		$FileZillaBox.checked = $True
		$CiscoWebExVDIBox.checked = $True
		$WinRARBox.checked = $True
		#$CiscoWebExDesktopBox.checked = $True
		$MicrosoftOpenJDKBox.checked = $True
		$GreenshotBox.checked = $True
		$OracleJava8Box.checked = $True
		$OracleJava8_32Box.checked = $True
		$ImageGlassBox.checked = $True
		$ShareXBox.checked = $True
		$pdf24CreatorBox.checked = $True	
		$FoxItReaderBox.checked = $True
		})
    $form.Controls.Add($SelectButton)
	
	# Unselect Button
    $UnselectButton = New-Object system.Windows.Forms.Button
    $UnselectButton.text = "Unselect all"
    $UnselectButton.width = 110
    $UnselectButton.height = 30
    $UnselectButton.location = New-Object System.Drawing.Point(131,510)
    $UnselectButton.Add_Click({
        $NotePadPlusPlusBox.Checked = $False
		$SevenZipBox.checked = $False
		$AdobeReaderDCBoxUpdate.checked = $False
		$AdobeReaderDCx64BoxUpdate.checked = $False
		$BISFBox.checked = $False
		$FSLogixBox.checked = $False
		$GoogleChromeBox.checked = $False
		$WorkspaceApp_CRBox.checked = $False
		$WorkspaceApp_LTSRBox.checked = $False
		$Citrix_VMToolsBox.checked = $False
		$Citrix_XenCenterBox.checked = $False
		$SharefileBox.checked = $False
		$VMWareToolsBox.checked = $False
		$RemoteDesktopManagerBox.checked = $False
		$deviceTRUSTBox.checked = $False
		$KeePassBox.checked = $False
		$KeePassXCBox.checked = $False
		$IGELUniversalManagementSuiteBox.checked = $False
		$mRemoteNGBox.checked = $False
		$WinSCPBox.checked = $False
		$PuttyBox.checked = $False
		$MS365AppsBox_SAC.checked = $False
		$MS365AppsBox_MEC.checked = $False
		$MSOffice2019Box.checked = $False
		$MSOffice2021Box.checked = $False
		$MSEdgeBox.checked = $False
		$MSOneDriveBox.checked = $False
		$MSTeamsBox.checked = $False
		$NEWMSTeamsBox.checked = $False
		$MSPowershellBox.checked = $False
		$MSDotNetBox.checked = $False
		$MSSQLManagementStudioDEBox.checked = $False
		$MSSQLManagementStudioENBox.checked = $False
		$VcRedistBox.checked = $False
		$MSSysinternalsBox.checked = $False
		$MSWVDDesktopAgentBox.checked = $False
		$MSWVDRTCServiceBox.checked = $False
		$MSWVDBootLoaderBox.checked = $False
		$TreeSizeFreeBox.checked = $False
		$ControlUpConsoleBox.checked = $False
		$ControlUpConsoleBox.checked = $False
		$ZoomVDIBox.checked = $False
		$ZoomCitrixBox.checked = $False
		#$ZoomVMWareBox.checked = $False
		$VLCPlayerBox.checked = $False
		$FileZillaBox.checked = $False
		$CiscoWebExVDIBox.checked = $False
		$WinRARBox.checked = $False
		#$CiscoWebExDesktopBox.checked = $False
		$MicrosoftOpenJDKBox.checked = $False
		$GreenshotBox.checked = $False
		$OracleJava8Box.checked = $False
		$OracleJava8_32Box.checked = $False
		$ImageGlassBox.checked = $False
		$ShareXBox.checked = $False
		$pdf24CreatorBox.checked = $False
		$FoxItReaderBox.checked = $False
		})
    $form.Controls.Add($UnselectButton)

    # OK Button
    $OKButton = New-Object system.Windows.Forms.Button
    $OKButton.text = "OK"
    $OKButton.width = 60
    $OKButton.height = 30
    $OKButton.location = New-Object System.Drawing.Point(271,510)
	#$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $OKButton.Add_Click({		
		$SoftwareSelection = New-Object PSObject
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NotepadPlusPlus" -Value $NotePadPlusPlusBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "SevenZip" -Value $SevenZipBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDC_MUI" -Value $AdobeReaderDCBoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCx64_MUI" -Value $AdobeReaderDCx64BoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "BISF" -Value $BISFBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FSLogix" -Value $FSLogixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "GoogleChrome" -Value $GoogleChromeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR" -Value $WorkspaceApp_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR" -Value $WorkspaceApp_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixVMTools" -Value $Citrix_VMToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixXenCenter" -Value $Citrix_XenCenterBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Sharefile" -Value $SharefileBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_SAC" -Value $MS365AppsBox_SAC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_MEC" -Value $MS365AppsBox_MEC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2019" -Value $MSOffice2019Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2021" -Value $MSOffice2021Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePass" -Value $KeePassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePassXC" -Value $KeePassXCBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "IGELUniversalManagementSuite" -Value $IGELUniversalManagementSuiteBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "mRemoteNG" -Value $mRemoteNGBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSEdge" -Value $MSEdgeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOneDrive" -Value $MSOneDriveBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeams" -Value $MSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NEWMSTeams" -Value $NEWMSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSPowershell" -Value $MSPowershellBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSDotNetDesktopRuntime" -Value $MSDotNetBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsEN" -Value $MSSQLManagementStudioENBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsDE" -Value $MSSQLManagementStudioDEBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VcRedist" -Value $VcRedistBox.checked -Force		
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSysinternals" -Value $MSSysinternalsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDDesktopAgent" -Value $MSWVDDesktopAgentBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDRTCService" -Value $MSWVDRTCServiceBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDBootLoader" -Value $MSWVDBootLoaderBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MicrosoftOpenJDK" -Value $MicrosoftOpenJDKBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Greenshot" -Value $GreenshotBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8" -Value $OracleJava8Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8_32" -Value $OracleJava8_32Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "TreeSizeFree" -Value $TreeSizeFreeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ControlUpConsole" -Value $ControlUpConsoleBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ControlUpRemoteDX" -Value $ControlUpRemoteDXBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVDI" -Value $ZoomVDIBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomCitrix" -Value $ZoomCitrixBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVMWare" -Value $ZoomVMWareBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VLCPlayer" -Value $VLCPlayerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FileZilla" -Value $FileZillaBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExVDI" -Value $CiscoWebExVDIBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinRAR" -Value $WinRARBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExDesktop" -Value $CiscoWebExDesktopBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "deviceTRUST" -Value $deviceTRUSTBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VMWareTools" -Value $VMWareToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RemoteDesktopManager" -Value $RemoteDesktopManagerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinSCP" -Value $WinSCPBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Putty" -Value $PuttyBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ImageGlass" -Value $ImageGlassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ShareX" -Value $ShareXBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "pdf24Creator" -Value $pdf24CreatorBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FoxItReader" -Value $FoxItReaderBox.checked -Force
	
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
    $CancelButton.location = New-Object System.Drawing.Point(341,510)
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

IF ($myWindowsPrincipal.IsInRole($adminRole))
   {
    # OK, runs as admin
    Write-Host "OK, script is running with Admin rights"
    Write-Output ""
	start-sleep -seconds 2
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
	[version]$EvergreenVersion = "2.11.6"
	$WebVersion = ""
	[bool]$NewerVersion = $false
	IF ($InternetCheck1 -eq "True" -or $InternetCheck2 -eq "True") {
		Write-Host -ForegroundColor Green "Internet access is working!"
		Write-Output ""
		start-sleep -seconds 2
		$WebResponseVersion = Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/Mohrpheus78/Evergreen/main/Evergreen-Software%20Updater.ps1"
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
		$message = "Do you want to cancel the update? The update script may be outdated!"
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

Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------- "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " Software-Updater (Powered by Evergreen-Module) "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed "    © D. Mohrmann - Cancom GmbH - BU S&L        "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------- "
Write-Output ""

Write-Host -ForegroundColor Cyan "Setting Variables"
Write-Output ""

# Variables
$SoftwareFolder = ("$PSScriptRoot" + "\" + "Software\")
$ErrorActionPreference = "SilentlyContinue"
#$WarningPreference = "Continue"
$SoftwareToUpdate = "$SoftwareFolder\Software-to-update.xml"

if ($noGUI -eq $False) {
Write-Host -Foregroundcolor Cyan "Current script version: $EvergreenVersion
Is there a newer Evergreen Script version?"
Write-Output ""
If ($NewerVersion -eq $false) {
        # No new version available
        Write-Host -Foregroundcolor Green "OK, script is newest version!"
        Write-Output ""
}
Else {
        # There is a new Evergreen Script Version
        Write-Host -Foregroundcolor Red "Attention! There is a new version $WebVersion of the Evergreen Updater!"
        Write-Output ""
		$wshell = New-Object -ComObject Wscript.Shell
            $AnswerPending = $wshell.Popup("Do you want to download the new version?",0,"New Version available",32+4)
            If ($AnswerPending -eq "6") {
				$update = @'
                Remove-Item -Path "$PSScriptRoot\Evergreen-Software Updater.ps1" -Force 
                Invoke-WebRequest -Uri https://raw.githubusercontent.com/Mohrpheus78/Evergreen/main/Evergreen-Software%20Updater.ps1 -OutFile ("$PSScriptRoot\" + "Evergreen-Software Updater.ps1")
                & "$PSScriptRoot\Evergreen-Software Updater.ps1"
'@
                $update > "$PSScriptRoot\UpdateUpdater.ps1"
                & "$PSScriptRoot\UpdateUpdater.ps1"
                BREAK
			}

}
}

# General update logfile
$Date = $Date = Get-Date -UFormat "%d.%m.%Y"
$UpdateLog = "$SoftwareFolder\_Update Logs\Software Updates $Date.log"
$ModulesUpdateLog = "$SoftwareFolder\_Update Logs\Modules Updates $Date.log"

# Import values (selected software) from XML file
if (Test-Path -Path $SoftwareToUpdate) {$SoftwareSelection = Import-Clixml $SoftwareToUpdate}


# Call Form
if ($noGUI -eq $False) {
gui_mode
}

# Disable progress bar while downloading
$ProgressPreference = 'SilentlyContinue'

# Install/Update Evergreen and Nevergreen modules
# Start logfile Modules Update Log

IF ($InternetCheck1 -eq "True" -or $InternetCheck2 -eq "True") {
	Start-Transcript $ModulesUpdateLog | Out-Null
	Write-Host -ForegroundColor Cyan "Installing/updating Evergreen and Nevergreen modules... please wait"
	Write-Output ""
	IF (!(Test-Path -Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget")) {
		Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
		}
	IF (!(Get-Module -ListAvailable -Name Evergreen)) {
		Install-Module Evergreen -Force | Import-Module Evergreen
		}
	IF (!(Get-Module -ListAvailable -Name Nevergreen)) {
		Install-Module Nevergreen -Force | Import-Module Nevergreen
		}
	IF (!(Get-Module -ListAvailable -Name VcRedist)) {
		Install-Module VcRedist -Force | Import-Module VcRedist
		
		}
	# Check for Updates
	$LocalEvergreenVersion = (Get-Module -Name Evergreen -ListAvailable | Select-Object -First 1).Version
	$CurrentEvergreenVersion = (Find-Module -Name Evergreen -Repository PSGallery).Version
	IF (($LocalEvergreenVersion -lt $CurrentEvergreenVersion)) {
		Update-Module Evergreen -force
	}

	$LocalNevergreenVersion = (Get-Module -Name Nevergreen -ListAvailable | Select-Object -First 1).Version
	$CurrentNevergreenVersion = (Find-Module -Name Nevergreen -Repository PSGallery).Version
	IF (($LocalNevergreenVersion -lt $CurrentNevergreenVersion)) {
		Update-Module Nevergreen -force
	}

	$LocalVcRedistVersion = (Get-Module -Name VcRedist -ListAvailable | Select-Object -First 1).Version
	$CurrentVcRedistVersion = (Find-Module -Name VcRedist -Repository PSGallery).Version
	IF (($LocalVcRedistVersion -lt $CurrentVcRedistVersion)) {
		Update-Module VcRedist -force
	}

	IF (!(Get-Module -ListAvailable -Name Evergreen)) {
		Write-Host -ForegroundColor Cyan "Evergreen module not found, check module installation!"
		BREAK
	}
	IF (!(Get-Module -ListAvailable -Name Nevergreen)) {
		Write-Host -ForegroundColor Cyan "Nevergreen module not found, check module installation!"
		BREAK
	}
	IF (!(Get-Module -ListAvailable -Name VcRedist)) {
		Write-Host -ForegroundColor Cyan "VcRedist module not found, check module installation!"
		BREAK
	}

	# Stop logfile Modules Update Log
	Stop-Transcript | Out-Null
	$Content = Get-Content -Path $ModulesUpdateLog | Select-Object -Skip 18
	Set-Content -Value $Content -Path $ModulesUpdateLog
}
ELSE {
	Write-Host -ForegroundColor Cyan "Powershell is NOT able to connect to the internet, the script will not update the Evergreen and Nevergreen Powershell modules!"
	Write-Output ""
}


# Start logfile Update Log
Start-Transcript $UpdateLog | Out-Null

# Import selection
$SoftwareSelection = Import-Clixml $SoftwareToUpdate
Write-Host -ForegroundColor Cyan "Import selection"
Write-Output ""

# Write-Output "Evergreen Version: $EvergreenVersion" | Out-File $UpdateLog -Append
Write-Host -ForegroundColor Cyan "Starting downloads..."
Write-Output ""

# Create ADMX subfolder
IF (!(Test-Path -Path "$SoftwareFolder\_ADMX")) {
	New-Item -Path "$SoftwareFolder\_ADMX" -Type Directory -EA SilentlyContinue | Out-Null
}


# Download RemoteDesktopManager
IF ($SoftwareSelection.RemoteDesktopManager -eq $true) {
	$Product = "RemoteDesktopManager"
	$PackageName = "RemoteDesktopManagerFree"
	Try {
	$URLVersionRDM = "https://devolutions.net/remote-desktop-manager/release-notes/free/"
	$webRequestRDM = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionRDM) -SessionVariable websession
	$regexAppVersionRDM = "\d\d\d\d\.\d\.\d\d\.\d+"
	$webVersionRDM = $webRequestRDM.RawContent | Select-String -Pattern $regexAppVersionRDM -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	[Version]$VersionRDM = $webVersionRDM.Trim("</td>").Trim("</td>")
	$URL = "https://cdn.devolutions.net/download/Setup.RemoteDesktopManager.$VersionRDM.msi"
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionRDM"
	Write-Host "Current Version: $CurrentVersion"
	IF (!(Test-Path "$SoftwareFolder\$Product\windowsdesktop-runtime-8.0.4-win-x64.exe")) {
		Try {
		Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/c1d08a81-6e65-4065-b606-ed1127a954d3/14fe55b8a73ebba2b05432b162ab3aa8/windowsdesktop-runtime-8.0.4-win-x64.exe" -OutFile "$SoftwareFolder\$Product\windowsdesktop-runtime-8.0.4-win-x64.exe"
		} catch {
		throw $_.Exception.Message
		}
	}
	IF ($VersionRDM) {
		IF ($VersionRDM -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionRDM.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionRDM"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionRDM"
		#Invoke-WebRequest -UseBasicParsing -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download pdf24Creator
IF ($SoftwareSelection.pdf24Creator -eq $true) {
	$Product = "pdf24Creator"
	$PackageName = "pdf24Creator"
	Try {
	$URLVersion = "https://creator.pdf24.org/listVersions.php"
	$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
	$regexAppVersionPDF2 = "\d\d\.\d\d\.\d+"
    $webVersionPDF24 = $webRequest.RawContent | Select-String -Pattern $regexAppVersionPDF2 -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1 -Skip 1
    [version]$VersionPDF24 = $webVersionPDF24
    $regexAppVersionDL = "pdf24-creator-.*.msi"
    $webVersionPDF24 = $webRequest.RawContent | Select-String -Pattern $regexAppVersionDL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    $VersionPDF24DL = $webVersionPDF24.Split('"<')[0]
    $URL = "https://download.pdf24.org/$VersionPDF24DL"
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionPDF24"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionPDF24) {
		IF ($VersionPDF24 -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionPDF24.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionPDF24"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionPDF24"
		#Invoke-WebRequest -UseBasicParsing -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Notepad ++
IF ($SoftwareSelection.NotePadPlusPlus -eq $true) {
    $Product = "NotePadPlusPlus"
	$PackageName = "NotePadPlusPlus_x64"
	Try {
		$Notepad = Get-EvergreenApp -Name NotepadPlusPlus | Where-Object {$_.Architecture -eq "x64" -and $_.URI -match ".exe"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
	}
	IF ($NotePad.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $Notepad.Version
		}
	# $Version = $Version.substring(1)
	$URL = $Notepad.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Get-ChildItem "$SoftwareFolder\$Product\" -Include *.exe, Version.txt, Download* -Recurse | Remove-Item -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Get-ChildItem "$SoftwareFolder\$Product\" -Include *.exe, Version.txt, Download* -Recurse | Remove-Item -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}



# Download Chrome
IF ($SoftwareSelection.GoogleChrome -eq $true) {
	$Product = "Google Chrome"
	$PackageName = "GoogleChromeStandaloneEnterprise64"
	Try {
	$Chrome = Get-EvergreenApp -Name GoogleChrome | Where-Object {$_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	# $Version = $Chrome.Version
	$URLChrome = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
	$webRequestChrome = Invoke-WebRequest -UseBasicParsing -Uri ($URLChrome) -SessionVariable websession
	$regexAppChrome = "<ChromeVer>([A-Za-z0-9]+(\.[A-Za-z0-9]+)+)</ChromeVer>"
	$UrlChrome = $webRequestChrome.RawContent | Select-String -Pattern $regexAppChrome -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    $UrlChrome = $UrlChrome.Split('"<')
    $UrlChrome = $UrlChrome.Split('">')
	$VersionChrome = $UrlChrome[2]
	$URL = $Chrome.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionChrome"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionChrome) {
		IF (!($CurrentVersion -eq $VersionChrome)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionChrome.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionChrome"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionChrome"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Edge
IF ($SoftwareSelection.MSEdge -eq $true) {
	$Product = "MS Edge"
	$PackageName = "MicrosoftEdgeEnterpriseX64"
	Try {
	$Edge = Get-EvergreenApp -Name MicrosoftEdge | Where-Object {$_.Platform -eq "Windows" -and $_.Channel -eq "stable" -and $_.Architecture -eq "x64" -and $_.Release -eq "Enterprise"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $Edge.Version
	$URL = $Edge.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue 
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS  | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download VLC Player
IF ($SoftwareSelection.VLCPlayer -eq $true) {
	$Product = "VLC Player"
	$PackageName = "VLC-Player"
	Try {
	$VLC = Get-EvergreenApp -Name VideoLanVlcPlayer | Where-Object {$_.Architecture -eq "x64" -and $_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $VLC.Version
	$URL = $VLC.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product" 
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available" 
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download FileZilla Client
IF ($SoftwareSelection.FileZilla -eq $true) {
	$Product = "FileZilla"
	$PackageName = "FileZilla"
	$URLFilezilla = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
	$webRequestFilezilla = Invoke-WebRequest -UseBasicParsing -Uri ($URLFilezilla) -SessionVariable websession
	$regexAppFilezilla = "<FileZillax64Download>.*"
	$UrlFilezilla = $webRequestFilezilla.RawContent | Select-String -Pattern $regexAppFilezilla -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    $UrlFilezilla = $UrlFilezilla.Split('"<')
    $UrlFilezilla = $UrlFilezilla.Split('">')
	$UrlFilezilla = $UrlFilezilla[2]
	$FileZillaFileName = [System.IO.Path]::GetFileName($URLFilezilla)
	if ($FileZillaFileName -match '_([0-9.]+)_([a-zA-Z0-9-]+)\.exe') {
		$Version = $matches[1]
    }
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product" 
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available" 
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $UrlFilezilla -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging" 
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download BIS-F
IF ($SoftwareSelection.BISF -eq $true) {
	$Product = "BIS-F"
	$PackageName = "setup-BIS-F"
	Try {
	$BISF = Get-EvergreenApp -Name BISF -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($BISF.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {	
		[Version]$Version = $BISF.Version
		}
	$URL = $BISF.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.ps1, SubCall -Recurse
		Start-Transcript $LogPS
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.ps1, *.log, SubCall -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WorkspaceApp Current
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true) {
	$Product = "WorkspaceApp"
	$PackageName = "CitrixWorkspaceApp"
	Try {
	$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Stream -eq "Current"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[version]$Version = $WSA.Version
	$URL = $WSA.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product CR"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF (!(Test-Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\windowsdesktop-runtime-6.0.20-win-x86.exe")) {
			Try {
			Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/0413b619-3eb2-4178-a78e-8d1aafab1a01/5247f08ea3c13849b68074a2142fbf31/windowsdesktop-runtime-6.0.20-win-x86.exe" -OutFile "$SoftwareFolder\Citrix\$Product\Windows\Current\windowsdesktop-runtime-6.0.20-win-x86.exe"
			} catch {
			throw $_.Exception.Message
			}
		}
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\Current")) {New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\Windows\Current\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\Windows\Current\*" -Exclude "windowsdesktop-runtime-6.0.20-win-x86.exe" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version Current Release"
		Try {
		Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\Windows\Current\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Copy-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\CitrixWorkspaceApp.exe" -Destination "$SoftwareFolder\Citrix\$Product\Windows\Current\CitrixWorkspaceAppWeb.exe" | Out-Null
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Download Microsoft EdgeWebView2 Runtime
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true -or $SoftwareSelection.WorkspaceApp_LTSR -eq $true -or $SoftwareSelection.MSEdge -eq $true) {
	$Product = "MS Edge WebView2 Runtime"
	$PackageName = "MicrosoftEdgeWebView2RuntimeInstallerX64"
	Try {
	$MEWV2RT = Get-EvergreenApp -Name MicrosoftEdgeWebView2Runtime | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MEWV2RT.Version
	$URL = $MEWV2RT.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		if (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\Citrix\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version Current Release"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WorkspaceApp LTSR
IF ($SoftwareSelection.WorkspaceApp_LTSR -eq $true) {
	$Product = "WorkspaceApp"
	$PackageName = "CitrixWorkspaceApp"
	Try {
	$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Stream -eq "LTSR"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[version]$Version = $WSA.Version
	$URL = $WSA.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product LTSR"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF (!(Test-Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\windowsdesktop-runtime-8.0.10-win-x86.exe")) {
			Try {
			Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/9836a475-66af-47eb-a726-8046c47ce6d5/ccb7d60db407a6d022a856852ef9e763/windowsdesktop-runtime-8.0.10-win-x86.exe" -OutFile "$SoftwareFolder\Citrix\$Product\Windows\LTSR\windowsdesktop-runtime-8.0.10-win-x86.exe"
			} catch {
			throw $_.Exception.Message
			}
		}
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR")) {New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\Windows\LTSR\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\Windows\LTSR\*" -Exclude "windowsdesktop-runtime-8.0.10-win-x86.exe" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version LTSR Release"
		Try {
		Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\Windows\LTSR\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Copy-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\CitrixWorkspaceApp.exe" -Destination "$SoftwareFolder\Citrix\$Product\Windows\LTSR\CitrixWorkspaceAppWeb.exe" | Out-Null
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download 7-ZIP
IF ($SoftwareSelection.SevenZip -eq $true) {
	$Product = "7-Zip"
	$PackageName = "7-Zip_x64"
	Try {
	$7Zip = Get-NevergreenApp -Name 7zip | Where-Object {$_.Architecture -eq "x64" -and $_.Type -like "exe"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $7Zip.Version
	$URL = $7Zip.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Adobe Reader DC MUI Update
IF ($SoftwareSelection.AdobeReaderDC_MUI -eq $true) {
	$Product = "Adobe Reader DC MUI"
	$PackageName = "Adobe_DC_MUI_Update"
	Try {
	$Adobe = Get-EvergreenApp -Name AdobeAcrobatDC | Where-Object {$_.Architecture -eq "x86" -and $_.Type -eq "ReaderMUI"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product"
		}
	$Version = $Adobe.Version
	$URL = $Adobe.uri
	$InstallerType = "msp"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Adobe Reader DC MUI x64 Update
IF ($SoftwareSelection.AdobeReaderDCx64_MUI -eq $true) {
	$Product = "Adobe Reader DC x64 MUI"
	$PackageName = "Adobe_DC_MUI_x64_Update"
	Try {
		$Adobe = Get-EvergreenApp -Name AdobeAcrobatDC | Where-Object {$_.Architecture -eq "x64" -and $_.Type -eq "ReaderMUI"} -ErrorAction Stop
		} catch {
			Write-Warning "Failed to find update of $Product"
			}
		$Version = $Adobe.Version
		$URL = $Adobe.uri
		$InstallerType = "msp"
		$Source = "$PackageName" + "." + "$InstallerType"
		$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
		Write-Host -ForegroundColor Yellow "Download $Product"
		Write-Host "Download Version: $Version"
		Write-Host "Current Version: $CurrentVersion"
		IF ($Version) {
			IF (!($CurrentVersion -eq $Version)) {
			Write-Host -ForegroundColor Green "Update available"
			IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
			$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
			Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, *.log, Version.txt, Download* -Recurse
			Start-Transcript $LogPS | Out-Null
			New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
			Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
			Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
			#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
			Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
			Write-Host "Stop logging"
			IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
			Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
			Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
			}
			Stop-Transcript | Out-Null
			Write-Output ""
			}
			ELSE {
			Write-Host -ForegroundColor Yellow "No new version available"
			Write-Output ""
			}
		}
		ELSE {
			Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
			Write-Output ""
		}
	}


# Download FSLogix
IF ($SoftwareSelection.FSLogix -eq $true) {
	$Product = "FSLogix"
	$PackageName = "FSLogixAppsSetup"
	Try {
	$FSLogix = Get-EvergreenApp -Name MicrosoftFSLogixApps | Where-Object {$_.Channel -eq "Production"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $FSLogix.Version
	$URL = $FSLogix.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Install\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\Install")) {New-Item -Path "$SoftwareFolder\$Product\Install" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\Install\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\Install\*" -Recurse
		New-Item -Path "$SoftwareFolder\$Product\Install" -ItemType Directory -EA SilentlyContinue
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product\Install" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Install\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\Install\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		expand-archive -path "$SoftwareFolder\$Product\Install\FSLogixAppsSetup.zip" -destinationpath "$SoftwareFolder\$Product\Install"
		Remove-Item -Path "$SoftwareFolder\$Product\Install\Win32" -Force -Recurse
        $FSLogixDir = (Get-ChildItem -Path "$SoftwareFolder\$Product\Install" -Directory).Name
		start-sleep -Seconds 5
		Remove-Item -Path "$SoftwareFolder\$Product\Install\FSLogixAppsSetup.zip" -Force
		Move-Item -Path "$SoftwareFolder\$Product\Install\$FSLogixDir\Release\*" -Destination "$SoftwareFolder\$Product\Install"
		Get-ChildItem -Path "$SoftwareFolder\$Product\Install\$FSLogixDir\*.adm*" | Copy-Item -Destination (New-Item -Type Directory -Force ("$SoftwareFolder\_ADMX\FSLogix")) -Force -EA SilentlyContinue
        Remove-Item -Path "$SoftwareFolder\$Product\Install\$FSLogixDir" -Force -Recurse
		Write-Host "Stop logging"
		IF (!(Get-ChildItem -Path "$SoftwareFolder\$Product\Install\*.exe")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\Install\*"  -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Teams
IF ($SoftwareSelection.MSTeams -eq $true) {
	$Product = "MS Teams"
	$PackageName = "Teams_windows_x64"
	Try {
	$Teams = Get-EvergreenApp -Name MicrosoftTeamsClassic | Where-Object {$_.Architecture -eq 'x64' -and $_.Type -eq 'MSI' -and $_.Ring -eq 'General'} -ErrorAction Stop | Select-Object -First 1
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $Teams.Version
	$URL = $Teams.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msi, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download NEW MS Teams
IF ($SoftwareSelection.NEWMSTeams -eq $true) {
	$Product = "MS Teams 2"
	$PackageName = "MSTeams-x64"
	Try {
	$NEWTeams = Get-EvergreenApp -Name MicrosoftTeams -WarningAction silentlyContinue | Where-Object { $_.Architecture -eq "x64" -and $_.Release -eq "Enterprise" -and $_.Type -eq "msix"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $NEWTeams.Version
	$URL = $NEWTeams.uri
	$InstallerType = "msix"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download MS Teams 2.x"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msix, *.exe, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version" ´n
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host -ForegroundColor Yellow "Download Microsoft Teams 2 Bootstrapper"
		Try {
			start-sleep -seconds 3
			Invoke-WebRequest -Uri  "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409" -OutFile ("$SoftwareFolder\$Product\teamsbootstrapper.exe")
		} catch {
		throw $_.Exception.Message
		}	
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msix, *.exe, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS OneDrive
IF ($SoftwareSelection.MSOneDrive -eq $true) {
	$Product = "MS OneDrive"
	$PackageName = "OneDriveSetup"
	Try {
	$OneDrive = Get-EvergreenApp -Name MicrosoftOneDrive | Where-Object {$_.Ring -eq "Production" -and $_.Type -eq "exe" -and $_.Architecture -eq "x64"} | Select-Object -First 1
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $OneDrive.Version
	$URL = $OneDrive.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS 365Apps Semi Annual Channel
IF ($SoftwareSelection.MS365Apps_SAC -eq $true) {
	$Product = "MS 365 Apps-Semi Annual Channel"
	$PackageName = "setup"
	Try {
	$MS365Apps_SAC = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "SemiAnnual"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MS365Apps_SAC.Version
	$URL = $MS365Apps_SAC.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MS365Apps_SACUpdate = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS 365Apps Monthly Enterprise Channel
IF ($SoftwareSelection.MS365Apps_MEC -eq $true) {
	$Product = "MS 365 Apps-Monthly Enterprise Channel"
	$PackageName = "setup"
	Try {
	$MS365Apps_MEC = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "MonthlyEnterprise"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MS365Apps_MEC.Version
	$URL = $MS365Apps_MEC.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MS365Apps_MECUpdate = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Office 2019 VL
IF ($SoftwareSelection.MSOffice2019 -eq $true) {
	$Product = "MS Office 2019"
	$PackageName = "setup"
	Try {
	$MSOffice2019 = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "PerpetualVL2019"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSOffice2019.Version
	$URL = $MSOffice2019.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MSOffice_Update = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Office 2021 VL
IF ($SoftwareSelection.MSOffice2021 -eq $true) {
	$Product = "MS Office 2021 LTSC"
	$PackageName = "setup"
	Try {
	$MSOffice2021 = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "PerpetualVL2021"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSOffice2021.Version
	$URL = $MSOffice2021.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MSOffice_Update = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Powershell
IF ($SoftwareSelection.MSPowershell -eq $true) {
	$Product = "MS Powershell"
	$PackageName = "Powershell"
	Try {
	$MSPowershell = Get-EvergreenApp -Name MicrosoftPowerShell | Where-Object {$_.Architecture -eq "x64" -and $_.Release -eq "Stable"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
	}
	IF ($MSPowershell.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $MSPowershell.Version
		}
	$URL = $MSPowershell.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS .Net Framework
IF ($SoftwareSelection.MSDotNetDesktopRuntime -eq $true) {
	$Product = "MS DotNet Desktop Runtime"
	$PackageName = "windowsdesktop-runtime-win-x86-runtime"
	Try {
	$MSDotNetDesktopRuntime = Get-EvergreenApp -Name Microsoft.NET | Where-Object {$_.Architecture -eq "x86" -and $_.Channel -eq "LTS" -and $_.Installer -eq "windowsdesktop"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSDotNetDesktopRuntime.Version
	$URL = $MSDotNetDesktopRuntime.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS SQL Management Studio en
IF ($SoftwareSelection.MSSsmsEN -eq $true) {
	$Product = "MS SQL Management Studio EN"
	$PackageName = "SSMS-Setup-ENU"
	Try {
	$MSSQLManagementStudioEN = Get-NevergreenApp -Name MicrosoftSsms -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSQLManagementStudioEN.Version
	$URL = 'https://aka.ms/ssmsfullsetup?clcid=0x409'
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS SQL Management Studio de
IF ($SoftwareSelection.MSSsmsDE -eq $true) {
	$Product = "MS SQL Management Studio DE"
	$PackageName = "SSMS-Setup-DEU"
	Try {
	$MSSQLManagementStudioDE = Get-NevergreenApp -Name MicrosoftSsms -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSQLManagementStudioDE.Version
	$URL = 'https://aka.ms/ssmsfullsetup?clcid=0x407'
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Download MS Sysinternals Suite
IF ($SoftwareSelection.MSSysinternals -eq $true) {
	$Product = "MS Sysinternals Suite"
	$PackageName = "SysinternalsSuite"
	Try {
	$MSSysinternals = Get-NevergreenApp -Name MicrosoftSysinternals | Where-Object {$_.Name -eq "Microsoft Sysinternals Suite" -and $_.Architecture -eq "Multi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSysinternals.Version
	$URL = $MSSysinternals.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


<#
# Download MS WVD Desktop Agent
IF ($SoftwareSelection.MSWVDDesktopAgent -eq $true) {
$Product = "MS WVD Desktop Agent"
$PackageName = "Microsoft.RDInfra.RDAgent.Installer-x64"
$MSWVDDesktopAgent = Get-EvergreenApp -Name MicrosoftWvdInfraAgent
$Version = $MSWVDDesktopAgent.Version
$URL = $MSWVDDesktopAgent.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor Green "Update available"
IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
Remove-Item "$SoftwareFolder\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
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
IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
Remove-Item "$SoftwareFolder\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
Write-Host -ForegroundColor Yellow "Starting Download of $Product"
#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($PackageName))
Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}


# Download MS WVD WebSocket Service
IF ($SoftwareSelection.MSWVDRTCService -eq $true) {
	$Product = "MS WVD RTC Service for Teams"
	$PackageName = "MsRdcWebRTCSvc_HostSetup_x64"
	Try {
	$MSWVDRTCService = Get-EvergreenApp -Name MicrosoftWvdRtcService
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
		$Version = $MSWVDRTCService.Version
		$URL = $MSWVDRTCService.uri
		$InstallerType = "msi"
		$Source = "$PackageName" + "." + "$InstallerType"
		$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
		Write-Host -ForegroundColor Yellow "Download $Product"
		Write-Host "Download Version: $Version"
		Write-Host "Current Version: $CurrentVersion"
		IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		Write-Host "Stop logging"
		Stop-Transcript | Out-Null
		Write-Output ""
		}
			ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}
#>

# Download Citrix VM Tools
IF ($SoftwareSelection.CitrixVMTools -eq $true) {
	$Product = "Citrix VM Tools"
	$PackageName = "managementagentx64"
	<#
	Try {
	$CitrixTools = Get-EvergreenApp -Name CitrixVMTools | Where-Object {$_.Architecture -eq "x64"} | Select-Object -First 1
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $CitrixTools.Version
	$URL = $CitrixTools.uri
	#>
	$URLVersionCitrixVMTools = "https://www.xenserver.com/downloads"
	$webRequestCitrixVMTools = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionCitrixVMTools) -SessionVariable websession
	$regexAppVersionCitrixVMTools = "<b>XenServer VM Tools for Windows \d\.\d\.\d</b>"
	$webVersionCitrixVMTools = $webRequestCitrixVMTools.RawContent | Select-String -Pattern $regexAppVersionCitrixVMTools -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    $webVersionCitrixVMTools = $webVersionCitrixVMTools.Split("s ")[7] -replace ".{4}$"
    [Version]$VersionCitrixVMTools  = $webVersionCitrixVMTools
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$URL = "https://downloads.xenserver.com/vm-tools-windows/$VersionCitrixVMTools/managementagent-9.4.0-x64.msi"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionCitrixVMTools"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionCitrixVMTools) {
		IF ($VersionCitrixVMTools -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product")) {New-Item -Path "$SoftwareFolder\Citrix\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\" + "$Product $VersionCitrixVMTools.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -Value "$VersionCitrixVMTools"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionCitrixVMTools"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Citrix XenCenter
IF ($SoftwareSelection.CitrixXenCenter -eq $true) {
	$Product = "Citrix XenCenter"
	$PackageName = "XenCenter"
	$URLVersionCitrixXenCenter = "https://www.xenserver.com/downloads"
	$webRequestCitrixXenCenter = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionCitrixXenCenter) -SessionVariable websession
	$regexAppVersionCitrixXenCenter = "<b>XenCenter \d\d\d\d\.\d\.\d</b>"
	$webVersionCitrixXenCenter = $webRequestCitrixXenCenter.RawContent | Select-String -Pattern $regexAppVersionCitrixXenCenter -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    $webVersionCitrixXenCenter = $webVersionCitrixXenCenter.Split("r ")[2] -replace ".{4}$"
    [Version]$VersionCitrixXenCenter  = $webVersionCitrixXenCenter
    $InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$URL = "https://downloads.xenserver.com/xencenter/$VersionCitrixXenCenter/XenCenter-$VersionCitrixXenCenter.msi"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionCitrixXenCenter"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionCitrixXenCenter) {
		IF ($VersionCitrixXenCenter -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product")) {New-Item -Path "$SoftwareFolder\Citrix\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\" + "$Product $VersionCitrixXenCenter.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -Value "$VersionCitrixXenCenter"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionCitrixXenCenter"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Sharefile
IF ($SoftwareSelection.Sharefile -eq $true) {
	$Product = "ShareFile"
	$PackageName = "ShareFile"
	Try {
	$Sharefile = Get-NevergreenApp -Name CitrixShareFile | Where-Object {$_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $Sharefile.Version
	$URL = $Sharefile.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}



# Download VMWareTools
IF ($SoftwareSelection.VMWareTools -eq $true) {
	$Product = "VMWare Tools"
	$PackageName = "VMWareTools"
	Try {
	$VMWareTools = Get-EvergreenApp -Name VMwareTools | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $VMWareTools.Version
	$URL = $VMWareTools.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download deviceTRUST
IF ($SoftwareSelection.deviceTRUST -eq $true) {
	$Product = "deviceTRUST"
	$PackageName = "deviceTRUST"
	Try {
	$deviceTRUST = Get-EvergreenApp -Name deviceTRUST  | Where-Object {$_.Platform -eq "Windows" -and $_.Type -eq "Bundle"} | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $deviceTRUST.Version
	$URL = $deviceTRUST.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
			} catch {
			throw $_.Exception.Message
		}
		expand-archive -path "$SoftwareFolder\$Product\deviceTRUST.zip" -destinationpath "$SoftwareFolder\$Product" -EA SilentlyContinue
		expand-archive -path "$SoftwareFolder\$Product\dtpolicydefinitions-$Version.zip" -destinationpath "$SoftwareFolder\$Product\ADMX" -EA SilentlyContinue
		start-sleep -Seconds 10
		Get-ChildItem -Path "$SoftwareFolder\$Product\ADMX" | Copy-Item -Destination (New-Item -Type directory -Force ("$SoftwareFolder\_ADMX\deviceTRUST")) -Force -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\deviceTRUST.zip" -Force -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\ADMX" -Force -Recurse -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\dtpolicydefinitions-$Version.zip" -Force -EA SilentlyContinue
		Get-ChildItem -Path "$SoftwareFolder\$Product" | Where-Object Name -like *"x86"* | Remove-Item -EA SilentlyContinue
		Write-Host "Stop logging"
		IF (!(Get-ChildItem -Path "$SoftwareFolder\$Product\*.msi")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Microsoft openJDK 21
IF ($SoftwareSelection.MicrosoftOpenJDK -eq $true) {
	$Product = "Microsoft OpenJDK 21"
	$PackageName = "MicrosoftOpenJDK"
	Try {
		$MicrosoftOpenJDK = Get-EvergreenApp -Name MicrosoftOpenJDK21 | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MicrosoftOpenJDK.version
	$URL = $MicrosoftOpenJDK.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt"
	IF ($CurrentVersion -like "*+*") {
		$CurrentVersion = [version]$CurrentVersion.Replace("+", ".")
	}
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionMicrosoftOpenJDK"
	Write-Host "Current Version: $CurrentVersion"
	IF ($version) {
		IF ($version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionMicrosoftOpenJDK.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionMicrosoftOpenJDK"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionMicrosoftOpenJDK"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download OracleJava8 64-Bit
IF ($SoftwareSelection.OracleJava8 -eq $true) {
	$Product = "Oracle Java 8 x64"
	$PackageName = "Oracle Java 8 x64"
	Try {
	$OracleJava8 = Get-EvergreenApp -Name OracleJava8 | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$VersionOracle8_x64 = $OracleJava8.Version
	$VersionOracle8_x64 = $VersionOracle8_x64 -replace ".{4}$"
	#$VersionOracle8_x64 = $VersionOracle8_x64.Substring(2)
	[Version]$VersionOracle8_x64 = $VersionOracle8_x64 -replace "_","."
	$URL = $OracleJava8.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionOracle8_x64"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionOracle8_x64) {
		IF ($VersionOracle8_x64 -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionOracle8_x64.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionOracle8_x64"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionOracle8_x64"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download OracleJava8 32-Bit
IF ($SoftwareSelection.OracleJava8_32 -eq $true) {
	$Product = "Oracle Java 8 x86"
	$PackageName = "Oracle Java 8 x86"
	Try {
	$OracleJava8 = Get-EvergreenApp -Name OracleJava8 | Where-Object {$_.Architecture -eq "x86"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$VersionOracle8_x86 = $OracleJava8.Version
	$VersionOracle8_x86 = $VersionOracle8_x86 -replace ".{4}$"
	[Version]$VersionOracle8_x86 = $VersionOracle8_x86 -replace "_","."
	$URL = $OracleJava8.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionOracle8_x86"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionOracle8_x86) {
		IF ($VersionOracle8_x86 -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionOracle8_x86.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionOracle8_x86"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionOracle8_x86"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download KeePass
IF ($SoftwareSelection.KeePass -eq $true) {
	$Product = "KeePass"
	$PackageName = "KeePass"
	Try {
	$KeePass = Get-EvergreenApp -Name KeePass | Where-Object {$_.Type -like "*exe*"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $KeePass.Version
	$URL = $KeePass.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download KeePassXC
IF ($SoftwareSelection.KeePassXC -eq $true) {
	$Product = "KeePassXC"
	$PackageName = "KeePassXC"
	Try {
	$KeePassXC = Get-EvergreenApp -Name KeePassXCTeamKeePassXC | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($KeePassXC.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $KeePassXC.Version
		}
	$URL = $KeePassXC.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download IGEL Universal Management Suite
IF ($SoftwareSelection.IGELUniversalManagementSuite -eq $true) {
	$Product = "IGEL Universal Management Suite"
	$PackageName = "setup-igel-ums-windows"
	Try {
	$IGELUniversalManagementSuite = Get-NevergreenApp -Name IGELUniversalManagementSuite -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $IGELUniversalManagementSuite.Version
	$URL = $IGELUniversalManagementSuite.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download mRemoteNG
IF ($SoftwareSelection.mRemoteNG -eq $true) {
	$Product = "mRemoteNG"
	$PackageName = "mRemoteNG"
	Try {
	$mRemoteNG = Get-EvergreenApp -Name mRemoteNG | Where-Object {$_.URI -like "*msi*"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($mRemoteNG.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $mRemoteNG.Version
		}
	$URL = $mRemoteNG.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Tree Size Free
IF ($SoftwareSelection.TreeSizeFree -eq $true) {
	$Product = "TreeSizeFree"
	$PackageName = "TreeSizeFree"
	Try {
	$TreeSizeFree = Get-EvergreenApp -Name JamTreeSizeFree -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $TreeSizeFree.Version
	$URL = $TreeSizeFree.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WinSCP
IF ($SoftwareSelection.WinSCP -eq $true) {
	$Product = "WinSCP"
	$PackageName = "WinSCP"
	Try {
	$WinSCP = Get-EvergreenApp -Name WinSCP | Where-Object {$_.Type -eq "exe"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $WinSCP.Version
	$URL = $WinSCP.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Putty
IF ($SoftwareSelection.Putty -eq $true) {
	$Product = "Putty"
	$PackageName = "Putty"
	Try {
	$putty = Get-EvergreenApp -Name PuTTY | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $putty.Version
	$URL = $putty.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}



# Download ControlUp Console
IF ($SoftwareSelection.ControlUpConsole -eq $true) {
	$Product = "ControlUp Console"
	$PackageName = "ControlUpConsole"
	Try {
	$ControlUpConsole = Get-EvergreenApp -Name ControlUpConsole -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ControlUpConsole.Version
	$URL = $ControlUpConsole.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		#expand-archive -path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -destinationpath "$SoftwareFolder\$Product"  
		#start-sleep -Seconds 5
		#Remove-Item -Path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -Force
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download ControlUp DX client
IF ($SoftwareSelection.ControlUpRemoteDX -eq $true) {
	$Product = "ControlUp DX Client"
	$PackageName = "curdx_windows_citrix"
	Try {
	$ControlUpRemoteDX = Get-EvergreenApp -Name ControlUpRemoteDX | Where-Object {$_.Plugin -like "Citrix*"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ControlUpRemoteDX.Version
	$URL = $ControlUpRemoteDX.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		#expand-archive -path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -destinationpath "$SoftwareFolder\$Product"  
		#start-sleep -Seconds 5
		#Remove-Item -Path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -Force
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Zoom VDI Installer
IF ($SoftwareSelection.ZoomVDI -eq $true) {
	$Product = "Zoom VDI Host"
	$PackageName = "ZoomInstallerVDI"
	Try {
	$ZoomVDI = Get-EvergreenApp -Name ZoomVDI | Where-Object {$_.Platform -eq "VDIClient" -and $_.Type -eq "msi" -and $_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$URLVersionZoom = "https://support.zoom.com/hc/de/article?id=zm_kb&sysparm_article=KB0063813#collapseGeneric52"
	$webRequestZoom = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionZoom) -SessionVariable websession
	$regexAppVersionZoom = "\d\.\d\d\.\d"
	$webVersionZoom = $webRequestZoom.RawContent | Select-String -Pattern $regexAppVersionZoom -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	[Version]$Version = $webVersionZoom.Trim("</td>").Trim("</td>")
	$URL = $ZoomVDI.Uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Zoom Citrix client
IF ($SoftwareSelection.ZoomCitrix -eq $true) {
	$Product = "Zoom Citrix Client"
	$PackageName = "ZoomCitrixHDXMediaPlugin"
	Try {
	$ZoomCitrix = Get-EvergreenApp -Name ZoomVDI | Where-Object {$_.Platform -eq "Citrix"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$URLVersionZoomCitrix = "https://support.zoom.com/hc/de/article?id=zm_kb&sysparm_article=KB0063813#collapseGeneric52"
	$webRequestZoomCitrix = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionZoomCitrix) -SessionVariable websession
	$regexAppVersionZoomCitrix = "\d\.\d\d\.\d"
	$webVersionZoomCitrix = $webRequestZoomCitrix.RawContent | Select-String -Pattern $regexAppVersionZoomCitrix -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	[Version]$Version = $webVersionZoomCitrix.Trim("</td>").Trim("</td>")
	$URL = $ZoomCitrix.Uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Zoom VMWare client
IF ($SoftwareSelection.ZoomVMWare -eq $true) {
	$Product = "Zoom VMWare Client"
	$PackageName = "ZoomVMWareMediaPlugin"
	Try {
	$ZoomVMWare = Get-NevergreenApp -Name Zoom | Where-Object {$_.Name -eq "Zoom VMWare Media Plugin"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ZoomVMWare.Version
	$URL = $ZoomVMWare.Uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

<#
# Download Cisco WebEx Desktop
IF ($SoftwareSelection.CiscoWebExDesktop -eq $true) {
$Product = "Cisco WebEx Desktop"
$PackageName = "WebEx"
$CiscoWebExDesktop = Get-NevergreenApp -Name CiscoWebEx | Where-Object {$_.Language -eq "Multi" -and $_.Name -eq "Cisco Webex"}
$Version = $CiscoWebExDesktop.Version
$URL = $CiscoWebExDesktop.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor Green "Update available"
IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
Remove-Item "$SoftwareFolder\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source)) -EA SilentlyContinue
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}
#>

# Download Cisco WebEx VDI Plugin
IF ($SoftwareSelection.CiscoWebExVDI -eq $true) {
	$Product = "Cisco WebEx VDI Plugin"
	Write-Host -ForegroundColor Red "$Product currently not available in Evergreen downloader, try again later!"
	Write-Output ""
	<#
	
	$PackageName = "WebExVDIPlugin"
	$URLVersionWebExVDI = "https://www.webex.com/downloads/teams-vdi.html"
	$webRequestWebExVDI = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionWebExVDI) -SessionVariable websession
	$regexAppVersionWebExVDI = '\(\d\d\.\d\.\d\.\d\d\d\d\d\)'
	$webVersionWebExVDI = $webRequestWebExVDI.RawContent | Select-String -Pattern $regexAppVersionWebExVDI -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	$webVersionWebExVDI = $webVersionWebExVDI.TrimEnd(')').Substring(1)
	[Version]$VersionWebExVDI  = $webVersionWebExVDI
	$regexLinkWebExVDI = '<td>Windows\s<a\shref=".*"\starget="_self">64-bit</a></td>'
	$URL = $webRequestWebExVDI.RawContent | Select-String -Pattern $regexLinkWebExVDI -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	$URL = $URL.Split('"')
	$URL = $URL[1]
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionWebExVDI"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionWebExVDI) {
		IF ($VersionWebExVDI -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionWebExVDI.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionWebExVDI"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionWebExVDI"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
	#>
}


# Download ImageGlass
IF ($SoftwareSelection.ImageGlass -eq $true) {
	$Product = "ImageGlass"
	$PackageName = "ImageGlass"
	Try {
	$ImageGlass = Get-EvergreenApp -Name ImageGlass | Where-Object {$_.Architecture -eq "x64"} | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($ImageGlass.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $ImageGlass.Version
		}
	$URL = $ImageGlass.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download ShareX
IF ($SoftwareSelection.ShareX -eq $true) {
	$Product = "ShareX"
	$PackageName = "ShareX"
	Try {
	$ShareX = Get-EvergreenApp -Name ShareX | Where-Object {$_.Type -eq "exe"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($ShareX.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $ShareX.Version
		}
	$URL = $ShareX.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Greenshot
IF ($SoftwareSelection.Greenshot -eq $true) {
	$Product = "Greenshot"
	$PackageName = "Greenshot"
	Try {
	$Greenshot = Get-EvergreenApp -Name Greenshot | Where-Object {$_.Type -eq "exe"} | Select-Object -Last 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($Greenshot.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $Greenshot.Version
		}
	$URL = $Greenshot.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download FoxItReader
IF ($SoftwareSelection.FoxItReader -eq $true) {
	$Product = "FoxitReader"
	$PackageName = "FoxIt-Reader"
	Try {
	$FoxItReader = Get-EvergreenApp -Name FoxItReader | Where-Object {$_.Language -eq "German"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $FoxItReader.Version
	$URL = $FoxItReader.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download VcRedist x64
IF ($SoftwareSelection.VcRedist -eq $true) {
	$Product = "Microsoft Visual C++ Redistributable packages x64"
	$PackageName = "VC_redist_x64"
	Try {
	$VcRedist = Get-VcList | Where-Object {$_.Name -like "*2022*" -and $_.Architecture -eq "x64"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $VcRedist.Version
	$URL = $VcRedist.URI
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download VcRedist x86
IF ($SoftwareSelection.VcRedist -eq $true) {
	$Product = "Microsoft Visual C++ Redistributable packages x86"
	$PackageName = "VC_redist_x86"
	Try {
	$VcRedist = Get-VcList | Where-Object {$_.Name -like "*2022*" -and $_.Architecture -eq "x86"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $VcRedist.Version
	$URL = $VcRedist.URI
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WinRAR
IF ($SoftwareSelection.WinRAR -eq $true) {
	$Product = "WinRAR"
	$PackageName = "WinRAR"
	$appURLVersion = "https://www.rarlab.com/download.htm"
	$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($appURLVersion) -SessionVariable websession
	$regexAppVersionDe = "<tr>\n.*\n.*German.*\n.*\n.*.*\n<\/tr>"
	$regexAppVersionEn = "<tr>\n.*\n.*English.*\n.*\n.*.*\n<\/tr>"
	$regexAppVersionbeta = 'center\">.*beta.{2}'
	$webVersionprodde = $webRequest.RawContent | Select-String -Pattern $regexAppVersionDe -AllMatches | ForEach-Object { $_.Matches.Value } | Select-String -NotMatch $regexAppVersionbeta -AllMatches | Select-Object -First 1
	$installerprodde = $webVersionprodde.Line.Split(">")[2]
	$installerprodde = $installerprodde.Split('"')[1]
	$appversionprodde = $webVersionprodde.Line.Split(">")[8]
	$appversionprodde = $appversionprodde.Split("<")[0]
	$webVersionbetade = $webRequest.RawContent | Select-String -Pattern $regexAppVersionDe -AllMatches | ForEach-Object { $_.Matches.Value } | Select-String -Pattern $regexAppVersionbeta -AllMatches | Select-Object -First 1
	
	$webVersionproden = $webRequest.RawContent | Select-String -Pattern $regexAppVersionEn -AllMatches | ForEach-Object { $_.Matches.Value } | Select-String -NotMatch $regexAppVersionbeta -AllMatches | Select-Object -First 1
	$installerproden = $webVersionproden.Line.Split(">")[2]
	$installerproden = $installerproden.Split('"')[1]
	$webVersionbetaen = $webRequest.RawContent | Select-String -Pattern $regexAppVersionEn -AllMatches | ForEach-Object { $_.Matches.Value } | Select-String -Pattern $regexAppVersionbeta -AllMatches | Select-Object -First 1
	$URLen = "https://www.rarlab.com" + "$installerproden"
	$URLde = "https://www.rarlab.com" + "$installerprodde"
	$InstallerType = "exe"
	$SourceDe = "$PackageName" + "_de" + "." + "$InstallerType"
	$SourceEn = "$PackageName" + "_en" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $appversionprodde"
	Write-Host "Current Version: $CurrentVersion"
	IF ($appversionprodde) {
		IF ($appversionprodde -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $appversionprodde.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$appversionprodde"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $appversionprodde"
		Try {
			Get-FileFromWeb -Url $URLde -File ("$SoftwareFolder\$Product\" + ($SourceDe))
		} catch {
			throw $_.Exception.Message
		}
		start-sleep -s 3
		Try {
			Get-FileFromWeb -Url $URLen -File ("$SoftwareFolder\$Product\" + ($SourceEn))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source_de")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source_de', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Stop UpdateLog
Stop-Transcript | Out-Null

# Format UpdateLog
$Content = Get-Content -Path $UpdateLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $UpdateLog

if ($noGUI -eq $False) {
	pause}

