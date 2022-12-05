# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs MS-Edge on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "MS Edge"

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
    "/qn"
    "DONOTCREATEDESKTOPSHORTCUT=TRUE"
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
	[version]$Edge = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft Edge"} | Select-Object -First 1).DisplayVersion
	IF ($Edge -lt $Version) {

	# MS Edge
	Write-Host -ForegroundColor Yellow "Installing $Product"
	DS_WriteLog "I" "Installing $Product" $LogFile
	try {
		"$PSScriptRoot\$Product\MicrosoftEdgeEnterpriseX64.msi" | Install-MSIFile
		} catch {
	DS_WriteLog "E" "Error installing $Product (error: $($Error[0]))" $LogFile       
	}
	DS_WriteLog "-" "" $LogFile

	# Disable scheduled tasks
	Start-Sleep -s 5
	$EdgeTasks= (Get-ScheduledTask | Where-Object {$_.TaskName -like "MicrosoftEdge*"}).TaskName
	foreach ($Task in $EdgeTasks) {
		Disable-ScheduledTask -TaskName $Task -EA SilentlyContinue | Out-Null
		} 

	# Disable Active Setup
	$EdgeKey = (Get-Childitem -recurse "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components" | Get-Itemproperty | Where-Object { $_  -match 'Edge' }).PSChildName | Select-Object -First 1
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\$EdgeKey" -EA SilentlyContinue

	# Disable Citrix API Hooks (MS Edge) on Citrix VDA
	$(
	$RegPath = "HKLM:SYSTEM\CurrentControlSet\services\CtxUvi"
	IF (Test-Path $RegPath) {
	$RegName = "UviProcessExcludes"
	$EdgeRegvalue = "msedge.exe"
	# Get current values in UviProcessExcludes
	$CurrentValues = Get-ItemProperty -Path $RegPath | Select-Object -ExpandProperty $RegName
	# Add the msedge.exe value to existing values in UviProcessExcludes
	IF ($CurrentValues -notlike "*msedge.exe*") {
		Set-ItemProperty -Path $RegPath -Name $RegName -Value "$CurrentValues$EdgeRegvalue;"
		}
	}
	) | Out-Null
	write-Host -ForegroundColor Green "...ready"
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