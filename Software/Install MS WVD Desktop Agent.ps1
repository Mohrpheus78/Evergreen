﻿# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the current MS WVD Desktop Agent on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "MS WVD Desktop Agent"

#========================================================================================================================================
# Logging
$BaseLogDir = $ENV:Temp       				# [edit] add the location of your log directory here, local folder because network gets interrupted 
$PackageName = "MS WVD Desktop Agent" 	 # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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
	"REGISTRATIONTOKEN=$REGISTRATIONTOKEN"
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
$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
$MSWVDDesktopAgent = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Remote Desktop Services Infrastructure*"}).InstallDate
IF ($MSWVDDesktopAgent) {$MSWVDDesktopAgent = $MSWVDDesktopAgent.Insert(4,'-')}
IF ($MSWVDDesktopAgent) {$MSWVDDesktopAgent = $MSWVDDesktopAgent.Insert(7,'-')}
IF ($MSWVDDesktopAgent) {$MSWVDDesktopAgent = [datetime]$MSWVDDesktopAgent}

IF ($MSWVDDesktopAgent -lt $Version) {
	
# MS WVD Desktop Agent Installation
Write-Host -ForegroundColor Yellow "Installing $Product"
DS_WriteLog "I" "Installing $Product" $LogFile
try {
	"$PSScriptRoot\$Product\Microsoft.RDInfra.RDAgent.Installer-x64.msi" | Install-MSIFile
	} catch {
DS_WriteLog "E" "Error while installing $Product (error: $($Error[0]))" $LogFile 
copy-item $LogFile "$PSScriptRoot\_Install Logs" 
}
Write-Host -ForegroundColor Green "...ready"
Write-Output ""
}

# Stop, if no new version is available
Else {
Write-Host "No Update available for $Product"
Write-Output ""
}
