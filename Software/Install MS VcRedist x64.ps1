# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs Microsoft Visual C++ bundle on a MCS/PVS master server/client or wherever you want.
		
.Description
Use the Software Updater script first, to check if a new version is available! After that use the Software Installer script. If you select this software
package it will be installed. 
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
$Product = "Microsoft Visual C++ Redistributable packages x64"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"      # [edit] add the location of your log directory here
$PackageName = "$Product" 		            	# [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

# Global variables
# $StartDir = $PSScriptRoot # the directory path of the script currently being executed
$LogDir = (Join-Path $BaseLogDir "Microsoft Visual C++ Redistributable")
$LogFileName = ("$ENV:COMPUTERNAME - Visual C++ Redistributable_x64.log")
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
	$VcRedist = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft Visual C++ 2022 x64*"}).DisplayVersion | Select-Object -First 1
	IF ([string]::ISNullOrEmpty( $VcRedist) -eq $True) {
		$VcRedist = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft Visual C++ 2019 x64*"}).DisplayVersion | Select-Object -First 1
		}
	$VcRedist = $VcRedist + ".0"
	[version]$VcRedist = [string]$VcRedist
	IF ($VcRedist -lt $Version) {
	# VcRedist
		IF ($SoftwareSelection.VMWareTools -eq $true) {
			Write-Host -ForegroundColor Yellow "Installing $Product, this is a prerequisite for current VMWare Tools"
		}
		Else {
			Write-Host -ForegroundColor Yellow "Installing $Product"
			DS_WriteLog "I" "Installing $Product" $LogFile
		}
		try	{
			Start-Process "$PSScriptRoot\$Product\VC_redist_x64.exe" -ArgumentList "/quiet /norestart" –NoNewWindow -Wait
			DS_WriteLog "-" "" $LogFile
			write-Host -ForegroundColor Green "...ready"
			Write-Host -ForegroundColor Red "Server needs to reboot after installation!"
			Write-Output ""
			} catch {
				Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing $Product (Error: $($Error[0]))" $LogFile   
				Write-Output ""        
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