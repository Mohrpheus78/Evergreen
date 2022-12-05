# ***************************************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
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
Version: 2.7
06/24: Changed internet connection check
06/25: Changed internet connection check
06/27: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 at the top of the script
07/04: Changed Adobe Reader update source (Evergreen)
07/25: Changed version check from pdf24Creator
07/27: Wrong URL for pdf24Creator, please remove all files from pdf24Creator folder before launching Updater again! Changed Citrix WorkspaceApp version check and always install MS Edge WebView updates, changed Adobe DC update check
11/21: Changed RemoteDesktopManager URL
11/22: Improved download check for alle apps, warning if app download fails
#>


Param (
		[Parameter(
            HelpMessage='Start the Gui to select the Software',
            ValuefromPipelineByPropertyName = $true
        )]
        [switch]$noGUI
    
)

$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
	Write-Host "Press any key to exit"
	Read-Host
    BREAK
   }
# ========================================================================================================================================


# FUNCTION Check internet access
# ========================================================================================================================================
Function Get-StatusCodeFromWebsite {
	param($Website)
	Try {
    (Invoke-WebRequest -Uri $Website -TimeoutSec 1 -UseBasicParsing).StatusCode
	}
	Catch {
    }
}
$Result = Get-StatusCodeFromWebsite -Website github.com

IF($Result -eq 200) {
	$Internet = "True"
}
ELSE {
    $Internet = "False"
}
# ========================================================================================================================================


