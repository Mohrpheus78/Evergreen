# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs the current Citrix WorkspaceApp on a MCS/PVS master server/client or wherever you want.
		
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

# Variablen
$Product = "WorkspaceApp Current Release"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "Citrix WorkspaceApp Clients" 		    # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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

# Prüfen, ob installiert werden muss
$Version = Get-Content -Path "$PSScriptRoot\Citrix\WorkspaceApp\Windows\Current\Version.txt"
$WSA = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Citrix Workspace*" -and $_.UninstallString -like "*Trolley*"}).DisplayVersion
IF ($WSA -ne $Version) {

# Alte Storefront Sites entfernen
$strKey = "Software\Citrix\Dazzle\Sites"
# Get current location to return to at the end of the script
$CurLoc = Get-Location
# check if HKU branch is already mounted as a PSDrive. If so, remove it first
$HKU = Get-PSDrive HKU -ea silentlycontinue

#check HKU branch mount status
if (!$HKU ) {
 # recreate a HKU as a PSDrive and navigate to it
 New-PSDrive -Name HKU -PsProvider Registry HKEY_USERS | out-null
 Set-Location HKU:
}
# select all desired user profiles, exlude *_classes & .DEFAULT
$regProfiles = Get-ChildItem -Path HKU: | ? { ($_.PSChildName.Length -gt 8) -and ($_.PSChildName -notlike "*.DEFAULT") }
# loop through all selected profiles & delete registry
ForEach ($profile in $regProfiles ) {
 If(Test-Path -Path $profile\$strKey){
	Remove-Item -Path $profile\$strKey -recurse
	}
}
# return to initial location at the end of the execution
Set-Location $CurLoc
Remove-PSDrive -Name HKU


# Installation Citrix WSA
$Options = @(
"/silent"
"/EnableCEIP=false"
"/FORCE_LAA=1"
"/AutoUpdateCheck=disabled"
"/ALLOWADDSTORE=S"
"/ALLOWSAVEPWD=S"
"/includeSSON"
"/ENABLE_SSON=Yes"
"/STORE0=Store;https://citrix.domain.local/Citrix/Store/discovery;On"
)
Write-Host -ForegroundColor Yellow "Eine neue Version der Citrix WorkspaceApp ist verfügbar"
Write-Host ""
Write-Host -ForegroundColor Yellow "Citrix WorkspaceApp wird installiert, bitte Geduld..." -NoNewLine
DS_WriteLog "I" "Citrix WorkspaceApp wird installiert" $LogFile
try	{
	$inst = Start-Process -FilePath "$PSScriptRoot\Citrix\WorkspaceApp\Windows\Current\CitrixWorkspaceApp.exe" -ArgumentList $Options -PassThru -ErrorAction Stop
	if($inst -ne $null)
	{
Wait-Process -InputObject $inst
	} 
	reg add "HKLM\SOFTWARE\Wow6432Node\Policies\Citrix" /v EnableX1FTU /t REG_DWORD /d 0 /f | Out-Null
	reg add "HKCU\Software\Citrix\Splashscreen" /v SplashscrrenShown /d 1 /f | Out-Null
	reg add "HKLM\SOFTWARE\Policies\Citrix" /f /v EnableFTU /t REG_DWORD /d 0 | Out-Null
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\domain.lan\citrix" /v https /t REG_DWORD /d 1 /f  | Out-Null
	} catch {
DS_WriteLog "E" "Ein Fehler ist aufgetreten beim Installieren von Citrix WorkspaceApp (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile
Write-Host -ForegroundColor Green " ... fertig!"
Write-Host ""
Write-Host -ForegroundColor Red "Rechner bitte neu starten!"
}

# Stop, if no new version is available
Else {
Write-Host -ForegroundColor Yellow "Kein Update für $Product verfügbar"
Write-Output ""
}

