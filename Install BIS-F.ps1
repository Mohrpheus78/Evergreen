# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs BIS-F on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "BIS-F"
$BISFDir = "C:\Program Files (x86)\Base Image Script Framework (BIS-F)\Framework\SubCall"

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "Base Image Script Framework" 		            # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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
$BISF = (Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Base Image*"}).DisplayVersion | Sort-Object -Property Version -Descending | Select-Object -First 1
$BISF = $BISF -replace ".{6}$"
IF ($BISF -ne $Version) {

# Base Image Script Framework
write-Host -ForegroundColor Yellow "Installing $Product"
DS_WriteLog "I" "Installing $Product" $LogFile
try {
	"$PSScriptRoot\$Product\setup-BIS-F.msi" | Install-MSIFile
	} catch {
DS_WriteLog "E" "Error installing $Product (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile
write-Host -ForegroundColor Green "...ready"

# Anpassungen der Skripte
write-Host -ForegroundColor Yellow "Edit BIS-F scripts (TCP Offload, DEP, RSS)"
DS_WriteLog "I" "Skripte anpassen" $LogFile
try {
	((Get-Content "$BISFDir\Preparation\97_PrepBISF_PRE_BaseImage.ps1" -Raw) -replace "DisableTaskOffload' -Value '1'","DisableTaskOffload' -Value '0'") | Set-Content -Path "$BISFDir\Preparation\97_PrepBISF_PRE_BaseImage.ps1"
	((Get-Content "$BISFDir\Preparation\97_PrepBISF_PRE_BaseImage.ps1" -Raw) -replace 'nx AlwaysOff','nx OptOut') | Set-Content -Path "$BISFDir\Preparation\97_PrepBISF_PRE_BaseImage.ps1"
	((Get-Content "$BISFDir\Preparation\97_PrepBISF_PRE_BaseImage.ps1" -Raw) -replace 'rss=disable','rss=enable') | Set-Content -Path "$BISFDir\Preparation\97_PrepBISF_PRE_BaseImage.ps1"
	((Get-Content "$BISFDir\Preparation\10_PrepBISF_AV-TM.ps1" -Raw) -replace 'deleteTMData','# deleteTMData') | Set-Content -Path "$BISFDir\Preparation\10_PrepBISF_AV-TM.ps1"
	((Get-Content "$BISFDir\Preparation\10_PrepBISF_AV-TM.ps1" -Raw) -replace 'function # deleteTMData','function deleteTMData') | Set-Content -Path "$BISFDir\Preparation\10_PrepBISF_AV-TM.ps1"
	((Get-Content "$BISFDir\Global\BISF.psm1" -Raw) -replace 'New-PSDrive -Name \$Driveletter','New-PSDrive -Name "F"') | Set-Content -Path "$BISFDir\Global\BISF.psm1"
	((Get-Content "$BISFDir\Global\BISF.psm1" -Raw) -replace 'Remove-PSDrive -Name \$Driveletter','Remove-PSDrive -Name "F"') | Set-Content -Path "$BISFDir\Global\BISF.psm1"
	copy-item -Path "$PSScriptRoot\$Product\BIS-F Personalization ready.ps1" -Destination "$BISFDir\Personalization\Custom"
	copy-item -Path "$PSScriptRoot\$Product\SubCall" -Destination "$BISFDir\Personalization\Custom" -Recurse -Force
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Login Consultants\BISF" -Name LIC_BISF_PersState -Value Finished
	} catch {
DS_WriteLog "E" "Error beim Anpassen der Skripte (error: $($Error[0]))" $LogFile       
}
DS_WriteLog "-" "" $LogFile
write-Host -ForegroundColor Green "...ready"
write-Output ""
}

# Stop, if no new version is available
Else {
Write-Host "No Update available for $Product"
Write-Output ""
}