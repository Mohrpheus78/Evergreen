# ******************************************************
# D. Mohrmann, Cancom GmbH, Twitter: @mohrpheus78
# Install Software packages on your master server/client
# ******************************************************

<#
.SYNOPSIS
This script calls other scripts to install software on a MCS/PVS master server/client or wherever you want. Install scripts have to be in the root folder. 
		
.DESCRIPTION
To install a software package just launch the Installer.ps1 script and select the software you want to install.
The selection is stored in a XML file, so you can easily replace the script and you don't have to make your selection again every time.

.EXAMPLE

.PARAMETER
If you made your selection once, you can run the script with the -noGUI parameter.

.NOTES
Thanks to Trond Eric Haarvarstein, I used some code from his great Automation Framework! Thanks to Manuel Winkel for the forms ;-)
Run as admin!
Version: 3.0.1
06/24: Changed internet connection check
06/25: Changed internet connection check
06/27: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 at the top of the script
06/29: Errors in MS Edge, pdf24creator and VLC install scripts
06/30: Changed Adobe Reader check if Reader is already installed, changed TreeSize version check
06/30: Changed FileZilla version check
07/04: Suppress error message while removing Teams from run key (if already removed)
07/06: Citrix WorkspaceApp run keys prevented the app from starting at logon (Current Release)
07/27: Changed Citrix WorkspaceApp version check and always install MS Edge WebView updates, changed Adobe DC update check
11/21: Wrong CitrixFiles Run registry key to prevent Citrix Files from lauch automtically
11/22: Added support for PVS Admin Toolkit, no version check if you run with -noGUI parameter
15/12: Minor changes in install scripts
20/12: Added results at the end for documentation (e.g. PVS vDisk properties)
22/12: Syntax error Office scripts
02/01: Addec MS VcRedist packages
03/01: Improved error logging for all scripts, various aother improvements, added SplashScreen
04/01: Load SplashScreen only if available, check for SplashScreen Powershell module and load from GitHub of not present
05/01: Added Foxit Reader, MS SQL MGMT Studio EN and DE, OneDrive Auto Update disabled
11/01: Better error handling if one install script fails
08/02: Improvements for MS Edge, Google Chrome
02/16: No error message if Splashscreen cannot be loaded, improvements for MS Edge, Google Chrome (check scheduled taks even if there is no update)
03/23: Added ShareX
04/11: Added KeePassXC, modified Citrix components scripts
04/21: Added Citrix scripts for VDA and WEM standalone
04/24: Changed Oracle Java version check
04/26: Added $SoftwareToAutoInstall  for PVS Admin Toolkit
05/30: Changed MS Teams notes, changed MS SQL MGMT Studio version check
23/07/18: Added WinRAR
23/07/27: Fixed error in PVS target LTSR script, changed Adobe script
23/10/06: Changed installation path for Citrix products, Better internet connection check
23/10/11: Added MS .NET Desktop Runtime as a requirement for Citrix WorkspaceApp CR
23/10/20: Move FSLogix rules before updating Office
23/10/23: WEM agent checks if WEM cloud service or onPrem is used, VDA and WEM version check
23/11/20: Second internet connection check
23/12/14: Changed Citrix PVS, WEM and VDA scripts to not cancel if selected and no newer version is available
24/01/16: Changed version variable for Citrix WorkspaceApp CR
24/02/08: Added Windows Task in FSLogix install script for Windows Search problem with multi user on Windows Server 2019/2022
24/02/15: Changed detection of WEM agent running on Cloud or on prem
24/03/19: Fixed update check for Citrix WorkspaceApp
24/04/23: Added new Citrix 2402 LTSR components, chaned WEM cloud service detection
24/04/25: Added MS .NET DesktopRuntime 8.4.0 for Remote Desktop Manager
24/05/02: nNw path for Google Chrome scheduled update tasks 
24/06/06: Changed version variable for Citrix WorkspaceApp LTSR
24/07/03: Disabled all Google Chrome update services
24/07/08: Delete Chrome active setup regkeys, corrected error with Chrome install syntax
24/07/19: Added NEW MS Teams 2.x
24/07/24: Added MS openJDK 21
24/07/30: Add MS Teams version environment variable to provision Teams for the user
24/08/26: Added new MS Teams plugin for Citrix WorkspaceApp, added MS .NET Desktop runtime for WSA LTSR
24/08/26: Changed Oracle Java version check
24/09/19: Changed PVS target device version check
24/10/11: Changed WorkspaceApp LTSR .NET Desktop Runtime to version 8.0.10, added Teams 2.0 logon script
24/10/14: Changed Foxit Reader version check, display NEW Teams update question only once, if migrating from old Teams
24/11/06: Changed MS Teams 2 update question
24/11/07: Register MS Teams for all users, including admins, changed Adobe update task check
24/11/19: Better approach to delete/disable OneDrive and Chrome update tasks, check if Windows search failure tasks are present if installing FSLogix
24/11/29: Changed uninstall procedure for MS Teams 2.x if OS is Server 2019 or Windows 10, removed mRemote NG
24/12/16: Changed .NET Desktop Runtime for CR WorkspaceApp to version 8.10
25/01/03: Added VMWare Tools
25/02/05: Added Windows Server 2025 to NEW MS Teamsa as OS, configured MS Teams scheduled task for App-X registration
25/02/12: Citrix PVS client LTSR display name correction
25/02/18: New app design, added MS Office 2024 LTSC
25/02/21: Added Mozilla Firefox
25/02/24: Changed Windows search failure workaround task
25/03/07: Added Firefox de/us language, changed MS Teams App-X registration
25/03/10: Corrected MS Teams App-X registration
25/04/10: Added .NET 9.0 Desktop Runtime (v9.0.4) for Remote Desktop Manager
25/04/14: Added Windows Desktop-Runtime-8.0.11 (for Citrix WorkspaceApp)
25/05/06: Removed Adobe Reader "Try Adobe Acrobat" add and diable AdobeCollabSync
25/06/10: Added uberAgent and deviceTRUST to Citrix VDA current release
25/06/11: Removed Adobe Reader "Try Adobe Acrobat" add and diable AdobeCollabSync
25/06/30: Removed deviceTRUST agent (now part of Citrix VDA)
25/07/31: Added MS .NET 8.0 Desktop Runtime (v8.0.18) for Citrix WorkspaceApp, changed VLC Media Player to EXE version
25/08/05: Fixed a VLC install error
25/09/01: Updated VDA scripts for version 2507 and feature CR versions
25/09/03: Added MS Teams VDI Plugin für WorkspaceApp
25/09/23: Prevent updates of Citrix WorkspaceApp within VDA Updates
25/10/09: Added switch SoftwareToRemoteInstall to install Evergreen apps from remote system (seperate scripts)
26/01/26: Added MS .NET 8.0 Desktop Runtime (v8.0.18) for Citrix WorkspaceApp LTSR, changed command line options for Citrix WorkspaceApp
26/02/16: Corrected VMWare Tools version
26/03/11: Added MS Visual Studio Code and MS .Net Runtime 8.x
26/03/16: Added MS SQL Management Studio 22 (Visual Studio Installer)
26/03/25: Changed Citrix WorkspaceApp to not install Zoom VDI plugin, changed .NET Desktop Runtime to 8.25, added .NET Desktop Runtime 10.0.5 for Remote Desktop Manager
26/04/29: Changed Citrix Hypervisor Tools to Citrix VM Tools, changed scheduled task to register Teams for users at logon
26/04/30: Typo in "Install MS Teams" script
26/05/12: Changed scheduled task for registering MS Teams AppX package
26/05/26: Added .NET Desktop Runtime 10.0.8 for Remote Desktop Manager
26/08/27: Bugfixes
26/09/15: Added MS .NET Desktop Runtime 10.0.12 for Citrix WorkspaceApp LTSR 2607, changed Citrix WorkspaceApp 2607 LTSR parameters
26/09/16: Changed MS Visual C++ 2015-2022 Runtime version check
26/09/21: corrected MS Visual C++ 2015-2022 Runtime version check
26/10/20: Changed version check for MS .NET Desktop Runtime 10.0.12
26/10/23: Addtional exclusions for Citrix VDA LTSR 2607
26/10/24: Changed components for Citrix VDA
26/10/24: Fixed ImageGlass installer
26/10/23: Version 3.0 with complete redesign
# Notes
#>
Param (
    [Parameter(
        HelpMessage = 'Start without GUI',
        ValueFromPipelineByPropertyName = $true
    )]
    [switch]$NoGUI,

    [Parameter(Mandatory = $false)]
    [switch]$SoftwareToAutoInstall,

    [Parameter(Mandatory = $false)]
    [switch]$SoftwareToRemoteInstall,

    [Parameter(Mandatory = $false)]
    [string]$UpdateManifestPath,

    [Parameter(Mandatory = $false)]
    [switch]$UpdateDryRun,

    [Parameter(Mandatory = $false)]
    [switch]$SkipUpdateCheck,

    [Parameter(Mandatory = $false)]
    [string]$UpdateHealthCheckPath,

    [Parameter(Mandatory = $false)]
    [string]$UpdateHealthCheckToken
)


# TLS settings
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[version]$EvergreenVersion = "3.0.1"


# ======================
# Startup window
# ======================
$script:StartupUiEnabled = -not $NoGUI
$script:StartupForm = $null
$script:StartupLogo = $null
$script:StartupLogoDisplay = $null

function New-EvergreenLogo {
	try {
		$LogoPath = Join-Path $PSScriptRoot "Shortcut\Software_Installation.png"
		if (-not (Test-Path -LiteralPath $LogoPath -PathType Leaf)) { return $null }
		$SourceImage = [System.Drawing.Image]::FromFile($LogoPath)
		try { return [System.Drawing.Bitmap]::new($SourceImage) }
		finally { $SourceImage.Dispose() }
	}
	catch { return $null }
}

function New-EvergreenIcon {
	try {
		$IconPath = Join-Path $PSScriptRoot "Shortcut\Software_Installation.ico"
		if (-not (Test-Path -LiteralPath $IconPath -PathType Leaf)) { return $null }
		return [System.Drawing.Icon]::new($IconPath)
	}
	catch { return $null }
}
$script:StartupShownAt = $null
$script:StartupMinimumDurationMilliseconds = 6500

function Start-StartupWindow {
	if (-not $script:StartupUiEnabled) { return }
	try {
		Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
		Add-Type -AssemblyName System.Drawing -ErrorAction Stop
		[System.Windows.Forms.Application]::EnableVisualStyles()
		$Form = New-Object System.Windows.Forms.Form
		$Form.Text = "Software Installer $EvergreenVersion"
		$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
		$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
		$Form.Size = New-Object System.Drawing.Size(760,400)
		$Form.BackColor = [System.Drawing.Color]::FromArgb(242,247,251)
		$Form.ShowInTaskbar = $true
		$StartupFormIcon = New-EvergreenIcon
		if ($null -ne $StartupFormIcon) { $Form.Icon = $StartupFormIcon }

		$Title = New-Object System.Windows.Forms.Label
		$Title.Text = "Software Installer"
		$Title.Location = New-Object System.Drawing.Point(42,38)
		$Title.Size = New-Object System.Drawing.Size(560,44)
		$Title.Font = New-Object System.Drawing.Font("Segoe UI Semibold",24)
		$Title.ForeColor = [System.Drawing.Color]::FromArgb(32,64,96)
		$Form.Controls.Add($Title)

		$Subtitle = New-Object System.Windows.Forms.Label
		$Subtitle.Text = "Powered by Evergreen  |  Version $EvergreenVersion"
		$Subtitle.Location = New-Object System.Drawing.Point(46,84)
		$Subtitle.Size = New-Object System.Drawing.Size(500,28)
		$Subtitle.Font = New-Object System.Drawing.Font("Segoe UI",11)
		$Subtitle.ForeColor = [System.Drawing.Color]::FromArgb(96,123,145)
		$Form.Controls.Add($Subtitle)

		$script:StartupLogo = New-EvergreenLogo
		if ($null -ne $script:StartupLogo) {
			try {
				$Logo = New-Object System.Windows.Forms.PictureBox
				$Logo.Location = New-Object System.Drawing.Point(620,22)
				$Logo.Size = New-Object System.Drawing.Size(96,96)
				$Logo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
				$Logo.Padding = New-Object System.Windows.Forms.Padding(12)
				$Logo.Image = $script:StartupLogo
				$Form.Controls.Add($Logo)
				$Logo.BringToFront()
			}
			catch { $script:StartupLogo = $null }
		}

		$Status = New-Object System.Windows.Forms.Label
		$Status.Text = "Starting..."
		$Status.Location = New-Object System.Drawing.Point(46,170)
		$Status.Size = New-Object System.Drawing.Size(668,34)
		$Status.Font = New-Object System.Drawing.Font("Segoe UI Semibold",15)
		$Status.ForeColor = [System.Drawing.Color]::FromArgb(22,112,184)
		$Form.Controls.Add($Status)

		$Detail = New-Object System.Windows.Forms.Label
		$Detail.Text = "Preparing the application."
		$Detail.Location = New-Object System.Drawing.Point(47,207)
		$Detail.Size = New-Object System.Drawing.Size(665,56)
		$Detail.Font = New-Object System.Drawing.Font("Segoe UI",11)
		$Detail.ForeColor = [System.Drawing.Color]::FromArgb(96,123,145)
		$Form.Controls.Add($Detail)

		$Progress = New-Object System.Windows.Forms.ProgressBar
		$Progress.Location = New-Object System.Drawing.Point(50,270)
		$Progress.Size = New-Object System.Drawing.Size(660,8)
		$Progress.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
		$Progress.ForeColor = [System.Drawing.Color]::FromArgb(22,112,184)
		$Progress.BackColor = [System.Drawing.Color]::FromArgb(208,222,234)
		$Progress.MarqueeAnimationSpeed = 25
		$Form.Controls.Add($Progress)

		$ActionPanel = New-Object System.Windows.Forms.FlowLayoutPanel
		$ActionPanel.Location = New-Object System.Drawing.Point(46,302)
		$ActionPanel.Size = New-Object System.Drawing.Size(668,48)
		$ActionPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
		$ActionPanel.Visible = $false
		$ActionPanel.Tag = $null
		$Form.Controls.Add($ActionPanel)
		foreach ($ButtonDefinition in @(
			@{ Text = "Retry"; Result = "Retry"; Width = 120 },
			@{ Text = "Continue offline"; Result = "Continue"; Width = 170 },
			@{ Text = "Exit"; Result = "Exit"; Width = 120 }
		)) {
			$Button = New-Object System.Windows.Forms.Button
			$Button.Text = $ButtonDefinition.Text
			$Button.Size = New-Object System.Drawing.Size($ButtonDefinition.Width,38)
			$Button.BackColor = [System.Drawing.Color]::White
			$Button.ForeColor = [System.Drawing.Color]::FromArgb(32,64,96)
			$Button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(180,201,218)
			$Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
			$Button.Font = New-Object System.Drawing.Font("Segoe UI",11)
			$Button.Tag = $ButtonDefinition.Result
			$Button.Add_Click({
				param($Sender,$EventArgs)
				$Sender.Parent.Tag = [string]$Sender.Tag
			})
			$ActionPanel.Controls.Add($Button)
		}

		$Footer = New-Object System.Windows.Forms.Label
		$Footer.Text = "© D. Mohrmann - @mohrpheus78"
		$Footer.Location = New-Object System.Drawing.Point(47,365)
		$Footer.Size = New-Object System.Drawing.Size(400,20)
		$Footer.Font = New-Object System.Drawing.Font("Segoe UI",9)
		$Footer.ForeColor = [System.Drawing.Color]::FromArgb(96,123,145)
		$Form.Controls.Add($Footer)

		$script:StartupForm = $Form
		$script:StartupStatusLabel = $Status
		$script:StartupDetailLabel = $Detail
		$script:StartupProgress = $Progress
		$script:StartupActionPanel = $ActionPanel
		$Form.Add_FormClosing({
			if ($null -ne $script:StartupActionPanel -and $null -eq $script:StartupActionPanel.Tag) { $script:StartupActionPanel.Tag = "Exit" }
		})
		$Form.Show()
		$Form.Activate()
		$script:StartupShownAt = [DateTime]::UtcNow
		[System.Windows.Forms.Application]::DoEvents()
	}
	catch {
		$script:StartupUiEnabled = $false
		$script:StartupForm = $null
	}
}

function Set-StartupStatus {
	param([string]$Status,[string]$Detail = "",[int]$MinimumDisplayMilliseconds = 0)
	if ($null -eq $script:StartupForm -or $script:StartupForm.IsDisposed) { return }
	$script:StartupStatusLabel.Text = $Status
	$script:StartupDetailLabel.Text = $Detail
	$script:StartupActionPanel.Visible = $false
	$script:StartupProgress.Visible = $true
	[System.Windows.Forms.Application]::DoEvents()
	if ($MinimumDisplayMilliseconds -gt 0) {
		$DisplayTimer = [System.Diagnostics.Stopwatch]::StartNew()
		while ($DisplayTimer.ElapsedMilliseconds -lt $MinimumDisplayMilliseconds) {
			[System.Windows.Forms.Application]::DoEvents()
			Start-Sleep -Milliseconds 50
		}
	}
}

function Wait-StartupInternetChoice {
	param([string]$Detail)
	if ($null -eq $script:StartupForm -or $script:StartupForm.IsDisposed) { return "Continue" }
	$script:StartupActionPanel.Tag = $null
	$script:StartupStatusLabel.Text = "GitHub update source could not be validated."
	$script:StartupDetailLabel.Text = $Detail
	$script:StartupProgress.Visible = $false
	$script:StartupActionPanel.Visible = $true
	while ($null -eq $script:StartupActionPanel.Tag) {
		if ($script:StartupForm.IsDisposed) { return "Exit" }
		[System.Windows.Forms.Application]::DoEvents()
		Start-Sleep -Milliseconds 50
	}
	$Choice = [string]$script:StartupActionPanel.Tag
	$script:StartupActionPanel.Visible = $false
	return $Choice
}

function Close-StartupWindow {
	if ($null -ne $script:StartupForm -and -not $script:StartupForm.IsDisposed) {
		if ($null -ne $script:StartupShownAt) {
			$ElapsedMilliseconds = ([DateTime]::UtcNow - $script:StartupShownAt).TotalMilliseconds
			while ($ElapsedMilliseconds -lt $script:StartupMinimumDurationMilliseconds) {
				[System.Windows.Forms.Application]::DoEvents()
				Start-Sleep -Milliseconds 50
				$ElapsedMilliseconds = ([DateTime]::UtcNow - $script:StartupShownAt).TotalMilliseconds
			}
		}
		$script:StartupForm.Close()
		$script:StartupForm.Dispose()
	}
	if ($null -ne $script:StartupLogo) { $script:StartupLogo.Dispose() }
	if ($null -ne $script:StartupLogoDisplay) { $script:StartupLogoDisplay.Dispose() }
	$script:StartupForm = $null
}

function Restore-StartupConsole {
	# Console visibility is controlled by the trusted shortcut, not by native API calls in this script.
}

function Get-EvergreenUpdateCandidate {
	param([string]$ManifestPath,[string]$ProductKey)
	if ([String]::IsNullOrWhiteSpace($ManifestPath)) { throw "No update manifest was specified." }
	$ResolvedManifestPath = if ([IO.Path]::IsPathRooted($ManifestPath)) { [IO.Path]::GetFullPath($ManifestPath) } else { [IO.Path]::GetFullPath((Join-Path $PSScriptRoot $ManifestPath)) }
	if (-not (Test-Path -LiteralPath $ResolvedManifestPath -PathType Leaf)) { throw "Update manifest not found: $ResolvedManifestPath" }
	$Manifest = Get-Content -LiteralPath $ResolvedManifestPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
	if ([int]$Manifest.schemaVersion -ne 1) { throw "Unsupported update manifest schema: $($Manifest.schemaVersion)" }
	$ProductProperty = $Manifest.products.PSObject.Properties[$ProductKey]
	if ($null -eq $ProductProperty) { throw "The manifest does not contain a '$ProductKey' product." }
	$Product = $ProductProperty.Value
	try { $CandidateVersion = [version]$Product.version } catch { throw "The manifest contains an invalid $ProductKey version." }
	if ([String]::IsNullOrWhiteSpace([string]$Product.source)) { throw "The manifest does not define a source for $ProductKey." }
	$Source = [string]$Product.source
	if (-not [Uri]::IsWellFormedUriString($Source,[UriKind]::Absolute)) {
		$Source = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $ResolvedManifestPath) $Source))
	}
	return [PSCustomObject]@{
		Product = $ProductKey
		Version = $CandidateVersion
		Source = $Source
		Sha256 = ([string]$Product.sha256).Trim().ToUpperInvariant()
		Notes = @($Product.notes)
		Channel = [string]$Manifest.channel
		ManifestPath = $ResolvedManifestPath
	}
}

