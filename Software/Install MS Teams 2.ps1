# *****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Install Software package on your master server/client
# *****************************************************

<#
.SYNOPSIS
This script installs MS-Teams 2 VDI installer on a MCS/PVS master server/client or wherever you want. An old version will first be uninstalled.
		
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
$Product = "MS Teams 2"

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
	$Version = Get-Content -Path "$PSScriptRoot\$Product\Version.txt"
	$Version = $Version -replace '^(\d+\.\d+\.\d+).*$', '$1'
	IF (Get-AppxPackage *MSTeams*) {
		$TeamsNew = (Get-AppxPackage *MSTeams*).Version
		$TeamsNew = $TeamsNew -replace '^(\d+\.\d+\.\d+).*$', '$1'
		
	}
	# Register MS Teams AppPackage
	IF (Get-ChildItem -Path 'C:\Program Files\WindowsApps' -Filter 'MSTeams*') {
		try {
			Add-AppPackage -Register -DisableDevelopmentMode "$((Get-ChildItem -Path 'C:\Program Files\WindowsApps' -Filter 'MSTeams*').FullName)\AppXManifest.xml" -EA SilentlyContinue
			Start-Sleep -Seconds 10
		} catch {
			Write-Error "Error registering MS Teams AppXPackage: $_"
		}
	}
	If ($TeamsNew -ne $Version) {	
		If (Test-Path -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\") {
			$UninstallTeams = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Teams Machine*"}).UninstallString
        }
        If (!$UninstallTeams) {
			If (Test-Path -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\") {
				$UninstallTeams = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Teams Machine*"}).UninstallString
			}
        }
        $UninstallTeams = $UninstallTeams -Replace("MsiExec.exe /I","")
		If ($UninstallTeams) {
			Write-Host -ForegroundColor Yellow "Uninstall old Teams"
			DS_WriteLog "I" "Uninstall old Teams" $LogFile
			try {
				Start-Process -FilePath msiexec.exe -ArgumentList "/X $UninstallTeams /qn" -wait
				Start-Sleep 3
				Remove-Item -Path "C:\Program Files (x86)\Microsoft\Teams" -Force -Recurse -EA SilentlyContinue
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error uninstalling old Teams (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error uninstalling old Teams (Error: $($Error[0]))"
			}	
			Start-Sleep 3
			Write-Host -ForegroundColor Green "...ready"
			Write-Output ""
		}
		
        If (Test-Path -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\") {
			$UninstallTeamsMeeting = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Microsoft Teams Meeting*"}).UninstallString
            }
        If (!$UninstallTeamsMeeting) {
			If (Test-Path -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\") {
            $UninstallTeamsMeeting = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Microsoft Teams Meeting*"}).UninstallString
            }
        }
			$UninstallTeamsMeeting = $UninstallTeamsMeeting -Replace("MsiExec.exe /I","")
			If ($UninstallTeamsMeeting) {
				Write-Host -ForegroundColor Yellow "Uninstalling MS Teams Meeting AddIn"
				DS_WriteLog "I" "Uninstall MS Teams Meeting AddIn" $LogFile
				try {
					Start-Process -FilePath msiexec.exe -ArgumentList "/X $UninstallTeamsMeeting /qn" -wait
				} catch {
					DS_WriteLog "-" "" $LogFile
					DS_WriteLog "E" "Error uninstalling MS Teams Meeting AddIn (Error: $($Error[0]))" $LogFile
					Write-Host -ForegroundColor Red "Error uninstalling  MS Teams Meeting AddIn (Error: $($Error[0]))"
					Write-Output ""
				}	
				Start-Sleep 3
				Write-Host -ForegroundColor Green "...ready"
				Write-Output ""
				DS_WriteLog "I" "Uninstall old Teams finished!" $LogFile
			}
	
	# Uninstalling NEW MS Teams 2.x
	IF (Get-AppxPackage *MSTeams*) {
	Write-Host -ForegroundColor Yellow "Uninstalling $Product"
	DS_WriteLog "I" "Uninstalling $Product" $LogFile
	try {
		Start-Process -FilePath "$PSScriptRoot\$Product\teamsbootstrapper.exe" -ArgumentList "-x"
        #Get-AppxPackage *MSTeams* -AllUsers | Remove-AppxPackage -AllUsers | Out-Null
        Start-Sleep 20
		DS_WriteLog "-" "" $LogFile
		Write-Host -ForegroundColor Green " ...ready!" 
		Write-Output ""
		} catch {
			DS_WriteLog "-" "" $LogFile
			DS_WriteLog "E" "Error uninstalling $Product (Error: $($Error[0]))" $LogFile
			Write-Host -ForegroundColor Red "Error uninstalling $Product (Error: $($Error[0]))"
			Write-Output ""    
			}
	}
	
	# MS Teams 2 installation
	Write-Host -ForegroundColor Yellow "Installing $Product, please wait..."
	DS_WriteLog "I" "Installing $Product" $LogFile
	$OS = (Get-WmiObject Win32_OperatingSystem).Caption
	New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Appx -Name AllowAllTrustedApps -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Appx -Name AllowDevelopmentWithoutDevLicense -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Appx -Name BlockNonAdminUserInstall -Value 0 -PropertyType DWORD -Force | Out-Null
	New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name DisableAppInstallsOnFirstLogon -Value 0 -PropertyType DWORD -Force | Out-Null
	If ($OS -Like "*Windows Server 2016*") {
		Write-Host -ForegroundColor Red "Windows Server 2016 detected. No installation possible!"
    } 
		If ($OS -Like "*Windows Server 2019*") {
			try {
				Write-Host "Windows Server 2019 detected. Installation without teamsbootstrapper.exe"
				Start-Process -wait -NoNewWindow -FilePath DISM.exe -Args "/Online /Add-ProvisionedAppxPackage /PackagePath:""$PSScriptRoot\$Product\MSTeams-x64.msix"" /SkipLicense"
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing $Product for Windows Server 2019 (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error installing $Product for Windows Server 2019 (Error: $($Error[0]))"
				Write-Output ""    
			}	
		}
		if ($OS -Like "*Windows Server 2022*") {
			Write-Host "Windows Server 2022 detected. Installation with teamsbootstrapper.exe"
			try {
				$Teams_bootstraper_exe = "$PSScriptRoot\$Product\teamsbootstrapper.exe"
				$New_Teams_MSIX = "$PSScriptRoot\$Product\MSTeams-x64.msix"
				& $Teams_bootstraper_exe -p -o $New_Teams_MSIX
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing $Product for Windows Server 2022 (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error installing $Product for Windows Server 2022 (Error: $($Error[0]))"
				Write-Output ""    
			}	
		}
        if ($OS -Like "*Windows 10*") {
			Write-Host "Windows 10 detected. Installation without teamsbootstrapper.exe"
			try {
				Start-Process -wait -NoNewWindow -FilePath DISM.exe -Args "/Online /Add-ProvisionedAppxPackage /PackagePath:""$PSScriptRoot\$Product\MSTeams-x64.msix"" /SkipLicense"
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing $Product for Windows 10 (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error installing $Product for Windows 10 (Error: $($Error[0]))"
				Write-Output ""    
			}	
		}
		if ($OS -Like "*Windows 11*") {
			Write-Host "Windows 11 detected. Installation with teamsbootstrapper.exe"
			try {
				$Teams_bootstraper_exe = "$PSScriptRoot\$Product\teamsbootstrapper.exe"
				$New_Teams_MSIX = "$PSScriptRoot\$Product\MSTeams-x64.msix"
				& $Teams_bootstraper_exe -p -o $New_Teams_MSIX
			} catch {
				DS_WriteLog "-" "" $LogFile
				DS_WriteLog "E" "Error installing $Product for Windows 10 (Error: $($Error[0]))" $LogFile
				Write-Host -ForegroundColor Red "Error installing $Product for Windows 10 (Error: $($Error[0]))"
				Write-Output ""    
			}	
        }
				
        Start-Sleep 5
		
		# Create environment variable
		$TeamsVersionPath = (Get-ChildItem -Path "C:\Program Files\WindowsApps" -Filter "MSTeams_*" -Directory).Fullname | Sort-Object Name
		Write-Host -ForegroundColor Yellow "Register Teams version as environment variable"
		[Environment]::SetEnvironmentVariable("TeamsVersionPath", $TeamsVersionPath, "Machine")
		
		# Register MS Teams AppXPackage
		try {
			Write-Host -ForegroundColor Yellow "Register MS Teams AppPackage"
			Add-AppPackage -Register -DisableDevelopmentMode "$((Get-ChildItem -Path 'C:\Program Files\WindowsApps' -Filter 'MSTeams*').FullName)\AppXManifest.xml" -EA SilentlyContinue
			Start-Sleep -Seconds 5
		} catch {
			Write-Error "Error registering MS Teams AppPackage: $_"
		}
		
		# Create scheduled task for registering MS Teams AppXPackage
		Write-Host -ForegroundColor Yellow "Create scheduled task for registering MS Teams AppXPackage"
		$Options = @(
		"-command"
		"{Add-AppPackage -Register -DisableDevelopmentMode '$((Get-ChildItem -Path 'C:\Program Files\WindowsApps' -Filter 'MSTeams*').FullName)\AppXManifest.xml'}"
		)
		$Trigger = New-JobTrigger -AtLogOn
		$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "$Options"
		$User = "NT AUTHORITY\SYSTEM"
		Register-ScheduledTask -TaskName 'Register MS Teams AppXPackage' -User $User -Action $Action -Trigger $Trigger -EA SilentlyContinue | Out-Null
		
		Write-Host -ForegroundColor Green "...ready"
		Write-Output ""
	
	If (Test-Path "$env:PUBLIC\Desktop\Microsoft Teams.lnk") {
		Remove-Item -Path "$env:PUBLIC\Desktop\Microsoft Teams.lnk" -Force
		}
    If (Test-Path -Path "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk") {
		Remove-Item -Path "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Microsoft Teams.lnk" -Force
		}
	reg add "HKLM\SOFTWARE\WOW6432Node\Citrix\WebSocketService" /v ProcessWhitelist /t REG_Multi_SZ /d msedgewebview2.exe /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Teams" /v disableAutoUpdate /t REG_DWORD /d 1 /f | Out-Null
	
	# MS Teams 2 Meeting Add-In installation
	Write-Host -ForegroundColor Yellow "Installing $Product Meeting Add-In"
	DS_WriteLog "I" "Installing $Product Meeting Add-In" $LogFile
	msiexec.exe /i "$((Get-ChildItem -Path 'C:\Program Files\WindowsApps' -Filter 'MSTeams*').FullName)\MicrosoftTeamsMeetingAddinInstaller.msi" Reboot=ReallySuppress ALLUSERS=1 TARGETDIR="C:\Windows\Microsoft\TeamsMeetingAddin" /qn
	Start-Sleep 10
	$appX64DLL = (Get-ChildItem -Path "C:\Windows\Microsoft\TeamsMeetingAddin\x64" -Include "Microsoft.Teams.AddinLoader.dll" -Recurse).FullName
    $appX86DLL = (Get-ChildItem -Path "C:\Windows\Microsoft\TeamsMeetingAddin\x86" -Include "Microsoft.Teams.AddinLoader.dll" -Recurse).FullName
    Start-Process -FilePath "$env:WinDir\SysWOW64\regsvr32.exe" -ArgumentList "/s /n /i:user `"$appX64DLL`"" -ErrorAction SilentlyContinue
    Start-Process -FilePath "$env:WinDir\SysWOW64\regsvr32.exe" -ArgumentList "/s /n /i:user `"$appX86DLL`"" -ErrorAction SilentlyContinue
    #Add Registry Keys for loading the Add-in
    If (!(Test-Path 'HKLM:\Software\Microsoft\Office\Outlook\Addins\')) {
		New-Item -Path "HKLM:\Software\Microsoft\Office\Outlook\Addins\" | Out-Null
	}
    New-Item -Path "HKLM:\Software\Microsoft\Office\Outlook\Addins" -Name "TeamsAddin.FastConnect" -Force -ErrorAction Ignore | Out-Null
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect" -Type "DWord" -Name "LoadBehavior" -Value 3 -force | Out-Null
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect" -Type "String" -Name "Description" -Value "Microsoft Teams Meeting Add-in for Microsoft Office" -force | Out-Null
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect" -Type "String" -Name "FriendlyName" -Value "Microsoft Teams Meeting Add-in for Microsoft Office" -force | Out-Null
	Write-Host -ForegroundColor Green "...ready"
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