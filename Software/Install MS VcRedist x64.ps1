# *****************************************************

# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78

# Install Software package on your master server/client

# *****************************************************



<#

.SYNOPSIS

This script installs Microsoft Visual C++ bundle on a MCS/PVS master server/client or wherever you want.

		

.Description

Use the Software Updater script first, to check if a new version is available! After that use the Software Installer script. If you select this software

package it will be installed. 

The script compares the software version and will install or update the software. A log file will be created in the 'Install Logs' folder. 



.EXAMPLE



.NOTES

Always call this script with the Software Installer script!

#>





# define Error handling

# note: do not change these values

$global:ErrorActionPreference = "Stop"

if($verbose){ $global:VerbosePreference = "Continue" }



Function ConvertTo-Version {



	Param(

		[Parameter(Mandatory=$true, Position = 0)]

		[AllowEmptyString()]

		[String]$VersionString

	)



	IF ([String]::IsNullOrWhiteSpace($VersionString)) {

		Return $null

	}



	$VersionParts = $VersionString.Trim() -split '\.'



	IF ($VersionParts.Count -gt 4 -or ($VersionParts | Where-Object { $_ -notmatch '^\d+$' })) {

		Throw "Invalid version number: $VersionString"

	}



	While ($VersionParts.Count -lt 4) {

		$VersionParts += '0'

	}



	Return [Version]($VersionParts -join '.')

}



Function Get-VcRedistEntry {



	Return Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |

		Where-Object {

			$_.DisplayName -like "Microsoft Visual C++*Redistributable*x64*" -and

			$_.DisplayVersion -match '^14\.'

		} |

		Where-Object {

			-not [String]::IsNullOrWhiteSpace($_.DisplayVersion)

		} |

		Sort-Object {

			ConvertTo-Version $_.DisplayVersion

		} -Descending |

		Select-Object -First 1

}



# Variables

$Product = "Microsoft Visual C++ Redistributable packages x64"



#========================================================================================================================================

# Logging

$BaseLogDir = "$PSScriptRoot\_Install Logs"      # [edit] add the location of your log directory here

$PackageName = "$Product" 		            	# [edit] enter the display name of the software (e.g. 'Arcobat Reader' or 'Microsoft Office')



# Global variables

# $StartDir = $PSScriptRoot # the directory path of the script currently being executed

$LogDir = (Join-Path $BaseLogDir "Microsoft Visual C++ Redistributable")

$LogFileName = ("$ENV:COMPUTERNAME - Visual C++ Redistributable_x64.log")

$LogFile = Join-path $LogDir $LogFileName



# Create the log directory if it does not exist

IF (!(Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType directory | Out-Null }



# Create new log file (overwrite existing one)

New-Item $LogFile -ItemType "file" -force | Out-Null



DS_WriteLog "I" "START SCRIPT - $PackageName" $LogFile

DS_WriteLog "-" "" $LogFile

#========================================================================================================================================



# Check, if a new version is available

$VersionFile = "$PSScriptRoot\$Product\Version.txt"



IF (Test-Path -Path $VersionFile) {

	[Version]$RequiredVcRedistX64 = ConvertTo-Version (Get-Content -Path $VersionFile -Raw)

	$VcRedistX64Entry = Get-VcRedistEntry



	IF ($null -eq $VcRedistX64Entry) {

		$InstallVcRedistX64 = $true

		DS_WriteLog "I" "$Product was not found" $LogFile

	}

	Else {

		[Version]$InstalledVcRedistX64 = ConvertTo-Version $VcRedistX64Entry.DisplayVersion

		$InstallVcRedistX64 = $InstalledVcRedistX64 -lt $RequiredVcRedistX64

		DS_WriteLog "I" "${Product}: installed $InstalledVcRedistX64, required $RequiredVcRedistX64" $LogFile

	}



	IF ($InstallVcRedistX64) {

		IF ($SoftwareSelection.VMWareTools -eq $true) {

			Write-Host -ForegroundColor Yellow "Installing $Product, this is a prerequisite for current VMWare Tools"

		}

		Else {

			Write-Host -ForegroundColor Yellow "Installing $Product"

			DS_WriteLog "I" "Installing $Product" $LogFile

		}

		try {

			Start-Process "$PSScriptRoot\$Product\VC_redist_x64.exe" -ArgumentList "/quiet /norestart" -NoNewWindow -Wait

			DS_WriteLog "-" "" $LogFile

			Write-Host -ForegroundColor Green "...ready"

			Write-Host -ForegroundColor Red "Server needs to reboot after installation!"

			Write-Output ""

		}

		catch {

			Write-Host -ForegroundColor Red "Error installing $Product (Error: $($Error[0]))"

			DS_WriteLog "-" "" $LogFile

			DS_WriteLog "E" "Error installing $Product (Error: $($Error[0]))" $LogFile

			Write-Output ""

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