function Test-EvergreenUpdateCandidate {
	param($Candidate,[switch]$KeepStagedFile)
	$StageFolder = Join-Path ([IO.Path]::GetTempPath()) ("Evergreen-Update-DryRun-" + [Guid]::NewGuid().ToString("N"))
	$StageFile = Join-Path $StageFolder ("Evergreen-Software $($Candidate.Product).ps1")
	$ValidationSucceeded = $false
	try {
		[void](New-Item -Path $StageFolder -ItemType Directory -Force -ErrorAction Stop)
		if ([Uri]::IsWellFormedUriString([string]$Candidate.Source,[UriKind]::Absolute) -and ([Uri]$Candidate.Source).Scheme -in @("http","https")) {
			Invoke-WebRequest -UseBasicParsing -Uri $Candidate.Source -OutFile $StageFile -TimeoutSec 30 -Headers @{ "User-Agent" = "Evergreen-Update-Validation" } -ErrorAction Stop
		}
		else {
			if (-not (Test-Path -LiteralPath $Candidate.Source -PathType Leaf)) { throw "Update source not found: $($Candidate.Source)" }
			Copy-Item -LiteralPath $Candidate.Source -Destination $StageFile -Force -ErrorAction Stop
		}
		if ([String]::IsNullOrWhiteSpace($Candidate.Sha256)) { throw "The manifest does not contain a SHA-256 checksum." }
		$ActualHash = (Get-FileHash -LiteralPath $StageFile -Algorithm SHA256 -ErrorAction Stop).Hash.ToUpperInvariant()
		if ($ActualHash -ne $Candidate.Sha256) { throw "SHA-256 mismatch. Expected $($Candidate.Sha256), received $ActualHash." }
		$Tokens = $null
		$ParseErrors = $null
		[void][System.Management.Automation.Language.Parser]::ParseFile($StageFile,[ref]$Tokens,[ref]$ParseErrors)
		if ($ParseErrors.Count -gt 0) { throw "PowerShell syntax validation failed: $($ParseErrors[0].Message)" }
		$PackageContent = Get-Content -LiteralPath $StageFile -Raw -ErrorAction Stop
		$HeaderVersionMatch = [regex]::Match($PackageContent,'(?m)^Version:\s*(?<Version>\d+(?:\.\d+){1,3})\s*$')
		$RuntimeVersionMatch = [regex]::Match($PackageContent,'(?m)^\[version\]\$EvergreenVersion\s*=\s*"(?<Version>\d+(?:\.\d+){1,3})"\s*$')
		if (-not $HeaderVersionMatch.Success) { throw "The package does not contain a Version header." }
		if (-not $RuntimeVersionMatch.Success) { throw "The package does not contain the runtime version constant." }
		if ([version]$HeaderVersionMatch.Groups['Version'].Value -ne $Candidate.Version -or [version]$RuntimeVersionMatch.Groups['Version'].Value -ne $Candidate.Version) { throw "Manifest, header, and runtime versions do not match." }
		$ValidationSucceeded = $true
		return [PSCustomObject]@{ Success = $true; Version = $Candidate.Version; Hash = $ActualHash; Message = "Download/staging, SHA-256, version, and PowerShell syntax checks passed."; StagedPath = $StageFile; StageFolder = $StageFolder }
	}
	catch {
		return [PSCustomObject]@{ Success = $false; Version = $Candidate.Version; Hash = ""; Message = $_.Exception.Message; StagedPath = ""; StageFolder = $StageFolder }
	}
	finally {
		if ((-not $KeepStagedFile -or -not $ValidationSucceeded) -and (Test-Path -LiteralPath $StageFolder)) { Remove-Item -LiteralPath $StageFolder -Recurse -Force -ErrorAction SilentlyContinue }
	}
}

function New-EvergreenValidatedUpdateFromContent {
	param([string]$Content,[version]$Version,[string]$ProductKey)
	$StageFolder = Join-Path ([IO.Path]::GetTempPath()) ("Evergreen-Update-DryRun-" + [Guid]::NewGuid().ToString("N"))
	$StageFile = Join-Path $StageFolder ("Evergreen-Software $ProductKey.ps1")
	try {
		if ([String]::IsNullOrWhiteSpace($Content)) { throw "The update source returned an empty script." }
		[void](New-Item -Path $StageFolder -ItemType Directory -Force -ErrorAction Stop)
		[IO.File]::WriteAllText($StageFile,$Content,[Text.UTF8Encoding]::new($true))
		$Tokens = $null
		$ParseErrors = $null
		[void][System.Management.Automation.Language.Parser]::ParseFile($StageFile,[ref]$Tokens,[ref]$ParseErrors)
		if ($ParseErrors.Count -gt 0) { throw "PowerShell syntax validation failed: $($ParseErrors[0].Message)" }
		$HeaderVersionMatch = [regex]::Match($Content,'(?m)^Version:\s*(?<Version>\d+(?:\.\d+){1,3})\s*$')
		$RuntimeVersionMatch = [regex]::Match($Content,'(?m)^\[version\]\$EvergreenVersion\s*=\s*"(?<Version>\d+(?:\.\d+){1,3})"\s*$')
		if (-not $HeaderVersionMatch.Success -or -not $RuntimeVersionMatch.Success) { throw "The downloaded script does not contain matching version metadata." }
		if ([version]$HeaderVersionMatch.Groups['Version'].Value -ne $Version -or [version]$RuntimeVersionMatch.Groups['Version'].Value -ne $Version) { throw "The downloaded script version does not match the advertised version." }
		$ActualHash = (Get-FileHash -LiteralPath $StageFile -Algorithm SHA256 -ErrorAction Stop).Hash.ToUpperInvariant()
		return [PSCustomObject]@{ Success = $true; Version = $Version; Hash = $ActualHash; Message = "Download, version, and PowerShell syntax checks passed."; StagedPath = $StageFile; StageFolder = $StageFolder }
	}
	catch {
		if (Test-Path -LiteralPath $StageFolder) { Remove-Item -LiteralPath $StageFolder -Recurse -Force -ErrorAction SilentlyContinue }
		return [PSCustomObject]@{ Success = $false; Version = $Version; Hash = ""; Message = $_.Exception.Message; StagedPath = ""; StageFolder = $StageFolder }
	}
}

function Write-EvergreenUpdateHealthCheck {
	if ([String]::IsNullOrWhiteSpace($UpdateHealthCheckPath) -or [String]::IsNullOrWhiteSpace($UpdateHealthCheckToken)) { return }
	try {
		$HealthDirectory = Split-Path -Parent $UpdateHealthCheckPath
		if (-not [String]::IsNullOrWhiteSpace($HealthDirectory)) { [void](New-Item -Path $HealthDirectory -ItemType Directory -Force -ErrorAction Stop) }
		[IO.File]::WriteAllText($UpdateHealthCheckPath,$UpdateHealthCheckToken,[Text.Encoding]::UTF8)
	}
	catch { }
}

function Install-EvergreenValidatedUpdate {
	param($ValidationResult,[string]$ProductKey,[int]$HealthTimeoutSeconds = 120)
	$RestartProcess = $null
	$IncomingPath = "$PSCommandPath.evergreen-update"
	$TransactionFolder = Join-Path ([IO.Path]::GetTempPath()) ("Evergreen-Update-Health-" + [Guid]::NewGuid().ToString("N"))
	$HealthPath = Join-Path $TransactionFolder "health.txt"
	$HealthToken = [Guid]::NewGuid().ToString("N")
	$BackupRoot = Join-Path $PSScriptRoot "_Update Backups"
	$BackupName = "{0}-{1}-{2}.ps1" -f $ProductKey,$EvergreenVersion,(Get-Date -Format "yyyyMMdd-HHmmss")
	$BackupScriptPath = Join-Path $BackupRoot $BackupName
	try {
		if ($null -eq $ValidationResult -or -not $ValidationResult.Success) { throw "The update package has not passed validation." }
		if (-not (Test-Path -LiteralPath $ValidationResult.StagedPath -PathType Leaf)) { throw "The validated update package is no longer available." }
		$StageHash = (Get-FileHash -LiteralPath $ValidationResult.StagedPath -Algorithm SHA256 -ErrorAction Stop).Hash.ToUpperInvariant()
		if ($StageHash -ne ([string]$ValidationResult.Hash).ToUpperInvariant()) { throw "The staged update package changed after validation." }
		[void](New-Item -Path $BackupRoot -ItemType Directory -Force -ErrorAction Stop)
		[void](New-Item -Path $TransactionFolder -ItemType Directory -Force -ErrorAction Stop)
		Copy-Item -LiteralPath $ValidationResult.StagedPath -Destination $IncomingPath -Force -ErrorAction Stop
		[IO.File]::Replace($IncomingPath,$PSCommandPath,$BackupScriptPath,$true)

		$PowerShellExecutable = if ($PSVersionTable.PSEdition -eq 'Core') { Join-Path $PSHOME 'pwsh.exe' } else { Join-Path $PSHOME 'powershell.exe' }
		if (-not (Test-Path -LiteralPath $PowerShellExecutable -PathType Leaf)) { $PowerShellExecutable = (Get-Process -Id $PID).Path }
		$RestartArguments = "-NoLogo -NoProfile -File `"$PSCommandPath`" -SkipUpdateCheck -UpdateHealthCheckPath `"$HealthPath`" -UpdateHealthCheckToken $HealthToken"
		$RestartProcess = Start-Process -FilePath $PowerShellExecutable -ArgumentList $RestartArguments -PassThru -ErrorAction Stop
		Set-StartupStatus "Verifying the updated $ProductKey..." "The new GUI is starting. The previous script remains available in _Update Backups."
		$HealthTimer = [Diagnostics.Stopwatch]::StartNew()
		do {
			if (Test-Path -LiteralPath $HealthPath -PathType Leaf) {
				$ReportedToken = (Get-Content -LiteralPath $HealthPath -Raw -ErrorAction SilentlyContinue).Trim()
				if ($ReportedToken -eq $HealthToken) {
					return [PSCustomObject]@{ Success = $true; Message = "The updated GUI started successfully."; BackupPath = $BackupScriptPath; Process = $RestartProcess }
				}
			}
			if ($RestartProcess.HasExited) { break }
			if ($null -ne $script:StartupForm -and -not $script:StartupForm.IsDisposed) { [System.Windows.Forms.Application]::DoEvents() }
			Start-Sleep -Milliseconds 100
		} while ($HealthTimer.Elapsed.TotalSeconds -lt $HealthTimeoutSeconds)
		throw "The updated GUI did not report a successful start within $HealthTimeoutSeconds seconds."
	}
	catch {
		$FailureMessage = $_.Exception.Message
		if ($null -ne $RestartProcess -and -not $RestartProcess.HasExited) { Stop-Process -Id $RestartProcess.Id -Force -ErrorAction SilentlyContinue }
		if (Test-Path -LiteralPath $BackupScriptPath -PathType Leaf) {
			try { Copy-Item -LiteralPath $BackupScriptPath -Destination $PSCommandPath -Force -ErrorAction Stop }
			catch { $FailureMessage = "$FailureMessage Rollback failed: $($_.Exception.Message)" }
		}
		return [PSCustomObject]@{ Success = $false; Message = $FailureMessage; BackupPath = $BackupScriptPath; Process = $RestartProcess }
	}
	finally {
		Remove-Item -LiteralPath $IncomingPath -Force -ErrorAction SilentlyContinue
		if (Test-Path -LiteralPath $TransactionFolder) { Remove-Item -LiteralPath $TransactionFolder -Recurse -Force -ErrorAction SilentlyContinue }
	}
}

function Remove-EvergreenStagedUpdate {
	param($ValidationResult)
	if ($null -eq $ValidationResult -or [String]::IsNullOrWhiteSpace([string]$ValidationResult.StageFolder)) { return }
	$ResolvedStage = [IO.Path]::GetFullPath([string]$ValidationResult.StageFolder)
	$ResolvedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
	if ($ResolvedStage.StartsWith($ResolvedTemp,[StringComparison]::OrdinalIgnoreCase) -and (Split-Path -Leaf $ResolvedStage) -like "Evergreen-Update-DryRun-*") { Remove-Item -LiteralPath $ResolvedStage -Recurse -Force -ErrorAction SilentlyContinue }
}


# FUNCTION Logging
#========================================================================================================================================
Function DS_WriteLog {
    
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$true, Position = 0)][ValidateSet("I","S","W","E","-",IgnoreCase = $True)][String]$InformationType,
        [Parameter(Mandatory=$true, Position = 1)][AllowEmptyString()][String]$Text,
        [Parameter(Mandatory=$true, Position = 2)][AllowEmptyString()][String]$LogFile
    )
 
    begin {
    }
 
    process {
     $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss)
 
        if ( $Text -eq "" ) {
            Add-Content $LogFile -value ("") # Write an empty line
        } Else {
         Add-Content $LogFile -value ($DateTime + " " + $InformationType.ToUpper() + " - " + $Text)
        }
    }
 
    end {
    }
}
#========================================================================================================================================


