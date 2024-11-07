# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the current Adobe Acrobat DC MUI x86 on a MCS/PVS master server/client or wherever you want.
		
.Description
Use the Software Updater script first, to check if a new version is available! After that use the Software Installer script. If you select this software
package it gets installed. 
The script compares the software version and will install or update the software. A log file will be created in the 'Install Logs' folder. 

.EXAMPLE

.NOTES
Always call this script with the Software Installer script!
#>

# define Error handling
# note: do not change these values
$global:ErrorActionPreference = "Stop"
if($verbose){ $global:VerbosePreference = "Continue" }

# Variables
$Product = "Adobe Reader DC MUI"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "Adobe Reader DC" 		            # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

# Global variables
# $StartDir = $PSScriptRoot # the directory path of the script currently being executed
$LogDir = (Join-Path $BaseLogDir $PackageName)
$LogFileName = ("$ENV:COMPUTERNAME - $PackageName.log")
$LogFile = Join-path $LogDir $LogFileName

# Create the log directory if it does not exist
if (!(Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType directory | Out-Null }

# Create new log file (overwrite existing one)
New-Item $LogFile -ItemType "file" -force | Out-Null

DS_WriteLog "I" "START SCRIPT - $PackageName" $LogFile
DS_WriteLog "-" "" $LogFile
#========================================================================================================================================

# Adobe Reader Installation
IF (!(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Adobe Acrobat Reader MUI*"})) {
Write-Host -ForegroundColor Yellow "Installing $Product"
DS_WriteLog "I" "Installing $Product" $LogFile
try {
	$msiArgs = "/I `"$PSScriptRoot\$Product\AcroRead.msi`" ALLUSERS=TRUE TRANSFORMS=`"$PSScriptRoot\$Product\XenApp.mst`" /quiet /qn"
	Start-Process -FilePath msiexec.exe -ArgumentList $msiArgs -Wait
	DS_WriteLog "-" "" $LogFile
	write-Host -ForegroundColor Green "...ready"
	Write-Output ""
	Copy-Item "$PSScriptRoot\$Product\Werkzeuge_ausblenden\Viewer.aapp" "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\DEU" -Recurse -Force -EA SilentlyContinue
	Copy-Item "$PSScriptRoot\$Product\Werkzeuge_ausblenden\Viewer.aapp" "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU" -Recurse -Force -EA SilentlyContinue
	} catch {
		DS_WriteLog "-" "" $LogFile
		DS_WriteLog "E" "Error installing $Product (Error: $($Error[0]))" $LogFile
		Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"
		Write-Output "" 
		}
}
ELSE {
	DS_WriteLog "-" "" $LogFile
	Write-Host -ForegroundColor Green "$Product already installed"
	Write-Output ""
}

# Check, if a new version is available
IF (Test-Path -Path "$PSScriptRoot\$Product\Version.txt") {
	[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
	[version]$Adobe = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Adobe Acrobat Reader*"}).DisplayVersion | Select-Object -Last 1
	IF ($Adobe -lt $Version) {
	# Adobe Reader DC Update
	Write-Host -ForegroundColor Yellow "Installing Adobe Reader DC Update"
	DS_WriteLog "I" "Installing Adobe Reader DC Update" $LogFile
	try {
		$mspArgs = "/P `"$PSScriptRoot\$Product\Adobe_DC_MUI_Update.msp`" /quiet /qn"
		Start-Process -FilePath msiexec.exe -ArgumentList $mspArgs -Wait
		DS_WriteLog "-" "" $LogFile
		write-Host -ForegroundColor Green "...ready"
		Write-Output ""	
		} catch {
			DS_WriteLog "-" "" $LogFile
			DS_WriteLog "E" "Error installing Adobe Reader DC x64 Update (Error: $($Error[0]))" $LogFile
			Write-Host -ForegroundColor Red "Error installing Adobe Reader DC x64 Update (Error: $($Error[0]))"
			Write-Output "" 
			}

		IF (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Adobe Acrobat Reader MUI*"}) {
		# Disale update service and scheduled task
		if (Get-Service -Name AdobeARMservice) {
			Start-Sleep 5
			Stop-Service AdobeARMservice
			Set-Service AdobeARMservice -StartupType Disabled
			Disable-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Out-Null
		}
		}
	}

	# Stop, if no new version is available
	Else {
	Write-Host "No Update available for $Product"
	Write-Output ""
	}
}
Else {
Write-Host -ForegroundColor Red "Version file not found for $Product"
Write-Output ""
}