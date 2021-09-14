# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the current Adobe Acrobat DC MUI on a MCS/PVS master server/client or wherever you want.
		
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
$StartDir = $PSScriptRoot # the directory path of the script currently being executed
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
IF (!(Test-Path -Path "C:\Program Files (x86)\Adobe\Acrobat Reader DC")) {
Write-Host -ForegroundColor Yellow "Installing $Product"
DS_WriteLog "I" "Installing $Product" $LogFile
try {
	$msiArgs = "/I `"$PSScriptRoot\$Product\AcroRead.msi`" ALLUSERS=TRUE TRANSFORMS=`"$PSScriptRoot\$Product\XenApp.mst`" /quiet /qn"
	Start-Process -FilePath msiexec.exe -ArgumentList $msiArgs -Wait
	cp "$PSScriptRoot\$Product\Werkzeuge_ausblenden\Viewer.aapp" "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\DEU" -Recurse -Force -EA SilentlyContinue
	cp "$PSScriptRoot\$Product\Werkzeuge_ausblenden\Viewer.aapp" "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroApp\ENU" -Recurse -Force -EA SilentlyContinue
	} catch {
DS_WriteLog "E" "Error while installing $Product (error: $($Error[0]))" $LogFile 
}
}
Write-Host -ForegroundColor Green "...ready"
Write-Output ""

# Adobe Reader DC Update
Write-Host -ForegroundColor Yellow "Installing Adobe Reader DC Update"
DS_WriteLog "I" "Installing Adobe Reader DC Update" $LogFile
try {
	$mspArgs = "/P `"$PSScriptRoot\$Product\Adobe_DC_MUI_Update.msp`" /quiet /qn"
	Start-Process -FilePath msiexec.exe -ArgumentList $mspArgs -Wait	
	} catch {
DS_WriteLog "E" "Error while installing Adobe Reader DC Update (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile

# Disale update service and scheduled task
Start-Sleep 5
Stop-Service AdobeARMservice
Set-Service AdobeARMservice -StartupType Disabled
Disable-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Out-Null
Write-Host -ForegroundColor Green "...ready"
Write-Output ""