# FUNCTION GUI
# ========================================================================================================================================
function gui_mode{
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
	$OriginalSoftwareSelection = $SoftwareSelection

	# Set the size of your form
    $Form = New-Object system.Windows.Forms.Form
	$Form.ClientSize = New-Object System.Drawing.Point(1280,820)
	$Form.MinimumSize = New-Object System.Drawing.Size(1100,720)
    $Form.text = "Software-Installer $EvergreenVersion"
    $Form.TopMost = $false
    $Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $Form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
	$FormIconPath = Join-Path $PSScriptRoot "Shortcut\Software_Installation.ico"
	if (Test-Path -LiteralPath $FormIconPath -PathType Leaf) { try { $Form.Icon = [System.Drawing.Icon]::new($FormIconPath) } catch { } }
	else { try { $FormIcon = New-EvergreenIcon; if ($null -ne $FormIcon) { $Form.Icon = $FormIcon } } catch { } }
	$Form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $Form.AutoSize = $false
	$Form.BackColor = [System.Drawing.Color]::FromArgb(245,247,250)
	$StyleEvergreenButton = {
		param($Button,[bool]$Primary = $false)
		$Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$Button.FlatAppearance.BorderSize = 1
		$Button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(180,201,218)
		$Button.BackColor = if ($Primary) { [System.Drawing.Color]::FromArgb(22,112,184) } else { [System.Drawing.Color]::FromArgb(216,229,240) }
		$Button.ForeColor = if ($Primary) { [System.Drawing.Color]::White } else { [System.Drawing.Color]::FromArgb(23,63,102) }
		$Button.Font = New-Object System.Drawing.Font("Segoe UI",11)
		$Button.Cursor = [System.Windows.Forms.Cursors]::Hand
	}
	$NewEvergreenCategoryIcon = {
		param([string]$CategoryName)
		$Bitmap = New-Object System.Drawing.Bitmap -ArgumentList 28,28
		$Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
		$IconColor = [System.Drawing.Color]::FromArgb(22,112,184)
		$Pen = New-Object System.Drawing.Pen -ArgumentList $IconColor,2
		$Brush = New-Object System.Drawing.SolidBrush -ArgumentList $IconColor
		try {
			$Graphics.Clear([System.Drawing.Color]::Transparent)
			$Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
			$Pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
			$Pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
			$Pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
			switch ($CategoryName) {
				"All categories" {
					$Graphics.DrawRectangle($Pen,3,3,8,8)
					$Graphics.DrawRectangle($Pen,17,3,8,8)
					$Graphics.DrawRectangle($Pen,3,17,8,8)
					$Graphics.DrawRectangle($Pen,17,17,8,8)
				}
				"Standard" {
					$Top = [System.Drawing.Point[]]@([System.Drawing.Point]::new(3,8),[System.Drawing.Point]::new(14,3),[System.Drawing.Point]::new(25,8),[System.Drawing.Point]::new(14,13))
					$Graphics.DrawPolygon($Pen,$Top)
					$Graphics.DrawLine($Pen,3,8,3,20)
					$Graphics.DrawLine($Pen,3,20,14,25)
					$Graphics.DrawLine($Pen,14,25,25,20)
					$Graphics.DrawLine($Pen,25,20,25,8)
					$Graphics.DrawLine($Pen,14,13,14,25)
				}
				"Microsoft" {
					$Graphics.DrawRectangle($Pen,5,3,18,22)
					$Windows = [System.Drawing.Rectangle[]]@([System.Drawing.Rectangle]::new(8,7,4,4),[System.Drawing.Rectangle]::new(16,7,4,4),[System.Drawing.Rectangle]::new(8,13,4,4),[System.Drawing.Rectangle]::new(16,13,4,4))
					foreach ($Window in $Windows) { $Graphics.FillRectangle($Brush,$Window) }
					$Graphics.DrawRectangle($Pen,11,19,6,6)
				}
				"Citrix" {
					$Graphics.DrawRectangle($Pen,2,4,24,16)
					$Graphics.DrawLine($Pen,10,25,18,25)
					$Graphics.DrawLine($Pen,14,20,14,25)
					$Graphics.FillEllipse($Brush,6,9,3,3)
					$Graphics.FillEllipse($Brush,12,9,3,3)
					$Graphics.FillEllipse($Brush,18,9,3,3)
				}
				"Utilities" {
					$Graphics.DrawLine($Pen,8,21,20,9)
					$Graphics.DrawEllipse($Pen,3,20,7,7)
					$Graphics.DrawArc($Pen,17,3,9,9,35,220)
				}
			}
		}
		finally {
			$Pen.Dispose()
			$Brush.Dispose()
			$Graphics.Dispose()
		}
		return $Bitmap
	}

	# Draw the installer header icon in memory. No Base64 data or external image file is required.
	$NewInstallerHeaderIcon = {
		$Bitmap = New-Object System.Drawing.Bitmap -ArgumentList 56,56
		$Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
		$Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
		$Graphics.Clear([System.Drawing.Color]::Transparent)
		$BoxBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(224,169,72))
		$TopBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245,205,117))
		$LinePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(79,57,25)),1.5
		$GearFill = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(231,235,239))
		$GearPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(135,145,155)),1.4
		$HubBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
		try {
			# Package body and lid.
			$Graphics.FillRectangle($BoxBrush,5,14,36,31)
			$Graphics.DrawRectangle($LinePen,5,14,36,31)
			$TopPoints = [System.Drawing.Point[]]@(
				[System.Drawing.Point]::new(5,14),
				[System.Drawing.Point]::new(13,6),
				[System.Drawing.Point]::new(49,6),
				[System.Drawing.Point]::new(41,14)
			)
			$Graphics.FillPolygon($TopBrush,$TopPoints)
			$Graphics.DrawPolygon($LinePen,$TopPoints)

			# Installation gear: eight teeth around a circular hub.
			$CenterX = 42.0; $CenterY = 40.0
			$OuterRadius = 13.0; $InnerRadius = 9.7
			$GearPoints = New-Object System.Collections.Generic.List[System.Drawing.PointF]
			for ($Tooth = 0; $Tooth -lt 8; $Tooth++) {
				foreach ($Offset in @(-0.34,-0.16,0.16,0.34)) {
					$Angle = ($Tooth * ([Math]::PI / 4.0)) + $Offset
					$Radius = if ([Math]::Abs($Offset) -lt 0.2) { $OuterRadius } else { $InnerRadius }
					$GearPoints.Add([System.Drawing.PointF]::new(
						[single]($CenterX + [Math]::Cos($Angle) * $Radius),
						[single]($CenterY + [Math]::Sin($Angle) * $Radius)
					))
				}
			}
			$GearArray = $GearPoints.ToArray()
			$Graphics.FillPolygon($GearFill,$GearArray)
			$Graphics.DrawPolygon($GearPen,$GearArray)
			$Graphics.FillEllipse($HubBrush,36,34,12,12)
			$Graphics.DrawEllipse($GearPen,36,34,12,12)
			$Graphics.FillEllipse($GearFill,40,38,4,4)
		}
		finally {
			$HubBrush.Dispose(); $GearPen.Dispose(); $GearFill.Dispose()
			$LinePen.Dispose(); $TopBrush.Dispose(); $BoxBrush.Dispose(); $Graphics.Dispose()
		}
		return $Bitmap
	}

    # Set the font of the text to be used within the form
	$Font = New-Object System.Drawing.Font("Segoe UI",10)
	$CardFont = New-Object System.Drawing.Font("Segoe UI",11)
	$FontBold = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
	$Form.Font = $Font

    # Software Headline
    $Headline2 = New-Object system.Windows.Forms.Label
    $Headline2.text = "Select Software to install"
    $Headline2.AutoSize = $true
    $Headline2.width = 25
    $Headline2.height = 10
    $Headline2.location = New-Object System.Drawing.Point(11,4)
    $form.Controls.Add($Headline2)
	#$FontBold = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
	$Headline2.Font = $FontBold

	# NotePadPlusPlus Checkbox
    $NotePadPlusPlusBox = New-Object system.Windows.Forms.CheckBox
    $NotePadPlusPlusBox.text = "NotePad++"
    $NotePadPlusPlusBox.width = 95
    $NotePadPlusPlusBox.height = 20
	$NotePadPlusPlusBox.Font = $Font
    $NotePadPlusPlusBox.autosize = $true
    $NotePadPlusPlusBox.location = New-Object System.Drawing.Point(11,45)
    $form.Controls.Add($NotePadPlusPlusBox)
	$NotePadPlusPlusBox.Checked =  $SoftwareSelection.NotePadPlusPlus

    # 7Zip Checkbox
    $SevenZipBox = New-Object system.Windows.Forms.CheckBox
    $SevenZipBox.text = "7 Zip"
    $SevenZipBox.width = 95
    $SevenZipBox.height = 20
	$SevenZipBox.Font = $Font
    $SevenZipBox.autosize = $true
    $SevenZipBox.location = New-Object System.Drawing.Point(11,70)
    $form.Controls.Add($SevenZipBox)
	$SevenZipBox.Checked =  $SoftwareSelection.SevenZip

    # AdobeReaderDC Checkbox
    $AdobeReaderDCBox = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBox.text = "Adobe Reader DC MUI x86 (only for Base Install)"
    $AdobeReaderDCBox.width = 95
    $AdobeReaderDCBox.height = 20
	$AdobeReaderDCBox.Font = $Font
    $AdobeReaderDCBox.autosize = $true
    $AdobeReaderDCBox.location = New-Object System.Drawing.Point(11,95)
    $form.Controls.Add($AdobeReaderDCBox)
	$AdobeReaderDCBox.Checked =  $SoftwareSelection.AdobeReaderDC
	
	# AdobeReaderDCUpdate Checkbox
    $AdobeReaderDCBoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBoxUpdate.text = "Adobe Reader DC MUI x86 (Updates only)"
    $AdobeReaderDCBoxUpdate.width = 95
    $AdobeReaderDCBoxUpdate.height = 20
	$AdobeReaderDCBoxUpdate.Font = $Font
    $AdobeReaderDCBoxUpdate.autosize = $true
    $AdobeReaderDCBoxUpdate.location = New-Object System.Drawing.Point(11,120)
    $form.Controls.Add($AdobeReaderDCBoxUpdate)
	$AdobeReaderDCBoxUpdate.Checked =  $SoftwareSelection.AdobeReaderDCUpdate
	
	# AdobeReaderDCx64 Checkbox
    $AdobeReaderDCx64Box = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCx64Box.text = "Adobe Reader DC MUI x64 (only for Base Install)"
    $AdobeReaderDCx64Box.width = 95
    $AdobeReaderDCx64Box.height = 20
	$AdobeReaderDCx64Box.Font = $Font
    $AdobeReaderDCx64Box.autosize = $true
    $AdobeReaderDCx64Box.location = New-Object System.Drawing.Point(11,145)
    $form.Controls.Add($AdobeReaderDCx64Box)
	$AdobeReaderDCx64Box.Checked =  $SoftwareSelection.AdobeReaderDCx64
	
	# AdobeReaderDCx64Update Checkbox
    $AdobeReaderDCx64BoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCx64BoxUpdate.text = "Adobe Reader DC MUI x64 Update (Updates only)"
    $AdobeReaderDCx64BoxUpdate.width = 95
    $AdobeReaderDCx64BoxUpdate.height = 20
	$AdobeReaderDCx64BoxUpdate.Font = $Font
    $AdobeReaderDCx64BoxUpdate.autosize = $true
    $AdobeReaderDCx64BoxUpdate.location = New-Object System.Drawing.Point(11,170)
    $form.Controls.Add($AdobeReaderDCx64BoxUpdate)
	$AdobeReaderDCx64BoxUpdate.Checked =  $SoftwareSelection.AdobeReaderDCx64Update
	
	# VMWareTools Checkbox
    $VMWareToolsBox = New-Object system.Windows.Forms.CheckBox
    $VMWareToolsBox.text = "VMWare Tools"
    $VMWareToolsBox.width = 95
    $VMWareToolsBox.height = 20
    $VMWareToolsBox.autosize = $true
	$VMWareToolsBox.Font = $Font
    $VMWareToolsBox.location = New-Object System.Drawing.Point(11,195)
    $form.Controls.Add($VMWareToolsBox)
	$VMWareToolsBox.Checked =  $SoftwareSelection.VMWareTools
	
	# Citrix VM Tools Checkbox
    $CitrixVMToolsBox = New-Object system.Windows.Forms.CheckBox
    $CitrixVMToolsBox.text = "Citrix VM Tools (Auto Update disabled)"
    $CitrixVMToolsBox.width = 95
    $CitrixVMToolsBox.height = 20
    $CitrixVMToolsBox.autosize = $true
	$CitrixVMToolsBox.Font = $Font
    $CitrixVMToolsBox.location = New-Object System.Drawing.Point(11,220)
    $form.Controls.Add($CitrixVMToolsBox)
	$CitrixVMToolsBox.Checked = $SoftwareSelection.CitrixVMTools

    # Citrix WorkspaceApp_Current_Release Checkbox
    $WorkspaceApp_CRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CRBox.text = "Citrix WorkspaceApp CR"
    $WorkspaceApp_CRBox.width = 95
    $WorkspaceApp_CRBox.height = 20
    $WorkspaceApp_CRBox.autosize = $true
	$WorkspaceApp_CRBox.Font = $Font
    $WorkspaceApp_CRBox.location = New-Object System.Drawing.Point(11,245)
    $form.Controls.Add($WorkspaceApp_CRBox)
	$WorkspaceApp_CRBox.Checked =  $SoftwareSelection.WorkspaceApp_CR

    # Citrix WorkspaceApp_LTSR_Release Checkbox
    $WorkspaceApp_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSRBox.text = "Citrix WorkspaceApp LTSR"
    $WorkspaceApp_LTSRBox.width = 95
    $WorkspaceApp_LTSRBox.height = 20
    $WorkspaceApp_LTSRBox.autosize = $true
	$WorkspaceApp_LTSRBox.Font = $Font
    $WorkspaceApp_LTSRBox.location = New-Object System.Drawing.Point(11,270)
    $form.Controls.Add($WorkspaceApp_LTSRBox)
	$WorkspaceApp_LTSRBox.Checked =  $SoftwareSelection.WorkspaceApp_LTSR
	
	# Citrix WorkspaceApp_Current_Release_Web Checkbox
    $WorkspaceApp_CR_WebBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CR_WebBox.text = "Citrix WorkspaceApp CR Web (Autostart disabled)"
    $WorkspaceApp_CR_WebBox.width = 95
    $WorkspaceApp_CR_WebBox.height = 20
    $WorkspaceApp_CR_WebBox.autosize = $true
	$WorkspaceApp_CR_WebBox.Font = $Font
    $WorkspaceApp_CR_WebBox.location = New-Object System.Drawing.Point(11,295)
    $form.Controls.Add($WorkspaceApp_CR_WebBox)
	$WorkspaceApp_CR_WebBox.Checked =  $SoftwareSelection.WorkspaceApp_CR_Web

    # Citrix WorkspaceApp_LTSR_Release_Web Checkbox
    $WorkspaceApp_LTSR_WebBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSR_WebBox.text = "Citrix WorkspaceApp LTSR Web (Autostart disabled)"
    $WorkspaceApp_LTSR_WebBox.width = 95
    $WorkspaceApp_LTSR_WebBox.height = 20
    $WorkspaceApp_LTSR_WebBox.autosize = $true
	$WorkspaceApp_LTSR_WebBox.Font = $Font
    $WorkspaceApp_LTSR_WebBox.location = New-Object System.Drawing.Point(11,320)
    $form.Controls.Add($WorkspaceApp_LTSR_WebBox)
	$WorkspaceApp_LTSR_WebBox.Checked =  $SoftwareSelection.WorkspaceApp_LTSR_Web
	
	# Citrix PVS Target Device LTSR Checkbox
    $PVSTargetDevice_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $PVSTargetDevice_LTSRBox.text = "Citrix PVS Target Device LTSR"
    $PVSTargetDevice_LTSRBox.width = 95
    $PVSTargetDevice_LTSRBox.height = 20
    $PVSTargetDevice_LTSRBox.autosize = $true
	$PVSTargetDevice_LTSRBox.Font = $Font
    $PVSTargetDevice_LTSRBox.location = New-Object System.Drawing.Point(11,345)
    $form.Controls.Add($PVSTargetDevice_LTSRBox)
	$PVSTargetDevice_LTSRBox.Checked =  $SoftwareSelection.CitrixPVSTargetDevice_LTSR
	
	# Citrix PVS Target Device CR/Cloud Checkbox
    $PVSTargetDevice_CRBox = New-Object system.Windows.Forms.CheckBox
    $PVSTargetDevice_CRBox.text = "Citrix PVS Target Device CR/Cloud"
    $PVSTargetDevice_CRBox.width = 95
    $PVSTargetDevice_CRBox.height = 20
    $PVSTargetDevice_CRBox.autosize = $true
	$PVSTargetDevice_CRBox.Font = $Font
    $PVSTargetDevice_CRBox.location = New-Object System.Drawing.Point(11,370)
    $form.Controls.Add($PVSTargetDevice_CRBox)
	$PVSTargetDevice_CRBox.Checked =  $SoftwareSelection.CitrixPVSTargetDevice_CR
	
	# Citrix VDA LTSR Checkbox
    $ServerVDA_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_LTSRBox.text = "Citrix Server VDA LTSR"
    $ServerVDA_LTSRBox.width = 95
    $ServerVDA_LTSRBox.height = 20
    $ServerVDA_LTSRBox.Font = $Font
	$ServerVDA_LTSRBox.autosize = $true
    $ServerVDA_LTSRBox.location = New-Object System.Drawing.Point(11,395)
    $form.Controls.Add($ServerVDA_LTSRBox)
	$ServerVDA_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_LTSR
	
	# Citrix VDA CR/Cloud Checkbox
    $ServerVDA_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_CRBox.text = "Citrix Server VDA CR/Cloud"
    $ServerVDA_CRBox.width = 95
    $ServerVDA_CRBox.height = 20
    $ServerVDA_CRBox.autosize = $true
	$ServerVDA_CRBox.Font = $Font
    $ServerVDA_CRBox.location = New-Object System.Drawing.Point(11,420)
    $form.Controls.Add($ServerVDA_CRBox)
	$ServerVDA_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_CR
	
	# Citrix VDA PVS LTSR Checkbox
    $ServerVDA_PVS_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_PVS_LTSRBox.text = "Citrix Server VDA for PVS LTSR"
    $ServerVDA_PVS_LTSRBox.width = 95
    $ServerVDA_PVS_LTSRBox.height = 20
    $ServerVDA_PVS_LTSRBox.autosize = $true
	$ServerVDA_PVS_LTSRBox.Font = $Font
    $ServerVDA_PVS_LTSRBox.location = New-Object System.Drawing.Point(11,445)
    $form.Controls.Add($ServerVDA_PVS_LTSRBox)
	$ServerVDA_PVS_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_PVS_LTSR
	
	# Citrix VDA PVS CR/Cloud Checkbox
    $ServerVDA_PVS_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_PVS_CRBox.text = "Citrix Server VDA for PVS CR/Cloud"
    $ServerVDA_PVS_CRBox.width = 95
    $ServerVDA_PVS_CRBox.height = 20
    $ServerVDA_PVS_CRBox.autosize = $true
	$ServerVDA_PVS_CRBox.Font = $Font
    $ServerVDA_PVS_CRBox.location = New-Object System.Drawing.Point(11,470)
    $form.Controls.Add($ServerVDA_PVS_CRBox)
	$ServerVDA_PVS_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_PVS_CR
	
	# Citrix VDA MCS LTSR Checkbox
    $ServerVDA_MCS_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_MCS_LTSRBox.text = "Citrix Server VDA for MCS LTSR"
    $ServerVDA_MCS_LTSRBox.width = 95
    $ServerVDA_MCS_LTSRBox.height = 20
    $ServerVDA_MCS_LTSRBox.autosize = $true
	$ServerVDA_MCS_LTSRBox.Font = $Font
    $ServerVDA_MCS_LTSRBox.location = New-Object System.Drawing.Point(11,495)
    $form.Controls.Add($ServerVDA_MCS_LTSRBox)
	$ServerVDA_MCS_LTSRBox.Checked =  $SoftwareSelection.CitrixServerVDA_MCS_LTSR
	
	# Citrix VDA MCS CR/Cloud Checkbox
    $ServerVDA_MCS_CRBox = New-Object system.Windows.Forms.CheckBox
    $ServerVDA_MCS_CRBox.text = "Citrix Server VDA for MCS CR/Cloud"
    $ServerVDA_MCS_CRBox.width = 95
    $ServerVDA_MCS_CRBox.height = 20
    $ServerVDA_MCS_CRBox.autosize = $true
	$ServerVDA_MCS_CRBox.Font = $Font
    $ServerVDA_MCS_CRBox.location = New-Object System.Drawing.Point(11,520)
    $form.Controls.Add($ServerVDA_MCS_CRBox)
	$ServerVDA_MCS_CRBox.Checked =  $SoftwareSelection.CitrixServerVDA_MCS_CR
	
	# Citrix WEM Agent Checkbox
    $WEM_Agent_Box = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_Box.text = "Citrix WEM Agent for VDA"
    $WEM_Agent_Box.width = 95
    $WEM_Agent_Box.height = 20
    $WEM_Agent_Box.autosize = $true
	$WEM_Agent_Box.Font = $Font
    $WEM_Agent_Box.location = New-Object System.Drawing.Point(11,545)
    $form.Controls.Add($WEM_Agent_Box)
	$WEM_Agent_Box.Checked =  $SoftwareSelection.CitrixWEM_Agent
	
	# Citrix WEM Agent PVS Checkbox
    $WEM_Agent_PVSBox = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_PVSBox.text = "Citrix WEM Agent for PVS VDA"
    $WEM_Agent_PVSBox.width = 95
    $WEM_Agent_PVSBox.height = 20
    $WEM_Agent_PVSBox.autosize = $true
	$WEM_Agent_PVSBox.Font = $Font
    $WEM_Agent_PVSBox.location = New-Object System.Drawing.Point(11,570)
    $form.Controls.Add($WEM_Agent_PVSBox)
	$WEM_Agent_PVSBox.Checked =  $SoftwareSelection.CitrixWEM_Agent_PVS
	
	# Citrix WEM Agent MCS Checkbox
    $WEM_Agent_MCSBox = New-Object system.Windows.Forms.CheckBox
    $WEM_Agent_MCSBox.text = "Citrix WEM Agent for MCS VDA"
    $WEM_Agent_MCSBox.width = 95
    $WEM_Agent_MCSBox.height = 20
    $WEM_Agent_MCSBox.autosize = $true
	$WEM_Agent_MCSBox.Font = $Font
    $WEM_Agent_MCSBox.location = New-Object System.Drawing.Point(11,595)
    $form.Controls.Add($WEM_Agent_MCSBox)
	$WEM_Agent_MCSBox.Checked =  $SoftwareSelection.CitrixWEM_Agent_MCS
	
	# MSEdge Checkbox
    $MSEdgeBox = New-Object system.Windows.Forms.CheckBox
    $MSEdgeBox.text = "Microsoft Edge (Stable Channel)"
    $MSEdgeBox.width = 95
    $MSEdgeBox.height = 20
    $MSEdgeBox.autosize = $true
	$MSEdgeBox.Font = $Font
    $MSEdgeBox.location = New-Object System.Drawing.Point(420,45)
    $form.Controls.Add($MSEdgeBox)
	$MSEdgeBox.Checked =  $SoftwareSelection.MSEdge

    # MSOneDrive Checkbox
    $MSOneDriveBox = New-Object system.Windows.Forms.CheckBox
    $MSOneDriveBox.text = "Microsoft OneDrive (Machine-Based VDI Installer)"
    $MSOneDriveBox.width = 95
    $MSOneDriveBox.height = 20
    $MSOneDriveBox.autosize = $true
	$MSOneDriveBox.Font = $Font
    $MSOneDriveBox.location = New-Object System.Drawing.Point(420,70)
    $form.Controls.Add($MSOneDriveBox)
	$MSOneDriveBox.Checked =  $SoftwareSelection.MSOneDrive

    # MSDotNetRuntimeBox Checkbox
    $MSDotNetRuntimeBox = New-Object system.Windows.Forms.CheckBox
    $MSDotNetRuntimeBox.text = "Microsoft .Net Runtime 8.x"
    $MSDotNetRuntimeBox.width = 95
    $MSDotNetRuntimeBox.height = 20
    $MSDotNetRuntimeBox.autosize = $true
	$MSDotNetRuntimeBox.Font = $Font
    $MSDotNetRuntimeBox.location = New-Object System.Drawing.Point(420,95)
    $form.Controls.Add($MSDotNetRuntimeBox)
	$MSDotNetRuntimeBox.Checked =  $SoftwareSelection.MSDotNetRuntime
	
	# MSTeams 2 Checkbox
    $NEWMSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $NEWMSTeamsBox.text = "NEW Microsoft Teams 2.x"
    $NEWMSTeamsBox.width = 95
    $NEWMSTeamsBox.height = 20
    $NEWMSTeamsBox.autosize = $true
	$NEWMSTeamsBox.Font = $Font
    $NEWMSTeamsBox.location = New-Object System.Drawing.Point(420,120)
    $form.Controls.Add($NEWMSTeamsBox)
	$NEWMSTeamsBox.Checked =  $SoftwareSelection.MSTeams2
	
	# MS365 Apps Semi Annual Channel Checkbox
    $MS365AppsBox_SAC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_SAC.text = "Microsoft 365 Apps (x64/Semi Annual Channel)"
    $MS365AppsBox_SAC.width = 95
    $MS365AppsBox_SAC.height = 20
    $MS365AppsBox_SAC.autosize = $true
	$MS365AppsBox_SAC.Font = $Font
    $MS365AppsBox_SAC.location = New-Object System.Drawing.Point(420,145)
    $form.Controls.Add($MS365AppsBox_SAC)
	$MS365AppsBox_SAC.Checked = $SoftwareSelection.MS365Apps_SAC
	
	# MS365 Apps Monthly Enterprise Channel Checkbox
    $MS365AppsBox_MEC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_MEC.text = "Microsoft 365 Apps (x64/Monthly Enterprise Channel)"
    $MS365AppsBox_MEC.width = 95
    $MS365AppsBox_MEC.height = 20
    $MS365AppsBox_MEC.autosize = $true
	$MS365AppsBox_MEC.Font = $Font
    $MS365AppsBox_MEC.location = New-Object System.Drawing.Point(420,170)
    $form.Controls.Add($MS365AppsBox_MEC)
	$MS365AppsBox_MEC.Checked = $SoftwareSelection.MS365Apps_MEC
	
	# MS Office2019 Checkbox
    $MSOffice2019Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2019Box.text = "Microsoft Office 2019 (x64/Perpetual VL)"
    $MSOffice2019Box.width = 95
    $MSOffice2019Box.height = 20
    $MSOffice2019Box.autosize = $true
	$MSOffice2019Box.Font = $Font
    $MSOffice2019Box.location = New-Object System.Drawing.Point(420,195)
    $form.Controls.Add($MSOffice2019Box)
	$MSOffice2019Box.Checked = $SoftwareSelection.MSOffice2019
	
	# MS Office2021 Checkbox
    $MSOffice2021Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2021Box.text = "Microsoft Office 2021 (x64/Perpetual VL)"
    $MSOffice2021Box.width = 95
    $MSOffice2021Box.height = 20
    $MSOffice2021Box.autosize = $true
	$MSOffice2021Box.Font = $Font
    $MSOffice2021Box.location = New-Object System.Drawing.Point(420,220)
    $form.Controls.Add($MSOffice2021Box)
	$MSOffice2021Box.Checked = $SoftwareSelection.MSOffice2021
	
	# MS Office2024 Checkbox
    $MSOffice2024Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2024Box.text = "Microsoft Office 2024 (x64/Perpetual VL)"
    $MSOffice2024Box.width = 95
    $MSOffice2024Box.height = 20
    $MSOffice2024Box.autosize = $true
	$MSOffice2024Box.Font = $Font
    $MSOffice2024Box.location = New-Object System.Drawing.Point(420,245)
    $form.Controls.Add($MSOffice2024Box)
	$MSOffice2024Box.Checked = $SoftwareSelection.MSOffice2024
	
	# MS VcRedist Checkbox
    $VcRedistBox = New-Object system.Windows.Forms.CheckBox
    $VcRedistBox.text = "Microsoft Visual C++ Redistributable"
    $VcRedistBox.width = 95
    $VcRedistBox.height = 20
    $VcRedistBox.autosize = $true
	$VcRedistBox.Font = $Font
    $VcRedistBox.location = New-Object System.Drawing.Point(420,270)
    $form.Controls.Add($VcRedistBox)
	$VcRedistBox.Checked = $SoftwareSelection.VcRedist

    # MS SQL Management Studio EN Checkbox
    $MSSQLManagementStudioENBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioENBox.text = "Microsoft SQL Management Studio EN"
    $MSSQLManagementStudioENBox.width = 95
    $MSSQLManagementStudioENBox.height = 20
    $MSSQLManagementStudioENBox.autosize = $true
	$MSSQLManagementStudioENBox.Font = $Font
    $MSSQLManagementStudioENBox.location = New-Object System.Drawing.Point(420,295)
    $form.Controls.Add($MSSQLManagementStudioENBox)
	$MSSQLManagementStudioENBox.Checked = $SoftwareSelection.MSSsmsEN

    # MS SQL Management Studio DE Checkbox
    $MSSQLManagementStudioDEBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioDEBox.text = "Microsoft SQL Management Studio DE"
    $MSSQLManagementStudioDEBox.width = 95
    $MSSQLManagementStudioDEBox.height = 20
    $MSSQLManagementStudioDEBox.autosize = $true
	$MSSQLManagementStudioDEBox.Font = $Font
    $MSSQLManagementStudioDEBox.location = New-Object System.Drawing.Point(420,320)
    $form.Controls.Add($MSSQLManagementStudioDEBox)
	$MSSQLManagementStudioDEBox.Checked = $SoftwareSelection.MSSsmsDE
	
	# MicrosoftOpenJDK Checkbox
    $MicrosoftOpenJDKBox = New-Object system.Windows.Forms.CheckBox
    $MicrosoftOpenJDKBox.text = "Microsoft OpenJDK 21"
    $MicrosoftOpenJDKBox.width = 95
    $MicrosoftOpenJDKBox.height = 20
    $MicrosoftOpenJDKBox.autosize = $true
	$MicrosoftOpenJDKBox.Font = $Font
    $MicrosoftOpenJDKBox.location = New-Object System.Drawing.Point(420,345)
    $form.Controls.Add($MicrosoftOpenJDKBox)
	$MicrosoftOpenJDKBox.Checked =  $SoftwareSelection.MicrosoftOpenJDK
	
	# MSVisualStudioCode  Checkbox
    $MSVisualStudioCodeBox = New-Object system.Windows.Forms.CheckBox
    $MSVisualStudioCodeBox.text = "Microsoft Visual Studio Code"
    $MSVisualStudioCodeBox.width = 95
    $MSVisualStudioCodeBox.height = 20
    $MSVisualStudioCodeBox.autosize = $true
	$MSVisualStudioCodeBox.Font = $Font
    $MSVisualStudioCodeBox.location = New-Object System.Drawing.Point(420,370)
    $form.Controls.Add($MSVisualStudioCodeBox)
	$MSVisualStudioCodeBox.Checked =  $SoftwareSelection.MSVisualStudioCode 
	
	# BISF Checkbox
    $BISFBox = New-Object system.Windows.Forms.CheckBox
    $BISFBox.text = "BIS-F"
    $BISFBox.width = 95
    $BISFBox.height = 20
    $BISFBox.autosize = $true
	$BISFBox.Font = $Font
    $BISFBox.location = New-Object System.Drawing.Point(420,395)
    $form.Controls.Add($BISFBox)
	$BISFBox.Checked =  $SoftwareSelection.BISF
	
	# FSLogix Checkbox
    $FSLogixBox = New-Object system.Windows.Forms.CheckBox
    $FSLogixBox.text = "FSLogix"
    $FSLogixBox.width = 95
    $FSLogixBox.height = 20
    $FSLogixBox.autosize = $true
	$FSLogixBox.Font = $Font
    $FSLogixBox.location = New-Object System.Drawing.Point(420,420)
    $form.Controls.Add($FSLogixBox)
	$FSLogixBox.Checked =  $SoftwareSelection.FSLogix
	
	# GoogleChrome Checkbox
    $GoogleChromeBox = New-Object system.Windows.Forms.CheckBox
    $GoogleChromeBox.text = "Google Chrome"
    $GoogleChromeBox.width = 95
    $GoogleChromeBox.height = 20
    $GoogleChromeBox.autosize = $true
	$GoogleChromeBox.Font = $Font
    $GoogleChromeBox.location = New-Object System.Drawing.Point(420,445)
    $form.Controls.Add($GoogleChromeBox)
	$GoogleChromeBox.Checked =  $SoftwareSelection.GoogleChrome
