﻿# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs Google Chrome on a MCS/PVS master server/client or wherever you want.
		
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

$Product = "Oracle Java 8 x64"

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
if (!(Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType directory | Out-Null }

# Create new log file (overwrite existing one)
New-Item $LogFile -ItemType "file" -force | Out-Null

DS_WriteLog "I" "START SCRIPT - $PackageName" $LogFile
DS_WriteLog "-" "" $LogFile
#========================================================================================================================================

# Check, if a new version is available
IF (Test-Path -Path "$PSScriptRoot\$Product\Version.txt") {
	[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
	$JavaVersion = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Java*Update* (64-bit)"}).DisplayVersion
	IF ([string]::ISNullOrEmpty( $JavaVersion) -eq $False) {
	# $Subfolder = (Get-ChildItem -Path "C:\Program Files\Java").Name | Select-Object -First 1
	$Java = Get-Content -Path "C:\Program Files\Java\latest\jre-1.8\release" -TotalCount 1 -EA SilentlyContinue
	IF (!($Java)) {
		$Java = Get-Content -Path "C:\Program Files\Java\jre-1.8\release" -TotalCount 1 -EA SilentlyContinue
		}
	$Java = $Java -replace ("JAVA_VERSION=","")
	$Java = $Java.TrimEnd('"')
	$Java = $Java.Substring(1)
	[version]$Java = $Java -replace "_","."
	}
	# Install Oracle Java 8 if new version or not installed
	IF ($Java -lt $Version) {
	Write-Host -ForegroundColor Yellow "Installing $Product"
	DS_WriteLog "I" "Installing $Product" $LogFile
	try	{
		Start-Process "$PSScriptRoot\$Product\Oracle Java 8 x64.exe" –ArgumentList 'INSTALL_SILENT=1 STATIC=0 AUTO_UPDATE=0 WEB_JAVA=1 WEB_JAVA_SECURITY_LEVEL=M WEB_ANALYTICS=0 EULA=0 REBOOT=0 SPONSORS=0 REMOVEOUTOFDATEJRES=1' –NoNewWindow -Wait
		DS_WriteLog "-" "" $LogFile
		Write-Host -ForegroundColor Green " ...fertig!"
		Write-Output ""
		} catch {
			DS_WriteLog "-" "" $LogFile
			DS_WriteLog "E" "Error installing $Product (Error: $($Error[0]))" $LogFile
			Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"
			Write-Output ""    
		}
	
		IF ((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Java*Update* (64-bit)"}).InstallLocation) {
			REG ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableJavaUpdate /t REG_DWORD /d 0 /f | Out-Null
			REG ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v EnableAutoUpdateCheck /t REG_DWORD /d 0 /f | Out-Null
			REG ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyDownload /t REG_DWORD /d 0 /f | Out-Null
			REG ADD "HKLM\SOFTWARE\JavaSoft\Java Update\Policy" /v NotifyInstall /t REG_DWORD /d 0 /f | Out-Null
			REG DELETE "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /v SunJavaUpdateSched /f | Out-Null
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