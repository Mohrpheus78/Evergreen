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

# Variables
$Product = "Google Chrome"

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


# FUNCTION MSI Installation
#========================================================================================================================================
function Install-MSIFile {

[CmdletBinding()]
 Param(
  [parameter(mandatory=$true,ValueFromPipeline=$true,ValueFromPipelinebyPropertyName=$true)]
        [ValidateNotNullorEmpty()]
        [string]$msiFile,

        [parameter()]
        [ValidateNotNullorEmpty()]
        [string]$targetDir
 )
if (!(Test-Path $msiFile)){
    throw "Path to MSI file ($msiFile) is invalid. Please check name and path"
}
$arguments = @(
    "/i"
    "`"$msiFile`""
    "/qn"
)
if ($targetDir){
    if (!(Test-Path $targetDir)){
        throw "Pfad zum Installationsverzeichnis $($targetDir) ist ungültig. Bitte Pfad und Dateinamen überprüfen!"
    }
    $arguments += "INSTALLDIR=`"$targetDir`""
}
$process = Start-Process -FilePath msiexec.exe -ArgumentList $arguments -Wait -NoNewWindow -PassThru
if ($process.ExitCode -eq 0){
    }
else {
    Write-Verbose "Installer Exit Code  $($process.ExitCode) für Datei  $($msifile)"
}
}
#========================================================================================================================================

# Check, if a new version is available
IF (Test-Path -Path "$PSScriptRoot\$Product\Version.txt") {
	[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
	[version]$Chrome = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Google Chrome"}).DisplayVersion
	IF ($Chrome -lt $Version) {

	# Delete all scheduled tasks
	# Unregister-ScheduledTask -EA SilentlyContinue -Confirm:$false | Where-Object {$_.TaskName -like "GoogleUpdaterTaskSystem*"}

	# Google Chrome
	Write-Host -ForegroundColor Yellow "Installing $Product"
	DS_WriteLog "I" "Installing $Product" $LogFile
	try {
		"$PSScriptRoot\$Product\googlechromestandaloneenterprise64.msi" | Install-MSIFile
		} catch {
			DS_WriteLog "-" "" $LogFile
			DS_WriteLog "E" "Error installing $Product (Error: $($Error[0]))" $LogFile
			Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"
			Write-Output ""    
			}
	}
	
	# Stop, if no new version is available
	Else {
	Write-Host "No Update available for $Product"
	Write-Output ""
	}

	IF ((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Google Chrome"}).DisplayVersion) {
	# Disable scheduled tasks
	Start-Sleep -s 3
	Write-Host "Disable scheduled update tasks for Chrome"
	try {
		$ChromeTasks = (Get-ScheduledTask -EA SilentlyContinue | Where-Object {$_.TaskName -like "GoogleUpdate*"})
		foreach ($Task in $ChromeTasks) {
			Disable-ScheduledTask -TaskName $Task.Taskname -TaskPath $Task.TaskPath | Out-Null
			}
		}
	catch {
		DS_WriteLog "E" "Error disabling scheduled tasks for $Product, Error: $($Error[0])" $LogFile
		Write-Host -ForegroundColor Red "Error disabling scheduled tasks for $Product, Error: $($Error[0])"
		}
	}
	Start-Sleep -s 3
	
	# Disable update service
	Write-Host "Disable update service for Chrome"
	try {
		$ChromeServices = (Get-Service | Where-Object {$_.Name -like "GoogleUpdater*" -or $_.Name -like "gupdate*"})
		foreach ($Service in $ChromeServices) {
       		Set-Service -Name $Service.Name -StartupType Disabled -EA SilentlyContinue | Out-Null
			}
		}
	catch {
		DS_WriteLog "E" "Error disabling update services for $Product, Error: $($Error[0])" $LogFile
		Write-Host -ForegroundColor Red "Error disabling update services for $Product, Error: $($Error[0])"
		}
	
	# Disable Active Setup
	Write-Host "Deleting active setup regkeys for Chrome"
	$ChromeKey = (Get-Childitem -recurse "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components" -Exclude 'AutorunsDisabled' | Get-Itemproperty | Where-Object { $_ -like '*Chrome*' }).PSChildName | Select-Object -First 1
	IF ($ChromeKey) {
		Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\$ChromeKey" -EA SilentlyContinue | Out-Null
	}

	DS_WriteLog "-" "" $LogFile
	write-Host -ForegroundColor Green "...ready"
	Write-Output ""
}
Else {
Write-Host -ForegroundColor Red "Version file not found for $Product"
Write-Output ""
}