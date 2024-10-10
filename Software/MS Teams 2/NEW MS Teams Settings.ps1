# ******************************************************
# D. Mohrmann, Cancom GmbH
# Configure NEW MS Teams 2.x settings in users json file
# ******************************************************

<#
.SYNOPSIS
This script configures MS-Teams 2 VDI user settings in the app_settings.json file located in %LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams
		
.Description
Use the scrpipt as a powershell logon script to configure various Teams settings

.EXAMPLE
Replace false and true to change the settings
"open_app_in_background":false (Don't open Teams in background)
"keep_app_running_on_close":false (Close Teams, don't minimize to the system tray)

.NOTES

#>

# Register MS Teams AppX Package for user
Add-AppPackage -Register -DisableDevelopmentMode "$ENV:TeamsVersionPath\AppXManifest.xml" -EA SilentlyContinue

# Define the json file location
$TeamsConfig = "$ENV:LocalAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\app_settings.json"

# Make a backup of the json file
Copy-Item -Path $TeamsConfig -Destination "$TeamsConfig.bak" -Force

# Read the content
$jsonContent = Get-Content -Path $TeamsConfig -Raw

# Replace the values
$jsonContent = $jsonContent -replace '"open_app_in_background":true', '"open_app_in_background":false'
$jsonContent = $jsonContent -replace '"keep_app_running_on_close":true', '"keep_app_running_on_close":false'

# Save the modified json file
Set-Content -Path $TeamsConfig -Value $jsonContent -Force
