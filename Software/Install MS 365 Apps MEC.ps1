# *****************************************************
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

# Check, if a new version is available
IF (Test-Path -Path "$PSScriptRoot\$Product\Version.txt") {
	[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
	[version]$MS365Apps = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft 365 Apps*"}).DisplayVersion | Select-Object -First 1
	[version]$MS365Apps = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft 365 Apps*"}).DisplayVersion | Select-Object -First 1
	IF ($MS365Apps -lt $Version) {

	# Installation MS 365 Apps-Monthly Enterprise Channel
	Write-Host -ForegroundColor Yellow "Installing $Product"
	DS_WriteLog "I" "Installing $Product" $LogFile

	# Move FSLogix Rules
	DS_WriteLog "I" "FSLogix rules will be temporarily moved, if there are any" $LogFile
	New-Item -Path "C:\Program Files\FSLogix\Apps\Rules" -Name WU -ItemType Directory -EA SilentlyContinue | Out-Null
	Move-Item -Path "C:\Program Files\FSLogix\Apps\Rules\*.*" "C:\Program Files\FSLogix\Apps\Rules\WU" | Out-Null	

	try	{
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
		if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
			Write-Host -ForegroundColor DarkRed "Attention! No Office configuration file (XML) found, Office cannot be installed! Please create a XML configuration file!"
			}
		else {
			  $InstallArgs = "/Configure `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
			  Start-Process "$SoftwareFolder\$Product\setup.exe" -ArgumentList $InstallArgs -NoNewWindow -Wait
			  DS_WriteLog "-" "" $LogFile
			  Write-Host -ForegroundColor Green "...ready"
			  Write-Output ""
			  }
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing $Product (Error: $($Error[0])))" $LogFile
				Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"
				Write-Output ""    
				}

	# Move FSLogix rules back
	DS_WriteLog "I" "Moving FSLogix rules back to rules folder" $LogFile
	Move-Item -Path "C:\Program Files\FSLogix\Apps\Rules\WU\*.*" "C:\Program Files\FSLogix\Apps\Rules" | Out-Null

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