# Is there a newer Evergreen Script version?
# ========================================================================================================================================
[version]$EvergreenVersion = "2.7"
$WebVersion = ""
[bool]$NewerVersion = $false
If ($Internet -eq "True") {
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

Clear-Host

Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------- "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " Software-Updater (Powered by Evergreen-Module) "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed "    © D. Mohrmann - S&L Firmengruppe            "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------- "
Write-Output ""


Write-Host -ForegroundColor Cyan "Setting Variables"
Write-Output ""

# Variables
$SoftwareFolder = ("$PSScriptRoot" + "\" + "Software\")
$ErrorActionPreference = "SilentlyContinue"
#$WarningPreference = "Continue"
$SoftwareToUpdate = "$SoftwareFolder\Software-to-update.xml"

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

# General update logfile
$Date = $Date = Get-Date -UFormat "%d.%m.%Y"
$UpdateLog = "$SoftwareFolder\_Update Logs\Software Updates $Date.log"
$ModulesUpdateLog = "$SoftwareFolder\_Update Logs\Modules Updates $Date.log"

# Import values (selected software) from XML file
if (Test-Path -Path $SoftwareToUpdate) {$SoftwareSelection = Import-Clixml $SoftwareToUpdate}

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
	
	# Citrix Hypervisor Tools Checkbox
    $Citrix_HypervisorToolsBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_HypervisorToolsBox.text = "Citrix Hypervisor Tools"
    $Citrix_HypervisorToolsBox.width = 95
    $Citrix_HypervisorToolsBox.height = 20
    $Citrix_HypervisorToolsBox.autosize = $true
    $Citrix_HypervisorToolsBox.location = New-Object System.Drawing.Point(11,270)
    $form.Controls.Add($Citrix_HypervisorToolsBox)
	$Citrix_HypervisorToolsBox.Checked = $SoftwareSelection.CitrixHypervisorTools
	
	# Citrix Files Checkbox
    $CitrixFilesBox = New-Object system.Windows.Forms.CheckBox
    $CitrixFilesBox.text = "Citrix Files"
    $CitrixFilesBox.width = 95
    $CitrixFilesBox.height = 20
    $CitrixFilesBox.autosize = $true
    $CitrixFilesBox.location = New-Object System.Drawing.Point(11,295)
    $form.Controls.Add($CitrixFilesBox)
	$CitrixFilesBox.Checked = $SoftwareSelection.CitrixFiles
	
	# VMWareTools Checkbox
    $VMWareToolsBox = New-Object system.Windows.Forms.CheckBox
    $VMWareToolsBox.text = "VMWare Tools"
    $VMWareToolsBox.width = 95
    $VMWareToolsBox.height = 20
    $VMWareToolsBox.autosize = $true
    $VMWareToolsBox.location = New-Object System.Drawing.Point(11,320)
    $form.Controls.Add($VMWareToolsBox)
	$VMWareToolsBox.Checked = $SoftwareSelection.VMWareTools

    # Remote Desktop Manager Checkbox
    $RemoteDesktopManagerBox = New-Object system.Windows.Forms.CheckBox
    $RemoteDesktopManagerBox.text = "Remote Desktop Manager Free"
    $RemoteDesktopManagerBox.width = 95
    $RemoteDesktopManagerBox.height = 20
    $RemoteDesktopManagerBox.autosize = $true
    $RemoteDesktopManagerBox.location = New-Object System.Drawing.Point(11,345)
    $form.Controls.Add($RemoteDesktopManagerBox)
	$RemoteDesktopManagerBox.Checked = $SoftwareSelection.RemoteDesktopManager

    # deviceTRUST CheckBox
    $deviceTRUSTBox = New-Object system.Windows.Forms.CheckBox
    $deviceTRUSTBox.text = "deviceTRUST"
    $deviceTRUSTBox.width = 95
    $deviceTRUSTBox.height = 20
    $deviceTRUSTBox.autosize = $true
    $deviceTRUSTBox.location = New-Object System.Drawing.Point(11,370)
    $form.Controls.Add($deviceTRUSTBox)
	$deviceTRUSTBox.Checked = $SoftwareSelection.deviceTRUST
    
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
	
	 # MS Powershell Checkbox
    $MSPowershellBox = New-Object system.Windows.Forms.CheckBox
    $MSPowershellBox.text = "Microsoft Powershell"
    $MSPowershellBox.width = 95
    $MSPowershellBox.height = 20
    $MSPowershellBox.autosize = $true
    $MSPowershellBox.location = New-Object System.Drawing.Point(250,245)
    $form.Controls.Add($MSPowershellBox)
	$MSPowershellBox.Checked = $SoftwareSelection.MSPowershell
	
	# MS DotNet Checkbox
    $MSDotNetBox = New-Object system.Windows.Forms.CheckBox
    $MSDotNetBox.text = "Microsoft .Net Framework"
    $MSDotNetBox.width = 95
    $MSDotNetBox.height = 20
    $MSDotNetBox.autosize = $true
    $MSDotNetBox.location = New-Object System.Drawing.Point(250,270)
    $form.Controls.Add($MSDotNetBox)
	$MSDotNetBox.Checked = $SoftwareSelection.MSDotNetFramework
	
	# MS SQL Management Studio EN Checkbox
    $MSSQLManagementStudioENBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioENBox.text = "Microsoft SQL Management Studio EN"
    $MSSQLManagementStudioENBox.width = 95
    $MSSQLManagementStudioENBox.height = 20
    $MSSQLManagementStudioENBox.autosize = $true
    $MSSQLManagementStudioENBox.location = New-Object System.Drawing.Point(250,295)
    $form.Controls.Add($MSSQLManagementStudioENBox)
	$MSSQLManagementStudioENBox.Checked = $SoftwareSelection.MSSsmsEN
	
	# MS SQL Management Studio DE Checkbox
    $MSSQLManagementStudioDEBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioDEBox.text = "Microsoft SQL Management Studio DE"
    $MSSQLManagementStudioDEBox.width = 95
    $MSSQLManagementStudioDEBox.height = 20
    $MSSQLManagementStudioDEBox.autosize = $true
    $MSSQLManagementStudioDEBox.location = New-Object System.Drawing.Point(250,320)
    $form.Controls.Add($MSSQLManagementStudioDEBox)
	$MSSQLManagementStudioDEBox.Checked = $SoftwareSelection.MSSsmsDE
	
	# ImageGlass Checkbox
    $ImageGlassBox = New-Object system.Windows.Forms.CheckBox
    $ImageGlassBox.text = "ImageGlass"
    $ImageGlassBox.width = 95
    $ImageGlassBox.height = 20
    $ImageGlassBox.autosize = $true
    $ImageGlassBox.location = New-Object System.Drawing.Point(250,345)
    $form.Controls.Add($ImageGlassBox)
	$ImageGlassBox.Checked =  $SoftwareSelection.ImageGlass
	
	# Greenshot Checkbox
    $GreenshotBox = New-Object system.Windows.Forms.CheckBox
    $GreenshotBox.text = "Greenshot"
    $GreenshotBox.width = 95
    $GreenshotBox.height = 20
    $GreenshotBox.autosize = $true
    $GreenshotBox.location = New-Object System.Drawing.Point(250,370)
    $form.Controls.Add($GreenshotBox)
	$GreenshotBox.Checked =  $SoftwareSelection.Greenshot
	
	# OracleJava8 x64 Checkbox
    $OracleJava8Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8Box.text = "Oracle Java 8/x64"
    $OracleJava8Box.width = 95
    $OracleJava8Box.height = 20
    $OracleJava8Box.autosize = $true
    $OracleJava8Box.location = New-Object System.Drawing.Point(250,395)
    $form.Controls.Add($OracleJava8Box)
	$OracleJava8Box.Checked =  $SoftwareSelection.OracleJava8
	
	# OracleJava8 x86 Checkbox
    $OracleJava8_32Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8_32Box.text = "Oracle Java 8/x86"
    $OracleJava8_32Box.width = 95
    $OracleJava8_32Box.height = 20
    $OracleJava8_32Box.autosize = $true
    $OracleJava8_32Box.location = New-Object System.Drawing.Point(250,420)
    $form.Controls.Add($OracleJava8_32Box)
	$OracleJava8_32Box.Checked =  $SoftwareSelection.OracleJava8_32
	
	# OpenJDK Checkbox
    $OpenJDKBox = New-Object system.Windows.Forms.CheckBox
    $OpenJDKBox.text = "Open JDK"
    $OpenJDKBox.width = 95
    $OpenJDKBox.height = 20
    $OpenJDKBox.autosize = $true
    $OpenJDKBox.location = New-Object System.Drawing.Point(250,445)
    $form.Controls.Add($OpenJDKBox)
	$OpenJDKBox.Checked =  $SoftwareSelection.OpenJDK
	
	<#
	# Cisco WebEx VDI Plugin Checkbox
    $CiscoWebExVDIBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExVDIBox.text = "Cisco WebEx VDI Plugin"
    $CiscoWebExVDIBox.width = 95
    $CiscoWebExVDIBox.height = 20
    $CiscoWebExVDIBox.autosize = $true
    $CiscoWebExVDIBox.location = New-Object System.Drawing.Point(250,395)
    $form.Controls.Add($CiscoWebExVDIBox)
	$CiscoWebExVDIBox.Checked =  $SoftwareSelection.CiscoWebExVDI
	
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
	
	# TreeSizeFree Checkbox
    $TreeSizeFreeBox = New-Object system.Windows.Forms.CheckBox
    $TreeSizeFreeBox.text = "TreeSize Free"
    $TreeSizeFreeBox.width = 95
    $TreeSizeFreeBox.height = 20
    $TreeSizeFreeBox.autosize = $true
    $TreeSizeFreeBox.location = New-Object System.Drawing.Point(685,45)
    $form.Controls.Add($TreeSizeFreeBox)
	$TreeSizeFreeBox.Checked =  $SoftwareSelection.TreeSizeFree
	
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
	
	# IGEL Universal Management Suite Checkbox
    $IGELUniversalManagementSuiteBox = New-Object system.Windows.Forms.CheckBox
    $IGELUniversalManagementSuiteBox.text = "IGEL Universal Management Suite"
    $IGELUniversalManagementSuiteBox.width = 95
    $IGELUniversalManagementSuiteBox.height = 20
    $IGELUniversalManagementSuiteBox.autosize = $true
    $IGELUniversalManagementSuiteBox.location = New-Object System.Drawing.Point(685,145)
    $form.Controls.Add($IGELUniversalManagementSuiteBox)
	$IGELUniversalManagementSuiteBox.Checked = $SoftwareSelection.IGELUniversalManagementSuite
	
	# pdf24Creator Checkbox
    $pdf24CreatorBox = New-Object system.Windows.Forms.CheckBox
    $pdf24CreatorBox.text = "pdf24Creator"
    $pdf24CreatorBox.width = 95
    $pdf24CreatorBox.height = 20
    $pdf24CreatorBox.autosize = $true
    $pdf24CreatorBox.location = New-Object System.Drawing.Point(685,170)
    $form.Controls.Add($pdf24CreatorBox)
	$pdf24CreatorBox.Checked =  $SoftwareSelection.pdf24Creator
	
	## Zoom Host Checkbox
    $ZoomVDIBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVDIBox.text = "Zoom VDI Host Installer (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    $ZoomVDIBox.Font = $CustomFont
    $ZoomVDIBox.width = 95
    $ZoomVDIBox.height = 20
    $ZoomVDIBox.autosize = $true
    $ZoomVDIBox.location = New-Object System.Drawing.Point(685,195)
    $form.Controls.Add($ZoomVDIBox)
	$ZoomVDIBox.Checked =  $SoftwareSelection.ZoomVDI
	
	# Zoom Citrix client Checkbox
    $ZoomCitrixBox = New-Object system.Windows.Forms.CheckBox
    $ZoomCitrixBox.text = "Zoom Citrix Client (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    $ZoomCitrixBox.Font = $CustomFont
    $ZoomCitrixBox.width = 95
    $ZoomCitrixBox.height = 20
    $ZoomCitrixBox.autosize = $true
    $ZoomCitrixBox.location = New-Object System.Drawing.Point(685,220)
    $form.Controls.Add($ZoomCitrixBox)
	$ZoomCitrixBox.Checked =  $SoftwareSelection.ZoomCitrix
	
	# Zoom VMWare client Checkbox
    $ZoomVMWareBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVMWareBox.text = "Zoom VMWare Client (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    $ZoomVMWareBox.Font = $CustomFont
    $ZoomVMWareBox.width = 95
    $ZoomVMWareBox.height = 20
    $ZoomVMWareBox.autosize = $true
    $ZoomVMWareBox.location = New-Object System.Drawing.Point(685,245)
    $form.Controls.Add($ZoomVMWareBox)
	$ZoomVMWareBox.Checked =  $SoftwareSelection.ZoomVMWare
	
		
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
		$Citrix_HypervisorToolsBox.checked = $True
		$CitrixFilesBox.checked = $True
		$VMWareToolsBox.checked = $True
		$RemoteDesktopManagerBox.checked = $True
		$deviceTRUSTBox.checked = $True
		$KeePassBox.checked = $True
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
		$MSPowershellBox.checked = $True
		$MSDotNetBox.checked = $True
		$MSSQLManagementStudioDEBox.checked = $True
		$MSSQLManagementStudioENBox.checked = $True
		$MSSysinternalsBox.checked = $True
		$MSWVDDesktopAgentBox.checked = $True
		$MSWVDRTCServiceBox.checked = $True
		$MSWVDBootLoaderBox.checked = $True
		$TreeSizeFreeBox.checked = $True
		$ZoomVDIBox.checked = $True
		$ZoomCitrixBox.checked = $True
		$ZoomVMWareBox.checked = $True
		$VLCPlayerBox.checked = $True
		$FileZillaBox.checked = $True
		#$CiscoWebExVDIBox.checked = $True
		#$CiscoWebExDesktopBox.checked = $True
		$OpenJDKBox.checked = $True
		$GreenshotBox.checked = $True
		$OracleJava8Box.checked = $True
		$OracleJava8_32Box.checked = $True
		$ImageGlassBox.checked = $True
		$pdf24CreatorBox.checked = $True	
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
		$Citrix_HypervisorToolsBox.checked = $False
		$CitrixFilesBox.checked = $False
		$VMWareToolsBox.checked = $False
		$RemoteDesktopManagerBox.checked = $False
		$deviceTRUSTBox.checked = $False
		$KeePassBox.checked = $False
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
		$MSPowershellBox.checked = $False
		$MSDotNetBox.checked = $False
		$MSSQLManagementStudioDEBox.checked = $False
		$MSSQLManagementStudioENBox.checked = $False
		$MSSysinternalsBox.checked = $False
		$MSWVDDesktopAgentBox.checked = $False
		$MSWVDRTCServiceBox.checked = $False
		$MSWVDBootLoaderBox.checked = $False
		$TreeSizeFreeBox.checked = $False
		$ZoomVDIBox.checked = $False
		$ZoomCitrixBox.checked = $False
		$ZoomVMWareBox.checked = $False
		$VLCPlayerBox.checked = $False
		$FileZillaBox.checked = $False
		#$CiscoWebExVDIBox.checked = $False
		#$CiscoWebExDesktopBox.checked = $False
		$OpenJDKBox.checked = $False
		$GreenshotBox.checked = $False
		$OracleJava8Box.checked = $False
		$OracleJava8_32Box.checked = $False
		$ImageGlassBox.checked = $False
		$pdf24CreatorBox.checked = $False
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
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixHypervisorTools" -Value $Citrix_HypervisorToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixFiles" -Value $CitrixFilesBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_SAC" -Value $MS365AppsBox_SAC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_MEC" -Value $MS365AppsBox_MEC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2019" -Value $MSOffice2019Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2021" -Value $MSOffice2021Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePass" -Value $KeePassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "IGELUniversalManagementSuite" -Value $IGELUniversalManagementSuiteBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "mRemoteNG" -Value $mRemoteNGBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSEdge" -Value $MSEdgeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOneDrive" -Value $MSOneDriveBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeams" -Value $MSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSPowershell" -Value $MSPowershellBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSDotNetFramework" -Value $MSDotNetBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsEN" -Value $MSSQLManagementStudioENBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsDE" -Value $MSSQLManagementStudioDEBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSysinternals" -Value $MSSysinternalsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDDesktopAgent" -Value $MSWVDDesktopAgentBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDRTCService" -Value $MSWVDRTCServiceBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDBootLoader" -Value $MSWVDBootLoaderBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "openJDK" -Value $OpenJDKBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Greenshot" -Value $GreenshotBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8" -Value $OracleJava8Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8_32" -Value $OracleJava8_32Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "TreeSizeFree" -Value $TreeSizeFreeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVDI" -Value $ZoomVDIBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomCitrix" -Value $ZoomCitrixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVMWare" -Value $ZoomVMWareBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VLCPlayer" -Value $VLCPlayerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FileZilla" -Value $FileZillaBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExVDI" -Value $CiscoWebExVDIBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExDesktop" -Value $CiscoWebExDesktopBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "deviceTRUST" -Value $deviceTRUSTBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VMWareTools" -Value $VMWareToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RemoteDesktopManager" -Value $RemoteDesktopManagerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinSCP" -Value $WinSCPBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Putty" -Value $PuttyBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ImageGlass" -Value $ImageGlassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "pdf24Creator" -Value $pdf24CreatorBox.checked -Force
	
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

# Call Form
if ($noGUI -eq $False) {
gui_mode
}

# Disable progress bar while downloading
$ProgressPreference = 'SilentlyContinue'

# Install/Update Evergreen and Nevergreen modules
# Start logfile Modules Update Log
Start-Transcript $ModulesUpdateLog | Out-Null
Write-Host -ForegroundColor Cyan "Installing/updating Evergreen and Nevergreen modules... please wait"
Write-Output ""
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
IF (!(Test-Path -Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget")) {Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies}
IF (!(Get-Module -ListAvailable -Name Evergreen)) {Install-Module Evergreen -Force | Import-Module Evergreen}
IF (!(Get-Module -ListAvailable -Name Nevergreen)) {Install-Module Nevergreen -Force | Import-Module Nevergreen}
# Check for Updates
$LocalEvergreenVersion = (Get-Module -Name Evergreen -ListAvailable | Select-Object -First 1).Version
$CurrentEvergreenVersion = (Find-Module -Name Evergreen -Repository PSGallery).Version
if (($LocalEvergreenVersion -lt $CurrentEvergreenVersion))
{
    Update-Module Evergreen -force
}
$LocalNevergreenVersion = (Get-Module -Name Nevergreen -ListAvailable | Select-Object -First 1).Version
$CurrentNevergreenVersion = (Find-Module -Name Nevergreen -Repository PSGallery).Version
if (($LocalNevergreenVersion -lt $CurrentNevergreenVersion))
{
    Update-Module Nevergreen -force
}

IF (!(Get-Module -ListAvailable -Name Evergreen))
	{
	Write-Host -ForegroundColor Cyan "Evergreen module not found, check module installation!"
	BREAK
	}
IF (!(Get-Module -ListAvailable -Name Nevergreen))
	{
	Write-Host -ForegroundColor Cyan "Nevergreen module not found, check module installation!"
	BREAK
	}
	
# Stop logfile Modules Update Log
Stop-Transcript | Out-Null
$Content = Get-Content -Path $ModulesUpdateLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $ModulesUpdateLog


# Start logfile Update Log
Start-Transcript $UpdateLog | Out-Null

# Import selection
$SoftwareSelection = Import-Clixml $SoftwareToUpdate
Write-Host -ForegroundColor Cyan "Import selection"
Write-Output ""

# Write-Output "Evergreen Version: $EvergreenVersion" | Out-File $UpdateLog -Append
Write-Host -ForegroundColor Cyan "Starting downloads..."
Write-Output ""


# Download RemoteDesktopManager
IF ($SoftwareSelection.RemoteDesktopManager -eq $true) {
	$Product = "RemoteDesktopManager"
	$PackageName = "RemoteDesktopManagerFree"
	Try {
	$URLVersionRDM = "https://remotedesktopmanager.com/de/release-notes/free"
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
	$regexAppVersionPDF2 = "\d\d\.\d\.\d+"
    $webVersionPDF24 = $webRequest.RawContent | Select-String -Pattern $regexAppVersionPDF2 -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
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
	$Version = $Notepad.Version
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
		Get-ChildItem "$SoftwareFolder\$Product\" -Exclude lang | Remove-Item -Recurse
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
        Get-ChildItem "$SoftwareFolder\$Product\" -Exclude lang | Remove-Item -Recurse
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
	$Chrome = Get-EvergreenApp -Name GoogleChrome | Where-Object {$_.Architecture -eq "x64" -and $_.Channel -eq "Stable"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $Chrome.Version
	$URL = $Chrome.uri
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
	$VLC = Get-EvergreenApp -Name VideoLanVlcPlayer | Where-Object {$_.Platform -eq "Windows"  -and $_.Architecture -eq "x64" -and $_.Type -eq "MSI"} -ErrorAction Stop
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
	Try {
	$FileZilla = Get-EvergreenApp -Name FileZilla -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $FileZilla.Version
	$URL = $FileZilla.uri
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


# Download BIS-F
IF ($SoftwareSelection.BISF -eq $true) {
	$Product = "BIS-F"
	$PackageName = "setup-BIS-F"
	Try {
	$BISF = Get-EvergreenApp -Name BISF -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[Version]$Version = $BISF.Version
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
	$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Title -like "Citrix Workspace*" -and $_.Stream -eq "Current"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[version]$Version = $WSA.Version
	$URL = $WSA.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		if (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\Current")) {New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\Windows\Current\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\Windows\Current\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version Current Release"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\Citrix\$Product\Windows\Current\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Copy-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\CitrixWorkspaceApp.exe" -Destination "$SoftwareFolder\Citrix\$Product\Windows\Current\CitrixWorkspaceAppWeb.exe" | Out-Null
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


# Download Microsoft EdgeWebView2 Runtime
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true) {
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
	$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Title -like "Citrix Workspace*" -and $_.Stream -eq "LTSR"} -ErrorAction Stop
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
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR")) {New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\Windows\LTSR\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\Windows\LTSR\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version LTSR Release"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\Citrix\$Product\Windows\LTSR\" + ($Source))
		Try {
		Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\Windows\LTSR\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Copy-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\CitrixWorkspaceApp.exe" -Destination "$SoftwareFolder\Citrix\$Product\Windows\LTSR\CitrixWorkspaceAppWeb.exe" | Out-Null
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


# Download 7-ZIP
IF ($SoftwareSelection.SevenZip -eq $true) {
	$Product = "7-Zip"
	$PackageName = "7-Zip_x64"
	Try {
	$7Zip = Get-EvergreenApp -Name 7zip | Where-Object {$_.Architecture -eq "x64" -and $_.URI -like "*exe*"} -ErrorAction Stop
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


<#
# Download Adobe Reader DC x64 MUI Update
IF ($SoftwareSelection.AdobeReaderDCx64_MUI -eq $true) {
	$Product = "Adobe Reader DC x64 MUI"
	$PackageName = "Adobe_DC_MUI_x64_Update"
	$InstallerType = "msp"
	$Source = "$PackageName" + "." + "$InstallerType"
	Try {
	$URLVersionAdobe = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
	$webRequestAdobe = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionAdobe) -SessionVariable websession
	$regexAppVersionAdobe = "<AcrobatReaderDCVer>.*"
	$webVersionAdobe = $webRequestAdobe.RawContent | Select-String -Pattern $regexAppVersionAdobe -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	$VersionAdobe = $webVersionAdobe.Trim("<AcrobatReaderDCVer>").Trim("</AcrobatReaderDCVer>")
	$VersionAdobeTrim = $VersionAdobe -replace ("\.","")
	$VersionAdobeDownload = ("AcroRdrDCx64Upd" + "$VersionAdobeTrim" + "_MUI" + ".msp")
	} catch {
		Write-Warning "Failed to find update of $Product"
		}
	$URL = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/$VersionAdobeTrim/$VersionAdobeDownload"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionAdobe"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionAdobe) {
		IF (!($CurrentVersion -eq $VersionAdobe)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionAdobe.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionAdobe"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionAdobe"
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
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product\Install" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Install\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\Install\" + ($Source))
		Try {
			Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\Install\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		expand-archive -path "$SoftwareFolder\$Product\Install\FSLogixAppsSetup.zip" -destinationpath "$SoftwareFolder\$Product\Install"
		Remove-Item -Path "$SoftwareFolder\$Product\Install\FSLogixAppsSetup.zip" -Force
		Move-Item -Path "$SoftwareFolder\$Product\Install\x64\Release\*" -Destination "$SoftwareFolder\$Product\Install"
		Remove-Item -Path "$SoftwareFolder\$Product\Install\Win32" -Force -Recurse
		Remove-Item -Path "$SoftwareFolder\$Product\Install\x64" -Force -Recurse
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\Install\$Source")) {
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
	$Teams = Get-EvergreenApp -Name MicrosoftTeams | Where-Object {$_.Architecture -eq 'x64' -and $_.Type -eq 'MSI' -and $_.Ring -eq 'General'} -ErrorAction Stop
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


# Download MS OneDrive
IF ($SoftwareSelection.MSOneDrive -eq $true) {
	$Product = "MS OneDrive"
	$PackageName = "OneDriveSetup"
	Try {
	$OneDrive = Get-EvergreenApp -Name MicrosoftOneDrive | Where-Object {$_.Ring -eq "Production" -and $_.Type -eq "exe" -and $_.Architecture -eq "AMD64"} | Select-Object -First 1 -ErrorAction Stop
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
		IF ($Download) {
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MS365Apps_SACUpdate = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  }
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
		IF ($Download) {
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MS365Apps_MECUpdate = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  }
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
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		IF ($Download) {
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MSOffice_Update = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  }
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
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		IF ($Download) {
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MSOffice_Update = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  }
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
	$Version = $MSPowershell.Version
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
IF ($SoftwareSelection.MSDotNetFramework -eq $true) {
	$Product = "MS DotNet Framework"
	$PackageName = "DotNetFramework-runtime"
	Try {
	$MSDotNetFramework = Get-EvergreenApp -Name Microsoft.NET | Where-Object {$_.Architecture -eq "x64" -and $_.Channel -eq "LTS" -and $_.Installer -eq "runtime"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSDotNetFramework.Version
	$URL = $MSDotNetFramework.uri
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
	$MSSQLManagementStudioEN = Get-EvergreenApp -Name MicrosoftSsms | Where-Object {$_.Language -eq "English"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSQLManagementStudioEN.Version
	$URL = $MSSQLManagementStudioEN.uri
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
	$MSSQLManagementStudioDE = Get-EvergreenApp -Name MicrosoftSsms | Where-Object {$_.Language -eq "German"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSQLManagementStudioDE.Version
	$URL = $MSSQLManagementStudioDE.uri
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

# Download Citrix Hypervisor Tools
IF ($SoftwareSelection.CitrixHypervisorTools -eq $true) {
	$Product = "Citrix Hypervisor Tools"
	$PackageName = "managementagentx64"
	Try {
	$CitrixTools = Get-EvergreenApp -Name CitrixVMTools | Where-Object {$_.Architecture -eq "x64"} | Select-Object -First 1
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $CitrixTools.Version
	$URL = $CitrixTools.uri
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


# Download Citrix Files
IF ($SoftwareSelection.CitrixFiles -eq $true) {
	$Product = "Citrix Files"
	$PackageName = "CitrixFiles"
	Try {
	$CitrixFiles = Get-NevergreenApp -Name CitrixFiles | Where-Object {$_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $CitrixFiles.Version
	$URL = $CitrixFiles.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product")) {New-Item -Path "$SoftwareFolder\Citrix\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\\Citrix\$Product\" + ($Source))
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
		#Invoke-WebRequest -UseBasicParsing -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		expand-archive -path "$SoftwareFolder\$Product\deviceTRUST.zip" -destinationpath "$SoftwareFolder\$Product" -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\deviceTRUST.zip" -Force -EA SilentlyContinue
		expand-archive -path "$SoftwareFolder\$Product\dtpolicydefinitions-$Version.0.zip" -destinationpath "$SoftwareFolder\$Product\ADMX" -EA SilentlyContinue
		copy-item -Path "$SoftwareFolder\$Product\ADMX\*" -Destination "$PSScriptRoot\ADMX\deviceTRUST" -Force -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\ADMX" -Force -Recurse -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\dtpolicydefinitions-$Version.0.zip" -Force -EA SilentlyContinue
		Get-ChildItem -Path "$SoftwareFolder\$Product" | Where-Object Name -like *"x86"* | Remove-Item -EA SilentlyContinue
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


# Download openJDK
IF ($SoftwareSelection.OpenJDK -eq $true) {
	$Product = "open JDK 8"
	$PackageName = "OpenJDK"
	Try {
	$OpenJDK = Get-EvergreenApp -Name OpenJDK | Where-Object {$_.Architecture -eq "x64" -and $_.URI -like "*msi*" -and $_.Version -like "1.8*"} | Sort-Object -Property Version -Descending | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$VersionOpenJDK = $OpenJDK.Version
	[Version]$VersionOpenJDK = $VersionOpenJDK -replace ".{6}$"
	$URL = $OpenJDK.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionOpenJDK"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionOpenJDK) {
		IF ($VersionOpenJDK -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionOpenJDK.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionOpenJDK"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionOpenJDK"
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
	$KeePass = Get-EvergreenApp -Name KeePass | Where-Object {$_.URI -like "*exe*"} -ErrorAction Stop
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
	$Version = $mRemoteNG.Version
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
	$WinSCP = Get-EvergreenApp -Name WinSCP -ErrorAction Stop
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
	$putty = Get-NevergreenApp -Name SimonTathamPuTTY | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
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


# Download Zoom VDI Installer
IF ($SoftwareSelection.ZoomVDI -eq $true) {
	$Product = "Zoom VDI Host"
	$PackageName = "ZoomInstallerVDI"
	Try {
	$ZoomVDI = Get-NevergreenApp -Name Zoom | Where-Object {$_.Name -eq "Zoom VDI Client"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ZoomVDI.Version
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


# Download Zoom Citrix client
IF ($SoftwareSelection.ZoomCitrix -eq $true) {
	$Product = "Zoom Citrix Client"
	$PackageName = "ZoomCitrixHDXMediaPlugin"
	Try {
	$ZoomCitrix = Get-NevergreenApp -Name Zoom | Where-Object {$_.Name -eq "Zoom Citrix HDX Media Plugin"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ZoomCitrix.Version
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
# Download Cisco WebEx VDI Plugin
IF ($SoftwareSelection.CiscoWebExVDI -eq $true) {
$Product = "Cisco WebEx VDI Plugin"
$PackageName = "WebExVDIPlugin"
$URLVersion = "https://www.webex.com/downloads/teams-vdi.html"
$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
$regexAppVersion = "\d\d.\d.\d.\d\d\d\d\d+"
$webVersion = $webRequest.RawContent | Select-String -Pattern $regexAppVersion -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
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



# Download Cisco WebEx Desktop
IF ($SoftwareSelection.CiscoWebExDesktop -eq $true) {
$Product = "Cisco WebEx Desktop"
$PackageName = "WebEx"
$CiscoWebExDesktop = Get-EvergreenApp -Name CiscoWebEx | Where-Object {$_.Type -eq "Desktop"}
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


# Download ImageGlass
IF ($SoftwareSelection.ImageGlass -eq $true) {
	$Product = "ImageGlass"
	$PackageName = "ImageGlass"
	Try {
	$ImageGlass = Get-EvergreenApp -Name ImageGlass | Where-Object {$_.Architecture -eq "x64"} | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ImageGlass.Version
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


# Download Greenshot
IF ($SoftwareSelection.Greenshot -eq $true) {
	$Product = "Greenshot"
	$PackageName = "Greenshot"
	Try {
	$Greenshot = Get-EvergreenApp -Name Greenshot | Where-Object {$_.Type -eq "exe"} | Select-Object -Last 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $Greenshot.Version
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


# Stop UpdateLog
Stop-Transcript | Out-Null

# Format UpdateLog
$Content = Get-Content -Path $UpdateLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $UpdateLog

if ($noGUI -eq $False) {pause}

