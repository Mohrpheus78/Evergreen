# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the current Adobe Acrobat DC MUI Update on a MCS/PVS master server/client or wherever you want.
		
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
$StartDir = $PSScriptRoot # the directory path of the script currently being executed
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
[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
[version]$Adobe = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Adobe Acrobat DC*"}).DisplayVersion
IF ($Adobe -lt $Version) {

# Adobe Reader DC Update
Write-Host -ForegroundColor Yellow "Installing $Product"
DS_WriteLog "I" "Installing $Product" $LogFile
try {
	$mspArgs = "/P `"$PSScriptRoot\$Product\Adobe_DC_MUI_x64_Update.msp`" /quiet /qn"
	Start-Process -FilePath msiexec.exe -ArgumentList $mspArgs -Wait
	} catch {
DS_WriteLog "E" "Error installinng $Product (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile

# Disale update service and scheduled task
Start-Sleep 5
Stop-Service AdobeARMservice
Set-Service AdobeARMservice -StartupType Disabled
Disable-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Out-Null
write-Host -ForegroundColor Green "...ready"
Write-Output ""
}

# Stop, if no new version is available
Else {
Write-Host "No Update available for $Product"
Write-Output ""
}