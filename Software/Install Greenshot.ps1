# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the current Zoom VDI Host on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "Greenshot"

#========================================================================================================================================
# Logging
$BaseLogDir = $ENV:Temp       				# [edit] add the location of your log directory here, local folder because network gets interrupted 
$PackageName = "Greenshot" 	 # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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


# Check, if a new version is available
IF (Test-Path -Path "$PSScriptRoot\$Product\Version.txt") {
	[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
	[version]$Greenshot = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Greenshot*"}).DisplayVersion
	IF ($Greenshot -lt $Version) {
		$Options = @(
					"/VERYSILENT"
					"/NORESTART"
					"/NORESTARTAPPLICATIONS"
					"/SUPPRESSMSGBOXES"
					"/LOADINF=Greenshot.inf"
				)
		
	# Greenshot Installation
	Write-Host -ForegroundColor Yellow "Installing $Product"
	DS_WriteLog "I" "Installing $Product" $LogFile
	try {
		$inst = Start-Process -FilePath "$PSScriptRoot\$Product\Greenshot.exe" -ArgumentList $Options -PassThru -ErrorAction Stop
			If ($inst) {
			Wait-Process -InputObject $inst
			Write-Host -ForegroundColor Green "...ready"
			}
		} catch {
	DS_WriteLog "E" "Error while installing $Product (error: $($Error[0]))" $LogFile 
	}
	DS_WriteLog "-" "" $LogFile
	Write-Host -ForegroundColor Green "...ready"
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
