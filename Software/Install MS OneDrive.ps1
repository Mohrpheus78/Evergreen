﻿# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs OneDrive on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "MS OneDrive"

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
	[version]$OneDrive = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*OneDrive*"}).DisplayVersion
	IF ($OneDrive -ne $Version) {

	# Delete all scheduled reporting tasks
	<#
	$OneDriveReportingTasks = Get-ScheduledTask -EA SilentlyContinue | Where-Object {$_.TaskName -like "OneDrive Reporting*"} | Select-Object -ExpandProperty TaskName
		foreach ($TaskName in $OneDriveReportingTasks) {
			schtasks /delete /tn "$TaskName" /f
		}
	#>

	# Installation OneDrive
	Write-Host -ForegroundColor Yellow "Installing $Product"
	DS_WriteLog "I" "Installing $Product" $LogFile
	try	{
		$null = Start-Process "$PSScriptRoot\$Product\OneDriveSetup.exe" –ArgumentList '/allusers' –NoNewWindow -PassThru
		while (Get-Process -Name "OneDriveSetup" -ErrorAction SilentlyContinue) {
			Start-Sleep -Seconds 10
			}
		# OneDrive starts automatically after setup. Kill process!
		if (Get-Process -Name "OneDrive" -EA SilentlyContinue) {
			Stop-Process -Name "OneDrive" -Force
		}
			DS_WriteLog "-" "" $LogFile
			Write-Host -ForegroundColor Green "...ready"
			Write-Output ""
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing $Product (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"
				Write-Output ""    
				}
	}

	IF ((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*OneDrive*"}).DisplayVersion) {
		$OneDriveTasks= (Get-ScheduledTask -EA SilentlyContinue | Where-Object {$_.TaskName -like "OneDrive*"}).TaskName
		foreach ($Task in $OneDriveTasks) {
			Disable-ScheduledTask -EA SilentlyContinue -TaskName $Task | Out-Null
			}
		If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive")) {
			New-Item "HKLM:\SOFTWARE\Policies\Microsoft" -Name "OneDrive" -Force | Out-Null
			}
		New-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\" -Name "GPOSetUpdateRing" -Value 0 -PropertyType "DWORD" -Force | Out-Null
		Set-Service -Name "OneDrive Updater Service" -StartupType Disabled
		Stop-Service -Name "OneDrive Updater Service" -Force		
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
