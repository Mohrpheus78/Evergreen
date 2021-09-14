# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs TreeSizeFree on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "PVS Target Device CR/Cloud"
$InstDir = Split-Path $PSScriptRoot -Parent

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

# Ask again
Write-host -ForegroundColor Gray -BackgroundColor DarkRed "Do you want to update the Citrix PVS Client, otherwise please uncheck in the selection!"
Write-Host ""
    $Frage = Read-Host "( y / n )"
	IF ($Frage -eq 'n') {
	Write-Host ""
	Write-host -ForegroundColor Red "Update canceled!"
	Write-Host ""
	BREAK
	}
Write-Host ""

# Installation PVS Target Device CR/Cloud
Write-Host -ForegroundColor Yellow "Installing $Product"
IF (!(Test-Path "$InstDir\Citrix\Current\PVS")) {
		Write-Host ""
		Write-host -ForegroundColor Red "Installation path not valid, please check '$InstDir\Citrix\Current\PVS'!"
		BREAK }
DS_WriteLog "I" "Installing $Product" $LogFile
try	{
	Start-Process "$InstDir\Citrix\Current\PVS\Device\PVS_Device_x64.exe" -ArgumentList '/S /v"/qn /norestart' -NoNewWindow -Wait
	} catch {
DS_WriteLog "E" "Error installing $Product (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile

# Remove Status Tray from autostart
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name StatusTray -Force -EA SilentlyContinue

Write-Host -ForegroundColor Green " ...ready!" 
Write-Output ""
Write-Host -ForegroundColor Red "Server needs to reboot, start script again after reboot to update Citrix VDA"
Write-Output "Hit any key to reboot server"
Read-Host
Restart-Computer


