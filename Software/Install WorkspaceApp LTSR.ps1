# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the Citrix WorkspaceApp LTSR on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "WorkspaceApp LTSR"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "Citrix WorkspaceApp LTSR" 		    # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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

# Check, if a new version of MS Edge WebView2 Runtime is available
IF (!(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft Edge WebView*"})) {
[version]$Version = Get-Content -Path "$PSScriptRoot\MS Edge WebView2 Runtime\Version.txt"
[version]$MEWV2RT = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Microsoft Edge WebView*"}).DisplayVersion
IF ($MEWV2RT -lt $Version) {
Write-Host -ForegroundColor Yellow "Installing MS Edge WebView2 Runtime"
DS_WriteLog "I" "Installing MS Edge WebView2 Runtime" $LogFile
try	{
	Start-Process -FilePath "$PSScriptRoot\MS Edge WebView2 Runtime\MicrosoftEdgeWebView2RuntimeInstallerX64.exe" -ArgumentList "/silent /install" –NoNewWindow -wait
	} catch {
	DS_WriteLog "E" "Error installing $Product (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile
Write-Host -ForegroundColor Green " ...ready!" 
Write-Output ""
}
}

# Check, if a new version is available
$Version = Get-Content -Path "$PSScriptRoot\Citrix\WorkspaceApp\Windows\LTSR\Version.txt"
$WSA = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Citrix Workspace*" -and $_.UninstallString -like "*Trolley*"}).DisplayVersion
IF ($WSA -ne $Version) {

# Citrix WSA Installation
$Options = @(
"/silent"
"/EnableCEIP=false"
"/FORCE_LAA=1"
"/AutoUpdateCheck=disabled"
"/EnableCEIP=false"
"/ALLOWADDSTORE=S"
"/ALLOWSAVEPWD=S"
"/includeSSON"
"/ENABLE_SSON=Yes"
)
Write-Host -ForegroundColor Yellow "Installing $Product"
DS_WriteLog "I" "Installing $Product" $LogFile
try	{
	$inst = Start-Process -FilePath "$PSScriptRoot\Citrix\WorkspaceApp\Windows\LTSR\CitrixWorkspaceAppWeb.exe" -ArgumentList $Options -PassThru -ErrorAction Stop
	if($inst -ne $null)
	{
	Wait-Process -InputObject $inst
	} 
	#New-Item -Path "HKCU:\SOFTWARE\Citrix\Splashscreen" -EA SilentlyContinue | Out-Null
	#New-ItemProperty -Path "HKCU:\Software\Citrix\Splashscreen" -Name SplashscrrenShown -Value 1 -PropertyType DWORD -EA SilentlyContinue | Out-Null
	New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Citrix" -EA SilentlyContinue | Out-Null
	New-Item -Path "HKLM:\SOFTWARE\Policies\Citrix" -EA SilentlyContinue -EA SilentlyContinue | Out-Null
	New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Citrix" -Name EnableX1FTU -Value 0 -PropertyType DWORD -EA SilentlyContinue | Out-Null
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Citrix" -Name EnableFTU -Value 0 -PropertyType DWORD -EA SilentlyContinue | Out-Null
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name InstallHelper -Force -EA SilentlyContinue | Out-Null
	} catch {
	DS_WriteLog "E" "Error installing $Product (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile
Write-Host -ForegroundColor Green " ...ready!" 
Write-Host -ForegroundColor Red "Server needs to reboot after installation!"
Write-Output ""
}

# Stop, if no new version is available
Else {
Write-Verbose "No Update available for $Product" -Verbose
Write-Output ""
}