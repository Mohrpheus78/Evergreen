# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs Citrix WEM agent on a MCS/PVS master server/client or wherever you want.
		
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
$Product = "Citrix WEM Agent for MCS"
# $InstDir = Split-Path $PSScriptRoot -Parent

#========================================================================================================================================
# Logging
$BaseLogDir = "$PSScriptRoot\_Install Logs"       # [edit] add the location of your log directory here
$PackageName = "$Product" 		    # [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')

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

# Ask again
Write-host -ForegroundColor Gray -BackgroundColor DarkRed "Do you want to update the Citrix WEM Agent, otherwise please uncheck in the selection!"
Write-Host ""
    $Frage = Read-Host "( y / n )"
	IF ($Frage -eq 'n') {
	Write-Host ""
	Write-host -ForegroundColor Red "Update canceled!"
	Write-Host ""
	BREAK
	}
Write-Host ""

[version]$WEMAgent = (Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Citrix Workspace Environment*"}).DisplayVersion | Select-Object -Last 1

# Cloud or onPrem?	
$WEMSettings = "HKLM:\SOFTWARE\Policies\Norskale\Agent Host"
$CC = Get-ItemProperty -Path $WEMSettings | Select-Object -ExpandProperty CloudConnectorList -EA SilentlyContinue
$CVADConnectors = Get-ItemProperty -Path "$WEMSettings" | Select-Object -ExpandProperty AllowWEMUseCvadConnectors -EA SilentlyContinue
if ($CC -ne $null -or $CVADConnectors -ne $null) {
    $Cloud=$true
	Write-Host -ForegroundColor Yellow "WEM Cloud service detected"
    }
else {
	$Cloud=$false
}

IF ($Cloud -eq $false) {	
	# Installation WEM Agent onPrem
	IF (!(Test-Path "$InstDir\Software\Citrix\WEM")) {
		Write-Host ""
		Write-host -ForegroundColor Red "Installation path not valid, please check if '$InstDir\Software\Citrix\WEM' exists and the WEM Agent is present!"
		pause
		BREAK
	}
	[version]$VersionWEM = (Get-Item "$InstDir\Software\Citrix\WEM\Citrix Workspace Environment Management Agent.exe").VersionInfo.ProductVersion	
	$WEMServer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Norskale\Agent Host").BrokerSvcName
	IF ($WEMAgent -lt $VersionWEM) {
		DS_WriteLog "I" "Installing $Product" $LogFile
		Write-Host -ForegroundColor Yellow "Installing $Product $VersionWEM On-Prem"
		try	{
			Start-Process "$InstDir\Software\Citrix\WEM\Citrix Workspace Environment Management Agent.exe" -ArgumentList '/quiet Cloud=0 InfrastructureServer=$WEMServer' –NoNewWindow -Wait
			DS_WriteLog "-" "" $LogFile
			write-Host -ForegroundColor Green "...ready"
			Write-Output ""
		} catch {
			DS_WriteLog "-" "" $LogFile
			DS_WriteLog "E" "Error installing $Product (Error: $($Error[0]))" $LogFile
			Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"
			Write-Output ""    
			}
	}
	ELSE {
		Write-Host "No Update available for $Product"
		Write-Output ""
	}
}
	ELSE {
	# Installation WEM Agent Cloud
	IF (!(Test-Path "$InstDir\Software\Citrix\Cloud")) {
		Write-Host ""
		Write-host -ForegroundColor Red "Installation path not valid, please check if '$InstDir\Software\Citrix\Cloud' exists and the WEM Agent is present!"
		pause
		BREAK
	}
	[version]$VersionWEM = (Get-Item "$InstDir\Software\Citrix\Cloud\Citrix Workspace Environment Management Agent.exe").VersionInfo.ProductVersion
	IF ($WEMAgent -lt $VersionWEM) {
		DS_WriteLog "I" "Installing $Product" $LogFile
		Write-Host -ForegroundColor Yellow "Installing $Product $VersionWEM for WEM Cloud service"
		try	{
			IF ($CC) {
				$CCList = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Norskale\Agent Host").CloudConnectorList -join","
				Start-Process "$InstDir\Software\Citrix\Cloud\Citrix Workspace Environment Management Agent.exe" -ArgumentList '/quiet Cloud=1 CloudConnectorList=$CCList' –NoNewWindow -Wait
			}
			IF ($CVADConnectors) {
				Start-Process "$InstDir\Software\Citrix\Cloud\Citrix Workspace Environment Management Agent.exe" -ArgumentList '/quiet Cloud=1' –NoNewWindow -Wait
			}
			DS_WriteLog "-" "" $LogFile
			write-Host -ForegroundColor Green "...ready"
			Write-Output ""
		} catch {
			DS_WriteLog "-" "" $LogFile
			DS_WriteLog "E" "Error installing $Product (Rrror: $($Error[0]))" $LogFile
			Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0])"
			Write-Output ""    
			}
	}
	ELSE {
		Write-Host "No Update available for $Product"
		Write-Output ""
	}
}