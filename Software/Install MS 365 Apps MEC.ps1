﻿# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs 365 Apps on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "MS 365 Apps-Monthly Enterprise Channel"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "$Product" 		    # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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
	[version]$MS365Apps = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft 365 Apps*"}).DisplayVersion | Select-Object -First 1
	[version]$MS365Apps = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft 365 Apps*"}).DisplayVersion | Select-Object -First 1
	IF ($MS365Apps -lt $Version) {

	# Installation MS 365 Apps-Monthly Enterprise Channel
	Write-Host -ForegroundColor Yellow "Installing $Product"
	DS_WriteLog "I" "Installing $Product" $LogFile
	try	{
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
		if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
			Write-Host -ForegroundColor DarkRed "Achtung! Keine Configuration.xml Datei gefunden, Office kann nicht installiert werden! Bitte eine XML Datei erstellen!" }
		else {
			  $InstallArgs = "/Configure `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
			  Start-Process "$SoftwareFolder\$Product\setup.exe" -ArgumentList $InstallArgs -NoNewWindow -Wait
			  }
		} catch {
	DS_WriteLog "E" "Error installing $Product (error: $($Error[0]))" $LogFile       
	}
	DS_WriteLog "-" "" $LogFile
	Write-Host -ForegroundColor Green "...ready"
	Write-Output ""
}
Else {
	Write-Host -ForegroundColor Red "Version file not found for $Product"
	Write-Output ""
	}

}
# Stop, if no new version is available
Else {
Write-Host "No Update available for $Product"
Write-Output ""
}