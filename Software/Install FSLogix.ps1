# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs FSLogix Apps on a MCS/PVS master server/client or wherever you want.
		
.Description
Use the Software Updater script first, to check if a new version is available! After that use the Software Installer script. If you select this software
package it will be first uninstalled after that it gets installed. 
The script compares the software version and will install or update the software. A log file will be created in the 'Install Logs' folder. 

.EXAMPLE

.NOTES
Always call this script with the Software Installer script!
Needs a reboot, call a second time after reboot.
#>


# define Error handling
# note: do not change these values
$global:ErrorActionPreference = "Stop"
if($verbose){ $global:VerbosePreference = "Continue" }

# Variables
$Product = "FSLogix"

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
IF (Test-Path -Path "$PSScriptRoot\$Product\Install\Version.txt") {
	[version]$Version = Get-Content -Path "$PSScriptRoot\$Product\Install\Version.txt"
	[version]$FSLogix = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft FSLogix Apps"}).DisplayVersion
	
	<#
	IF (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft FSLogix Apps"}) {
	$UninstallFSL = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft FSLogix Apps"}).UninstallString.replace("/uninstall","")
	}
	IF (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft FSLogix Apps RuleEditor"}) {
	$UninstallFSLRE = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft FSLogix Apps RuleEditor"}).UninstallString.replace("/uninstall","")
	}
	#>

	IF ($FSLogix -lt $Version) {
    <#
	# FSLogix Uninstall
	IF (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft FSLogix Apps"}) {
	Write-Host -ForegroundColor Yellow "Uninstalling $Product"
	DS_WriteLog "I" "Uninstalling $Product" $LogFile
	try	{
	Start-process $UninstallFSL -ArgumentList '/uninstall /quiet /norestart' –NoNewWindow -Wait
	Start-process $UninstallFSLRE -ArgumentList '/uninstall /quiet /norestart' –NoNewWindow -Wait
	} catch {
	DS_WriteLog "E" "Error Uninstalling $Product (error: $($Error[0]))" $LogFile       
	}
	DS_WriteLog "-" "" $LogFile
	Write-Host -ForegroundColor Green "...ready"
	Write-Host -ForegroundColor Red "Server needs to reboot, start script again after reboot"
	Write-Output "Hit any key to reboot server"
	Read-Host
	Restart-Computer
	}
    #>
		# FSLogix Install
		Write-Host -ForegroundColor Yellow "Installing FSLogix Apps"
		DS_WriteLog "I" "Installing FSLogix Apps" $LogFile
		try	{
			Start-Process "$PSScriptRoot\$Product\Install\FSLogixAppsSetup.exe" -ArgumentList '/install /norestart /quiet'  –NoNewWindow -Wait
			DS_WriteLog "-" "" $LogFile
			Write-Host -ForegroundColor Green "...ready"
			Write-Host -ForegroundColor Red "Server needs to reboot after installation!"
			Write-Output ""
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing FSLogix Apps (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error installing FSLogix Apps (Error: $($Error[0]))"
				Write-Output ""    
				}

		Write-Host -ForegroundColor Yellow "Installing FSLogix Rule Editor"
		DS_WriteLog "I" "Installing FSLogix Rule Editor" $LogFile
		try	{
			Start-Process "$PSScriptRoot\$Product\Install\FSLogixAppsRuleEditorSetup.exe" -ArgumentList '/install /norestart /quiet'  –NoNewWindow -Wait
			DS_WriteLog "-" "" $LogFile
			Write-Host -ForegroundColor Green "...ready"
			Write-Host -ForegroundColor Red "Server needs to reboot after installation!"
			Write-Output ""
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing FSLogix Apps (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error installing FSLogix Apps (Error: $($Error[0]))"
				Write-Output ""    
				}

		# Windows Search Task importieren bei Windows Server 2019/2022 oder Windows 11
		IF ((Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Microsoft FSLogix Apps"}).DisplayVersion) {
			IF (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName | Where-Object {$_.ProductName -match "Windows Server 2019" -or $_.ProductName -like "*Windows 10*"}) {
				IF (!(Get-ScheduledTask -EA SilentlyContinue | Where-Object {$_.TaskName -like "Windows Search*"}).TaskName) {
				Write-Host -ForegroundColor Yellow "Creating scheduled task for Windows Search error"
				DS_WriteLog "I" "Importing Windows Search Task" $LogFile
				try {
					Register-ScheduledTask -Xml (get-content "$PSScriptRoot\$Product\Task\Windows Search.xml" | out-string) -TaskName "Windows Search Failure" | Out-Null
					DS_WriteLog "-" "" $LogFile
					Write-Host -ForegroundColor Green "...ready"
					Write-Output ""
				} catch {
					DS_WriteLog "-" "" $LogFile
					DS_WriteLog "E" "Unable to find scheduled task 'Windows search failure' in folder '$PSScriptRoot\$Product\Task' (Error: $($Error[0]))" $LogFile
					Write-Host -ForegroundColor Red "Unable to find scheduled task 'Windows search failure' in folder '$PSScriptRoot\$Product\Task' (Error: $($Error[0]))"
					Write-Output ""    
					}
				}
				IF (!(Get-ScheduledTask -EA SilentlyContinue | Where-Object {$_.TaskName -eq "Windows Search User Logon"}).TaskName) {
					Write-Host -ForegroundColor Yellow "Creating scheduled task for Windows Search User Logon"
					DS_WriteLog "I" "Importing Windows search user logon task" $LogFile
					try {
						Register-ScheduledTask -Xml (get-content "$PSScriptRoot\$Product\Task\Windows Search User Logon.xml" | out-string) -TaskName "Windows Search User Logon" | Out-Null
						DS_WriteLog "-" "" $LogFile
						Write-Host -ForegroundColor Green "...ready"
						Write-Output ""
					} catch {
						DS_WriteLog "-" "" $LogFile
						DS_WriteLog "E" "Unable to find scheduled task 'Windows search user logon' in folder '$PSScriptRoot\$Product\Task'(Error: $($Error[0]))" $LogFile
						Write-Host -ForegroundColor Red "Unable to find scheduled task 'Windows search user logon' in folder '$PSScriptRoot\$Product\Task' (Error: $($Error[0]))"
						Write-Output ""    
						}
					}
			}
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