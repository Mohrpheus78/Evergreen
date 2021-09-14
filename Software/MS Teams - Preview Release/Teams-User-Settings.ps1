# ****************************************************
# D. Mohrmann, S&L Firmengruppe, Twitter: @mohrpheus78
# Modify MS Teams VDI App
# ****************************************************

<#
    .SYNOPSIS
        Change Teams setting per user
		
    .Description
        Change the MS Teams VDI installer app settings, such as GPU acceleration or fully close Teams app 
		
    .EXAMPLE
	WEM:
	Path: powershell.exe
        Arguments: -executionpolicy bypass -file "C:\Program Files (x86)\SuL\Scripts\Teams User Settings.ps1"  
	    
    .NOTES
	Execute as WEM external task, logonscript or task at logon
	You can add seeting 
#>

# Define settings
param(
# Enable or disable GPU acceleration
[boolean]$disableGpu=$True,
# Fully close Teams App
[boolean]$runningOnClose=$False
)

## Get Teams Configuration and Convert file content from JSON format to PowerShell object
$JSONObject=Get-Content -Raw -Path "$ENV:APPDATA\Microsoft\Teams\desktop-config.json" | ConvertFrom-Json

# Update Object settings
$JSONObject.appPreferenceSettings.disableGpu=$disableGpu
$JSONObject.appPreferenceSettings.runningOnClose=$runningOnClose
$NewFileContent=$JSONObject | ConvertTo-Json

# Update configuration in file
$NewFileContent | Set-Content -Path "$ENV:APPDATA\Microsoft\Teams\desktop-config.json" 