<#	
	# Zoom VMWare client Checkbox
    $ZoomVMWareBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVMWareBox.text = "Zoom VMWare Client"
    $ZoomVMWareBox.width = 95
    $ZoomVMWareBox.height = 20
    $ZoomVMWareBox.autosize = $true
	$ZoomVMWareBox.Font = $Font
    $ZoomVMWareBox.location = New-Object System.Drawing.Point(420,195)
    $form.Controls.Add($ZoomVMWareBox)
	$ZoomVMWareBox.Checked =  $SoftwareSelection.ZoomVMWare
#>
    # WinSCP Checkbox
    $WinSCPBox = New-Object system.Windows.Forms.CheckBox
    $WinSCPBox.text = "WinSCP"
    $WinSCPBox.width = 95
    $WinSCPBox.height = 20
    $WinSCPBox.autosize = $true
	$WinSCPBox.Font = $Font
    $WinSCPBox.location = New-Object System.Drawing.Point(420,470)
    $form.Controls.Add($WinSCPBox)
    $WinSCPBox.Checked =  $SoftwareSelection.WinSCP
	
	# Putty Checkbox
    $PuttyBox = New-Object system.Windows.Forms.CheckBox
    $PuttyBox.text = "Putty"
    $PuttyBox.width = 95
    $PuttyBox.height = 20
    $PuttyBox.autosize = $true
	$PuttyBox.Font = $Font
    $PuttyBox.location = New-Object System.Drawing.Point(420,495)
	$form.Controls.Add($PuttyBox)
    $PuttyBox.Checked =  $SoftwareSelection.Putty
	
	<#
	# CiscoWebExDesktop Checkbox
    $CiscoWebExDesktopBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExDesktopBox.text = "Cisco WebEx"
    $CiscoWebExDesktopBox.width = 95
    $CiscoWebExDesktopBox.height = 20
    $CiscoWebExDesktopBox.autosize = $true
	$CiscoWebExDesktopBox.Font = $Font
    $CiscoWebExDesktopBox.location = New-Object System.Drawing.Point(420,320)
    $form.Controls.Add($CiscoWebExDesktopBox)
	$CiscoWebExDesktopBox.Checked =  $SoftwareSelection.CiscoWebExDesktop
	#>
	
	# OracleJava8 Checkbox
    $OracleJava8Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8Box.text = "Oracle Java 8/x64"
    $OracleJava8Box.width = 95
    $OracleJava8Box.height = 20
    $OracleJava8Box.autosize = $true
	$OracleJava8Box.Font = $Font
    $OracleJava8Box.location = New-Object System.Drawing.Point(420,520)
    $form.Controls.Add($OracleJava8Box)
	$OracleJava8Box.Checked =  $SoftwareSelection.OracleJava8
	
	# OracleJava8-32Bit Checkbox
    $OracleJava8_32Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8_32Box.text = "Oracle Java 8/x86"
    $OracleJava8_32Box.width = 95
    $OracleJava8_32Box.height = 20
    $OracleJava8_32Box.autosize = $true
	$OracleJava8_32Box.Font = $Font
    $OracleJava8_32Box.location = New-Object System.Drawing.Point(420,545)
    $form.Controls.Add($OracleJava8_32Box)
	$OracleJava8_32Box.Checked =  $SoftwareSelection.OracleJava8_32
	
	# RemoteDesktopManager Checkbox
    $RemoteDesktopManagerBox = New-Object system.Windows.Forms.CheckBox
    $RemoteDesktopManagerBox.text = "Remote Desktop Manager Free"
    $RemoteDesktopManagerBox.width = 95
    $RemoteDesktopManagerBox.height = 20
    $RemoteDesktopManagerBox.autosize = $true
	$RemoteDesktopManagerBox.Font = $Font
    $RemoteDesktopManagerBox.location = New-Object System.Drawing.Point(420,570)
    $form.Controls.Add($RemoteDesktopManagerBox)
	$RemoteDesktopManagerBox.Checked =  $SoftwareSelection.RemoteDesktopManager
	
	# pdf24Creator Checkbox
    $pdf24CreatorBox = New-Object system.Windows.Forms.CheckBox
    $pdf24CreatorBox.text = "PDF24 Creator"
    $pdf24CreatorBox.width = 95
    $pdf24CreatorBox.height = 20
    $pdf24CreatorBox.autosize = $true
	$pdf24CreatorBox.Font = $Font
    $pdf24CreatorBox.location = New-Object System.Drawing.Point(420,595)
    $form.Controls.Add($pdf24CreatorBox)
	$pdf24CreatorBox.Checked =  $SoftwareSelection.pdf24Creator

	# Firefox Checkbox
    $FirefoxBox = New-Object system.Windows.Forms.CheckBox
    $FirefoxBox.text = "Mozilla Firefox"
    $FirefoxBox.width = 95
    $FirefoxBox.height = 20
    $FirefoxBox.autosize = $true
	$FirefoxBox.Font = $Font
    $FirefoxBox.location = New-Object System.Drawing.Point(810,45)
    $form.Controls.Add($FirefoxBox)
	$FirefoxBox.Checked =  $SoftwareSelection.Firefox

	# VLCPlayer Checkbox
    $VLCPlayerBox = New-Object system.Windows.Forms.CheckBox
    $VLCPlayerBox.text = "VLC Player"
    $VLCPlayerBox.width = 95
    $VLCPlayerBox.height = 20
    $VLCPlayerBox.autosize = $true
	$VLCPlayerBox.Font = $Font
    $VLCPlayerBox.location = New-Object System.Drawing.Point(810,70)
    $form.Controls.Add($VLCPlayerBox)
	$VLCPlayerBox.Checked =  $SoftwareSelection.VLCPlayer
	
	# KeePass Checkbox
    $KeePassBox = New-Object system.Windows.Forms.CheckBox
    $KeePassBox.text = "KeePass"
    $KeePassBox.width = 95
    $KeePassBox.height = 20
    $KeePassBox.autosize = $true
	$KeePassBox.Font = $Font
    $KeePassBox.location = New-Object System.Drawing.Point(810,95)
    $form.Controls.Add($KeePassBox)
	$KeePassBox.Checked =  $SoftwareSelection.KeePass
	
	# KeePassXC Checkbox
    $KeePassXCBox = New-Object system.Windows.Forms.CheckBox
    $KeePassXCBox.text = "KeePassXC"
    $KeePassXCBox.width = 95
    $KeePassXCBox.height = 20
    $KeePassXCBox.autosize = $true
	$KeePassXCBox.Font = $Font
    $KeePassXCBox.location = New-Object System.Drawing.Point(810,120)
    $form.Controls.Add($KeePassXCBox)
	$KeePassXCBox.Checked =  $SoftwareSelection.KeePassXC

    # TreeSizeFree Checkbox
    $TreeSizeFreeBox = New-Object system.Windows.Forms.CheckBox
    $TreeSizeFreeBox.text = "TreeSize Free"
    $TreeSizeFreeBox.width = 95
    $TreeSizeFreeBox.height = 20
    $TreeSizeFreeBox.autosize = $true
	$TreeSizeFreeBox.Font = $Font
    $TreeSizeFreeBox.location = New-Object System.Drawing.Point(810,145)
    $form.Controls.Add($TreeSizeFreeBox)
	$TreeSizeFreeBox.Checked =  $SoftwareSelection.TreeSizeFree
	
	# ShareX Checkbox
    $ShareXBox = New-Object system.Windows.Forms.CheckBox
    $ShareXBox.text = "ShareX"
    $ShareXBox.width = 95
    $ShareXBox.height = 20
    $ShareXBox.autosize = $true
	$ShareXBox.Font = $Font
    $ShareXBox.location = New-Object System.Drawing.Point(810,170)
    $form.Controls.Add($ShareXBox)
	$ShareXBox.Checked =  $SoftwareSelection.ShareX
	
	# Greenshot Checkbox
    $GreenshotBox = New-Object system.Windows.Forms.CheckBox
    $GreenshotBox.text = "Greenshot"
    $GreenshotBox.width = 95
    $GreenshotBox.height = 20
    $GreenshotBox.autosize = $true
	$GreenshotBox.Font = $Font
    $GreenshotBox.location = New-Object System.Drawing.Point(810,195)
    $form.Controls.Add($GreenshotBox)
	$GreenshotBox.Checked =  $SoftwareSelection.Greenshot
	
	# ImageGlass Checkbox
    $ImageGlassBox = New-Object system.Windows.Forms.CheckBox
    $ImageGlassBox.text = "ImageGlass"
    $ImageGlassBox.width = 95
    $ImageGlassBox.height = 20
    $ImageGlassBox.autosize = $true
	$ImageGlassBox.Font = $Font
    $ImageGlassBox.location = New-Object System.Drawing.Point(810,220)
    $form.Controls.Add($ImageGlassBox)
	$ImageGlassBox.Checked =  $SoftwareSelection.ImageGlass
	
	# FileZilla Checkbox
    $FileZillaBox = New-Object system.Windows.Forms.CheckBox
    $FileZillaBox.text = "FileZilla Client"
    $FileZillaBox.width = 95
    $FileZillaBox.height = 20
    $FileZillaBox.autosize = $true
	$FileZillaBox.Font = $Font
    $FileZillaBox.location = New-Object System.Drawing.Point(810,245)
    $form.Controls.Add($FileZillaBox)
	$FileZillaBox.Checked =  $SoftwareSelection.FileZilla

	# WinRAR Checkbox
    $WinRARBox = New-Object system.Windows.Forms.CheckBox
    $WinRARBox.text = "WinRAR"
    $WinRARBox.width = 95
    $WinRARBox.height = 20
    $WinRARBox.autosize = $true
	$WinRARBox.Font = $Font
    $WinRARBox.location = New-Object System.Drawing.Point(810,270)
    $form.Controls.Add($WinRARBox)
	$WinRARBox.Checked =  $SoftwareSelection.WinRAR
	
	# FoxitReader Checkbox
    $FoxitReaderBox = New-Object system.Windows.Forms.CheckBox
    $FoxitReaderBox.text = "Foxit Reader"
    $FoxitReaderBox.width = 95
    $FoxitReaderBox.height = 20
    $FoxitReaderBox.autosize = $true
	$FoxitReaderBox.Font = $Font
    $FoxitReaderBox.location = New-Object System.Drawing.Point(810,295)
    $form.Controls.Add($FoxitReaderBox)
	$FoxitReaderBox.Checked =  $SoftwareSelection.FoxitReader


	<#
	# Zoom Host Checkbox
    $ZoomVDIBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVDIBox.text = "Zoom VDI Host Installer (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",10.5, [System.Drawing.FontStyle]::Strikeout)
    $ZoomVDIBox.Font = $CustomFont
    $ZoomVDIBox.width = 95
    $ZoomVDIBox.height = 20
    $ZoomVDIBox.autosize = $true
    $ZoomVDIBox.location = New-Object System.Drawing.Point(420,570)
    $form.Controls.Add($ZoomVDIBox)
	$ZoomVDIBox.Checked =  $SoftwareSelection.ZoomVDI
	
	# Zoom Citrix client Checkbox
    $ZoomCitrixBox = New-Object system.Windows.Forms.CheckBox
    $ZoomCitrixBox.text = "Zoom Citrix Client (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",10.5, [System.Drawing.FontStyle]::Strikeout)
    $ZoomCitrixBox.Font = $CustomFont
    $ZoomCitrixBox.width = 95
    $ZoomCitrixBox.height = 20
    $ZoomCitrixBox.autosize = $true
    $ZoomCitrixBox.location = New-Object System.Drawing.Point(420,595)
    $form.Controls.Add($ZoomCitrixBox)
	$ZoomCitrixBox.Checked =  $SoftwareSelection.ZoomCitrix
	#>
	
	# Responsive category layout
	$SoftwareCheckBoxes = @(
		[PSCustomObject]@{ Control = $NotePadPlusPlusBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $SevenZipBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $AdobeReaderDCBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $AdobeReaderDCBoxUpdate; Category = "Standard" }
		[PSCustomObject]@{ Control = $AdobeReaderDCx64Box; Category = "Standard" }
		[PSCustomObject]@{ Control = $AdobeReaderDCx64BoxUpdate; Category = "Standard" }
		[PSCustomObject]@{ Control = $GoogleChromeBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $FirefoxBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $VLCPlayerBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $MSEdgeBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOneDriveBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSDotNetRuntimeBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $NEWMSTeamsBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MS365AppsBox_SAC; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MS365AppsBox_MEC; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOffice2019Box; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOffice2021Box; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOffice2024Box; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $VcRedistBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSSQLManagementStudioENBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSSQLManagementStudioDEBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MicrosoftOpenJDKBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSVisualStudioCodeBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $CitrixVMToolsBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WorkspaceApp_CRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WorkspaceApp_LTSRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WorkspaceApp_CR_WebBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WorkspaceApp_LTSR_WebBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $PVSTargetDevice_LTSRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $PVSTargetDevice_CRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ServerVDA_LTSRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ServerVDA_CRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ServerVDA_PVS_LTSRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ServerVDA_PVS_CRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ServerVDA_MCS_LTSRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ServerVDA_MCS_CRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WEM_Agent_Box; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WEM_Agent_PVSBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WEM_Agent_MCSBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $FSLogixBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $VMWareToolsBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $BISFBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $KeePassBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $KeePassXCBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $OracleJava8Box; Category = "Utilities" }
		[PSCustomObject]@{ Control = $OracleJava8_32Box; Category = "Utilities" }
		[PSCustomObject]@{ Control = $TreeSizeFreeBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $ShareXBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $FileZillaBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $ImageGlassBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $GreenshotBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $pdf24CreatorBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $FoxitReaderBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $RemoteDesktopManagerBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $PuttyBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $WinSCPBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $WinRARBox; Category = "Utilities" }
	)

	$HeaderPanel = New-Object System.Windows.Forms.Panel
	$HeaderPanel.Location = New-Object System.Drawing.Point(0,0)
	$HeaderPanel.Size = New-Object System.Drawing.Size(1280,78)
	$HeaderPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$HeaderPanel.BackColor = [System.Drawing.Color]::FromArgb(16,64,104)
	$Form.Controls.Add($HeaderPanel)

	$HeaderLogo = New-Object System.Windows.Forms.PictureBox
	$HeaderLogo.Location = New-Object System.Drawing.Point(20,11)
	$HeaderLogo.Size = New-Object System.Drawing.Size(56,56)
	$HeaderLogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
	$HeaderLogo.BackColor = [System.Drawing.Color]::Transparent
	$HeaderLogo.Image = & $NewInstallerHeaderIcon
	$HeaderPanel.Controls.Add($HeaderLogo)

	$ProductTitle = New-Object System.Windows.Forms.Label
	$ProductTitle.Text = "Evergreen Software Installer"
	$ProductTitle.AutoSize = $true
	$ProductTitle.Location = New-Object System.Drawing.Point(82,14)
	$ProductTitle.Font = New-Object System.Drawing.Font("Segoe UI",17,[System.Drawing.FontStyle]::Bold)
	$ProductTitle.ForeColor = [System.Drawing.Color]::White
	$HeaderPanel.Controls.Add($ProductTitle)

	$VersionBadge = New-Object System.Windows.Forms.Label
	$VersionBadge.Text = "VERSION $EvergreenVersion"
	$VersionBadge.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
	$VersionBadge.Location = New-Object System.Drawing.Point(455,19)
	$VersionBadge.Size = New-Object System.Drawing.Size(145,25)
	$VersionBadge.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
	$VersionBadge.ForeColor = [System.Drawing.Color]::White
	$VersionBadge.BackColor = [System.Drawing.Color]::FromArgb(56,160,93)
	$HeaderPanel.Controls.Add($VersionBadge)

	$ProductSubtitle = New-Object System.Windows.Forms.Label
	$ProductSubtitle.Text = "Select software and save the installation profile for this host"
	$ProductSubtitle.AutoSize = $true
	$ProductSubtitle.Location = New-Object System.Drawing.Point(84,48)
	$ProductSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(205,222,236)
	$HeaderPanel.Controls.Add($ProductSubtitle)

	$HeaderProfileCaption = New-Object System.Windows.Forms.Label
	$HeaderProfileCaption.Text = "HOST PROFILE"
	$HeaderProfileCaption.AutoSize = $true
	$HeaderProfileCaption.Location = New-Object System.Drawing.Point(1010,16)
	$HeaderProfileCaption.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
	$HeaderProfileCaption.Font = New-Object System.Drawing.Font("Segoe UI",8,[System.Drawing.FontStyle]::Bold)
	$HeaderProfileCaption.ForeColor = [System.Drawing.Color]::FromArgb(155,195,222)
	$HeaderPanel.Controls.Add($HeaderProfileCaption)

	$HeaderProfileValue = New-Object System.Windows.Forms.Label
	$HeaderProfileValue.Text = "$(Split-Path -Leaf $SoftwareToInstall)"
	$HeaderProfileValue.AutoEllipsis = $true
	$HeaderProfileValue.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
	$HeaderProfileValue.Location = New-Object System.Drawing.Point(945,36)
	$HeaderProfileValue.Size = New-Object System.Drawing.Size(310,26)
	$HeaderProfileValue.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
	$HeaderProfileValue.ForeColor = [System.Drawing.Color]::White
	$HeaderPanel.Controls.Add($HeaderProfileValue)

	$NavigationPanel = New-Object System.Windows.Forms.Panel
	$NavigationPanel.Location = New-Object System.Drawing.Point(0,78)
	$NavigationPanel.Size = New-Object System.Drawing.Size(1280,54)
	$NavigationPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$NavigationPanel.BackColor = [System.Drawing.Color]::White
	$Form.Controls.Add($NavigationPanel)

	$SelectionNavButton = New-Object System.Windows.Forms.Button
	$SelectionNavButton.Text = "Software selection"
	$SelectionNavButton.Location = New-Object System.Drawing.Point(22,6)
	$SelectionNavButton.Size = New-Object System.Drawing.Size(205,42)
	$SelectionNavButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
	$SelectionNavButton.FlatAppearance.BorderSize = 0
	$SelectionNavButton.BackColor = [System.Drawing.Color]::FromArgb(232,241,248)
	$SelectionNavButton.ForeColor = [System.Drawing.Color]::FromArgb(16,91,145)
	$SelectionNavButton.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
	$NavigationPanel.Controls.Add($SelectionNavButton)

	$ProcessNavButton = New-Object System.Windows.Forms.Button
	$ProcessNavButton.Text = "Process && results"
	$ProcessNavButton.Location = New-Object System.Drawing.Point(233,6)
	$ProcessNavButton.Size = New-Object System.Drawing.Size(205,42)
	$ProcessNavButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
	$ProcessNavButton.FlatAppearance.BorderSize = 0
	$ProcessNavButton.BackColor = [System.Drawing.Color]::White
	$ProcessNavButton.ForeColor = [System.Drawing.Color]::FromArgb(90,100,115)
	$ProcessNavButton.Font = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Bold)
	$NavigationPanel.Controls.Add($ProcessNavButton)

	$NavigationStatus = New-Object System.Windows.Forms.Label
	$NavigationStatus.Text = "Profile loaded  |  Host: $ENV:ComputerName"
	$NavigationStatus.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
	$NavigationStatus.Location = New-Object System.Drawing.Point(930,11)
	$NavigationStatus.Size = New-Object System.Drawing.Size(325,32)
	$NavigationStatus.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
	$NavigationStatus.ForeColor = [System.Drawing.Color]::FromArgb(69,128,90)
	$NavigationPanel.Controls.Add($NavigationStatus)

	$SelectionPanel = New-Object System.Windows.Forms.Panel
	$SelectionPanel.Location = New-Object System.Drawing.Point(0,132)
	$SelectionPanel.Size = New-Object System.Drawing.Size(1280,688)
	$SelectionPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$SelectionPanel.BackColor = [System.Drawing.Color]::FromArgb(245,247,250)
	$Form.Controls.Add($SelectionPanel)

	$Headline2.Text = "Choose software to install"
	$Headline2.Location = New-Object System.Drawing.Point(24,15)
	$Headline2.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
	$SelectionPanel.Controls.Add($Headline2)

	$ProfileLabel = New-Object System.Windows.Forms.Label
	$ProfileLabel.AutoSize = $true
	$ProfileLabel.ForeColor = [System.Drawing.Color]::FromArgb(90,100,115)
	$ProfileLabel.Text = "Selections are stored per host in $(Split-Path -Leaf $SoftwareToInstall)."
	$ProfileLabel.Location = New-Object System.Drawing.Point(26,49)
	$SelectionPanel.Controls.Add($ProfileLabel)

	$SearchLabel = New-Object System.Windows.Forms.Label
	$SearchLabel.Text = "Search software"
	$SearchLabel.AutoSize = $true
	$SearchLabel.Location = New-Object System.Drawing.Point(24,81)
	$SelectionPanel.Controls.Add($SearchLabel)

	$SearchBox = New-Object System.Windows.Forms.TextBox
	$SearchBox.Location = New-Object System.Drawing.Point(24,104)
	$SearchBox.Size = New-Object System.Drawing.Size(340,30)
	$SearchBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
	$SelectionPanel.Controls.Add($SearchBox)

	$CategoryFilterState = [PSCustomObject]@{ Selected = "All categories" }
	$CategoryButtons = @()
	$CategoryPanel = New-Object System.Windows.Forms.FlowLayoutPanel
	$CategoryPanel.Location = New-Object System.Drawing.Point(380,74)
	$CategoryPanel.Size = New-Object System.Drawing.Size(740,76)
	$CategoryPanel.WrapContents = $false
	$CategoryPanel.BackColor = [System.Drawing.Color]::Transparent
	foreach ($CategoryName in @("All categories","Standard","Microsoft","Citrix","Utilities")) {
		$CategoryCount = if ($CategoryName -eq "All categories") { $SoftwareCheckBoxes.Count } else { @($SoftwareCheckBoxes | Where-Object { $_.Category -eq $CategoryName }).Count }
		$CategoryDisplayName = if ($CategoryName -eq "All categories") { "ALL" } else { $CategoryName.ToUpperInvariant() }
		$CategoryButton = New-Object System.Windows.Forms.Button
		$CategoryButton.Text = ""
		$CategoryButton.Tag = $CategoryName
		$CategoryButton.AccessibleName = "$CategoryDisplayName category, $CategoryCount products"
		$CategoryButton.Size = New-Object System.Drawing.Size(142,68)
		$CategoryButton.Margin = New-Object System.Windows.Forms.Padding(3)
		$CategoryButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$CategoryButton.FlatAppearance.BorderSize = 1
		$CategoryButton.FlatAppearance.BorderColor = if ($CategoryName -eq "All categories") { [System.Drawing.Color]::FromArgb(22,112,184) } else { [System.Drawing.Color]::FromArgb(205,218,230) }
		$CategoryButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(232,241,248)
		$CategoryButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(216,229,240)
		$CategoryButton.BackColor = if ($CategoryName -eq "All categories") { [System.Drawing.Color]::FromArgb(216,229,240) } else { [System.Drawing.Color]::White }
		$CategoryButton.ForeColor = [System.Drawing.Color]::FromArgb(23,63,102)
		$CategoryButton.Cursor = [System.Windows.Forms.Cursors]::Hand

		$CategoryIconPanel = New-Object System.Windows.Forms.Panel
		$CategoryIconPanel.Name = "CategoryIconPanel"
		$CategoryIconPanel.Location = New-Object System.Drawing.Point(10,15)
		$CategoryIconPanel.Size = New-Object System.Drawing.Size(38,38)
		$CategoryIconPanel.BackColor = [System.Drawing.Color]::FromArgb(232,241,248)
		$CategoryIconPanel.Cursor = [System.Windows.Forms.Cursors]::Hand
		$CategoryIcon = New-Object System.Windows.Forms.PictureBox
		$CategoryIcon.Location = New-Object System.Drawing.Point(5,5)
		$CategoryIcon.Size = New-Object System.Drawing.Size(28,28)
		$CategoryIcon.Image = & $NewEvergreenCategoryIcon -CategoryName $CategoryName
		$CategoryIcon.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::CenterImage
		$CategoryIcon.Cursor = [System.Windows.Forms.Cursors]::Hand
		$CategoryIconPanel.Controls.Add($CategoryIcon)

		$CategoryNameLabel = New-Object System.Windows.Forms.Label
		$CategoryNameLabel.Text = $CategoryDisplayName
		$CategoryNameLabel.Location = New-Object System.Drawing.Point(56,9)
		$CategoryNameLabel.Size = New-Object System.Drawing.Size(80,21)
		$CategoryNameLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$CategoryNameLabel.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
		$CategoryNameLabel.ForeColor = [System.Drawing.Color]::FromArgb(23,63,102)
		$CategoryNameLabel.BackColor = [System.Drawing.Color]::Transparent
		$CategoryNameLabel.Cursor = [System.Windows.Forms.Cursors]::Hand

		$CategoryCountLabel = New-Object System.Windows.Forms.Label
		$CategoryCountLabel.Text = [string]$CategoryCount
		$CategoryCountLabel.Location = New-Object System.Drawing.Point(56,31)
		$CategoryCountLabel.Size = New-Object System.Drawing.Size(80,24)
		$CategoryCountLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$CategoryCountLabel.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Bold)
		$CategoryCountLabel.ForeColor = [System.Drawing.Color]::FromArgb(47,164,91)
		$CategoryCountLabel.BackColor = [System.Drawing.Color]::Transparent
		$CategoryCountLabel.Cursor = [System.Windows.Forms.Cursors]::Hand

		$ForwardCategoryClick = { $CategoryButton.PerformClick() }.GetNewClosure()
		foreach ($ChildControl in @($CategoryIconPanel,$CategoryIcon,$CategoryNameLabel,$CategoryCountLabel)) { $ChildControl.Add_Click($ForwardCategoryClick) }
		$CategoryButton.Controls.Add($CategoryIconPanel)
		$CategoryButton.Controls.Add($CategoryNameLabel)
		$CategoryButton.Controls.Add($CategoryCountLabel)
		$CategoryPanel.Controls.Add($CategoryButton)
		$CategoryButtons += $CategoryButton
	}
	$SelectionPanel.Controls.Add($CategoryPanel)

	# Read the newest changelog entry directly from this script.
	$GuiLastChangesText = "Release note information unavailable"
	try {
		$GuiScriptPath = if (-not [String]::IsNullOrWhiteSpace($PSCommandPath)) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }
		if (-not [String]::IsNullOrWhiteSpace($GuiScriptPath) -and (Test-Path -LiteralPath $GuiScriptPath -PathType Leaf)) {
			$GuiScriptContent = @(Get-Content -LiteralPath $GuiScriptPath -ErrorAction Stop)
			$GuiNotesIndex = [Array]::IndexOf($GuiScriptContent,"# Notes")
			if ($GuiNotesIndex -gt 0) {
				$GuiLastChangesText = ([string]$GuiScriptContent[$GuiNotesIndex - 1]).Trim().TrimStart('#').Trim()
			}
		}
	}
	catch { }

	$LastChangesLabel = New-Object System.Windows.Forms.Label
	$LastChangesLabel.Text = "Last changes: $GuiLastChangesText"
	$LastChangesLabel.Location = New-Object System.Drawing.Point(1135,84)
	$LastChangesLabel.Size = New-Object System.Drawing.Size(120,54)
	$LastChangesLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$LastChangesLabel.Font = New-Object System.Drawing.Font("Segoe UI",9)
	$LastChangesLabel.ForeColor = [System.Drawing.Color]::FromArgb(48,58,70)
	$LastChangesLabel.AutoEllipsis = $true
	$LastChangesLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
	$SelectionPanel.Controls.Add($LastChangesLabel)
	$LastChangesToolTip = New-Object System.Windows.Forms.ToolTip
	$LastChangesToolTip.SetToolTip($LastChangesLabel,$LastChangesLabel.Text)

	$ResizeLastChanges = {
		$LabelLeft = $CategoryPanel.Right + 12
		$AvailableLabelWidth = $SelectionPanel.ClientSize.Width - $LabelLeft - 24
		$LastChangesLabel.Location = New-Object System.Drawing.Point($LabelLeft,84)
		$LastChangesLabel.Width = [Math]::Max(0,$AvailableLabelWidth)
		$LastChangesLabel.Visible = $AvailableLabelWidth -ge 160
	}.GetNewClosure()
	$SelectionPanel.Add_SizeChanged($ResizeLastChanges)
	& $ResizeLastChanges

	$SelectionCountLabel = New-Object System.Windows.Forms.Label
	$SelectionCountLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
	$SelectionCountLabel.ForeColor = [System.Drawing.Color]::FromArgb(16,91,145)
	$SelectionCountLabel.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
	$SelectionCountLabel.Location = New-Object System.Drawing.Point(24,136)
	$SelectionCountLabel.Size = New-Object System.Drawing.Size(340,24)
	$SelectionCountLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
	$SelectionPanel.Controls.Add($SelectionCountLabel)

	$SoftwareFlow = New-Object System.Windows.Forms.FlowLayoutPanel
	$SoftwareFlow.Location = New-Object System.Drawing.Point(20,166)
	$SoftwareFlow.Size = New-Object System.Drawing.Size(1240,454)
	$SoftwareFlow.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$SoftwareFlow.AutoScroll = $true
	$SoftwareFlow.WrapContents = $true
	$SoftwareFlow.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
	$SoftwareFlow.Padding = New-Object System.Windows.Forms.Padding(4)
	$SoftwareFlow.BackColor = [System.Drawing.Color]::FromArgb(235,239,244)
	$SelectionPanel.Controls.Add($SoftwareFlow)

	foreach ($SoftwareItem in $SoftwareCheckBoxes) {
		$CardPanel = New-Object System.Windows.Forms.Panel
		$CardPanel.Size = New-Object System.Drawing.Size(595,72)
		$CardPanel.Margin = New-Object System.Windows.Forms.Padding(5)
		$CardPanel.BackColor = [System.Drawing.Color]::White
		$CardPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

		$SoftwareItem.Control.Font = $CardFont
		$SoftwareItem.Control.ForeColor = [System.Drawing.Color]::FromArgb(30,40,55)
		$SoftwareItem.Control.AutoSize = $false
		$SoftwareItem.Control.Location = New-Object System.Drawing.Point(14,11)
		$SoftwareItem.Control.Size = New-Object System.Drawing.Size(450,48)
		$SoftwareItem.Control.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
		$SoftwareItem.Control.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$SoftwareItem.Control.UseCompatibleTextRendering = $true

		$CategoryBadge = New-Object System.Windows.Forms.Label
		$CategoryBadge.Text = $SoftwareItem.Category.ToUpperInvariant()
		$CategoryBadge.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
		$CategoryBadge.Location = New-Object System.Drawing.Point(470,24)
		$CategoryBadge.Size = New-Object System.Drawing.Size(108,23)
		$CategoryBadge.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
		$CategoryBadge.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
		$CategoryBadge.ForeColor = [System.Drawing.Color]::FromArgb(91,111,127)

		$CardPanel.Controls.Add($SoftwareItem.Control)
		$CardPanel.Controls.Add($CategoryBadge)
		$SoftwareFlow.Controls.Add($CardPanel)
		$SoftwareItem | Add-Member -MemberType NoteProperty -Name Container -Value $CardPanel
	}

	$ResizeCards = {
		$AvailableWidth = $SoftwareFlow.ClientSize.Width - 22
		$ColumnCount = if ($AvailableWidth -ge 1050) { 3 } elseif ($AvailableWidth -ge 700) { 2 } else { 1 }
		$CardWidth = [Math]::Max(340,[int]($AvailableWidth / $ColumnCount) - 10)
		foreach ($SoftwareItem in $SoftwareCheckBoxes) {
			$SoftwareItem.Container.Width = $CardWidth
			$SoftwareItem.Control.Width = [Math]::Max(190,$CardWidth - 145)
		}
	}.GetNewClosure()
	$SoftwareFlow.Add_SizeChanged($ResizeCards)
	& $ResizeCards

	$RefreshSelectionCount = {
		$SelectedCount = @($SoftwareCheckBoxes | Where-Object { $_.Control.Checked }).Count
		$SelectionCountLabel.Text = "$SelectedCount of $($SoftwareCheckBoxes.Count) selected"

		# Highlight selected software cards in light blue.
		foreach ($SoftwareItem in $SoftwareCheckBoxes) {
			if ($SoftwareItem.Control.Checked) {
				$SoftwareItem.Container.BackColor = [System.Drawing.Color]::FromArgb(216,229,240)
			} else {
				$SoftwareItem.Container.BackColor = [System.Drawing.Color]::White
			}
		}
	}.GetNewClosure()
	foreach ($SoftwareItem in $SoftwareCheckBoxes) { $SoftwareItem.Control.Add_CheckedChanged($RefreshSelectionCount) }

	$ApplySoftwareFilter = {
		$SearchText = $SearchBox.Text.Trim()
		$SelectedCategory = [string]$CategoryFilterState.Selected
		foreach ($SoftwareItem in $SoftwareCheckBoxes) {
			$MatchesSearch = [String]::IsNullOrWhiteSpace($SearchText) -or $SoftwareItem.Control.Text.IndexOf($SearchText,[StringComparison]::OrdinalIgnoreCase) -ge 0
			$MatchesCategory = $SelectedCategory -eq "All categories" -or $SoftwareItem.Category -eq $SelectedCategory
			$SoftwareItem.Container.Visible = $MatchesSearch -and $MatchesCategory
		}
	}.GetNewClosure()
	$SearchBox.Add_TextChanged($ApplySoftwareFilter)
	foreach ($CategoryButton in $CategoryButtons) {
		$CategoryButton.Add_Click({
			param($sender,$eventArgs)
			$CategoryFilterState.Selected = [string]$sender.Tag
			foreach ($ButtonItem in $CategoryButtons) {
				$IsActiveCategory = $ButtonItem -eq $sender
				$ButtonItem.BackColor = if ($IsActiveCategory) { [System.Drawing.Color]::FromArgb(216,229,240) } else { [System.Drawing.Color]::White }
				$ButtonItem.FlatAppearance.BorderColor = if ($IsActiveCategory) { [System.Drawing.Color]::FromArgb(22,112,184) } else { [System.Drawing.Color]::FromArgb(205,218,230) }
			}
			& $ApplySoftwareFilter
		}.GetNewClosure())
	}
	& $RefreshSelectionCount

	$ProcessPanel = New-Object System.Windows.Forms.Panel
	$ProcessPanel.Location = New-Object System.Drawing.Point(0,132)
	$ProcessPanel.Size = New-Object System.Drawing.Size(1280,688)
	$ProcessPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$ProcessPanel.BackColor = [System.Drawing.Color]::FromArgb(245,247,250)
	$ProcessPanel.Visible = $false
	$Form.Controls.Add($ProcessPanel)

	$ProcessTitle = New-Object System.Windows.Forms.Label
	$ProcessTitle.Text = "Process & results"
	$ProcessTitle.AutoSize = $true
	$ProcessTitle.Location = New-Object System.Drawing.Point(24,20)
	$ProcessTitle.Font = New-Object System.Drawing.Font("Segoe UI",17,[System.Drawing.FontStyle]::Bold)
	$ProcessPanel.Controls.Add($ProcessTitle)

	$ProcessCard = New-Object System.Windows.Forms.Panel
	$ProcessCard.Location = New-Object System.Drawing.Point(24,72)
	$ProcessCard.Size = New-Object System.Drawing.Size(1230,590)
	$ProcessCard.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$ProcessCard.BackColor = [System.Drawing.Color]::White
	$ProcessCard.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
	$ProcessPanel.Controls.Add($ProcessCard)

	$ProcessState = New-Object System.Windows.Forms.Label
	$ProcessState.Text = "No active installation"
	$ProcessState.AutoSize = $true
	$ProcessState.Location = New-Object System.Drawing.Point(24,26)
	$ProcessState.Font = New-Object System.Drawing.Font("Segoe UI",13,[System.Drawing.FontStyle]::Bold)
	$ProcessCard.Controls.Add($ProcessState)

	$ProcessInfo = New-Object System.Windows.Forms.Label
	$ProcessInfo.Text = "Start the installation from the software selection. PowerShell output and errors will appear here live."
	$ProcessInfo.Location = New-Object System.Drawing.Point(26,66)
	$ProcessInfo.Size = New-Object System.Drawing.Size(1120,28)
	$ProcessInfo.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$ProcessInfo.ForeColor = [System.Drawing.Color]::FromArgb(90,100,115)
	$ProcessCard.Controls.Add($ProcessInfo)

	$ProcessProgress = New-Object System.Windows.Forms.ProgressBar
	$ProcessProgress.Location = New-Object System.Drawing.Point(26,101)
	$ProcessProgress.Size = New-Object System.Drawing.Size(1176,18)
	$ProcessProgress.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
	$ProcessCard.Controls.Add($ProcessProgress)

	$ProcessGrid = New-Object System.Windows.Forms.DataGridView
	$ProcessGrid.Location = New-Object System.Drawing.Point(26,135)
	$ProcessGrid.Size = New-Object System.Drawing.Size(1176,285)
	$ProcessGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$ProcessGrid.ReadOnly = $true
	$ProcessGrid.AllowUserToAddRows = $false
	$ProcessGrid.AllowUserToDeleteRows = $false
	$ProcessGrid.AllowUserToResizeRows = $false
	$ProcessGrid.MultiSelect = $false
	$ProcessGrid.RowHeadersVisible = $false
	$ProcessGrid.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
	$ProcessGrid.AutoGenerateColumns = $false
	$ProcessGrid.BackgroundColor = [System.Drawing.Color]::White
	$ProcessGrid.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
	$ProcessGrid.CellBorderStyle = [System.Windows.Forms.DataGridViewCellBorderStyle]::SingleHorizontal
	$ProcessGrid.GridColor = [System.Drawing.Color]::FromArgb(225,231,237)
	$ProcessGrid.EnableHeadersVisualStyles = $false
	$ProcessGrid.ColumnHeadersHeight = 36
	$ProcessGrid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(232,241,248)
	$ProcessGrid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(16,64,104)
	$ProcessGrid.ColumnHeadersDefaultCellStyle.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
	$ProcessGrid.DefaultCellStyle.BackColor = [System.Drawing.Color]::White
	$ProcessGrid.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(42,52,64)
	$ProcessGrid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(218,233,244)
	$ProcessGrid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::FromArgb(30,40,55)
	$ProcessGrid.DefaultCellStyle.Font = New-Object System.Drawing.Font("Segoe UI",9)
	$ProcessGrid.RowTemplate.Height = 30

	$TimeColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$TimeColumn.Name = "Time"
	$TimeColumn.HeaderText = "Time"
	$TimeColumn.Width = 82
	$TimeColumn.SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::NotSortable
	[void]$ProcessGrid.Columns.Add($TimeColumn)
	$StatusColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$StatusColumn.Name = "Status"
	$StatusColumn.HeaderText = "Status"
	$StatusColumn.Width = 105
	$StatusColumn.SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::NotSortable
	[void]$ProcessGrid.Columns.Add($StatusColumn)
	$MessageColumn = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
	$MessageColumn.Name = "Message"
	$MessageColumn.HeaderText = "Message"
	$MessageColumn.AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
	$MessageColumn.SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::NotSortable
	[void]$ProcessGrid.Columns.Add($MessageColumn)
	$StatusCellFont = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
	$ProcessCard.Controls.Add($ProcessGrid)

	$InstallSummaryLabel = New-Object System.Windows.Forms.Label
	$InstallSummaryLabel.Text = "Documentation summary"
	$InstallSummaryLabel.AutoSize = $true
	$InstallSummaryLabel.Location = New-Object System.Drawing.Point(26,432)
	$InstallSummaryLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
	$InstallSummaryLabel.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
	$InstallSummaryLabel.ForeColor = [System.Drawing.Color]::FromArgb(16,64,104)
	$ProcessCard.Controls.Add($InstallSummaryLabel)

	$InstallSummaryBox = New-Object System.Windows.Forms.TextBox
	$InstallSummaryBox.Location = New-Object System.Drawing.Point(26,455)
	$InstallSummaryBox.Size = New-Object System.Drawing.Size(1176,70)
	$InstallSummaryBox.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$InstallSummaryBox.Multiline = $true
	$InstallSummaryBox.ReadOnly = $true
	$InstallSummaryBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
	$InstallSummaryBox.BackColor = [System.Drawing.Color]::FromArgb(247,250,252)
	$InstallSummaryBox.ForeColor = [System.Drawing.Color]::FromArgb(30,40,55)
	$InstallSummaryBox.Font = New-Object System.Drawing.Font("Segoe UI",10)
	$InstallSummaryBox.Text = "The installation summary will appear here after the process has completed."
	$ProcessCard.Controls.Add($InstallSummaryBox)

	$BackToSelectionButton = New-Object System.Windows.Forms.Button
	$BackToSelectionButton.Text = "Back to software selection"
	$BackToSelectionButton.Location = New-Object System.Drawing.Point(26,536)
	$BackToSelectionButton.Size = New-Object System.Drawing.Size(220,40)
	$BackToSelectionButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
	& $StyleEvergreenButton $BackToSelectionButton
	$ProcessCard.Controls.Add($BackToSelectionButton)

	$CopySummaryButton = New-Object System.Windows.Forms.Button
	$CopySummaryButton.Text = "Copy summary"
	$CopySummaryButton.Location = New-Object System.Drawing.Point(256,536)
	$CopySummaryButton.Size = New-Object System.Drawing.Size(150,40)
	$CopySummaryButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
	$CopySummaryButton.Enabled = $false
	& $StyleEvergreenButton $CopySummaryButton
	$ProcessCard.Controls.Add($CopySummaryButton)

	$CloseResultsButton = New-Object System.Windows.Forms.Button
	$CloseResultsButton.Text = "Exit"
	$CloseResultsButton.Location = New-Object System.Drawing.Point(1082,536)
	$CloseResultsButton.Size = New-Object System.Drawing.Size(120,40)
	$CloseResultsButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
	$CloseResultsButton.Enabled = $false
	& $StyleEvergreenButton $CloseResultsButton
	$ProcessCard.Controls.Add($CloseResultsButton)

	$ProcessContext = [PSCustomObject]@{
		Job = $null
		Running = $false
		Completed = $false
		ExitCode = 1
		CancelButton = $null
		ErrorCount = 0
		WarningCount = 0
		TransferActive = $false
		InstalledSoftwareBefore = @()
		InstallOperations = New-Object System.Collections.ArrayList
		ForcedUpdateProducts = New-Object System.Collections.ArrayList
		CurrentInstallProduct = $null
	}

	$InstallDetectionPatterns = @{
		"NotepadPlusPlus" = @("*Notepad++*")
		"Adobe Reader DC MUI" = @("*Adobe Acrobat*","*Adobe Reader*")
		"Adobe Reader DC x64 MUI" = @("*Adobe Acrobat*","*Adobe Reader*")
		"FSLogix" = @("*FSLogix*")
		"Microsoft Visual C++ Redistributable packages x64" = @("*Microsoft Visual C++*x64*")
		"Microsoft Visual C++ Redistributable packages x86" = @("*Microsoft Visual C++*x86*")
		"MS 365 Apps-Semi Annual Channel" = @("*Microsoft 365 Apps*")
		"MS 365 Apps-Monthly Enterprise Channel" = @("*Microsoft 365 Apps*")
		"MS DotNet Runtime" = @("*Microsoft .NET Runtime*")
		"MS Edge" = @("*Microsoft Edge*")
		"MS OneDrive" = @("*Microsoft OneDrive*")
		"MS Teams 2" = @("*Microsoft Teams*","*MSTeams*")
		"Microsoft OpenJDK 21" = @("*OpenJDK*")
		"MS Powershell" = @("*PowerShell*")
		"MS Visual Studio Code" = @("*Visual Studio Code*")
		"Oracle Java 8 x64" = @("*Java 8*64*","*Java(TM) SE Development Kit 8*")
		"Oracle Java 8 x86" = @("*Java 8*","*Java(TM) SE Development Kit 8*")
		"RemoteDesktopManager" = @("*Remote Desktop Manager*")
		"WorkspaceApp Current Release" = @("*Citrix Workspace*")
		"WorkspaceApp LTSR" = @("*Citrix Workspace*")
		"Citrix VDA Standalone CR" = @("*Citrix Virtual Apps and Desktops*","*Citrix Virtual Delivery Agent*")
		"Citrix VDA Standalone LTSR" = @("*Citrix Virtual Apps and Desktops*","*Citrix Virtual Delivery Agent*")
		"Citrix VDA for MCS CR-Cloud" = @("*Citrix Virtual Apps and Desktops*","*Citrix Virtual Delivery Agent*")
		"Citrix VDA for MCS LTSR" = @("*Citrix Virtual Apps and Desktops*","*Citrix Virtual Delivery Agent*")
		"Citrix VDA for PVS CR-Cloud" = @("*Citrix Virtual Apps and Desktops*","*Citrix Virtual Delivery Agent*")
		"Citrix VDA for PVS LTSR" = @("*Citrix Virtual Apps and Desktops*","*Citrix Virtual Delivery Agent*")
	}
	$InstallSummaryDisplayNames = @{
		"NotepadPlusPlus" = "Notepad++"
		"FoxitReader" = "Foxit PDF Reader"
		"Putty" = "PuTTY"
		"RemoteDesktopManager" = "Remote Desktop Manager"
		"WorkspaceApp Current Release" = "Citrix WorkspaceApp CR"
		"WorkspaceApp LTSR" = "Citrix WorkspaceApp LTSR"
	}

	$GetInstalledSoftwareSnapshot = {
		$InstalledSoftware = New-Object System.Collections.ArrayList
		$RegistryPaths = @(
			"HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
			"HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
		)
		foreach ($RegistryPath in $RegistryPaths) {
			foreach ($RegistryEntry in @(Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue | Where-Object { -not [String]::IsNullOrWhiteSpace($_.DisplayName) })) {
				[void]$InstalledSoftware.Add([PSCustomObject]@{ DisplayName = [string]$RegistryEntry.DisplayName; DisplayVersion = [string]$RegistryEntry.DisplayVersion })
			}
		}
		return @($InstalledSoftware)
	}.GetNewClosure()

	$TestProductInstalled = {
		param([string]$Product,[array]$InstalledSoftware)
		$Patterns = @($InstallDetectionPatterns[$Product])
		if ($Patterns.Count -eq 0) { $Patterns = @("*$Product*") }
		foreach ($InstalledEntry in $InstalledSoftware) {
			foreach ($Pattern in $Patterns) {
				if ($InstalledEntry.DisplayName -like $Pattern) { return $true }
			}
		}
		return $false
	}.GetNewClosure()

	$NormalizeInstallProduct = {
		param([string]$Product)
		$Product = $Product.Trim()
		$Product = $Product -replace ',.*$',''
		$Product = $Product -replace '\s+\(Prerequisite.*$',''
		if ($Product -match '^Adobe Reader DC x64 Update$') { return 'Adobe Reader DC x64 MUI' }
		if ($Product -match '^Adobe Reader DC Update$') { return 'Adobe Reader DC MUI' }
		if ($Product -match '^FSLogix (Apps|Rule Editor)$') { return 'FSLogix' }
		if ($Product -match '^(MS DotNet Desktop Runtime)\s+[\d\.]+') { return $Matches[1] }
		if ($Product -match '^(Citrix WEM Agent(?: for MCS| for PVS)?)\s+[\d\.]+.*$') { return $Matches[1] }
		$Product = $Product -replace '\s+(Update|Meeting Add-In|8\.x)$',''
		return $Product
	}.GetNewClosure()

	$RegisterInstallOperation = {
		param([string]$Product)
		if ([String]::IsNullOrWhiteSpace($Product)) { return }
		$ExistingOperation = $ProcessContext.InstallOperations | Where-Object { $_.Product -eq $Product } | Select-Object -First 1
		if ($null -eq $ExistingOperation) {
			$WasInstalled = (& $TestProductInstalled $Product $ProcessContext.InstalledSoftwareBefore) -or ($ProcessContext.ForcedUpdateProducts -contains $Product)
			$ExistingOperation = [PSCustomObject]@{ Product = $Product; Action = $(if ($WasInstalled) { "Update" } else { "Installation" }); Failed = $false }
			[void]$ProcessContext.InstallOperations.Add($ExistingOperation)
		}
		elseif ($ProcessContext.ForcedUpdateProducts -contains $Product) {
			$ExistingOperation.Action = "Update"
		}
		$ExistingOperation.Failed = $false
		$ProcessContext.CurrentInstallProduct = $Product
	}.GetNewClosure()

	$BuildInstallSummary = {
		$SummaryLines = New-Object System.Collections.ArrayList
		$InstalledSoftwareAfter = & $GetInstalledSoftwareSnapshot
		foreach ($ActionName in @("Update","Installation")) {
			$SummaryEntries = New-Object System.Collections.ArrayList
			foreach ($Operation in @($ProcessContext.InstallOperations | Where-Object { $_.Action -eq $ActionName -and -not $_.Failed })) {
				$DisplayName = if ($InstallSummaryDisplayNames.ContainsKey($Operation.Product)) { $InstallSummaryDisplayNames[$Operation.Product] } else { $Operation.Product }
				$Version = ""
				$VersionPath = Join-Path (Join-Path $SoftwareFolder $Operation.Product) "Version.txt"
				if (Test-Path -LiteralPath $VersionPath) { $Version = [string](Get-Content -LiteralPath $VersionPath -ErrorAction SilentlyContinue | Select-Object -First 1) }
				if ([String]::IsNullOrWhiteSpace($Version)) {
					$Patterns = @($InstallDetectionPatterns[$Operation.Product])
					if ($Patterns.Count -eq 0) { $Patterns = @("*$($Operation.Product)*") }
					$MatchedEntry = $InstalledSoftwareAfter | Where-Object { $Entry = $_; @($Patterns | Where-Object { $Entry.DisplayName -like $_ }).Count -gt 0 } | Select-Object -First 1
					if ($null -ne $MatchedEntry) { $Version = $MatchedEntry.DisplayVersion }
				}
				$SummaryText = if ([String]::IsNullOrWhiteSpace($Version)) { $DisplayName } else { "$DisplayName $Version" }
				[void]$SummaryEntries.Add($SummaryText)
			}
			if ($SummaryEntries.Count -gt 0) { [void]$SummaryLines.Add("${ActionName}: $($SummaryEntries -join ', ')") }
		}
		if ($SummaryLines.Count -eq 0) { [void]$SummaryLines.Add("No software was installed or updated.") }
		$InstallSummaryBox.Lines = @($SummaryLines)
		$CopySummaryButton.Enabled = $SummaryLines.Count -gt 0
		return @($ProcessContext.InstallOperations | Where-Object { -not $_.Failed }).Count
	}.GetNewClosure()

	$AppendProcessLine = {
		param([string]$Text,[bool]$IsError)
		if ([String]::IsNullOrWhiteSpace($Text)) { return }
		$Text = [regex]::Replace($Text,'\x1B\[[0-9;]*[A-Za-z]','').Trim()
		if ($Text -match '^[-=]{5,}$') { return }
		$TransferMatch = [regex]::Match($Text,'(?i)(?<current>\d*[\.,]?\d+\s*(?:KB|MB|GB))\s*/\s*(?<total>\d*[\.,]?\d+\s*(?:KB|MB|GB)).*?(?<percent>\d+(?:[\.,]\d+)?)\s*%\s*complete')
		if ($TransferMatch.Success) {
			$CurrentAmount = $TransferMatch.Groups['current'].Value.Trim()
			$TotalAmount = $TransferMatch.Groups['total'].Value.Trim()
			if ($CurrentAmount.StartsWith('.')) { $CurrentAmount = "0$CurrentAmount" }
			$PercentText = $TransferMatch.Groups['percent'].Value.Replace(',','.')
			try { $PercentValue = [Convert]::ToDouble($PercentText,[Globalization.CultureInfo]::InvariantCulture) } catch { $PercentValue = 0 }
			$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
			$ProcessProgress.Value = [Math]::Max(0,[Math]::Min(100,[int][Math]::Round($PercentValue)))
			$DownloadProductName = [string]$ProcessContext.CurrentInstallProduct
			if (-not [String]::IsNullOrWhiteSpace($DownloadProductName) -and $InstallSummaryDisplayNames.ContainsKey($DownloadProductName)) {
				$DownloadProductName = [string]$InstallSummaryDisplayNames[$DownloadProductName]
			}
			$DownloadLabel = if ([String]::IsNullOrWhiteSpace($DownloadProductName)) { "Downloading" } else { "Downloading $DownloadProductName" }
			$ProcessInfo.Text = "${DownloadLabel}: $CurrentAmount of $TotalAmount ($PercentText %)"
			$ProcessContext.TransferActive = $true
			return
		}
		if ($ProcessContext.TransferActive -and $Text -match '(?i)stop logging|error downloading|download (completed|finished)') {
			$ProcessContext.TransferActive = $false
			$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
			$ProcessInfo.Text = "Download finished. Continuing with the installation process..."
		}
		$UninstallMatch = [regex]::Match($Text,'(?i)^Uninstalling\s+(.+)$')
		if ($UninstallMatch.Success) {
			$UninstallProduct = & $NormalizeInstallProduct $UninstallMatch.Groups[1].Value
			if (-not ($ProcessContext.ForcedUpdateProducts -contains $UninstallProduct)) { [void]$ProcessContext.ForcedUpdateProducts.Add($UninstallProduct) }
			$ExistingOperation = $ProcessContext.InstallOperations | Where-Object { $_.Product -eq $UninstallProduct } | Select-Object -First 1
			if ($null -ne $ExistingOperation) { $ExistingOperation.Action = "Update" }
		}
		$InstallingMatch = [regex]::Match($Text,'(?i)^Installing\s+(.+)$')
		if ($InstallingMatch.Success -and $Text -notmatch '(?i)^Installing/updating') {
			$InstallProduct = & $NormalizeInstallProduct $InstallingMatch.Groups[1].Value
			& $RegisterInstallOperation $InstallProduct
		}
		if ($Text -match '(?i)error (installing|launching script)' -and -not [String]::IsNullOrWhiteSpace($ProcessContext.CurrentInstallProduct)) {
			$FailedOperation = $ProcessContext.InstallOperations | Where-Object { $_.Product -eq $ProcessContext.CurrentInstallProduct } | Select-Object -First 1
			if ($null -ne $FailedOperation) { $FailedOperation.Failed = $true }
			$ProcessContext.CurrentInstallProduct = $null
		}
		if ($Text -match '(?i)^\.{3}\s*ready!?$') { $ProcessContext.CurrentInstallProduct = $null }
		$LineStatus = "Info"
		$StatusColor = [System.Drawing.Color]::FromArgb(75,94,110)
		$RowColor = [System.Drawing.Color]::White
		$IsInformationalLine = $Text -match '(?i)^Last changes:\s*'
		if ($IsInformationalLine) {
			# Changelog text can legitimately mention errors or failures without reporting a runtime problem.
		}
		elseif ($IsError -or $Text -match '(?i)\b(error|failed|failure|exception|not able|aborted)\b') {
			$LineStatus = "Error"
			$StatusColor = [System.Drawing.Color]::FromArgb(180,45,45)
			$RowColor = [System.Drawing.Color]::FromArgb(255,239,239)
			$ProcessContext.ErrorCount++
		}
		elseif ($Text -match '(?i)\b(warning|attention)\b') {
			$LineStatus = "Warning"
			$StatusColor = [System.Drawing.Color]::FromArgb(166,102,0)
			$RowColor = [System.Drawing.Color]::FromArgb(255,248,224)
			$ProcessContext.WarningCount++
		}
		elseif ($Text -match '(?i)\b(finished|success|successful|update available|installed|newest version|OK)\b|no new version available') {
			$LineStatus = "Success"
			$StatusColor = [System.Drawing.Color]::FromArgb(20,120,52)
			$RowColor = [System.Drawing.Color]::FromArgb(218,245,225)
		}
		elseif ($Text -match '(?i)\b(installing|starting|download|import selection)\b') {
			$LineStatus = "Action"
			$StatusColor = [System.Drawing.Color]::FromArgb(0,86,158)
			$RowColor = [System.Drawing.Color]::FromArgb(226,240,252)
		}
		if ($ProcessGrid.RowCount -ge 1000) { $ProcessGrid.Rows.RemoveAt(0) }
		$RowIndex = $ProcessGrid.Rows.Add((Get-Date -Format "HH:mm:ss"),$LineStatus,$Text)
		$Row = $ProcessGrid.Rows[$RowIndex]
		$Row.DefaultCellStyle.BackColor = $RowColor
		$Row.Cells[1].Style.ForeColor = $StatusColor
		$Row.Cells[1].Style.Font = $StatusCellFont
		$Row.Cells[2].ToolTipText = $Text
		try { $ProcessGrid.FirstDisplayedScrollingRowIndex = $ProcessGrid.RowCount - 1 } catch {}
	}.GetNewClosure()

	$DrainProcessOutput = {
		if ($null -eq $ProcessContext.Job) { return }
		$JobErrors = @()
		$JobInformation = @()
		$JobWarnings = @()
		$JobOutput = @(Receive-Job -Job $ProcessContext.Job -ErrorAction SilentlyContinue -ErrorVariable +JobErrors -InformationAction SilentlyContinue -InformationVariable +JobInformation -WarningAction SilentlyContinue -WarningVariable +JobWarnings)
		$ProcessedLineCount = 0
		$LatestProgressText = $null
		foreach ($OutputItem in $JobOutput) {
			if ($null -ne $OutputItem.PSObject.Properties['EvergreenJobResult'] -and $OutputItem.EvergreenJobResult) {
				$ProcessContext.ExitCode = [int]$OutputItem.ExitCode
				continue
			}
			$OutputText = if ($OutputItem -is [System.Management.Automation.InformationRecord]) { [string]$OutputItem.MessageData } else { [string]$OutputItem }
			if ($OutputText -match '(?i)%\s*complete') { $LatestProgressText = $OutputText; continue }
			if ($ProcessedLineCount -ge 200) { continue }
			& $AppendProcessLine $OutputText $false
			$ProcessedLineCount++
		}
		if (-not [String]::IsNullOrWhiteSpace($LatestProgressText)) { & $AppendProcessLine $LatestProgressText $false }
		foreach ($JobError in $JobErrors) {
			& $AppendProcessLine ([string]$JobError) $true
		}
		foreach ($InformationItem in $JobInformation) {
			$InformationText = if ($InformationItem -is [System.Management.Automation.InformationRecord]) { [string]$InformationItem.MessageData } else { [string]$InformationItem }
			& $AppendProcessLine $InformationText $false
		}
		foreach ($JobWarning in $JobWarnings) { & $AppendProcessLine ([string]$JobWarning) $false }
	}.GetNewClosure()

	$ProcessTimer = New-Object System.Windows.Forms.Timer
	$ProcessTimer.Interval = 200
	$ProcessTimer.Add_Tick({
		& $DrainProcessOutput
		if ($ProcessContext.Running -and $ProcessContext.Job.State -in @('Completed','Failed','Stopped')) {
			& $DrainProcessOutput
			$ProcessTimer.Stop()
			$ProcessContext.Running = $false
			$ProcessContext.Completed = $true
			if ($ProcessContext.Job.State -ne 'Completed') { $ProcessContext.ExitCode = 1 }
			$script:GuiWorkflowExitCode = [int]$ProcessContext.ExitCode
			$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
			$ProcessProgress.Value = 100
			$BackToSelectionButton.Enabled = $true
			$CloseResultsButton.Enabled = $true
			$SelectionNavButton.Enabled = $true
			$ProcessNavButton.Enabled = $true
			$CompletedOperationCount = & $BuildInstallSummary
			if ($script:GuiWorkflowExitCode -eq 0 -and $ProcessContext.ErrorCount -eq 0) {
				$ProcessState.Text = "Installation completed"
				$ProcessState.ForeColor = [System.Drawing.Color]::FromArgb(20,120,52)
				$ProcessInfo.Text = "The installation process completed $CompletedOperationCount package operation(s) with $($ProcessContext.WarningCount) warning(s). The documentation summary is ready to copy."
				$NavigationStatus.Text = "Installation completed"
				& $AppendProcessLine "Installation process finished with exit code 0." $false
			}
			else {
				$ProcessState.Text = "Installation completed with errors"
				$ProcessState.ForeColor = [System.Drawing.Color]::FromArgb(185,55,55)
				$ProcessInfo.Text = "The installation process reported $($ProcessContext.ErrorCount) error line(s) and returned exit code $script:GuiWorkflowExitCode. Review the red output lines and install logs."
				$NavigationStatus.Text = "Installation requires attention"
				& $AppendProcessLine "Installation process finished with exit code $script:GuiWorkflowExitCode." $true
			}
		}
	}.GetNewClosure())

	$ShowSelection = {
		$SelectionPanel.Visible = $true
		$ProcessPanel.Visible = $false
		$SelectionNavButton.BackColor = [System.Drawing.Color]::FromArgb(232,241,248)
		$SelectionNavButton.ForeColor = [System.Drawing.Color]::FromArgb(16,91,145)
		$ProcessNavButton.BackColor = [System.Drawing.Color]::White
		$ProcessNavButton.ForeColor = [System.Drawing.Color]::FromArgb(90,100,115)
		$Form.AcceptButton = $Form.Tag
		$Form.CancelButton = $ProcessContext.CancelButton
	}.GetNewClosure()
	$ShowProcess = {
		$SelectionPanel.Visible = $false
		$ProcessPanel.Visible = $true
		$SelectionNavButton.BackColor = [System.Drawing.Color]::White
		$SelectionNavButton.ForeColor = [System.Drawing.Color]::FromArgb(90,100,115)
		$ProcessNavButton.BackColor = [System.Drawing.Color]::FromArgb(232,241,248)
		$ProcessNavButton.ForeColor = [System.Drawing.Color]::FromArgb(16,91,145)
		$Form.AcceptButton = $null
		$Form.CancelButton = $null
	}.GetNewClosure()

	$StartWorkflow = {
		if ($ProcessContext.Running) { return }
		$script:GuiWorkflowStarted = $true
		$script:GuiWorkflowExitCode = 1
		$ProcessContext.Completed = $false
		$ProcessContext.ErrorCount = 0
		$ProcessContext.WarningCount = 0
		$ProcessContext.ExitCode = 1
		$ProcessContext.TransferActive = $false
		$ProcessContext.InstallOperations.Clear()
		$ProcessContext.ForcedUpdateProducts.Clear()
		$ProcessContext.CurrentInstallProduct = $null
		$ProcessContext.InstalledSoftwareBefore = & $GetInstalledSoftwareSnapshot
		$ProcessGrid.Rows.Clear()
		$InstallSummaryBox.Text = "The installation summary will appear here after the process has completed."
		$CopySummaryButton.Text = "Copy summary"
		$CopySummaryButton.Enabled = $false
		$ProcessState.Text = "Installation is running..."
		$ProcessState.ForeColor = [System.Drawing.Color]::FromArgb(30,40,55)
		$ProcessInfo.Text = "The existing installer is running with -NoGUI. Output is transferred live into this window."
		$ProcessProgress.Value = 0
		$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
		$ProcessProgress.MarqueeAnimationSpeed = 25
		$BackToSelectionButton.Enabled = $false
		$CloseResultsButton.Enabled = $false
		$SelectionNavButton.Enabled = $false
		$ProcessNavButton.Enabled = $false
		$NavigationStatus.Text = "Installation is running"
		& $ShowProcess
		Stop-Transcript -ErrorAction SilentlyContinue | Out-Null
		try {
			if ($null -ne $ProcessContext.Job) { Remove-Job -Job $ProcessContext.Job -Force -ErrorAction SilentlyContinue }
			& $AppendProcessLine "Starting installer process..." $false
			# Pass switch states as 0/1 because Start-Job serializes ArgumentList values.
			# Binding a serialized string such as "False" directly to [bool] fails in PowerShell.
			$AutoInstallJobValue = if ($SoftwareToAutoInstall.IsPresent) { 1 } else { 0 }
			$RemoteInstallJobValue = if ($SoftwareToRemoteInstall.IsPresent) { 1 } else { 0 }
			$ProcessContext.Job = Start-Job -Name "Evergreen-Installer-GUI" -ScriptBlock {
				param([string]$ScriptPath,[int]$AutoInstall,[int]$RemoteInstall)
				$InvocationParameters = @{ NoGUI = $true }
				if ($AutoInstall -eq 1) { $InvocationParameters.SoftwareToAutoInstall = $true }
				if ($RemoteInstall -eq 1) { $InvocationParameters.SoftwareToRemoteInstall = $true }
				try {
					& $ScriptPath @InvocationParameters 6>&1 3>&1
					[PSCustomObject]@{ EvergreenJobResult = $true; ExitCode = 0 }
				}
				catch {
					Write-Error -ErrorRecord $_
					[PSCustomObject]@{ EvergreenJobResult = $true; ExitCode = 1 }
				}
			} -ArgumentList $PSCommandPath,$AutoInstallJobValue,$RemoteInstallJobValue
			$ProcessContext.Running = $true
			$ProcessTimer.Start()
		}
		catch {
			$ProcessContext.Running = $false
			$ProcessContext.Completed = $true
			$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
			$ProcessState.Text = "Installation could not be started"
			$ProcessState.ForeColor = [System.Drawing.Color]::FromArgb(185,55,55)
			$ProcessInfo.Text = $_.Exception.Message
			$BackToSelectionButton.Enabled = $true
			$CloseResultsButton.Enabled = $true
			& $AppendProcessLine $_.Exception.ToString() $true
		}
	}.GetNewClosure()

	$SelectionNavButton.Add_Click($ShowSelection)
	$ProcessNavButton.Add_Click($ShowProcess)
	$BackToSelectionButton.Add_Click($ShowSelection)
	$CopySummaryButton.Add_Click({
		if (-not [String]::IsNullOrWhiteSpace($InstallSummaryBox.Text)) {
			try {
				[System.Windows.Forms.Clipboard]::SetText($InstallSummaryBox.Text)
				$CopySummaryButton.Text = "Copied"
			}
			catch {
				[void][System.Windows.Forms.MessageBox]::Show("The summary could not be copied to the clipboard.","Clipboard unavailable",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
			}
		}
	})
	$CloseResultsButton.Add_Click({ $Form.Close() })
	$Form.Add_FormClosed({
		if ($null -ne $HeaderLogo.Image) { $HeaderLogo.Image.Dispose(); $HeaderLogo.Image = $null }
		if ($null -ne $LastChangesToolTip) { $LastChangesToolTip.Dispose() }
	}.GetNewClosure())
	$Form.Add_FormClosing({
		param($Sender,$EventArgs)
		if ($ProcessContext.Running) {
			[void][System.Windows.Forms.MessageBox]::Show("The installation is still running. Please wait until the process has completed.","Installation active",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
			$EventArgs.Cancel = $true
		}
	}.GetNewClosure())

	# Select Button
    $SelectButton = New-Object system.Windows.Forms.Button
	$SelectButton.text = "Select all"
	$SelectButton.width = 130
	$SelectButton.height = 40
	$SelectButton.Font = $Font
	$SelectButton.location = New-Object System.Drawing.Point(24,632)
	$SelectButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
	& $StyleEvergreenButton $SelectButton
	$SelectAllExclusions = @($CitrixVMToolsBox)
    $SelectButton.Add_Click({
		foreach ($SoftwareItem in $SoftwareCheckBoxes) {
			if ($SoftwareItem.Container.Visible) {
				$SoftwareItem.Control.Checked = -not ($SelectAllExclusions -contains $SoftwareItem.Control)
			}
		}
	})
    $SelectionPanel.Controls.Add($SelectButton)
	
	# Unselect Button
    $UnselectButton = New-Object system.Windows.Forms.Button
	$UnselectButton.text = "Clear all"
	$UnselectButton.width = 110
	$UnselectButton.height = 40
	$UnSelectButton.Font = $Font
	$UnselectButton.location = New-Object System.Drawing.Point(164,632)
	& $StyleEvergreenButton $UnselectButton
	$UnselectButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
    $UnselectButton.Add_Click({
		foreach ($SoftwareItem in $SoftwareCheckBoxes) { $SoftwareItem.Control.Checked = $false }
	})
    $SelectionPanel.Controls.Add($UnselectButton)
	
    # OK Button
    $OKButton = New-Object system.Windows.Forms.Button
	$OKButton.text = "Save && Start Installation"
	$OKButton.width = 210
	$OKButton.height = 40
	$OKButton.Font = $Font
	$OKButton.location = New-Object System.Drawing.Point(1046,632)
	$OKButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
	$OKButton.BackColor = [System.Drawing.Color]::FromArgb(31,120,180)
	$OKButton.ForeColor = [System.Drawing.Color]::White
	$OKButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
	& $StyleEvergreenButton $OKButton $true
    $OKButton.Add_Click({
		#if (!($SoftwareToInstall)) {$SoftwareSelection = New-Object PSObject}
		$SoftwareSelection = New-Object PSObject
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NotepadPlusPlus" -Value $NotePadPlusPlusBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "SevenZip" -Value $SevenZipBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDC" -Value $AdobeReaderDCBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCUpdate" -Value $AdobeReaderDCBoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCx64" -Value $AdobeReaderDCx64Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCx64Update" -Value $AdobeReaderDCx64BoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "BISF" -Value $BISFBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FSLogix" -Value $FSLogixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "GoogleChrome" -Value $GoogleChromeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Firefox" -Value $FirefoxBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR" -Value $WorkspaceApp_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR" -Value $WorkspaceApp_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR_Web" -Value $WorkspaceApp_CR_WebBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR_Web" -Value $WorkspaceApp_LTSR_WebBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixVMTools" -Value $CitrixVMToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePass" -Value $KeePassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePassXC" -Value $KeePassXCBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSEdge" -Value $MSEdgeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOneDrive" -Value $MSOneDriveBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSDotNetRuntime" -Value $MSDotNetRuntimeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSTeams2" -Value $NEWMSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_SAC" -Value $MS365AppsBox_SAC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_MEC" -Value $MS365AppsBox_MEC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2019" -Value $MSOffice2019Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2021" -Value $MSOffice2021Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2024" -Value $MSOffice2024Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VcRedist" -Value $VcRedistBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsEN" -Value $MSSQLManagementStudioENBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsDE" -Value $MSSQLManagementStudioDEBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MicrosoftOpenJDK" -Value $MicrosoftOpenJDKBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSVisualStudioCode" -Value $MSVisualStudioCodeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8" -Value $OracleJava8Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8_32" -Value $OracleJava8_32Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "TreeSizeFree" -Value $TreeSizeFreeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ShareX" -Value $ShareXBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VLCPlayer" -Value $VLCPlayerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FileZilla" -Value $FileZillaBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinRAR" -Value $WinRARBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ImageGlass" -Value $ImageGlassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Greenshot" -Value $GreenshotBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "pdf24Creator" -Value $pdf24CreatorBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FoxitReader" -Value $FoxitReaderBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "deviceTRUST" -Value $OriginalSoftwareSelection.deviceTRUST -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VMWareTools" -Value $VMWareToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RemoteDesktopManager" -Value $RemoteDesktopManagerBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVDI" -Value $ZoomVDIBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomCitrix" -Value $ZoomCitrixBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVMWare" -Value $ZoomVMWareBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExDesktop" -Value $CiscoWebExDesktopBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixPVSTargetDevice_LTSR" -Value $PVSTargetDevice_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixPVSTargetDevice_CR" -Value $PVSTargetDevice_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_LTSR" -Value $ServerVDA_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_PVS_LTSR" -Value $ServerVDA_PVS_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_CR" -Value $ServerVDA_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_PVS_CR" -Value $ServerVDA_PVS_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_MCS_LTSR" -Value $ServerVDA_MCS_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixServerVDA_MCS_CR" -Value $ServerVDA_MCS_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent" -Value $WEM_Agent_Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent_PVS" -Value $WEM_Agent_PVSBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixWEM_Agent_MCS" -Value $WEM_Agent_MCSBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Putty" -Value $PuttyBox.checked -Force
        Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinSCP" -Value $WinSCPBox.checked -Force
	
	# Export objects to	XML
	$SoftwareSelection | Export-Clixml $SoftwareToInstall
	& $StartWorkflow
	})
    $SelectionPanel.Controls.Add($OKButton)

    # Cancel Button
    $CancelButton = New-Object system.Windows.Forms.Button
    $CancelButton.text = "Exit"
	$CancelButton.width = 110
	$CancelButton.height = 40
	$CancelButton.Font = $Font
	$CancelButton.location = New-Object System.Drawing.Point(926,632)
	$CancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	& $StyleEvergreenButton $CancelButton
    $CancelButton.Add_Click({
        Write-Host -ForegroundColor Red "Canceled - Nothing happens"
        $Form.Close()
		[System.Environment]::Exit(0)
		})
    $SelectionPanel.Controls.Add($CancelButton)
	$ProcessContext.CancelButton = $CancelButton
	$Form.Tag = $OKButton
	$Form.AcceptButton = $OKButton
	$Form.CancelButton = $CancelButton

	# Activate the form and confirm a successful post-update GUI start.
    $Form.Add_Shown({$Form.Activate(); Write-EvergreenUpdateHealthCheck})
	Close-StartupWindow
    [void] $Form.ShowDialog()
}
# ========================================================================================================================================

# Show a dependency-free startup window before running startup checks.
Start-StartupWindow

# FUNCTION Check internet access
# ========================================================================================================================================
function Test-EvergreenInternetConnection {
	$Endpoint = "https://raw.githubusercontent.com/Mohrpheus78/Evergreen/main/Evergreen-Software%20Installer.ps1"
	$Errors = New-Object System.Collections.ArrayList
	try {
		# Use the same raw GitHub endpoint as the actual self-update. Do not require a
		# historical marker string because comments/header text can legitimately change.
		$Response = Invoke-WebRequest -UseBasicParsing -Uri $Endpoint -TimeoutSec 15 -Headers @{ "User-Agent" = "Evergreen-Installer"; "Accept" = "text/plain,*/*" } -ErrorAction Stop
		$Content = [string]$Response.Content
		$VersionMatch = [regex]::Match($Content,'(?m)^Version:\s*(?<Version>\d+(?:\.\d+){1,3})\s*$')
		$HasPowerShellStructure = [regex]::IsMatch($Content,'(?im)^\s*Param\s*\(') -and $Content.IndexOf('$EvergreenVersion',[StringComparison]::OrdinalIgnoreCase) -ge 0
		if ([String]::IsNullOrWhiteSpace($Content)) {
			[void]$Errors.Add("The GitHub update source returned an empty response.")
		}
		elseif (-not $VersionMatch.Success -or -not $HasPowerShellStructure) {
			$StatusCode = if ($null -ne $Response.StatusCode) { [string][int]$Response.StatusCode } else { "unknown" }
			$ContentType = if ($null -ne $Response.Headers['Content-Type']) { [string]$Response.Headers['Content-Type'] } else { "unknown" }
			[void]$Errors.Add("GitHub was reachable (HTTP $StatusCode, Content-Type '$ContentType'), but the response was not recognized as the Evergreen installer script.")
		}
		else {
			return [PSCustomObject]@{ Connected = $true; Endpoint = $Endpoint; Content = $Content; Version = $VersionMatch.Groups['Version'].Value; Errors = @() }
		}
	}
	catch {
		$Detail = $_.Exception.Message
		if ($null -ne $_.Exception.Response) {
			try { $Detail += " (HTTP $([int]$_.Exception.Response.StatusCode))" } catch {}
		}
		[void]$Errors.Add($Detail)
	}
	return [PSCustomObject]@{ Connected = $false; Endpoint = $Endpoint; Content = ""; Version = $null; Errors = @($Errors) }
}
if ($SkipUpdateCheck) {
	$InternetResult = [PSCustomObject]@{ Connected = $true; Endpoint = ""; Content = ""; Version = [string]$EvergreenVersion; Errors = @() }
	$InternetCheck1 = "True"
	$InternetCheck2 = "True"
	if ($noGUI -eq $False) { Set-StartupStatus "Starting updated installer..." "Version $EvergreenVersion passed update validation. Skipping the second GitHub update check." 900 }
}
else {
	Set-StartupStatus "Checking update access..." "Validating access to the Evergreen installer on GitHub."
	do {
		$InternetResult = Test-EvergreenInternetConnection
		if ($InternetResult.Connected) { break }
		if ($NoGUI) { break }
		$InternetFailureDetail = if ($InternetResult.Errors.Count -gt 0) { "GitHub update source could not be validated: " + ($InternetResult.Errors -join " | ") + " You can retry, continue with the locally available installer files, or exit." } else { "GitHub update source could not be validated. You can retry, continue with the locally available installer files, or exit." }
		$InternetChoice = Wait-StartupInternetChoice $InternetFailureDetail
		if ($InternetChoice -eq "Exit") { Close-StartupWindow; Restore-StartupConsole; exit 1 }
		if ($InternetChoice -eq "Continue") { break }
		Set-StartupStatus "Retrying update access..." "Validating the Evergreen update source on GitHub again."
	} while ($true)
	$InternetCheck1 = if ($InternetResult.Connected) { "True" } else { "False" }
	$InternetCheck2 = $InternetCheck1
	if ($InternetResult.Connected) { Set-StartupStatus "Update source available" "The Evergreen installer script and its version were verified successfully." 900 }
	else { Set-StartupStatus "Continuing in offline mode" "The installer will use the locally available scripts and packages." 900 }
}
# ========================================================================================================================================


# Do you run the script as admin?
# ========================================================================================================================================
Set-StartupStatus "Checking permissions..." "Verifying that the installer is running with administrator rights."
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

if ($myWindowsPrincipal.IsInRole($adminRole) -or $UpdateDryRun)
   {
    # OK, runs as admin
    Write-Host "OK, script is running with Admin rights"
    Write-Output ""
	if ($UpdateDryRun -and -not $myWindowsPrincipal.IsInRole($adminRole)) {
		Set-StartupStatus "Update dry run" "Administrator rights are not required because no file will be changed." 500
	}
	else { Set-StartupStatus "Administrator rights confirmed" "The installer has the required permissions." 500 }
   }

else
   {
    # Script doesn't run as admin, stop!
    Write-Host -ForegroundColor Red "Error! Script is NOT running with Admin rights!"
	if ($null -ne $script:StartupForm) {
		[void][System.Windows.Forms.MessageBox]::Show($script:StartupForm,"The Software Installer must be started with administrator rights.","Administrator rights required",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
	}
	Close-StartupWindow
	Restore-StartupConsole
	exit 1
   }
# ========================================================================================================================================


# Is there a newer Evergreen Script version?
# ========================================================================================================================================
$WebVersion = ""
[bool]$NewerVersion = $false
$UpdateCandidate = $null
$UpdateDryRunResult = $null
if ($noGUI -eq $False -and -not $SkipUpdateCheck) {
	Set-StartupStatus "Checking the installer version..." "Comparing the local script with the published Evergreen version."
	if (-not [String]::IsNullOrWhiteSpace($UpdateManifestPath)) {
		try {
			Set-StartupStatus "Loading the test update manifest..." "No production files will be changed."
			$UpdateCandidate = Get-EvergreenUpdateCandidate $UpdateManifestPath "Installer"
			[version]$WebVersion = $UpdateCandidate.Version
			$NewerVersion = $WebVersion -gt $EvergreenVersion
			if ($UpdateDryRun -or $NewerVersion) {
				Set-StartupStatus "Validating installer update $WebVersion..." "Staging the package and checking SHA-256, version, and PowerShell syntax."
				$UpdateDryRunResult = Test-EvergreenUpdateCandidate $UpdateCandidate -KeepStagedFile:(-not $UpdateDryRun)
			}
		}
		catch {
			$UpdateDryRunResult = [PSCustomObject]@{ Success = $false; Version = $null; Hash = ""; Message = $_.Exception.Message }
			$WebVersion = ""
		}
	}
	elseif ($UpdateDryRun) {
		$UpdateDryRunResult = [PSCustomObject]@{ Success = $false; Version = $null; Hash = ""; Message = "-UpdateDryRun requires -UpdateManifestPath." }
	}
	elseif ($InternetCheck1 -eq "True" -or $InternetCheck2 -eq "True") {
		try {
			[version]$WebVersion = $InternetResult.Version
			If ($WebVersion -gt $EvergreenVersion) { $NewerVersion = $true }
		}
		catch {
			$WebVersion = ""
			Set-StartupStatus "Version check unavailable" "Local installer version: $EvergreenVersion. The locally available scripts can still be used." 1100
		}
	}
	if ($null -ne $UpdateDryRunResult) {
		if ($UpdateDryRunResult.Success) {
			if ($UpdateDryRun) { Set-StartupStatus "Dry run completed successfully" "Installer $($UpdateDryRunResult.Version): staging, SHA-256, version, and syntax checks passed. No file was replaced." 1500 }
			else { Set-StartupStatus "Update package validated" "Installer $($UpdateDryRunResult.Version) is ready for the transactional test update." 1200 }
		}
		else {
			Set-StartupStatus "Dry run validation failed" $UpdateDryRunResult.Message 1800
		}
	}
	elseif ($NewerVersion) {
		Set-StartupStatus "New installer version available" "Installed: $EvergreenVersion  |  Available: $WebVersion" 1200
	}
	elseif ($InternetResult.Connected -and -not [String]::IsNullOrWhiteSpace([string]$WebVersion)) {
		Set-StartupStatus "Installer is up to date" "Installed version: $EvergreenVersion" 1200
	}
	elseif (-not $InternetResult.Connected) {
		Set-StartupStatus "Version check skipped in offline mode" "Installed version: $EvergreenVersion" 1200
	}
}
elseif ($noGUI -eq $False) {
	Set-StartupStatus "Starting updated installer..." "Version $EvergreenVersion passed package validation. Waiting for the main GUI." 900
}

Clear-Host

Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " -------------------------------------------------"
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " Software-Installer (Powered by Evergreen-Module) "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " © D. Mohrmann - Cancom GmbH                      "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " -------------------------------------------------"
Write-Output ""


# Variables
Set-StartupStatus "Preparing the installer..." "Loading paths, saved host selections, and local package information."
Write-Host -ForegroundColor Cyan "Setting Variables"
Write-Output ""
$SoftwareFolder = ("$PSScriptRoot" + "\" + "Software\")
$ErrorActionPreference = "Continue"
$SoftwareToInstall = "$SoftwareFolder\Software-to-install-$ENV:Computername.xml"
IF ($SoftwareToAutoInstall -eq $True) {
	$SoftwareToInstall = "$SoftwareFolder\Software-to-install-$ENV:Computername-Auto.xml"
	}
<#
IF ($SoftwareToRemoteInstall -eq $True) {
	$SoftwareToInstall = "$SoftwareFolder\Software-to-install-$ENV:Computername.xml"
	}
#>
	
# Check version
if ($noGUI -eq $False -and -not $SkipUpdateCheck) {
Write-Host -Foregroundcolor Cyan "Current script version: $EvergreenVersion"`n
Write-Output ""
Write-Host -Foregroundcolor Cyan "Is there a newer Evergreen Script version?"

If ($null -ne $UpdateDryRunResult -and ($UpdateDryRun -or -not $UpdateDryRunResult.Success)) {
	$DryRunMessage = if ($UpdateDryRunResult.Success) { "Dry run passed for Installer $($UpdateDryRunResult.Version).`r`n`r`n$($UpdateDryRunResult.Message)`r`n`r`nNo file was replaced." } elseif ($UpdateDryRun) { "Dry run failed:`r`n`r`n$($UpdateDryRunResult.Message)`r`n`r`nNo file was replaced." } else { "Update package validation failed:`r`n`r`n$($UpdateDryRunResult.Message)`r`n`r`nNo file was replaced." }
	$DryRunIcon = if ($UpdateDryRunResult.Success) { [System.Windows.Forms.MessageBoxIcon]::Information } else { [System.Windows.Forms.MessageBoxIcon]::Warning }
	if ($null -ne $script:StartupForm) { [void][System.Windows.Forms.MessageBox]::Show($script:StartupForm,$DryRunMessage,"Update dry run",[System.Windows.Forms.MessageBoxButtons]::OK,$DryRunIcon) }
	else { [void][System.Windows.Forms.MessageBox]::Show($DryRunMessage,"Update dry run",[System.Windows.Forms.MessageBoxButtons]::OK,$DryRunIcon) }
}
ElseIf ($NewerVersion -eq $false) {
        # No new version available
        Write-Host -Foregroundcolor Green "OK, script is newest version!"
        Write-Output ""
}
Else {
        # There is a new Evergreen Script Version
        Write-Host -Foregroundcolor Red "Attention! There is a new version $WebVersion of the Evergreen Installer available!"
        Write-Output ""
		Set-StartupStatus "A newer installer is available" "Version $WebVersion can be downloaded before continuing."
		if (-not [String]::IsNullOrWhiteSpace($UpdateManifestPath)) {
			if ($null -ne $UpdateDryRunResult -and $UpdateDryRunResult.Success -and $UpdateCandidate.Channel -eq "Test") {
				$AnswerPending = [System.Windows.Forms.MessageBox]::Show($script:StartupForm,"Installer $WebVersion passed all package checks.`r`n`r`nThe test update will create a backup, replace only this script, restart the GUI, and automatically roll back if the new GUI does not report a healthy start.`r`n`r`nStart the transactional test update now?","Validated test update",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
			}
			else {
				[void][System.Windows.Forms.MessageBox]::Show($script:StartupForm,"The manifest update was not started because validation failed or the manifest is not using the Test channel.","Test update blocked",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
				$AnswerPending = [System.Windows.Forms.DialogResult]::No
			}
		}
		elseif ($null -ne $script:StartupForm) {
			$AnswerPending = [System.Windows.Forms.MessageBox]::Show($script:StartupForm,"Evergreen Installer $WebVersion is available. Do you want to download it now?","New installer version",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
		}
		else {
			$AnswerPending = [System.Windows.Forms.MessageBox]::Show("Evergreen Installer $WebVersion is available. Do you want to download it now?","New installer version",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
		}
			If ($AnswerPending -eq [System.Windows.Forms.DialogResult]::Yes) {
				if ([String]::IsNullOrWhiteSpace($UpdateManifestPath)) {
					Set-StartupStatus "Validating the new installer..." "Checking version metadata and PowerShell syntax before replacing any file."
					$UpdateDryRunResult = New-EvergreenValidatedUpdateFromContent $InternetResult.Content ([version]$WebVersion) "Installer"
				}
				if ($null -ne $UpdateDryRunResult -and $UpdateDryRunResult.Success) {
					Set-StartupStatus "Installing the validated installer..." "Creating a backup, replacing this script, and checking the restarted GUI."
					$UpdateInstallResult = Install-EvergreenValidatedUpdate $UpdateDryRunResult "Installer"
					Remove-EvergreenStagedUpdate $UpdateDryRunResult
					if ($UpdateInstallResult.Success) {
						Close-StartupWindow
						return
					}
					[void][System.Windows.Forms.MessageBox]::Show($script:StartupForm,"The update was rolled back.`r`n`r`n$($UpdateInstallResult.Message)","Update could not be completed",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error)
				}
				else {
					$ValidationMessage = if ($null -ne $UpdateDryRunResult) { $UpdateDryRunResult.Message } else { "The update package could not be validated." }
					[void][System.Windows.Forms.MessageBox]::Show($script:StartupForm,$ValidationMessage,"Update validation failed",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
				}
			}
			if (-not [String]::IsNullOrWhiteSpace($UpdateManifestPath) -and $AnswerPending -ne [System.Windows.Forms.DialogResult]::Yes) { Remove-EvergreenStagedUpdate $UpdateDryRunResult }

}
}

# Release notes
# Read the currently running script instead of relying on a fixed file name.
$CurrentScriptPath = $PSCommandPath
if ([String]::IsNullOrWhiteSpace($CurrentScriptPath)) {
    $CurrentScriptPath = $MyInvocation.MyCommand.Path
}

$lastLineBeforeNotes = $null
if (-not [String]::IsNullOrWhiteSpace($CurrentScriptPath) -and (Test-Path -LiteralPath $CurrentScriptPath)) {
    $scriptContent = @(Get-Content -LiteralPath $CurrentScriptPath -ErrorAction SilentlyContinue)
    $notesIndex = [Array]::IndexOf($scriptContent, "# Notes")
    if ($notesIndex -gt 0) {
        $lastLineBeforeNotes = $scriptContent[$notesIndex - 1]
    }
}

if (-not [String]::IsNullOrWhiteSpace($lastLineBeforeNotes)) {
    Write-Host -Foregroundcolor Cyan "Last changes: $lastLineBeforeNotes"
} else {
    Write-Host -Foregroundcolor DarkGray "Last changes: release note information unavailable"
}
Write-Output ""

# General install logfile
$Date = $Date = Get-Date -UFormat "%d.%m.%Y"
$InstallLog = "$SoftwareFolder\_Install Logs\General Install $ENV:Computername $Date.log"

# Import values (selected software) from XML file
if (Test-Path -Path $SoftwareToInstall) {$SoftwareSelection = Import-Clixml $SoftwareToInstall}

#Remove-Item $InstallLog*
Start-Transcript $InstallLog | Out-Null

# Call Form
if ($noGUI -eq $False) {
Set-StartupStatus "Opening software selection..." "The installer is ready."
gui_mode
	if ($script:GuiWorkflowStarted) {
		exit [int]$script:GuiWorkflowExitCode
	}
	exit 0
}

# Import selection
$SoftwareSelection = Import-Clixml $SoftwareToInstall
Write-Host -ForegroundColor Cyan "Import selection"
Write-Output ""

# Call software install scripts

# Install Notepad ++
IF ($SoftwareSelection.NotePadPlusPlus -eq $true)
	{
		try {
			& "$SoftwareFolder\Install NotepadPlusPlus.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "NotePadPlusPlus remote installation  not allowed"
			Write-Output ""
			}
	}

# Install 7-ZIP
IF ($SoftwareSelection.SevenZip -eq $true)
	{
		try {
			& "$SoftwareFolder\Install 7-Zip.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing 7-Zip"
			Write-Host -ForegroundColor Red "Error launching script 'Install 7-Zip': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC MUI
IF ($SoftwareSelection.AdobeReaderDC -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC"
			Write-Host -ForegroundColor Red "Error launching script 'Install Adobe Reader DC': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC MUI Update
IF ($SoftwareSelection.AdobeReaderDCUpdate -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC Update.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC Update"
			Write-Host -ForegroundColor Red "Error launching script 'Install Adobe Reader DC Update': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC x64 MUI
IF ($SoftwareSelection.AdobeReaderDCx64 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC 64 Bit.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC 64 Bit"
			Write-Host -ForegroundColor Red "Error launching script 'Install Adobe Reader DC 64 Bit': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Adobe Reader DC x64 MUI Update
IF ($SoftwareSelection.AdobeReaderDCx64Update -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Adobe Reader DC 64 Bit Update.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Adobe Reader DC 64 Bit Update"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Adobe Reader DC 64 Bit Update': $($Error[0])"
			Write-Output ""
			}
	}

# Install BIS-F
IF ($SoftwareSelection.BISF -eq $true)
	{
		try {
			& "$SoftwareFolder\Install BIS-F.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing BIS-F"
			Write-Host -ForegroundColor Red "Error launching script 'Install BIS-F': $($Error[0])"
			Write-Output ""
			}
	}

# Install FSLogix
IF ($SoftwareSelection.FSLogix -eq $true)
	{
		try {
			& "$SoftwareFolder\Install FSLogix.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing FSLogix"
			Write-Host -ForegroundColor Red "Error launching script 'Install FSLogix': $($Error[0])"
			Write-Output ""
			}
	}

# Install Chrome
IF ($SoftwareSelection.GoogleChrome -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Google Chrome.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Google Chrome"
			Write-Host -ForegroundColor Red "Error launching script 'Install Google Chrome': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Mozilla Firefox
IF ($SoftwareSelection.Firefox -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Mozilla Firefox.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Mozilla Firefox"
			Write-Host -ForegroundColor Red "Error launching script 'Install Mozilla Firefox': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix WorkspaceApp Current
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WorkspaceApp Current.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WorkspaceApp Current Release"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix WorkspaceApp Current': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix WorkspaceApp LTSR
IF ($SoftwareSelection.WorkspaceApp_LTSR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WorkspaceApp LTSR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WorkspaceApp LTSR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix WorkspaceApp LTSR': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix WorkspaceApp Current Web
IF ($SoftwareSelection.WorkspaceApp_CR_Web -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WorkspaceApp Current Web.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WorkspaceApp Current Release Web"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix WorkspaceApp Current Web': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix WorkspaceApp LTSR Web
IF ($SoftwareSelection.WorkspaceApp_LTSR_Web -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WorkspaceApp LTSR Web.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WorkspaceApp LTSR Web"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix WorkspaceApp LTSR Web': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix VM Tools
IF ($SoftwareSelection.CitrixVMTools -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix VM Tools.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix VM Tools"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix VM Tools': $($Error[0])"
			Write-Output ""
			}
	}

# Install KeePass
IF ($SoftwareSelection.KeePass -eq $true)
	{
		try {
			& "$SoftwareFolder\Install KeePass.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing KeePass"
			Write-Host -ForegroundColor Red "Error launching script 'Install KeePass': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install KeePassXC
IF ($SoftwareSelection.KeePassXC -eq $true)
	{
		try {
			& "$SoftwareFolder\Install KeePassXC.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing KeePassXC"
			Write-Host -ForegroundColor Red "Error launching script 'Install KeePassXC': $($Error[0])"
			Write-Output ""
			}
	}

# Install MS Edge
IF ($SoftwareSelection.MSEdge -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Edge.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS Edge"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Edge': $($Error[0])"
			Write-Output ""
			}
	}

# Install MS OneDrive
IF ($SoftwareSelection.MSOneDrive -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS OneDrive.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS OneDrive"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS OneDrive': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install NEW MS Teams
IF ($SoftwareSelection.MSTeams2 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Teams 2.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "MS Teams 2.x"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Teams': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS 365Apps
IF ($SoftwareSelection.MS365Apps_SAC -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install MS 365 Apps SAC.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing MS 365 Apps-Semi Annual Channel"
				Write-Host -ForegroundColor Red "Error launching script 'Install MS 365 Apps SAC': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Microsoft 365 Apps allowed"
				Write-Output ""
			}
	}
	
# Install MS 365Apps
IF ($SoftwareSelection.MS365Apps_MEC -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install MS 365 Apps MEC.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing MS 365 Apps-Monthly Enterprise Channel"
				Write-Host -ForegroundColor Red "Error launching script 'Install MS 365 Apps MEC': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Microsoft 365 Apps allowed"
				Write-Output ""
			}
	}
	
# Install MS Office 2019
IF ($SoftwareSelection.MSOffice2019 -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install MS Office 2019.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing MS Office 2019"
				Write-Host -ForegroundColor Red "Error in launching script 'Install MS Office 2019': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Microsoft 2019 allowed"
				Write-Output ""
			}
	}
	
# Install MS Office 2021
IF ($SoftwareSelection.MSOffice2021 -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install MS Office 2021.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing MS Office 2021"
				Write-Host -ForegroundColor Red "Error launching script 'Install MS Office 2021': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Microsoft 2021 allowed"
				Write-Output ""
			}
	}
	
# Install MS Office 2024
IF ($SoftwareSelection.MSOffice2024 -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install MS Office 2024.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing MS Office 2024"
				Write-Host -ForegroundColor Red "Error launching script 'Install MS Office 2024': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Microsoft 2024 allowed"
				Write-Output ""
			}
	}
	
	
# Install MS VcRedist
IF ($SoftwareSelection.VcRedist -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS VcRedist x86.ps1"
		}
		catch {
			Write-Host -ForegroundColor Red "Installing Microsoft Visual C++ Redistributable packages x86"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x86': $($Error[0])"
			Write-Output ""
		}
		try {
			& "$SoftwareFolder\Install MS VcRedist x64.ps1"
		}
		catch {
			Write-Host -ForegroundColor Red "Installing Microsoft Visual C++ Redistributable packages x64"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x64': $($Error[0])"
			Write-Output ""
		}
	}

# Install MS MS SQL Management Studio EN
IF ($SoftwareSelection.MSSsmsEN -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS SQL MGMT Studio EN.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS SQL MGMT Studio EN"
			Write-Host -ForegroundColor Red "Error  launching script 'Install MS SQL MGMT Studio EN': $($Error[0])"
			Write-Output ""
			}
	}

# Install MS MS SQL Management Studio DE
IF ($SoftwareSelection.MSSsmsDE -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS SQL MGMT Studio DE.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS SQL MGMT Studio DE"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS SQL MGMT Studio DE': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS openJDK 21
IF ($SoftwareSelection.MicrosoftOpenJDK -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS openJDK21.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS openJDK 21"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS openJDK 21': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS Visual Studio Code
IF ($SoftwareSelection.MSVisualStudioCode -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS Visual Studio Code.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing MS Visual Studio Code"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS Visual Studio Code': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install MS .Net Runtime
IF ($SoftwareSelection.MSDotNetRuntime -eq $true)
	{
		try {
			& "$SoftwareFolder\Install MS DotNet Runtime.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "MS .Net Runtime 8.x"
			Write-Host -ForegroundColor Red "Error launching script 'Install MS .Net Runtime 8.x': $($Error[0])"
			Write-Output ""
			}
	}

# Install Oracle Java 8
IF ($SoftwareSelection.OracleJava8 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Oracle Java 8 - 64 Bit.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Oracle Java 8 x64"
			Write-Host -ForegroundColor Red "Error launching script 'Install Oracle Java 8 - 64 Bit': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Oracle Java 8 32 Bit
IF ($SoftwareSelection.OracleJava8_32 -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Oracle Java 8 - 32 Bit.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Oracle Java 8 x86"
			Write-Host -ForegroundColor Red "Error launching script 'Install Oracle Java 8 - 32 Bit': $($Error[0])"
			Write-Output ""
			}
	}

# Install TreeSizeFree
IF ($SoftwareSelection.TreeSizeFree -eq $true)
	{
		try {
			& "$SoftwareFolder\Install TreeSizeFree.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing TreeSize Free"
			Write-Host -ForegroundColor Red "Error launching script 'Install TreeSizeFree': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install ShareX
IF ($SoftwareSelection.ShareX -eq $true)
	{
		try {
			& "$SoftwareFolder\Install ShareX.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing ShareX"
			Write-Host -ForegroundColor Red "Error launching script 'Install ShareX': $($Error[0])"
			Write-Output ""
			}
	}

# Install VLC Player
IF ($SoftwareSelection.VLCPlayer -eq $true)
	{
		try {
			& "$SoftwareFolder\Install VLC Player.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing VLC Player"
			Write-Host -ForegroundColor Red "Error launching script 'Install VLC Player': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install FileZilla
IF ($SoftwareSelection.FileZilla -eq $true)
	{
		try {
			& "$SoftwareFolder\Install FileZilla.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing FileZilla"
			Write-Host -ForegroundColor Red "Error launching script 'Install FileZilla': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install ImageGlass
IF ($SoftwareSelection.ImageGlass -eq $true)
	{
		try {
			& "$SoftwareFolder\Install ImageGlass.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing ImageGlass"
			Write-Host -ForegroundColor Red "Error launching script 'Install ImageGlass': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Greenshot
IF ($SoftwareSelection.Greenshot -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Greenshot.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Greenshot"
			Write-Host -ForegroundColor Red "Error launching script 'Install Greenshot': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install pdf24Creator
IF ($SoftwareSelection.pdf24Creator -eq $true)
	{
		try {
			& "$SoftwareFolder\Install pdf24Creator.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing pdf24Creator"
			Write-Host -ForegroundColor Red "Error launching script 'Install pdf24Creator': $($Error[0])"
			Write-Output ""
			}
	}

# Install FoxitReader
IF ($SoftwareSelection.FoxitReader -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Foxit Reader.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Foxit Reader"
			Write-Host -ForegroundColor Red "Error launching script 'Install Foxit Reader': $($Error[0])"
			Write-Output ""
			}
	}
	
	
# Install RemoteDesktopManager
IF ($SoftwareSelection.RemoteDesktopManager -eq $true)
	{
		try {
			& "$SoftwareFolder\Install RemoteDesktopManager.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing RemoteDesktopManager"
			Write-Host -ForegroundColor Red "Error launching script 'Install RemoteDesktopManager': $($Error[0])"
			Write-Output ""
			}
	}

<#
# Install Zoom VDI Host
IF ($SoftwareSelection.ZoomVDI -eq $true)
	{
		& "$SoftwareFolder\Install Zoom VDI Host.ps1"
	}
	
# Install Zoom Citrix Client
IF ($SoftwareSelection.ZoomCitrix -eq $true)
	{
		& "$SoftwareFolder\Install Zoom Citrix Client.ps1"
	}
	
# Install Zoom VMWare Client
IF ($SoftwareSelection.ZoomVMWare -eq $true)
	{
		& "$SoftwareFolder\Install Zoom VMWare Client.ps1"
	}
	
# Install CiscoWebExDesktop PlugIn
IF ($SoftwareSelection.CiscoWebExDesktop -eq $true)
	{
		& "$SoftwareFolder\Install Cisco WebEx Desktop.ps1"
	}
#>

# Install Citrix PVS Target Device Client
IF ($SoftwareSelection.CitrixPVSTargetDevice_LTSR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix PVS Target Device LTSR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix PVS Target Device LTSR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix PVS Target Device LTSR': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix PVS Target Device Client
IF ($SoftwareSelection.CitrixPVSTargetDevice_CR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix PVS Target Device CR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix PVS Target Device CR"
			Write-Host -ForegroundColor Red "Error launching script 'Install Citrix PVS Target Device CR ': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix Server VDA LTSR
IF ($SoftwareSelection.CitrixServerVDA_LTSR -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install Citrix Server VDA LTSR.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing Citrix Server VDA LTSR"
				Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA LTSR': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Citrix Server VDA LTSR not allowed, please install local!"
				Write-Output ""
			}
	}

# Install Citrix Server VDA PVS LTSR
IF ($SoftwareSelection.CitrixServerVDA_PVS_LTSR -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install Citrix Server VDA for PVS LTSR.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing Citrix Server VDA for PVS LTSR"
				Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA for PVS LTSR': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Citrix Server VDA LTSR not allowed, please install local!"
				Write-Output ""
			}
	}
	
# Install Citrix Server VDA CR/Cloud
IF ($SoftwareSelection.CitrixServerVDA_CR -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install Citrix Server VDA CR.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing Citrix Server VDA CR"
				Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA CR': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Citrix Server VDA CR not allowed, please install local!"
				Write-Output ""
			}
	}
	
# Install Citrix Server VDA PVS CR/Cloud
IF ($SoftwareSelection.CitrixServerVDA_PVS_CR -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install Citrix Server VDA for PVS CR.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing Citrix Server VDA for PVS CR"
				Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA for PVS CR': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Citrix Server VDA CR not allowed, please install local!"
				Write-Output ""
			}
	}
	
# Install Citrix Server VDA MCS LTSR
IF ($SoftwareSelection.CitrixServerVDA_MCS_LTSR -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install Citrix Server VDA for MCS LTSR.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing Citrix Server VDA for MCS LTSR"
				Write-Host -ForegroundColor Red "Error launching script 'Install Citrix Server VDA for MCS LTSR': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Citrix Server VDA LTSR not allowed, please install local!"
				Write-Output ""
			}
	}
	
# Install Citrix Server VDA MCS CR
IF ($SoftwareSelection.CitrixServerVDA_MCS_CR -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install Citrix Server VDA for MCS CR.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing Citrix Server VDA for MCS CR"
				Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix Server VDA for MCS CR': $($Error[0])"
				Write-Output ""
				}
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of Citrix Server VDA LTSR not allowed, please install local!"
				Write-Output ""
			}
	}
	
# Install Citrix WEM Agent
IF ($SoftwareSelection.CitrixWEM_Agent -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WEM Agent.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WEM Agent"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix WEM Agent': $($Error[0])"
			Write-Output ""
			}
	}

# Install Citrix WEM Agent PVS
IF ($SoftwareSelection.CitrixWEM_Agent_PVS -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WEM Agent for PVS.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WEM Agent for PVS"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix WEM Agent for PVS': $($Error[0])"
			Write-Output ""
			}
	}
	
# Install Citrix WEM Agent MCS
IF ($SoftwareSelection.CitrixWEM_Agent_MCS -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Citrix WEM Agent for MCS.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Citrix WEM Agent for MCS"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Citrix WEM Agent for MCS': $($Error[0])"
			Write-Output ""
			}
	}

# Install Putty
IF ($SoftwareSelection.Putty -eq $true)
	{
		try {
			& "$SoftwareFolder\Install Putty.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing Putty"
			Write-Host -ForegroundColor Red "Error in launching script 'Install Putty': $($Error[0])"
			Write-Output ""
			}
	}

# Install WinSCP
IF ($SoftwareSelection.WinSCP -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WinSCP.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WinSCP"
			Write-Host -ForegroundColor Red "Error in launching script 'Install WinSCP': $($Error[0])"
			Write-Output ""
			}
	}

# Install WinRAR
IF ($SoftwareSelection.WinRAR -eq $true)
	{
		try {
			& "$SoftwareFolder\Install WinRAR.ps1"
			}
		catch {
			Write-Host -ForegroundColor Red "Installing WinSCP"
			Write-Host -ForegroundColor Red "Error in launching script 'Install WinSCP': $($Error[0])"
			Write-Output ""
			}
	}

# Install VMWareTools
IF ($SoftwareSelection.VMWareTools -eq $true)
	{
		IF (!($SoftwareToRemoteInstall)) {
			try {
				& "$SoftwareFolder\Install MS VcRedist x64.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing MS VcRedist x64"
				Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x64': $($Error[0])"
				Write-Output ""
				}	
			try {
				& "$SoftwareFolder\Install MS VcRedist x86.ps1"
				}
			catch {
				Write-Host -ForegroundColor Red "Installing MS VcRedist x86"
				Write-Host -ForegroundColor Red "Error launching script 'Install MS VcRedist x86': $($Error[0])"
				Write-Output ""
				}	
				& "$SoftwareFolder\Install VMWareTools.ps1"
		}
		ELSE {
				Write-Host -ForegroundColor Red "Remote installation of VMWare Tools not allowed, please install local!"
				Write-Output ""
			}
	}
	
# Stop install log
Stop-Transcript

# Format install log
$Content = Get-Content -Path $InstallLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $InstallLog

Write-Output ""
Write-Host -ForegroundColor Cyan "Finished, please check if selected software is installed!"
$Updates = Get-Content -Path $InstallLog | Select-String -Pattern Installing
$Updates = ($Updates -replace ("Uninstalling","") -replace ("Installing","") | Select-Object -Unique) -join ","
$Updates = "Update" + $Updates
Write-Host -ForegroundColor Yellow "Copy summary for your documentation:"
$Updates
Write-Output ""

if ($noGUI -eq $False) {
    pause}