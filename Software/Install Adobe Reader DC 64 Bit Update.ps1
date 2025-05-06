# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the current Adobe Acrobat DC MUI 64 Bit Update on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "Adobe Reader DC x64 MUI"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "$Product" 		            # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

# Global variables
# $StartDir = $PSScriptRoot # the directory path of the script currently being executed
$LogDir = (Join-Path $BaseLogDir $PackageName)
$LogFileName = ("$ENV:COMPUTERNAME - $PackageName.log")
$LogFile = Join-path $LogDir $LogFileName

# Create the log directory if it does not exist
IF (!(Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType directory | Out-Null }

# Create new log file (overwrite existing one)
New-Item $LogFile -ItemType "file" -force | Out-Null

DS_WriteLog "I" "START SCRIPT - $PackageName" $LogFile
DS_WriteLog "-" "" $LogFile
#========================================================================================================================================

# Check, if a new version is available
IF (Test-Path -Path "$PSScriptRoot\$Product\Version.txt") {
	[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
	[version]$Adobe = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Adobe Acrobat (64-bit)"}).DisplayVersion | Select-Object -Last 1
	IF ($Adobe -lt $Version) {

	# Adobe Reader DC Update
	Write-Host -ForegroundColor Yellow "Installing $Product Update"
	DS_WriteLog "I" "Installing $Product Update" $LogFile
	try {
		$mspArgs = "/P `"$PSScriptRoot\$Product\Adobe_DC_MUI_x64_Update.msp`" /quiet /qn"
		Start-Process -FilePath msiexec.exe -ArgumentList $mspArgs -Wait
	} catch {
		DS_WriteLog "-" "" $LogFile
		DS_WriteLog "E" "Error installing $Product Update (Error: $($Error[0]))" $LogFile
		Write-Host -ForegroundColor Red "Error installing $Product Update (Error: $($Error[0]))"
		Write-Output "" 
	}
		# Disable update service
		if (Get-Service -Name AdobeARMservice -EA SilentlyContinue) {
			Start-Sleep 3
			Stop-Service AdobeARMservice
			Set-Service AdobeARMservice -StartupType Disabled
			New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Name "bAcroSuppressUpsell" -Value 1 -PropertyType DWORD -Force
			New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" -Name "bAcroSuppressUpsell" -Value 1 -PropertyType DWORD -Force
		}
		# Disable scheduled task
		Get-ScheduledTask -TaskName "Adobe Acrobat Update Task" -EA SilentlyContinue | Disable-ScheduledTask | Out-Null

		DS_WriteLog "-" "" $LogFile
		write-Host -ForegroundColor Green "...ready"
		Write-Output ""
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