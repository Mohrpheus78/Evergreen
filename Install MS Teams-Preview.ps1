# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs MS-Teams VDI installer on a MCS/PVS master server/client or wherever you want. An old version will first be uninstalled.
		
.Description
Use the Software Updater script first, to check if a new version is available! After that use the Software Installer script. If you select this software
package it will be first uninstalled after that it gets installed. 
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
$Product = "MS Teams - Preview Release"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "$Product" 		            # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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
	"ALLUSER=1"
	"ALLUSERS=1"
	"OPTIONS='noAutoStart=true'"
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
$Teams = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Teams Machine*"}).DisplayVersion
IF ($Teams) {$Teams = $Teams.Insert(5,'0')}
IF ($Teams -ne $Version) {

#Uninstalling MS Teams
Write-Host -ForegroundColor Yellow "Uninstalling $Product"
DS_WriteLog "I" "Uninstalling $Product" $LogFile
try {
    $UninstallTeams = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Teams Machine*"}).UninstallString
	$UninstallTeams = $UninstallTeams -Replace("MsiExec.exe /I","")
	Start-Process -FilePath msiexec.exe -ArgumentList "/X $UninstallTeams /qn"
	Start-Sleep 20
    } catch {
DS_WriteLog "E" "Ein Fehler ist aufgetreten beim Deinstallieren von $Product (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile
Write-Host -ForegroundColor Green " ...ready!" 
Write-Output ""

#MS Teams Installation
Write-Host -ForegroundColor Yellow "Installing $Product"
DS_WriteLog "I" "Installing $Product" $LogFile
try {
    "$PSScriptRoot\$Product\Teams_windows_x64.msi" | Install-MSIFile
	} catch {
DS_WriteLog "E" "Error installing $Product (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile

# Configure Teams Settings with json template
copy-item -Path "$PSScriptRoot\$Product\desktop-config.json" -Destination "C:\USers\Default\AppData\Roaming\Microsoft\Teams"

# Prevents MS Teams from starting at logon
Start-Sleep 5
Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Teams" -Force
Write-Host -ForegroundColor Green " ...ready!" 
Write-Output ""
}

# Stop, if no new version is available
Else {
Write-Host "No Update available for $Product"
Write-Output ""
}