# ***************************************************************************
# D. Mohrmann, Cancom GmbH BU S&L, Twitter: @mohrpheus78
# Download Software packages with Evergreen powershell module
# ***************************************************************************

<#
.SYNOPSIS
This script downloads software packages if new versions are available.
		
.DESCRIPTION
The script uses the excellent Powershell Evergreen module from Aaron Parker, Bronson Magnan and Trond Eric Haarvarstein. 
To update a software package just switch from 0 to 1 in the section "Select software to download".
A new folder for every single package will be created, together with a Version file, a download date file and a log file. IF a new version is available the scriot checks
the version number and will update the package.

.NOTES
Many thanks to Aaron Parker, Bronson Magnan and Trond Eric Haarvarstein for the module!
https://github.com/aaronparker/Evergreen
Run as admin!
Version: 3.0.2
06/24: Changed internet connection check
06/25: Changed internet connection check
06/27: [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 at the top of the script
07/04: Changed Adobe Reader update source (Evergreen)
07/25: Changed version check from pdf24Creator
07/27: Wrong URL for pdf24Creator, please remove all files from pdf24Creator folder before launching Updater again! Changed Citrix WorkspaceApp version check and always install MS Edge WebView updates, changed Adobe DC update check
11/21: Changed RemoteDesktopManager URL
11/22: Improved download check for alle apps, warning if app download fails
12/06: Changed MS SMSS to Nevergreen to get the current version, changed download url https://aka.ms/ssmsfullsetup
12/07: Office downloads corrected, better improved expand archive deviceTRUST and FSLogix, copy ADMX files to subfolder _ADMX
12/08: If -noGUI switch is used, there is no update check
12/13: Wrong download path for Citrix WorkspaceApp CR, Added Cisco WebEx VDI
15/12: Wrong download path for Citrix Files
02/01: Office download error, FoxIt-Reader version not found
02/01: Added MS Visual Redistributable packages
04/01: Added SplashScreen, check for SplashScreen Powershell module and load from GitHub of not present
05/01: Foxit Reader had wrong file extensionm changed to msi
11/01: Changed MS Visual Redistributable download url
02/16: No error message if Splashscreen cannot be loaded
03/23: Added ShareX
04/11: Added KeepassXC
04/24: Changed Oracle Java version check
04/26: Delete Office download data older 40 days, changed regex for Cisco WebEx VDI
05/30: Changed regex for pdf24Creator, changed WinSCP download type, changed PuTTY source to Evergreen
06/13: Changed RemoteDesktopManager URL, added MS EdgeWebView2 to Citrix WorkspaceApp LTSR
06/29: Changed Filezilla URL because of error 403
23/07/17: Added WinRAR de and en
23/09/04: Citrix Files corrected
23/09/11: WinRAR corrected 
23/09/18: Chrome corrected
23/09/29: MS Teams corrected
23/10/06: Better internet connection check
23/10/08: Changed Citrix VM Tools (not in Evergreen anymore), added Citrix XenCenter
23/10/11: Added MS .NET Desktop Runtime as a requirement for Citrix WorkspaceApp CR
23/11/20: Second internet connection check
23/11/22: Added MS .NET Desktop Runtime 6.0.20 as a requirement for Citrix WorkspaceApp CR
23/12/05: Fixed FSLogix download and expand archive error
24/01/23: Version check for XenCenter and Citrix VM Tools corrected
24/02/15: New FSLogix version
24/04/10: Changed MS Teams classic
24/04/25: Added MS .NET DesktopRuntime 8.4.0 for Remote Desktop Manager
24/05/02: Fixed KeePass, 7-Zip and OneDrive
24/07/22: Fixed Citrix WorkspaceApp, Sharefile, 7-Zip and VLC Player, added NEW MS Teams 2.x
24/07/23: Fixed FileZilla, replaced openJDK with Microsoft openJDK 
24/07/23: Added Zoom VDI client and Citrix HDX plugin, added ControlUp console and ControlUp DX client for Windows
24/08/26: Changed Citrix WorkspaceApp LTSR (.NET Desktop runtime)
24/09/12: Fix for Chrome version bug, version now provided by PatchmyPC
24/10/11: Changed WorkspaceApp LTSR .NET Desktop Runtime to version 8.0.10, added Teams 2.0 logon script
24/11/07: Changed CiscoWebEx, currently not available
24/11/13: Changed pdf24Creator download link
24/11/19: Changed VLC Player version and download information to PatchMyPC
24/12/16: Changed .NET Desktop Runtime for CR WorkspaceApp to version 8.10
25/01/03: Changed WinSCP and WINRAR download and version source, removed ShareFile
25/02/07: Added Microsoft Office LTSC 2024, fixed MS Powershell
25/02/12: Changed FSLogix version detection for new FSLogix release
25/02/18: New app design
25/02/21: Added Mozilla Firefox
25/02/24: Changed FSLogix version to match with installed version
25/02/07: Added Firefox de/us language
25/04/10: Added .NET 9.0 Desktop Runtime (v9.0.4) for Remote Desktop Manager
25/04/14: Added new FSLogix version 25.04, Windows Desktop-Runtime-8.0.11 (for Citrix WorkspaceApp)
25/06/10: Removed deviceTRUST (now part of VDA 2503), temporarly removed SQL Management Studio (SMSS), fixed download link for XenServer VM Tools
25/06/26: Fixed MS Edge version check
25/07/31: Added MS .NET 8.0 Desktop Runtime (v8.0.18) for Citrix WorkspaceApp
25/08/04: Fixed download failure for .NET Runtime 8.0.18
25/08/21: Removed MS Teams, Sharefile, fixed Google Chrome
25/08/28: Fixed version issue with MS openJDK
25/09/03: Added MS Teams VDI Plugin to Citrix WorkspaceApp
25/10/08: Temporarly removed MS Sysinternals, new FSLogix version
25/11/07: Added Update-Evergreen command
25/12/08: Fixed MS Visual C++ downloads
26/01/13: Added MS .NET 8.0 Desktop Runtime (v8.0.18) for Citrix WorkspaceApp LTSR, added RD Analyzer
26/01/27: Changed XenServer VM Tools to 9.4.2
26/03/11: Added MS Visual Studio Code and MS .Net Runtime 8.x LTS
26/03/16: Added MS SQL Management Studio 22 (Visual Studio Installer)
26/03/25: Added .NET Desktop Runtime 8.25 for Citrix WorkspaceApp
26/04/15: Changed Adobe Reader DC Evergreen syntax
26/05/12: MS 365 Apps semi anual channel is not available anymore, please switch to monthly anual channel and create a new configuration XML file
26/05/26: Added .NET Desktop Runtime (v10.0.8) for Remote Desktop Manager
26/06/11: Added MS .Net Runtime 10.x LTS
26/07/13: Updates Citrix VMTools 9.6.0 (delete folder content to force update, because of old version)
26/08/27: Bugfixes
26/09/15: Added MS .NET Desktop Runtime 10.0.12 for Citrix WorkspaceApp LTSR 2607
26/09/21: Update FSLogix 3.26.826.17182
26/10/20: Wrong download name for MS .NET Desktop Runtime 10.0.12, changed to WindowsDesktopRuntime-10.0.12-win-x86.exe
26/10/21: Fixed ImageGlass download
26/10/23: Version 3.0 with complete redesign, fixed download for XenCenter and VM Tools
# Notes
#>
Param (
		[Parameter(
            HelpMessage='Start the Gui to select the Software',
            ValuefromPipelineByPropertyName = $true
        )]
        [switch]$noGUI,

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
[version]$EvergreenVersion = "3.0.2"


# ======================
# Startup window
# ======================
$script:StartupUiEnabled = -not $NoGUI
$script:StartupForm = $null
$script:StartupLogo = $null
$script:StartupLogoDisplay = $null

function New-EvergreenLogo {
	try {
		$LogoPath = Join-Path $PSScriptRoot "Shortcut\Software_Update_Download.png"
		if (-not (Test-Path -LiteralPath $LogoPath -PathType Leaf)) { return $null }
		$SourceImage = [System.Drawing.Image]::FromFile($LogoPath)
		try { return [System.Drawing.Bitmap]::new($SourceImage) }
		finally { $SourceImage.Dispose() }
	}
	catch { return $null }
}

function New-EvergreenIcon {
	try {
		$IconPath = Join-Path $PSScriptRoot "Shortcut\Software_Update_Download.ico"
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
		$Form.Text = "Software Updater $EvergreenVersion"
		$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
		$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
		$Form.Size = New-Object System.Drawing.Size(760,400)
		$Form.BackColor = [System.Drawing.Color]::FromArgb(242,247,251)
		$Form.ShowInTaskbar = $true
		$StartupFormIcon = New-EvergreenIcon
		if ($null -ne $StartupFormIcon) { $Form.Icon = $StartupFormIcon }

		$Title = New-Object System.Windows.Forms.Label
		$Title.Text = "Software Updater"
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
		$RestartArguments = "-NoLogo -NoProfile -NonInteractive -WindowStyle Hidden -File `"$PSCommandPath`" -SkipUpdateCheck -UpdateHealthCheckPath `"$HealthPath`" -UpdateHealthCheckToken $HealthToken"
		$RestartProcess = Start-Process -FilePath $PowerShellExecutable -ArgumentList $RestartArguments -WindowStyle Hidden -PassThru -ErrorAction Stop
		Set-StartupStatus "Verifying the updated $ProductKey..." "The updated script is starting in a hidden PowerShell process. The previous script remains available in _Update Backups."
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

# FUNCTION Download progress
#========================================================================================================================================

function Get-FileFromWeb {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$URL,
  
        # Parameter help description
        [Parameter(Mandatory)]
        [string]$File 
    )
    Begin {
        function Show-Progress {
            param (
                # Enter total value
                [Parameter(Mandatory)]
                [Single]$TotalValue,
        
                # Enter current value
                [Parameter(Mandatory)]
                [Single]$CurrentValue,
        
                # Enter custom progresstext
                [Parameter(Mandatory)]
                [string]$ProgressText,
        
                # Enter value suffix
                [Parameter()]
                [string]$ValueSuffix,
        
                # Enter bar lengh suffix
                [Parameter()]
                [int]$BarSize = 40,

                # show complete bar
                [Parameter()]
                [switch]$Complete
            )
            
            # calc %
            $percent = $CurrentValue / $TotalValue
            $percentComplete = $percent * 100
            if ($ValueSuffix) {
                $ValueSuffix = " $ValueSuffix" # add space in front
            }
            if ($psISE) {
                Write-Progress "$ProgressText $CurrentValue$ValueSuffix of $TotalValue$ValueSuffix" -id 0 -percentComplete $percentComplete            
            }
            else {
                # build progressbar with string function
                $curBarSize = $BarSize * $percent
                $progbar = ""
                $progbar = $progbar.PadRight($curBarSize,[char]9608)
                $progbar = $progbar.PadRight($BarSize,[char]9617)
        
                if (!$Complete.IsPresent) {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($CurrentValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"
                }
                else {
                    Write-Host -NoNewLine "`r$ProgressText $progbar [ $($TotalValue.ToString("#.###").PadLeft($TotalValue.ToString("#.###").Length))$ValueSuffix / $($TotalValue.ToString("#.###"))$ValueSuffix ] $($percentComplete.ToString("##0.00").PadLeft(6)) % complete"                    
                }                
            }   
        }
    }
    Process {
        try {
            $storeEAP = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
        
            # invoke request
            $request = [System.Net.HttpWebRequest]::Create($URL)
            $response = $request.GetResponse()
  
            if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) {
                throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'."
            }
  
            if($File -match '^\.\\') {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") ($File -Split '^\.')[1]
            }
            
            if($File -and !(Split-Path $File)) {
                $File = Join-Path (Get-Location -PSProvider "FileSystem") $File
            }

            if ($File) {
                $fileDirectory = $([System.IO.Path]::GetDirectoryName($File))
                if (!(Test-Path($fileDirectory))) {
                    [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
                }
            }

            [long]$fullSize = $response.ContentLength
            $fullSizeMB = $fullSize / 1024 / 1024
  
            # define buffer
            [byte[]]$buffer = new-object byte[] 1048576
            [long]$total = [long]$count = 0
  
            # create reader / writer
            $reader = $response.GetResponseStream()
            $writer = new-object System.IO.FileStream $File, "Create"
  
            # start download
            $finalBarCount = 0 #show final bar only one time
            do {
          
                $count = $reader.Read($buffer, 0, $buffer.Length)
          
                $writer.Write($buffer, 0, $count)
              
                $total += $count
                $totalMB = $total / 1024 / 1024
          
                if ($fullSize -gt 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "Downloading $($File.Name)" -ValueSuffix "MB"
                }

                if ($total -eq $fullSize -and $count -eq 0 -and $finalBarCount -eq 0) {
                    Show-Progress -TotalValue $fullSizeMB -CurrentValue $totalMB -ProgressText "Downloading $($File.Name)" -ValueSuffix "MB" -Complete
                    $finalBarCount++
                    #Write-Host "$finalBarCount"
                }

            } while ($count -gt 0)
        }
  
        catch {
            $ExeptionMsg = $_.Exception.Message
            $StatusCode = $null
            if ($null -ne $_.Exception.Response -and $null -ne $_.Exception.Response.StatusCode) {
                try { $StatusCode = [int]$_.Exception.Response.StatusCode } catch { $StatusCode = $null }
            }
            $StatusText = if ($null -ne $StatusCode) { " HTTP=$StatusCode" } else { "" }
            Write-Host -ForegroundColor Red "Download breaks with error:$StatusText $ExeptionMsg"
            Write-Host -ForegroundColor DarkGray "Source: $URL"
            Write-Host -ForegroundColor DarkGray "Target: $File"
            # Deliberately non-terminating: continue with the next product.
        }
  
        finally {
            # cleanup
            if ($reader) { $reader.Close() }
            if ($writer) { $writer.Flush(); $writer.Close() }
        
            $ErrorActionPreference = $storeEAP
            [GC]::Collect()
        }    
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
    $Form.text = "Software-Updater $EvergreenVersion"
    $Form.TopMost = $false
	$Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
	$Form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
	$FormIconPath = Join-Path $PSScriptRoot "Shortcut\Software_Update_Download.ico"
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

	# Draw the updater header icon in memory. No Base64 data or external image file is required.
	$NewUpdaterHeaderIcon = {
		$Bitmap = New-Object System.Drawing.Bitmap -ArgumentList 56,56
		$Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
		$Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
		$Graphics.Clear([System.Drawing.Color]::Transparent)
		$BoxBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(224,169,72))
		$TopBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(245,205,117))
		$BlueBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(38,124,218))
		$WhiteBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
		$BoxPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(79,57,25)),1.5
		$BluePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(20,81,155)),1.5
		$ArrowPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White),3
		try {
			$Graphics.FillRectangle($BoxBrush,6,14,35,31)
			$Graphics.DrawRectangle($BoxPen,6,14,35,31)
			$TopPoints = [System.Drawing.Point[]]@(
				[System.Drawing.Point]::new(6,14),
				[System.Drawing.Point]::new(14,6),
				[System.Drawing.Point]::new(48,6),
				[System.Drawing.Point]::new(41,14)
			)
			$Graphics.FillPolygon($TopBrush,$TopPoints)
			$Graphics.DrawPolygon($BoxPen,$TopPoints)
			$Graphics.FillEllipse($BlueBrush,31,28,23,23)
			$Graphics.DrawEllipse($BluePen,31,28,23,23)
			$ArrowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
			$ArrowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
			$Graphics.DrawLine($ArrowPen,42,33,42,42)
			$ArrowPoints = [System.Drawing.Point[]]@(
				[System.Drawing.Point]::new(36,40),
				[System.Drawing.Point]::new(42,46),
				[System.Drawing.Point]::new(48,40)
			)
			$Graphics.FillPolygon($WhiteBrush,$ArrowPoints)
		}
		finally {
			$ArrowPen.Dispose(); $BluePen.Dispose(); $BoxPen.Dispose()
			$WhiteBrush.Dispose(); $BlueBrush.Dispose(); $TopBrush.Dispose(); $BoxBrush.Dispose()
			$Graphics.Dispose()
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
    $Headline2.text = "Select Software to download"
    $Headline2.AutoSize = $true
    $Headline2.width = 25
    $Headline2.height = 10
    $Headline2.location = New-Object System.Drawing.Point(11,4)
    $form.Controls.Add($Headline2)
	$Headline2.Font = $FontBold

	$form.Controls.Add($Headline2)

	# NotePadPlusPlus Checkbox
    $NotePadPlusPlusBox = New-Object system.Windows.Forms.CheckBox
    $NotePadPlusPlusBox.text = "NotePad++"
    $NotePadPlusPlusBox.width = 95
    $NotePadPlusPlusBox.height = 20
    $NotePadPlusPlusBox.autosize = $true
	$NotePadPlusPlusBox.Font = $Font
    $NotePadPlusPlusBox.location = New-Object System.Drawing.Point(11,45)
    $form.Controls.Add($NotePadPlusPlusBox)
	$NotePadPlusPlusBox.Checked = $SoftwareSelection.NotePadPlusPlus
	
    # 7Zip Checkbox
    $SevenZipBox = New-Object system.Windows.Forms.CheckBox
    $SevenZipBox.text = "7 Zip"
    $SevenZipBox.width = 95
    $SevenZipBox.height = 20
    $SevenZipBox.autosize = $true
	$SevenZipBox.Font = $Font
    $SevenZipBox.location = New-Object System.Drawing.Point(11,70)
    $form.Controls.Add($SevenZipBox)
	$SevenZipBox.Checked = $SoftwareSelection.SevenZip

    # AdobeReaderDC Checkbox
    $AdobeReaderDCBoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCBoxUpdate.text = "Adobe Reader DC MUI x86"
    $AdobeReaderDCBoxUpdate.width = 95
    $AdobeReaderDCBoxUpdate.height = 20
    $AdobeReaderDCBoxUpdate.autosize = $true
	$AdobeReaderDCBoxUpdate.Font = $Font
    $AdobeReaderDCBoxUpdate.location = New-Object System.Drawing.Point(11,95)
    $form.Controls.Add($AdobeReaderDCBoxUpdate)
	$AdobeReaderDCBoxUpdate.Checked = $SoftwareSelection.AdobeReaderDC_MUI
	
	# AdobeReaderDCx64 Checkbox
    $AdobeReaderDCx64BoxUpdate = New-Object system.Windows.Forms.CheckBox
    $AdobeReaderDCx64BoxUpdate.text = "Adobe Reader DC MUI x64"
    $AdobeReaderDCx64BoxUpdate.width = 95
    $AdobeReaderDCx64BoxUpdate.height = 20
    $AdobeReaderDCx64BoxUpdate.autosize = $true
	$AdobeReaderDCx64BoxUpdate.Font = $Font
    $AdobeReaderDCx64BoxUpdate.location = New-Object System.Drawing.Point(11,120)
    $form.Controls.Add($AdobeReaderDCx64BoxUpdate)
	$AdobeReaderDCx64BoxUpdate.Checked = $SoftwareSelection.AdobeReaderDCx64_MUI

    # BISF Checkbox
    $BISFBox = New-Object system.Windows.Forms.CheckBox
    $BISFBox.text = "BIS-F"
    $BISFBox.width = 95
    $BISFBox.height = 20
    $BISFBox.autosize = $true
	$BISFBox.Font = $Font
    $BISFBox.location = New-Object System.Drawing.Point(11,145)
    $form.Controls.Add($BISFBox)
	$BISFBox.Checked = $SoftwareSelection.BISF
	
	# FSLogix Checkbox
    $FSLogixBox = New-Object system.Windows.Forms.CheckBox
    $FSLogixBox.text = "FSLogix"
    $FSLogixBox.width = 95
    $FSLogixBox.height = 20
    $FSLogixBox.autosize = $true
	$FSLogixBox.Font = $Font
    $FSLogixBox.location = New-Object System.Drawing.Point(11,170)
    $form.Controls.Add($FSLogixBox)
	$FSLogixBox.Checked = $SoftwareSelection.FSLogix

    # GoogleChrome Checkbox
    $GoogleChromeBox = New-Object system.Windows.Forms.CheckBox
    $GoogleChromeBox.text = "Google Chrome"
    $GoogleChromeBox.width = 95
    $GoogleChromeBox.height = 20
    $GoogleChromeBox.autosize = $true
	$GoogleChromeBox.Font = $Font
    $GoogleChromeBox.location = New-Object System.Drawing.Point(11,195)
    $form.Controls.Add($GoogleChromeBox)
	$GoogleChromeBox.Checked = $SoftwareSelection.GoogleChrome

    # Citrix WorkspaceApp_Current_Release Checkbox
    $WorkspaceApp_CRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_CRBox.text = "Citrix WorkspaceApp CR"
    $WorkspaceApp_CRBox.width = 95
    $WorkspaceApp_CRBox.height = 20
    $WorkspaceApp_CRBox.autosize = $true
	$WorkspaceApp_CRBox.Font = $Font
    $WorkspaceApp_CRBox.location = New-Object System.Drawing.Point(11,220)
    $form.Controls.Add($WorkspaceApp_CRBox)
	$WorkspaceApp_CRBox.Checked = $SoftwareSelection.WorkspaceApp_CR

    # Citrix WorkspaceApp_LTSR_Release Checkbox
    $WorkspaceApp_LTSRBox = New-Object system.Windows.Forms.CheckBox
    $WorkspaceApp_LTSRBox.text = "Citrix WorkspaceApp LTSR"
    $WorkspaceApp_LTSRBox.width = 95
    $WorkspaceApp_LTSRBox.height = 20
    $WorkspaceApp_LTSRBox.autosize = $true
	$WorkspaceApp_LTSRBox.Font = $Font
    $WorkspaceApp_LTSRBox.location = New-Object System.Drawing.Point(11,245)
    $form.Controls.Add($WorkspaceApp_LTSRBox)
	$WorkspaceApp_LTSRBox.Checked = $SoftwareSelection.WorkspaceApp_LTSR
	
	# Citrix VM Tools Checkbox
    $Citrix_VMToolsBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_VMToolsBox.text = "Citrix VM Tools (Windows)"
    $Citrix_VMToolsBox.width = 95
    $Citrix_VMToolsBox.height = 20
    $Citrix_VMToolsBox.autosize = $true
	$Citrix_VMToolsBox.Font = $Font
    $Citrix_VMToolsBox.location = New-Object System.Drawing.Point(11,270)
    $form.Controls.Add($Citrix_VMToolsBox)
	$Citrix_VMToolsBox.Checked = $SoftwareSelection.CitrixVMTools
	
	# Citrix XenCenter Checkbox
    $Citrix_XenCenterBox = New-Object system.Windows.Forms.CheckBox
    $Citrix_XenCenterBox.text = "Citrix XenCenter"
	$Citrix_XenCenterBox.width = 95
    $Citrix_XenCenterBox.height = 20
    $Citrix_XenCenterBox.autosize = $true
	$Citrix_XenCenterBox.Font = $Font
    $Citrix_XenCenterBox.location = New-Object System.Drawing.Point(11,295)
    $form.Controls.Add($Citrix_XenCenterBox)
	$Citrix_XenCenterBox.Checked = $SoftwareSelection.CitrixXenCenter
	
	# FileZilla Checkbox
    $FileZillaBox = New-Object system.Windows.Forms.CheckBox
    $FileZillaBox.text = "FileZilla Client"
    $FileZillaBox.width = 95
    $FileZillaBox.height = 20
    $FileZillaBox.autosize = $true
	$FileZillaBox.Font = $Font
    $FileZillaBox.location = New-Object System.Drawing.Point(11,320)
    $form.Controls.Add($FileZillaBox)
	$FileZillaBox.Checked =  $SoftwareSelection.FileZilla
		
	# VMWareTools Checkbox
    $VMWareToolsBox = New-Object system.Windows.Forms.CheckBox
    $VMWareToolsBox.text = "VMWare Tools"
    $VMWareToolsBox.width = 95
    $VMWareToolsBox.height = 20
    $VMWareToolsBox.autosize = $true
	$VMWareToolsBox.Font = $Font
    $VMWareToolsBox.location = New-Object System.Drawing.Point(11,345)
    $form.Controls.Add($VMWareToolsBox)
	$VMWareToolsBox.Checked = $SoftwareSelection.VMWareTools

    # Remote Desktop Manager Checkbox
    $RemoteDesktopManagerBox = New-Object system.Windows.Forms.CheckBox
    $RemoteDesktopManagerBox.text = "Remote Desktop Manager Free"
    $RemoteDesktopManagerBox.width = 95
    $RemoteDesktopManagerBox.height = 20
    $RemoteDesktopManagerBox.autosize = $true
	$RemoteDesktopManagerBox.Font = $Font
    $RemoteDesktopManagerBox.location = New-Object System.Drawing.Point(11,370)
    $form.Controls.Add($RemoteDesktopManagerBox)
	$RemoteDesktopManagerBox.Checked = $SoftwareSelection.RemoteDesktopManager

    # mRemoteNG Checkbox
    $mRemoteNGBox = New-Object system.Windows.Forms.CheckBox
    $mRemoteNGBox.text = "mRemoteNG"
    $mRemoteNGBox.width = 95
    $mRemoteNGBox.height = 20
    $mRemoteNGBox.autosize = $true
	$mRemoteNGBox.Font = $Font
    $mRemoteNGBox.location = New-Object System.Drawing.Point(11,395)
    $form.Controls.Add($mRemoteNGBox)
	$mRemoteNGBox.Checked = $SoftwareSelection.mRemoteNG
	
	# WinSCP Checkbox
    $WinSCPBox = New-Object system.Windows.Forms.CheckBox
    $WinSCPBox.text = "WinSCP"
    $WinSCPBox.width = 95
    $WinSCPBox.height = 20
    $WinSCPBox.autosize = $true
	$WinSCPBox.Font = $Font
    $WinSCPBox.location = New-Object System.Drawing.Point(11,420)
    $form.Controls.Add($WinSCPBox)
	$WinSCPBox.Checked = $SoftwareSelection.WinSCP
	
	# Putty Checkbox
    $PuttyBox = New-Object system.Windows.Forms.CheckBox
    $PuttyBox.text = "Putty"
    $PuttyBox.width = 95
    $PuttyBox.height = 20
    $PuttyBox.autosize = $true
	$PuttyBox.Font = $Font
    $PuttyBox.location = New-Object System.Drawing.Point(11,445)
    $form.Controls.Add($PuttyBox)
	$PuttyBox.Checked = $SoftwareSelection.Putty
	
	# OracleJava8 x64 Checkbox
    $OracleJava8Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8Box.text = "Oracle Java 8/x64"
    $OracleJava8Box.width = 95
    $OracleJava8Box.height = 20
    $OracleJava8Box.autosize = $true
	$OracleJava8Box.Font = $Font
    $OracleJava8Box.location = New-Object System.Drawing.Point(11,470)
    $form.Controls.Add($OracleJava8Box)
	$OracleJava8Box.Checked =  $SoftwareSelection.OracleJava8
	
	# OracleJava8 x86 Checkbox
    $OracleJava8_32Box = New-Object system.Windows.Forms.CheckBox
    $OracleJava8_32Box.text = "Oracle Java 8/x86"
    $OracleJava8_32Box.width = 95
    $OracleJava8_32Box.height = 20
    $OracleJava8_32Box.autosize = $true
	$OracleJava8_32Box.Font = $Font
    $OracleJava8_32Box.location = New-Object System.Drawing.Point(11,495)
    $form.Controls.Add($OracleJava8_32Box)
	$OracleJava8_32Box.Checked =  $SoftwareSelection.OracleJava8_32

    # MS365 Apps Semi Annual Channel Checkbox
    $MS365AppsBox_SAC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_SAC.text = "Microsoft 365 Apps (x64/Semi Annual Channel)"
    $MS365AppsBox_SAC.width = 95
    $MS365AppsBox_SAC.height = 20
    $MS365AppsBox_SAC.autosize = $true
	$CustomFont = [System.Drawing.Font]::new("Arial",10, [System.Drawing.FontStyle]::Strikeout)
	#$MS365AppsBox_SAC.Font = $Font
	$MS365AppsBox_SAC.Font = $CustomFont
    $MS365AppsBox_SAC.location = New-Object System.Drawing.Point(250,45)
    $form.Controls.Add($MS365AppsBox_SAC)
	$MS365AppsBox_SAC.Checked = $SoftwareSelection.MS365Apps_SAC
	
	# MS365 Apps Monthly Enterprise Channel Checkbox
    $MS365AppsBox_MEC = New-Object system.Windows.Forms.CheckBox
    $MS365AppsBox_MEC.text = "Microsoft 365 Apps (x64/Monthly Enterprise Channel)"
    $MS365AppsBox_MEC.width = 95
    $MS365AppsBox_MEC.height = 20
    $MS365AppsBox_MEC.autosize = $true
	$MS365AppsBox_MEC.Font = $Font
    $MS365AppsBox_MEC.location = New-Object System.Drawing.Point(250,70)
    $form.Controls.Add($MS365AppsBox_MEC)
	$MS365AppsBox_MEC.Checked = $SoftwareSelection.MS365Apps_MEC

	# MS Office2019 Checkbox
    $MSOffice2019Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2019Box.text = "Microsoft Office 2019 (x64/Perpetual VL)"
    $MSOffice2019Box.width = 95
    $MSOffice2019Box.height = 20
    $MSOffice2019Box.autosize = $true
	$MSOffice2019Box.Font = $Font
    $MSOffice2019Box.location = New-Object System.Drawing.Point(250,95)
    $form.Controls.Add($MSOffice2019Box)
	$MSOffice2019Box.Checked = $SoftwareSelection.MSOffice2019
	
	# MS Office2021 Checkbox
    $MSOffice2021Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2021Box.text = "Microsoft Office 2021 (x64/Perpetual VL)"
    $MSOffice2021Box.width = 95
    $MSOffice2021Box.height = 20
    $MSOffice2021Box.autosize = $true
	$MSOffice2021Box.Font = $Font
    $MSOffice2021Box.location = New-Object System.Drawing.Point(250,120)
    $form.Controls.Add($MSOffice2021Box)
	$MSOffice2021Box.Checked = $SoftwareSelection.MSOffice2021
	
	# MS Office2024 Checkbox
    $MSOffice2024Box = New-Object system.Windows.Forms.CheckBox
    $MSOffice2024Box.text = "Microsoft Office 2024 (x64/Perpetual VL)"
    $MSOffice2024Box.width = 95
    $MSOffice2024Box.height = 20
    $MSOffice2024Box.autosize = $true
	$MSOffice2024Box.Font = $Font
    $MSOffice2024Box.location = New-Object System.Drawing.Point(250,145)
    $form.Controls.Add($MSOffice2024Box)
	$MSOffice2024Box.Checked = $SoftwareSelection.MSOffice2024
	
	
	# MS Sysinternals Checkbox
    $MSSysinternalsBox = New-Object system.Windows.Forms.CheckBox
    $MSSysinternalsBox.text = "Microsoft Sysinternals Suite"
    $MSSysinternalsBox.width = 95
    $MSSysinternalsBox.height = 20
    $MSSysinternalsBox.autosize = $true
	$CustomFont = [System.Drawing.Font]::new("Arial",10, [System.Drawing.FontStyle]::Strikeout)
	$MSSysinternalsBox.Font = $CustomFont
	#$MSSysinternalsBox.Font = $Font
    $MSSysinternalsBox.location = New-Object System.Drawing.Point(250,170)
    $form.Controls.Add($MSSysinternalsBox)
	$MSSysinternalsBox.Checked = $SoftwareSelection.MSSysinternals
	
    # MS Edge Checkbox
    $MSEdgeBox = New-Object system.Windows.Forms.CheckBox
    $MSEdgeBox.text = "Microsoft Edge (Stable Channel)"
    $MSEdgeBox.width = 95
    $MSEdgeBox.height = 20
    $MSEdgeBox.autosize = $true
	$MSEdgeBox.Font = $Font
    $MSEdgeBox.location = New-Object System.Drawing.Point(250,195)
    $form.Controls.Add($MSEdgeBox)
	$MSEdgeBox.Checked = $SoftwareSelection.MSEdge

    # MS OneDrive Checkbox
    $MSOneDriveBox = New-Object system.Windows.Forms.CheckBox
    $MSOneDriveBox.text = "Microsoft OneDrive (Machine-Based Install)"
    $MSOneDriveBox.width = 95
    $MSOneDriveBox.height = 20
    $MSOneDriveBox.autosize = $true
	$MSOneDriveBox.Font = $Font
    $MSOneDriveBox.location = New-Object System.Drawing.Point(250,220)
    $form.Controls.Add($MSOneDriveBox)
	$MSOneDriveBox.Checked = $SoftwareSelection.MSOneDrive
	
	# NEW MS Teams Checkbox
    $NEWMSTeamsBox = New-Object system.Windows.Forms.CheckBox
    $NEWMSTeamsBox.text = "Microsoft Teams 2.x (Boostrapper MSIX)"
    $NEWMSTeamsBox.width = 95
    $NEWMSTeamsBox.height = 20
    $NEWMSTeamsBox.autosize = $true
	$NEWMSTeamsBox.Font = $Font
    $NEWMSTeamsBox.location = New-Object System.Drawing.Point(250,245)
    $form.Controls.Add($NEWMSTeamsBox)
	$NEWMSTeamsBox.Checked = $SoftwareSelection.NEWMSTeams
	
	# MS VcRedist Checkbox
    $VcRedistBox = New-Object system.Windows.Forms.CheckBox
    $VcRedistBox.text = "Microsoft Visual C++ Redistributable"
    $VcRedistBox.width = 95
    $VcRedistBox.height = 20
    $VcRedistBox.autosize = $true
	$VcRedistBox.Font = $Font
    $VcRedistBox.location = New-Object System.Drawing.Point(250,270)
    $form.Controls.Add($VcRedistBox)
	$VcRedistBox.Checked = $SoftwareSelection.VcRedist
	
	 # MS Powershell Checkbox
    $MSPowershellBox = New-Object system.Windows.Forms.CheckBox
    $MSPowershellBox.text = "Microsoft Powershell"
    $MSPowershellBox.width = 95
    $MSPowershellBox.height = 20
    $MSPowershellBox.autosize = $true
	$MSPowershellBox.Font = $Font
    $MSPowershellBox.location = New-Object System.Drawing.Point(250,295)
    $form.Controls.Add($MSPowershellBox)
	$MSPowershellBox.Checked = $SoftwareSelection.MSPowershell
	
	# MS DotNet Checkbox
    $MSDotNetRuntimeBox = New-Object system.Windows.Forms.CheckBox
    $MSDotNetRuntimeBox.text = "Microsoft .Net Runtime 10.x"
    $MSDotNetRuntimeBox.width = 95
    $MSDotNetRuntimeBox.height = 20
    $MSDotNetRuntimeBox.autosize = $true
	$MSDotNetRuntimeBox.Font = $Font
    $MSDotNetRuntimeBox.location = New-Object System.Drawing.Point(250,320)
    $form.Controls.Add($MSDotNetRuntimeBox)
	$MSDotNetRuntimeBox.Checked = $SoftwareSelection.MSDotNetDesktopRuntime
	
	# MS DotNet Runtime Checkbox
    $MSDotNetDesktopRuntimeBox = New-Object system.Windows.Forms.CheckBox
    $MSDotNetDesktopRuntimeBox.text = "Microsoft .Net Desktop Runtime 8.x"
    $MSDotNetDesktopRuntimeBox.width = 95
    $MSDotNetDesktopRuntimeBox.height = 20
    $MSDotNetDesktopRuntimeBox.autosize = $true
	$MSDotNetDesktopRuntimeBox.Font = $Font
    $MSDotNetDesktopRuntimeBox.location = New-Object System.Drawing.Point(250,345)
    $form.Controls.Add($MSDotNetDesktopRuntimeBox)
	$MSDotNetDesktopRuntimeBox.Checked = $SoftwareSelection.MSDotNetRuntime
	
	# MS SQL Management Studio EN Checkbox
    $MSSQLManagementStudioENBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioENBox.text = "Microsoft SQL Management Studio EN"
	#$CustomFont = [System.Drawing.Font]::new("Arial",10, [System.Drawing.FontStyle]::Strikeout)
    $MSSQLManagementStudioENBox.width = 95
    $MSSQLManagementStudioENBox.height = 20
    $MSSQLManagementStudioENBox.autosize = $true
	#$MSSQLManagementStudioENBox.Font = $CustomFont
	$MSSQLManagementStudioENBox.Font = $Font
    $MSSQLManagementStudioENBox.location = New-Object System.Drawing.Point(250,370)
    $form.Controls.Add($MSSQLManagementStudioENBox)
	$MSSQLManagementStudioENBox.Checked = $SoftwareSelection.MSSsmsEN
	
	# MS SQL Management Studio DE Checkbox
    $MSSQLManagementStudioDEBox = New-Object system.Windows.Forms.CheckBox
    $MSSQLManagementStudioDEBox.text = "Microsoft SQL Management Studio DE"
	#$CustomFont = [System.Drawing.Font]::new("Arial",10, [System.Drawing.FontStyle]::Strikeout)
    $MSSQLManagementStudioDEBox.width = 95
    $MSSQLManagementStudioDEBox.height = 20
    $MSSQLManagementStudioDEBox.autosize = $true
	#$MSSQLManagementStudioDEBox.Font = $CustomFont
	$MSSQLManagementStudioDEBox.Font = $Font
    $MSSQLManagementStudioDEBox.location = New-Object System.Drawing.Point(250,395)
    $form.Controls.Add($MSSQLManagementStudioDEBox)
	$MSSQLManagementStudioDEBox.Checked = $SoftwareSelection.MSSsmsDE
	
	# MicrosoftOpenJDK Checkbox
    $MicrosoftOpenJDKBox = New-Object system.Windows.Forms.CheckBox
    $MicrosoftOpenJDKBox.text = "Microsoft OpenJDK 21"
    $MicrosoftOpenJDKBox.width = 95
    $MicrosoftOpenJDKBox.height = 20
    $MicrosoftOpenJDKBox.autosize = $true
	$MicrosoftOpenJDKBox.Font = $Font
    $MicrosoftOpenJDKBox.location = New-Object System.Drawing.Point(250,420)
    $form.Controls.Add($MicrosoftOpenJDKBox)
	$MicrosoftOpenJDKBox.Checked =  $SoftwareSelection.MicrosoftOpenJDK
	
	# MSVisualStudioCode  Checkbox
    $MSVisualStudioCodeBox = New-Object system.Windows.Forms.CheckBox
    $MSVisualStudioCodeBox.text = "Microsoft Visual Studio Code"
    $MSVisualStudioCodeBox.width = 95
    $MSVisualStudioCodeBox.height = 20
    $MSVisualStudioCodeBox.autosize = $true
	$MSVisualStudioCodeBox.Font = $Font
    $MSVisualStudioCodeBox.location = New-Object System.Drawing.Point(250,445)
    $form.Controls.Add($MSVisualStudioCodeBox)
	$MSVisualStudioCodeBox.Checked =  $SoftwareSelection.MSVisualStudioCode 
	
	# pdf24Creator Checkbox
    $pdf24CreatorBox = New-Object system.Windows.Forms.CheckBox
    $pdf24CreatorBox.text = "pdf24Creator"
    $pdf24CreatorBox.width = 95
    $pdf24CreatorBox.height = 20
    $pdf24CreatorBox.autosize = $true
	$pdf24CreatorBox.Font = $Font
    $pdf24CreatorBox.location = New-Object System.Drawing.Point(250,470)
    $form.Controls.Add($pdf24CreatorBox)
	$pdf24CreatorBox.Checked =  $SoftwareSelection.pdf24Creator
	
	# Firefox Checkbox
    $FirefoxBox = New-Object system.Windows.Forms.CheckBox
    $FirefoxBox.text = "Mozilla Firefox"
    $FirefoxBox.width = 95
    $FirefoxBox.height = 20
    $FirefoxBox.autosize = $true
	$FirefoxBox.Font = $Font
    $FirefoxBox.location = New-Object System.Drawing.Point(250,495)
    $form.Controls.Add($FirefoxBox)
	$FirefoxBox.Checked =  $SoftwareSelection.Firefox
	
	# Firefox de Checkbox
    $FirefoxBoxDE = New-Object system.Windows.Forms.CheckBox
    $FirefoxBoxDE.text = "Mozilla Firefox (Deutsch)"
    $FirefoxBoxDE.width = 95
    $FirefoxBoxDE.height = 20
    $FirefoxBoxDE.autosize = $true
	$FirefoxBoxDE.Font = $Font
    $FirefoxBoxDE.location = New-Object System.Drawing.Point(375,495)
    $form.Controls.Add($FirefoxBoxDE)
	$FirefoxBoxDE.Checked =  $SoftwareSelection.FirefoxDE
	
	# Firefox en Checkbox
    $FirefoxBoxEN = New-Object system.Windows.Forms.CheckBox
    $FirefoxBoxEN.text = "Mozilla Firefox (Englisch)"
    $FirefoxBoxEN.width = 95
    $FirefoxBoxEN.height = 20
    $FirefoxBoxEN.autosize = $true
	$FirefoxBoxEN.Font = $Font
    $FirefoxBoxEN.location = New-Object System.Drawing.Point(425,495)
    $form.Controls.Add($FirefoxBoxEN)
	$FirefoxBoxEN.Checked =  $SoftwareSelection.FirefoxEN
	
	# KeePass Checkbox
    $KeePassBox = New-Object system.Windows.Forms.CheckBox
    $KeePassBox.text = "KeePass"
    $KeePassBox.width = 95
    $KeePassBox.height = 20
    $KeePassBox.autosize = $true
	$KeePassBox.Font = $Font
    $KeePassBox.location = New-Object System.Drawing.Point(660,45)
    $form.Controls.Add($KeePassBox)
	$KeePassBox.Checked = $SoftwareSelection.KeePass
	
	# KeePassXC Checkbox
    $KeePassXCBox = New-Object system.Windows.Forms.CheckBox
    $KeePassXCBox.text = "KeePassXC"
    $KeePassXCBox.width = 95
    $KeePassXCBox.height = 20
    $KeePassXCBox.autosize = $true
	$KeePassXCBox.Font = $Font
    $KeePassXCBox.location = New-Object System.Drawing.Point(660,70)
    $form.Controls.Add($KeePassXCBox)
	$KeePassXCBox.Checked = $SoftwareSelection.KeePassXC
	
	# WinRAR Checkbox
    $WinRARBox = New-Object system.Windows.Forms.CheckBox
    $WinRARBox.text = "WinRAR"
    $WinRARBox.width = 95
    $WinRARBox.height = 20
    $WinRARBox.autosize = $true
	$WinRARBox.Font = $Font
    $WinRARBox.location = New-Object System.Drawing.Point(660,95)
    $form.Controls.Add($WinRARBox)
	$WinRARBox.Checked =  $SoftwareSelection.WinRAR
	
	# Greenshot Checkbox
    $GreenshotBox = New-Object system.Windows.Forms.CheckBox
    $GreenshotBox.text = "Greenshot"
    $GreenshotBox.width = 95
    $GreenshotBox.height = 20
    $GreenshotBox.autosize = $true
	$GreenshotBox.Font = $Font
    $GreenshotBox.location = New-Object System.Drawing.Point(660,120)
    $form.Controls.Add($GreenshotBox)
	$GreenshotBox.Checked =  $SoftwareSelection.Greenshot
	
	# IGEL Universal Management Suite Checkbox
    $IGELUniversalManagementSuiteBox = New-Object system.Windows.Forms.CheckBox
    $IGELUniversalManagementSuiteBox.text = "IGEL Universal Management Suite"
    $IGELUniversalManagementSuiteBox.width = 95
    $IGELUniversalManagementSuiteBox.height = 20
    $IGELUniversalManagementSuiteBox.autosize = $true
	$IGELUniversalManagementSuiteBox.Font = $Font
    $IGELUniversalManagementSuiteBox.location = New-Object System.Drawing.Point(660,145)
    $form.Controls.Add($IGELUniversalManagementSuiteBox)
	$IGELUniversalManagementSuiteBox.Checked = $SoftwareSelection.IGELUniversalManagementSuite
	
	# ImageGlass Checkbox
    $ImageGlassBox = New-Object system.Windows.Forms.CheckBox
    $ImageGlassBox.text = "ImageGlass"
    $ImageGlassBox.width = 95
    $ImageGlassBox.height = 20
    $ImageGlassBox.autosize = $true
	$ImageGlassBox.Font = $Font
    $ImageGlassBox.location = New-Object System.Drawing.Point(660,170)
    $form.Controls.Add($ImageGlassBox)
	$ImageGlassBox.Checked =  $SoftwareSelection.ImageGlass
	
	# ShareX Checkbox
    $ShareXBox = New-Object system.Windows.Forms.CheckBox
    $ShareXBox.text = "ShareX"
    $ShareXBox.width = 95
    $ShareXBox.height = 20
    $ShareXBox.autosize = $true
	$ShareXBox.Font = $Font
    $ShareXBox.location = New-Object System.Drawing.Point(660,195)
    $form.Controls.Add($ShareXBox)
	$ShareXBox.Checked =  $SoftwareSelection.ShareX
	
	# TreeSizeFree Checkbox
    $TreeSizeFreeBox = New-Object system.Windows.Forms.CheckBox
    $TreeSizeFreeBox.text = "TreeSize Free for Client OS"
    $TreeSizeFreeBox.width = 95
    $TreeSizeFreeBox.height = 20
    $TreeSizeFreeBox.autosize = $true
	$TreeSizeFreeBox.Font = $Font
    $TreeSizeFreeBox.location = New-Object System.Drawing.Point(660,220)
    $form.Controls.Add($TreeSizeFreeBox)
	$TreeSizeFreeBox.Checked =  $SoftwareSelection.TreeSizeFree
	
	# ControlUpConsole Checkbox
    $ControlUpConsoleBox = New-Object system.Windows.Forms.CheckBox
    $ControlUpConsoleBox.text = "ControlUp Console"
    $ControlUpConsoleBox.width = 95
    $ControlUpConsoleBox.height = 20
    $ControlUpConsoleBox.autosize = $true
	$ControlUpConsoleBox.Font = $Font
    $ControlUpConsoleBox.location = New-Object System.Drawing.Point(660,245)
    $form.Controls.Add($ControlUpConsoleBox)
	$ControlUpConsoleBox.Checked =  $SoftwareSelection.ControlUpConsole
	
	# ControlUpRemoteDX Checkbox
    $ControlUpRemoteDXBox = New-Object system.Windows.Forms.CheckBox
    $ControlUpRemoteDXBox.text = "ControlUp DX client"
    $ControlUpRemoteDXBox.width = 95
    $ControlUpRemoteDXBox.height = 20
    $ControlUpRemoteDXBox.autosize = $true
	$ControlUpRemoteDXBox.Font = $Font
    $ControlUpRemoteDXBox.location = New-Object System.Drawing.Point(660,270)
    $form.Controls.Add($ControlUpRemoteDXBox)
	$ControlUpRemoteDXBox.Checked =  $SoftwareSelection.ControlUpRemoteDX
	
	<#
	# Cisco WebEx Desktop Checkbox
    $CiscoWebExDesktopBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExDesktopBox.text = "Cisco WebEx Desktop"
    $CiscoWebExDesktopBox.width = 95
    $CiscoWebExDesktopBox.height = 20
    $CiscoWebExDesktopBox.autosize = $true
    $CiscoWebExDesktopBox.location = New-Object System.Drawing.Point(250,420)
    $form.Controls.Add($CiscoWebExDesktopBox)
	$CiscoWebExDesktopBox.Checked =  $SoftwareSelection.CiscoWebExDesktop
	#>
	
	# Zoom Host Checkbox
    $ZoomVDIBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVDIBox.text = "Zoom VDI Host Installer"
	#$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    #$ZoomVDIBox.Font = $CustomFont
    $ZoomVDIBox.width = 95
    $ZoomVDIBox.height = 20
    $ZoomVDIBox.autosize = $true
	$ZoomVDIBox.Font = $Font
    $ZoomVDIBox.location = New-Object System.Drawing.Point(660,295)
    $form.Controls.Add($ZoomVDIBox)
	$ZoomVDIBox.Checked =  $SoftwareSelection.ZoomVDI
	
	# Zoom Citrix client Checkbox
    $ZoomCitrixBox = New-Object system.Windows.Forms.CheckBox
    $ZoomCitrixBox.text = "Zoom Citrix HDX Media Plugin"
	#$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    #$ZoomCitrixBox.Font = $CustomFont
    $ZoomCitrixBox.width = 95
    $ZoomCitrixBox.height = 20
    $ZoomCitrixBox.autosize = $true
	$ZoomCitrixBox.Font = $Font
    $ZoomCitrixBox.location = New-Object System.Drawing.Point(660,320)
    $form.Controls.Add($ZoomCitrixBox)
	$ZoomCitrixBox.Checked =  $SoftwareSelection.ZoomCitrix
	
	# Cisco WebEx VDI Plugin Checkbox
    $CiscoWebExVDIBox = New-Object system.Windows.Forms.CheckBox
    $CiscoWebExVDIBox.text = "Cisco WebEx VDI Plugin"
	$CustomFont = [System.Drawing.Font]::new("Arial",10, [System.Drawing.FontStyle]::Strikeout)
    $CiscoWebExVDIBox.Font = $CustomFont
    $CiscoWebExVDIBox.width = 95
    $CiscoWebExVDIBox.height = 20
    $CiscoWebExVDIBox.autosize = $true
	$CiscoWebExVDIBox.Font = $Font
    $CiscoWebExVDIBox.location = New-Object System.Drawing.Point(660,345)
    $form.Controls.Add($CiscoWebExVDIBox)
	$CiscoWebExVDIBox.Checked =  $SoftwareSelection.CiscoWebExVDI
	
	# RD Analyzer Checkbox
    $RDAnalyzerBox = New-Object system.Windows.Forms.CheckBox
    $RDAnalyzerBox.text = "RD Analyzer"
	$RDAnalyzerBox.width = 95
    $RDAnalyzerBox.height = 20
    $RDAnalyzerBox.autosize = $true
	$RDAnalyzerBox.Font = $Font
    $RDAnalyzerBox.location = New-Object System.Drawing.Point(660,370)
    $form.Controls.Add($RDAnalyzerBox)
	$RDAnalyzerBox.Checked =  $SoftwareSelection.RDAnalyzer
	
	# FoxItReader Checkbox
    $FoxItReaderBox = New-Object system.Windows.Forms.CheckBox
    $FoxItReaderBox.text = "FoxIt PDF Reader"
    $FoxItReaderBox.width = 95
    $FoxItReaderBox.height = 20
    $FoxItReaderBox.autosize = $true
	$CustomFont = [System.Drawing.Font]::new("Arial",10, [System.Drawing.FontStyle]::Strikeout)
	#$FoxitReaderBox.Font = $Font
	$FoxitReaderBox.Font = $CustomFont
    $FoxItReaderBox.location = New-Object System.Drawing.Point(660,395)
    $form.Controls.Add($FoxItReaderBox)
	$FoxItReaderBox.Checked =  $SoftwareSelection.FoxItReader
	
	# VLCPlayer Checkbox
    $VLCPlayerBox = New-Object system.Windows.Forms.CheckBox
    $VLCPlayerBox.text = "VLC Player"
    $VLCPlayerBox.width = 95
    $VLCPlayerBox.height = 20
    $VLCPlayerBox.autosize = $true
	$VLCPlayerBox.Font = $Font
    $VLCPlayerBox.location = New-Object System.Drawing.Point(660,420)
    $form.Controls.Add($VLCPlayerBox)
	$VLCPlayerBox.Checked =  $SoftwareSelection.VLCPlayer
	
	
	<#
	# Zoom VMWare client Checkbox
    $ZoomVMWareBox = New-Object system.Windows.Forms.CheckBox
    $ZoomVMWareBox.text = "Zoom VMWare Client (N/A)"
	$CustomFont = [System.Drawing.Font]::new("Arial",11, [System.Drawing.FontStyle]::Strikeout)
    $ZoomVMWareBox.Font = $CustomFont
    $ZoomVMWareBox.width = 95
    $ZoomVMWareBox.height = 20
    $ZoomVMWareBox.autosize = $true
    $ZoomVMWareBox.location = New-Object System.Drawing.Point(660,295)
    $form.Controls.Add($ZoomVMWareBox)
	$ZoomVMWareBox.Checked =  $SoftwareSelection.ZoomVMWare
	#>
		
	# Responsive category layout
	$SoftwareCheckBoxes = @(
		[PSCustomObject]@{ Control = $NotePadPlusPlusBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $SevenZipBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $AdobeReaderDCBoxUpdate; Category = "Standard" }
		[PSCustomObject]@{ Control = $AdobeReaderDCx64BoxUpdate; Category = "Standard" }
		[PSCustomObject]@{ Control = $GoogleChromeBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $FirefoxBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $FirefoxBoxDE; Category = "Standard" }
		[PSCustomObject]@{ Control = $FirefoxBoxEN; Category = "Standard" }
		[PSCustomObject]@{ Control = $VLCPlayerBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $FileZillaBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $pdf24CreatorBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $FoxItReaderBox; Category = "Standard" }
		[PSCustomObject]@{ Control = $FSLogixBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MS365AppsBox_SAC; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MS365AppsBox_MEC; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOffice2019Box; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOffice2021Box; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOffice2024Box; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSEdgeBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSOneDriveBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $NEWMSTeamsBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $VcRedistBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSPowershellBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSDotNetRuntimeBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSDotNetDesktopRuntimeBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSSQLManagementStudioENBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSSQLManagementStudioDEBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSSysinternalsBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MicrosoftOpenJDKBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $MSVisualStudioCodeBox; Category = "Microsoft" }
		[PSCustomObject]@{ Control = $RDAnalyzerBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $BISFBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WorkspaceApp_CRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $WorkspaceApp_LTSRBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $Citrix_VMToolsBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $Citrix_XenCenterBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ControlUpConsoleBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ControlUpRemoteDXBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $CiscoWebExVDIBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ZoomVDIBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ZoomCitrixBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $VMWareToolsBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $RemoteDesktopManagerBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $mRemoteNGBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $WinSCPBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $PuttyBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $OracleJava8Box; Category = "Utilities" }
		[PSCustomObject]@{ Control = $OracleJava8_32Box; Category = "Utilities" }
		[PSCustomObject]@{ Control = $KeePassBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $KeePassXCBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $WinRARBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $GreenshotBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $IGELUniversalManagementSuiteBox; Category = "Citrix" }
		[PSCustomObject]@{ Control = $ImageGlassBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $ShareXBox; Category = "Utilities" }
		[PSCustomObject]@{ Control = $TreeSizeFreeBox; Category = "Utilities" }
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
	$HeaderLogo.Image = & $NewUpdaterHeaderIcon
	$HeaderPanel.Controls.Add($HeaderLogo)

	$ProductTitle = New-Object System.Windows.Forms.Label
	$ProductTitle.Text = "Evergreen Software Updater"
	$ProductTitle.AutoSize = $true
	$ProductTitle.Location = New-Object System.Drawing.Point(82,14)
	$ProductTitle.Font = New-Object System.Drawing.Font("Segoe UI",17,[System.Drawing.FontStyle]::Bold)
	$ProductTitle.ForeColor = [System.Drawing.Color]::White
	$HeaderPanel.Controls.Add($ProductTitle)

	$VersionBadge = New-Object System.Windows.Forms.Label
	$VersionBadge.Text = "VERSION $EvergreenVersion"
	$VersionBadge.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
	$VersionBadge.Location = New-Object System.Drawing.Point(620,19)
	$VersionBadge.Size = New-Object System.Drawing.Size(145,25)
	$VersionBadge.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
	$VersionBadge.ForeColor = [System.Drawing.Color]::White
	$VersionBadge.BackColor = [System.Drawing.Color]::FromArgb(56,160,93)
	$HeaderPanel.Controls.Add($VersionBadge)

	$ProductSubtitle = New-Object System.Windows.Forms.Label
	$ProductSubtitle.Text = "Select software packages to download on the management host"
	$ProductSubtitle.AutoSize = $true
	$ProductSubtitle.Location = New-Object System.Drawing.Point(84,48)
	$ProductSubtitle.ForeColor = [System.Drawing.Color]::FromArgb(205,222,236)
	$HeaderPanel.Controls.Add($ProductSubtitle)

	$HeaderProfileCaption = New-Object System.Windows.Forms.Label
	$HeaderProfileCaption.Text = "SHARED PROFILE"
	$HeaderProfileCaption.AutoSize = $true
	$HeaderProfileCaption.Location = New-Object System.Drawing.Point(1010,16)
	$HeaderProfileCaption.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
	$HeaderProfileCaption.Font = New-Object System.Drawing.Font("Segoe UI",8,[System.Drawing.FontStyle]::Bold)
	$HeaderProfileCaption.ForeColor = [System.Drawing.Color]::FromArgb(155,195,222)
	$HeaderPanel.Controls.Add($HeaderProfileCaption)

	$HeaderProfileValue = New-Object System.Windows.Forms.Label
	$HeaderProfileValue.Text = "$(Split-Path -Leaf $SoftwareToUpdate)"
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
	$NavigationStatus.Text = "Profile loaded  |  Management host: $ENV:ComputerName"
	$NavigationStatus.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
	$NavigationStatus.Location = New-Object System.Drawing.Point(880,11)
	$NavigationStatus.Size = New-Object System.Drawing.Size(375,32)
	$NavigationStatus.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
	$NavigationStatus.ForeColor = [System.Drawing.Color]::FromArgb(69,128,90)
	$NavigationPanel.Controls.Add($NavigationStatus)

	$SelectionPanel = New-Object System.Windows.Forms.Panel
	$SelectionPanel.Location = New-Object System.Drawing.Point(0,132)
	$SelectionPanel.Size = New-Object System.Drawing.Size(1280,688)
	$SelectionPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
	$SelectionPanel.BackColor = [System.Drawing.Color]::FromArgb(245,247,250)
	$Form.Controls.Add($SelectionPanel)

	$Headline2.Text = "Choose software to download"
	$Headline2.Location = New-Object System.Drawing.Point(24,15)
	$Headline2.Font = New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
	$SelectionPanel.Controls.Add($Headline2)

	$ProfileLabel = New-Object System.Windows.Forms.Label
	$ProfileLabel.AutoSize = $true
	$ProfileLabel.ForeColor = [System.Drawing.Color]::FromArgb(90,100,115)
	$ProfileLabel.Text = "Selections are stored in the shared profile $(Split-Path -Leaf $SoftwareToUpdate)."
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

	$SelectionCountLabel = New-Object System.Windows.Forms.Label
	$SelectionCountLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
	$SelectionCountLabel.ForeColor = [System.Drawing.Color]::FromArgb(16,91,145)
	$SelectionCountLabel.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
	$SelectionCountLabel.Location = New-Object System.Drawing.Point(24,136)
	$SelectionCountLabel.Size = New-Object System.Drawing.Size(340,24)
	$SelectionCountLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
	$SelectionPanel.Controls.Add($SelectionCountLabel)

	$AvailableUpdatesLabel = New-Object System.Windows.Forms.Label
	$AvailableUpdatesLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
	$AvailableUpdatesLabel.ForeColor = [System.Drawing.Color]::FromArgb(20,120,52)
	$AvailableUpdatesLabel.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
	$AvailableUpdatesLabel.Location = New-Object System.Drawing.Point(945,39)
	$AvailableUpdatesLabel.Size = New-Object System.Drawing.Size(310,27)
	$AvailableUpdatesLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
	$AvailableUpdatesLabel.Visible = $false
	$SelectionPanel.Controls.Add($AvailableUpdatesLabel)

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

	$UnavailableSoftwareControls = @($MS365AppsBox_SAC,$MSSysinternalsBox,$FoxItReaderBox)
	$UnavailableCardFont = New-Object System.Drawing.Font("Segoe UI",11,[System.Drawing.FontStyle]::Strikeout)
	foreach ($SoftwareItem in $SoftwareCheckBoxes) {
		$CardPanel = New-Object System.Windows.Forms.Panel
		$CardPanel.Size = New-Object System.Drawing.Size(595,72)
		$CardPanel.Margin = New-Object System.Windows.Forms.Padding(5)
		$CardPanel.BackColor = [System.Drawing.Color]::White
		$CardPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

		if ($UnavailableSoftwareControls -contains $SoftwareItem.Control) {
			$SoftwareItem.Control.Font = $UnavailableCardFont
			$SoftwareItem.Control.ForeColor = [System.Drawing.Color]::FromArgb(125,132,140)
		}
		else {
			$SoftwareItem.Control.Font = $CardFont
			$SoftwareItem.Control.ForeColor = [System.Drawing.Color]::FromArgb(30,40,55)
		}
		$SoftwareItem.Control.AutoSize = $false
		$SoftwareItem.Control.Location = New-Object System.Drawing.Point(14,11)
		$SoftwareItem.Control.Size = New-Object System.Drawing.Size(370,48)
		$SoftwareItem.Control.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
		$SoftwareItem.Control.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
		$SoftwareItem.Control.UseCompatibleTextRendering = $true

		$CategoryBadge = New-Object System.Windows.Forms.Label
		$CategoryBadge.Text = $SoftwareItem.Category.ToUpperInvariant()
		$CategoryBadge.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
		$CategoryBadge.Location = New-Object System.Drawing.Point(398,7)
		$CategoryBadge.Size = New-Object System.Drawing.Size(180,23)
		$CategoryBadge.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
		$CategoryBadge.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
		$CategoryBadge.ForeColor = [System.Drawing.Color]::FromArgb(91,111,127)

		$UpdateBadge = New-Object System.Windows.Forms.Label
		$UpdateBadge.Text = "NEW VERSION DOWNLOADED"
		$UpdateBadge.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
		$UpdateBadge.Location = New-Object System.Drawing.Point(398,37)
		$UpdateBadge.Size = New-Object System.Drawing.Size(180,23)
		$UpdateBadge.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
		$UpdateBadge.Font = New-Object System.Drawing.Font("Segoe UI",8,[System.Drawing.FontStyle]::Bold)
		$UpdateBadge.ForeColor = [System.Drawing.Color]::White
		$UpdateBadge.BackColor = [System.Drawing.Color]::FromArgb(20,120,52)
		$UpdateBadge.Visible = $false

		$CardPanel.Controls.Add($SoftwareItem.Control)
		$CardPanel.Controls.Add($CategoryBadge)
		$CardPanel.Controls.Add($UpdateBadge)
		$SoftwareFlow.Controls.Add($CardPanel)
		$SoftwareItem | Add-Member -MemberType NoteProperty -Name Container -Value $CardPanel
		$SoftwareItem | Add-Member -MemberType NoteProperty -Name UpdateBadge -Value $UpdateBadge
	}

	$ResizeCards = {
		$AvailableWidth = $SoftwareFlow.ClientSize.Width - 22
		$ColumnCount = if ($AvailableWidth -ge 1050) { 3 } elseif ($AvailableWidth -ge 700) { 2 } else { 1 }
		$CardWidth = [Math]::Max(340,[int]($AvailableWidth / $ColumnCount) - 10)
		foreach ($SoftwareItem in $SoftwareCheckBoxes) {
			$SoftwareItem.Container.Width = $CardWidth
			$SoftwareItem.Control.Width = [Math]::Max(120,$CardWidth - 215)
		}
	}.GetNewClosure()
	$SoftwareFlow.Add_SizeChanged($ResizeCards)
	& $ResizeCards

	$RefreshSelectionCount = {
		$SelectedCount = @($SoftwareCheckBoxes | Where-Object { $_.Control.Checked }).Count
		$SelectionCountLabel.Text = "$SelectedCount of $($SoftwareCheckBoxes.Count) selected"

		# Highlight selected software cards with the same color as Select all / Clear all.
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
	$ProcessState.Text = "No active update"
	$ProcessState.AutoSize = $true
	$ProcessState.Location = New-Object System.Drawing.Point(24,26)
	$ProcessState.Font = New-Object System.Drawing.Font("Segoe UI",13,[System.Drawing.FontStyle]::Bold)
	$ProcessCard.Controls.Add($ProcessState)

	$ProcessInfo = New-Object System.Windows.Forms.Label
	$ProcessInfo.Text = "Start the update from the software selection. PowerShell output and errors will appear here live."
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
	$ProcessGrid.Size = New-Object System.Drawing.Size(1176,390)
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

	$BackToSelectionButton = New-Object System.Windows.Forms.Button
	$BackToSelectionButton.Text = "Back to software selection"
	$BackToSelectionButton.Location = New-Object System.Drawing.Point(26,536)
	$BackToSelectionButton.Size = New-Object System.Drawing.Size(220,40)
	$BackToSelectionButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
	& $StyleEvergreenButton $BackToSelectionButton
	$ProcessCard.Controls.Add($BackToSelectionButton)

	$CloseResultsButton = New-Object System.Windows.Forms.Button
	$CloseResultsButton.Text = "Exit"
	$CloseResultsButton.Location = New-Object System.Drawing.Point(1082,536)
	$CloseResultsButton.Size = New-Object System.Drawing.Size(120,40)
	$CloseResultsButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
	& $StyleEvergreenButton $CloseResultsButton
	$CloseResultsButton.Enabled = $false
	$ProcessCard.Controls.Add($CloseResultsButton)

	$ProcessContext = [PSCustomObject]@{
		Job = $null
		Running = $false
		Completed = $false
		ExitCode = 1
		CancelButton = $null
		ErrorCount = 0
		WarningCount = 0
		CurrentProduct = $null
		AvailableProducts = New-Object System.Collections.ArrayList
		DownloadErrors = New-Object System.Collections.ArrayList
		TransferActive = $false
	}


	$ShowDownloadErrorSummary = {
		if ($ProcessContext.DownloadErrors.Count -eq 0) { return }

		$SummaryLines = New-Object System.Collections.Generic.List[string]
		$SummaryLines.Add("Evergreen Software Updater - Download error summary")
		$SummaryLines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
		$SummaryLines.Add("Failed products: $($ProcessContext.DownloadErrors.Count)")
		$SummaryLines.Add("")
		$Index = 1
		foreach ($DownloadError in $ProcessContext.DownloadErrors) {
			$SummaryLines.Add("$Index. $($DownloadError.Product)")
			$SummaryLines.Add("   Error: $($DownloadError.Message)")
			if (-not [String]::IsNullOrWhiteSpace([string]$DownloadError.Source)) { $SummaryLines.Add("   Source: $($DownloadError.Source)") }
			if (-not [String]::IsNullOrWhiteSpace([string]$DownloadError.Target)) { $SummaryLines.Add("   Target: $($DownloadError.Target)") }
			$SummaryLines.Add("")
			$Index++
		}
		$SummaryText = $SummaryLines -join [Environment]::NewLine

		$SummaryForm = New-Object System.Windows.Forms.Form
		$SummaryForm.Text = "Download error summary"
		$SummaryForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
		$SummaryForm.Size = New-Object System.Drawing.Size(860,560)
		$SummaryForm.MinimumSize = New-Object System.Drawing.Size(700,450)
		$SummaryForm.BackColor = [System.Drawing.Color]::FromArgb(245,247,250)
		$SummaryForm.ShowInTaskbar = $false

		$SummaryLabel = New-Object System.Windows.Forms.Label
		$SummaryLabel.Text = "$($ProcessContext.DownloadErrors.Count) product(s) generated download errors. The complete summary can be copied."
		$SummaryLabel.Location = New-Object System.Drawing.Point(18,18)
		$SummaryLabel.Size = New-Object System.Drawing.Size(800,28)
		$SummaryLabel.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
		$SummaryLabel.ForeColor = [System.Drawing.Color]::FromArgb(185,55,55)
		$SummaryForm.Controls.Add($SummaryLabel)

		$SummaryBox = New-Object System.Windows.Forms.TextBox
		$SummaryBox.Multiline = $true
		$SummaryBox.ReadOnly = $true
		$SummaryBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
		$SummaryBox.WordWrap = $false
		$SummaryBox.Location = New-Object System.Drawing.Point(18,54)
		$SummaryBox.Size = New-Object System.Drawing.Size(806,420)
		$SummaryBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
		$SummaryBox.Font = New-Object System.Drawing.Font("Consolas",9)
		$SummaryBox.Text = $SummaryText
		$SummaryForm.Controls.Add($SummaryBox)

		$CopySummaryButton = New-Object System.Windows.Forms.Button
		$CopySummaryButton.Text = "Copy summary"
		$CopySummaryButton.Location = New-Object System.Drawing.Point(18,486)
		$CopySummaryButton.Size = New-Object System.Drawing.Size(150,36)
		$CopySummaryButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left
		& $StyleEvergreenButton $CopySummaryButton $true
		$CopySummaryButton.Add_Click({
			[System.Windows.Forms.Clipboard]::SetText($SummaryBox.Text)
			$CopySummaryButton.Text = "Copied"
		}.GetNewClosure())
		$SummaryForm.Controls.Add($CopySummaryButton)

		$CloseSummaryButton = New-Object System.Windows.Forms.Button
		$CloseSummaryButton.Text = "Close"
		$CloseSummaryButton.Location = New-Object System.Drawing.Point(704,486)
		$CloseSummaryButton.Size = New-Object System.Drawing.Size(120,36)
		$CloseSummaryButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
		& $StyleEvergreenButton $CloseSummaryButton
		$CloseSummaryButton.Add_Click({ $SummaryForm.Close() }.GetNewClosure())
		$SummaryForm.Controls.Add($CloseSummaryButton)
		$SummaryForm.AcceptButton = $CopySummaryButton
		$SummaryForm.CancelButton = $CloseSummaryButton
		[void]$SummaryForm.ShowDialog($Form)
	}.GetNewClosure()

	$ProductCardMap = @{
		"NotePadPlusPlus" = @($NotePadPlusPlusBox)
		"7-Zip" = @($SevenZipBox)
		"Adobe Reader DC MUI" = @($AdobeReaderDCBoxUpdate)
		"Adobe Reader DC x64 MUI" = @($AdobeReaderDCx64BoxUpdate)
		"Google Chrome" = @($GoogleChromeBox)
		"Mozilla Firefox" = @($FirefoxBoxDE,$FirefoxBoxEN)
		"VLC Player" = @($VLCPlayerBox)
		"FileZilla" = @($FileZillaBox)
		"pdf24Creator" = @($pdf24CreatorBox)
		"FoxitReader" = @($FoxItReaderBox)
		"FSLogix" = @($FSLogixBox)
		"MS 365 Apps-Semi Annual Channel" = @($MS365AppsBox_SAC)
		"MS 365 Apps-Monthly Enterprise Channel" = @($MS365AppsBox_MEC)
		"MS Office 2019" = @($MSOffice2019Box)
		"MS Office 2021 LTSC" = @($MSOffice2021Box)
		"MS Office 2024 LTSC" = @($MSOffice2024Box)
		"MS Edge WebView2 Runtime" = @()
		"MS Edge" = @($MSEdgeBox)
		"MS OneDrive" = @($MSOneDriveBox)
		"MS Teams 2" = @($NEWMSTeamsBox)
		"Microsoft Visual C++ Redistributable packages x64" = @($VcRedistBox)
		"Microsoft Visual C++ Redistributable packages x86" = @($VcRedistBox)
		"MS Powershell" = @($MSPowershellBox)
		"MS DotNet Runtime" = @($MSDotNetRuntimeBox)
		"MS DotNet Desktop Runtime" = @($MSDotNetDesktopRuntimeBox)
		"MS SQL Management Studio EN" = @($MSSQLManagementStudioENBox)
		"MS SQL Management Studio DE" = @($MSSQLManagementStudioDEBox)
		"MS Sysinternals Suite" = @($MSSysinternalsBox)
		"Microsoft OpenJDK 21" = @($MicrosoftOpenJDKBox)
		"MS Visual Studio Code" = @($MSVisualStudioCodeBox)
		"RD Analyzer" = @($RDAnalyzerBox)
		"BIS-F" = @($BISFBox)
		"WorkspaceApp" = @($WorkspaceApp_CRBox,$WorkspaceApp_LTSRBox)
		"Citrix VM Tools" = @($Citrix_VMToolsBox)
		"Citrix XenCenter" = @($Citrix_XenCenterBox)
		"ControlUp Console" = @($ControlUpConsoleBox)
		"ControlUp DX Client" = @($ControlUpRemoteDXBox)
		"Cisco WebEx VDI Plugin" = @($CiscoWebExVDIBox)
		"Zoom VDI Host" = @($ZoomVDIBox)
		"Zoom Citrix Client" = @($ZoomCitrixBox)
		"VMWare Tools" = @($VMWareToolsBox)
		"RemoteDesktopManager" = @($RemoteDesktopManagerBox)
		"mRemoteNG" = @($mRemoteNGBox)
		"WinSCP" = @($WinSCPBox)
		"Putty" = @($PuttyBox)
		"Oracle Java 8 x64" = @($OracleJava8Box)
		"Oracle Java 8 x86" = @($OracleJava8_32Box)
		"KeePassXC" = @($KeePassXCBox)
		"KeePass" = @($KeePassBox)
		"WinRAR" = @($WinRARBox)
		"Greenshot" = @($GreenshotBox)
		"IGEL Universal Management Suite" = @($IGELUniversalManagementSuiteBox)
		"ImageGlass" = @($ImageGlassBox)
		"ShareX" = @($ShareXBox)
		"TreeSizeFree" = @($TreeSizeFreeBox)
	}
	$ProductNamesByLength = @($ProductCardMap.Keys | Sort-Object { $_.Length } -Descending)

	$ResetAvailableUpdateBadges = {
		foreach ($SoftwareItem in $SoftwareCheckBoxes) { $SoftwareItem.UpdateBadge.Visible = $false }
		$AvailableUpdatesLabel.Visible = $false
		$AvailableUpdatesLabel.Text = ""
	}.GetNewClosure()

	$ShowAvailableUpdateBadges = {
		$ControlsWithUpdates = New-Object System.Collections.ArrayList
		foreach ($ProductName in $ProcessContext.AvailableProducts) {
			foreach ($MappedControl in @($ProductCardMap[$ProductName])) {
				if ($null -ne $MappedControl -and -not ($ControlsWithUpdates -contains $MappedControl)) {
					[void]$ControlsWithUpdates.Add($MappedControl)
				}
			}
		}
		$AvailableUpdateCount = 0
		foreach ($SoftwareItem in $SoftwareCheckBoxes) {
			$HasAvailableUpdate = ($ControlsWithUpdates -contains $SoftwareItem.Control) -and $SoftwareItem.Control.Checked
			$SoftwareItem.UpdateBadge.Visible = $HasAvailableUpdate
			if ($HasAvailableUpdate) { $AvailableUpdateCount++ }
		}
		if ($AvailableUpdateCount -gt 0) {
			$AvailableUpdatesLabel.Text = "$AvailableUpdateCount new version(s) downloaded"
			$AvailableUpdatesLabel.Visible = $true
		}
		else {
			$AvailableUpdatesLabel.Text = "No new versions downloaded"
			$AvailableUpdatesLabel.Visible = $true
		}
		return $AvailableUpdateCount
	}.GetNewClosure()

	$AppendProcessLine = {
		param([string]$Text,[bool]$IsError)
		if ([String]::IsNullOrWhiteSpace($Text)) { return }
		$Text = [regex]::Replace($Text,'\x1B\[[0-9;]*[A-Za-z]','').Trim()
		if ($Text -match '^[-=]{5,}$') { return }
		foreach ($ProductName in $ProductNamesByLength) {
			if ($Text.IndexOf($ProductName,[StringComparison]::OrdinalIgnoreCase) -ge 0) {
				$ProcessContext.CurrentProduct = $ProductName
				break
			}
		}
		$IsDownloadErrorLine = $Text -match '(?i)error downloading|download breaks with error|not able to get version|failed to.*download'
		if ($IsDownloadErrorLine) {
			$FailedProduct = if (-not [String]::IsNullOrWhiteSpace([string]$ProcessContext.CurrentProduct)) { [string]$ProcessContext.CurrentProduct } else { "Unknown product" }
			$ExistingError = $ProcessContext.DownloadErrors | Where-Object { $_.Product -eq $FailedProduct } | Select-Object -First 1
			if ($null -eq $ExistingError) {
				[void]$ProcessContext.DownloadErrors.Add([PSCustomObject]@{ Product = $FailedProduct; Message = $Text; Source = ""; Target = "" })
			} else {
				$ExistingError.Message = $Text
			}
		}
		elseif ($Text -match '(?i)^Source:\s*(?<Value>.+)$' -and $ProcessContext.DownloadErrors.Count -gt 0) {
			$ProcessContext.DownloadErrors[$ProcessContext.DownloadErrors.Count - 1].Source = $Matches['Value'].Trim()
		}
		elseif ($Text -match '(?i)^Target:\s*(?<Value>.+)$' -and $ProcessContext.DownloadErrors.Count -gt 0) {
			$ProcessContext.DownloadErrors[$ProcessContext.DownloadErrors.Count - 1].Target = $Matches['Value'].Trim()
		}
		$TransferMatch = [regex]::Match($Text,'(?i)(?<current>\d*[\.,]?\d+\s*(?:KB|MB|GB))\s*/\s*(?<total>\d*[\.,]?\d+\s*(?:KB|MB|GB)).*?(?<percent>\d+(?:[\.,]\d+)?)\s*%\s*complete')
		if ($TransferMatch.Success) {
			$CurrentAmount = $TransferMatch.Groups['current'].Value.Trim()
			$TotalAmount = $TransferMatch.Groups['total'].Value.Trim()
			if ($CurrentAmount.StartsWith('.')) { $CurrentAmount = "0$CurrentAmount" }
			$PercentText = $TransferMatch.Groups['percent'].Value.Replace(',','.')
			try { $PercentValue = [Convert]::ToDouble($PercentText,[Globalization.CultureInfo]::InvariantCulture) } catch { $PercentValue = 0 }
			$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
			$ProcessProgress.Value = [Math]::Max(0,[Math]::Min(100,[int][Math]::Round($PercentValue)))
			$DownloadProductName = [string]$ProcessContext.CurrentProduct
			if (-not [String]::IsNullOrWhiteSpace($DownloadProductName) -and $ProductCardMap.ContainsKey($DownloadProductName)) {
				$MappedProductControl = @($ProductCardMap[$DownloadProductName])[0]
				if ($null -ne $MappedProductControl -and -not [String]::IsNullOrWhiteSpace([string]$MappedProductControl.Text)) {
					$DownloadProductName = [string]$MappedProductControl.Text
				}
			}
			$DownloadLabel = if ([String]::IsNullOrWhiteSpace($DownloadProductName)) { "Downloading" } else { "Downloading $DownloadProductName" }
			$ProcessInfo.Text = "${DownloadLabel}: $CurrentAmount of $TotalAmount ($PercentText %)"
			$ProcessContext.TransferActive = $true
			return
		}
		if ($ProcessContext.TransferActive -and $Text -match '(?i)stop logging|error downloading|download (completed|finished)') {
			$ProcessContext.TransferActive = $false
			$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
			$ProcessInfo.Text = "Download finished. Continuing with the update process..."
		}
		if ($Text -match '(?i)\bUpdate available\b' -and -not [String]::IsNullOrWhiteSpace($ProcessContext.CurrentProduct)) {
			if (-not ($ProcessContext.AvailableProducts -contains $ProcessContext.CurrentProduct)) {
				[void]$ProcessContext.AvailableProducts.Add($ProcessContext.CurrentProduct)
			}
		}
		if ($Text -match '(?i)error downloading|download breaks with error|failed to.*download|not able to get version' -and -not [String]::IsNullOrWhiteSpace($ProcessContext.CurrentProduct)) {
			[void]$ProcessContext.AvailableProducts.Remove($ProcessContext.CurrentProduct)
		}
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
		elseif ($Text -match '(?i)\b(finished|success|successful|update available|downloaded|newest version|OK)\b|no new version available') {
			$LineStatus = "Success"
			$StatusColor = [System.Drawing.Color]::FromArgb(20,120,52)
			$RowColor = [System.Drawing.Color]::FromArgb(218,245,225)
		}
		elseif ($Text -match '(?i)\b(installing|starting|download|current version)\b') {
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
			$AvailableUpdateCount = & $ShowAvailableUpdateBadges
			if ($script:GuiWorkflowExitCode -eq 0 -and $ProcessContext.ErrorCount -eq 0) {
				$ProcessState.Text = "Update completed"
				$ProcessState.ForeColor = [System.Drawing.Color]::FromArgb(20,120,52)
				$ProcessInfo.Text = "The update process ended successfully. $AvailableUpdateCount selected package(s) downloaded a new version; $($ProcessContext.WarningCount) warning(s) were logged."
				$NavigationStatus.Text = "Update completed"
				& $AppendProcessLine "Update process finished with exit code 0." $false
			}
			else {
				$ProcessState.Text = "Update completed with errors"
				$ProcessState.ForeColor = [System.Drawing.Color]::FromArgb(185,55,55)
				$ProcessInfo.Text = "The update process reported $($ProcessContext.ErrorCount) error line(s) and returned exit code $script:GuiWorkflowExitCode. Review the red output lines and update logs."
				$NavigationStatus.Text = "Update requires attention"
				& $AppendProcessLine "Update process finished with exit code $script:GuiWorkflowExitCode." $true
			}
			if ($ProcessContext.DownloadErrors.Count -gt 0) { & $ShowDownloadErrorSummary }
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
		$ProcessContext.CurrentProduct = $null
		$ProcessContext.AvailableProducts.Clear()
		$ProcessContext.DownloadErrors.Clear()
		$ProcessContext.TransferActive = $false
		& $ResetAvailableUpdateBadges
		$ProcessGrid.Rows.Clear()
		$ProcessState.Text = "Update is running..."
		$ProcessState.ForeColor = [System.Drawing.Color]::FromArgb(30,40,55)
		$ProcessInfo.Text = "The existing updater is running with -NoGUI. Output is transferred live into this window."
		$ProcessProgress.Value = 0
		$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
		$ProcessProgress.MarqueeAnimationSpeed = 25
		$BackToSelectionButton.Enabled = $false
		$CloseResultsButton.Enabled = $false
		$SelectionNavButton.Enabled = $false
		$ProcessNavButton.Enabled = $false
		$NavigationStatus.Text = "Update is running"
		& $ShowProcess
		try {
			if ($null -ne $ProcessContext.Job) { Remove-Job -Job $ProcessContext.Job -Force -ErrorAction SilentlyContinue }
			& $AppendProcessLine "Starting updater process..." $false
			$ProcessContext.Job = Start-Job -Name "Evergreen-Updater-GUI" -ScriptBlock {
				param([string]$ScriptPath)
				# Run the known-good legacy engine without a caller-level try/catch.
				# Its package blocks intentionally report individual errors and continue.
				& $ScriptPath -NoGUI 6>&1 3>&1
				[PSCustomObject]@{ EvergreenJobResult = $true; ExitCode = 0 }
			} -ArgumentList $PSCommandPath
			$ProcessContext.Running = $true
			$ProcessTimer.Start()
		}
		catch {
			$ProcessContext.Running = $false
			$ProcessContext.Completed = $true
			$ProcessProgress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
			$ProcessState.Text = "Update could not be started"
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
	$CloseResultsButton.Add_Click({ $Form.Close() })
	$Form.Add_FormClosed({
		if ($null -ne $HeaderLogo.Image) { $HeaderLogo.Image.Dispose(); $HeaderLogo.Image = $null }
	}.GetNewClosure())
	$Form.Add_FormClosing({
		param($Sender,$EventArgs)
		if ($ProcessContext.Running) {
			[void][System.Windows.Forms.MessageBox]::Show("The update is still running. Please wait until the process has completed.","Update active",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
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
	$SelectAllExclusions = @($ZoomVDIBox,$ZoomCitrixBox)
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
	$OKButton.text = "Save && Start Update"
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
		$SoftwareSelection = New-Object PSObject
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NotepadPlusPlus" -Value $NotePadPlusPlusBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "SevenZip" -Value $SevenZipBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDC_MUI" -Value $AdobeReaderDCBoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "AdobeReaderDCx64_MUI" -Value $AdobeReaderDCx64BoxUpdate.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "BISF" -Value $BISFBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FSLogix" -Value $FSLogixBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "GoogleChrome" -Value $GoogleChromeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_CR" -Value $WorkspaceApp_CRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WorkspaceApp_LTSR" -Value $WorkspaceApp_LTSRBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixVMTools" -Value $Citrix_VMToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CitrixXenCenter" -Value $Citrix_XenCenterBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_SAC" -Value $MS365AppsBox_SAC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MS365Apps_MEC" -Value $MS365AppsBox_MEC.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2019" -Value $MSOffice2019Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2021" -Value $MSOffice2021Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOffice2024" -Value $MSOffice2024Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePass" -Value $KeePassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "KeePassXC" -Value $KeePassXCBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "IGELUniversalManagementSuite" -Value $IGELUniversalManagementSuiteBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "mRemoteNG" -Value $mRemoteNGBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSEdge" -Value $MSEdgeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSOneDrive" -Value $MSOneDriveBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "NEWMSTeams" -Value $NEWMSTeamsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSPowershell" -Value $MSPowershellBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSDotNetDesktopRuntime" -Value $MSDotNetDesktopRuntimeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSDotNetRuntime" -Value $MSDotNetRuntimeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsEN" -Value $MSSQLManagementStudioENBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSsmsDE" -Value $MSSQLManagementStudioDEBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VcRedist" -Value $VcRedistBox.checked -Force		
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSSysinternals" -Value $MSSysinternalsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDDesktopAgent" -Value $OriginalSoftwareSelection.MSWVDDesktopAgent -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDRTCService" -Value $OriginalSoftwareSelection.MSWVDRTCService -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSWVDBootLoader" -Value $OriginalSoftwareSelection.MSWVDBootLoader -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MicrosoftOpenJDK" -Value $MicrosoftOpenJDKBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "MSVisualStudioCode" -Value $MSVisualStudioCodeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Greenshot" -Value $GreenshotBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8" -Value $OracleJava8Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "OracleJava8_32" -Value $OracleJava8_32Box.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "TreeSizeFree" -Value $TreeSizeFreeBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ControlUpConsole" -Value $ControlUpConsoleBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ControlUpRemoteDX" -Value $ControlUpRemoteDXBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVDI" -Value $ZoomVDIBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomCitrix" -Value $ZoomCitrixBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ZoomVMWare" -Value $ZoomVMWareBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VLCPlayer" -Value $VLCPlayerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Firefox" -Value $FirefoxBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FirefoxDE" -Value $FirefoxBoxDE.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FirefoxEN" -Value $FirefoxBoxEN.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FileZilla" -Value $FileZillaBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExVDI" -Value $CiscoWebExVDIBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RDAnalyzer" -Value $RDAnalyzerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinRAR" -Value $WinRARBox.checked -Force
		#Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "CiscoWebExDesktop" -Value $CiscoWebExDesktopBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "deviceTRUST" -Value $OriginalSoftwareSelection.deviceTRUST -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "VMWareTools" -Value $VMWareToolsBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "RemoteDesktopManager" -Value $RemoteDesktopManagerBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "WinSCP" -Value $WinSCPBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "Putty" -Value $PuttyBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ImageGlass" -Value $ImageGlassBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "ShareX" -Value $ShareXBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "pdf24Creator" -Value $pdf24CreatorBox.checked -Force
		Add-member -inputobject $SoftwareSelection -MemberType NoteProperty -Name "FoxItReader" -Value $FoxItReaderBox.checked -Force
	
	# Export objects to	XML
	$SoftwareSelection | Export-Clixml $SoftwareToUpdate
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
        #$Script:download = $true
        Write-Host -ForegroundColor Red "Canceled - Nothing happens!"
        $Form.Close()
		[System.Environment]::Exit(0)
    })
    $SelectionPanel.Controls.Add($CancelButton)
	$ProcessContext.CancelButton = $CancelButton
	$Form.Tag = $OKButton
	$Form.AcceptButton = $OKButton
	$Form.CancelButton = $CancelButton
	
    # Activate the form and confirm a successful post-update GUI start.
    $Form.Add_Shown({$Form.Activate()})
	Close-StartupWindow
    [void] $Form.ShowDialog()
}
# ========================================================================================================================================


# Show a dependency-free startup window before running startup checks.
Start-StartupWindow

# FUNCTION Check internet access
# ========================================================================================================================================
function Test-EvergreenInternetConnection {
	$Endpoint = "https://raw.githubusercontent.com/Mohrpheus78/Evergreen/main/Evergreen-Software%20Updater.ps1"
	$Errors = New-Object System.Collections.ArrayList
	try {
		# Use the same raw GitHub endpoint as the actual self-update. Do not require a
		# historical marker string: users may legitimately change comments/header text.
		$Response = Invoke-WebRequest -UseBasicParsing -Uri $Endpoint -TimeoutSec 15 -Headers @{ "User-Agent" = "Evergreen-Updater"; "Accept" = "text/plain,*/*" } -ErrorAction Stop
		$Content = [string]$Response.Content
		$VersionMatch = [regex]::Match($Content,'(?m)^Version:\s*(?<Version>\d+(?:\.\d+){1,3})\s*$')
		$HasPowerShellStructure = [regex]::IsMatch($Content,'(?im)^\s*Param\s*\(') -and $Content.IndexOf('$EvergreenVersion',[StringComparison]::OrdinalIgnoreCase) -ge 0
		if ([String]::IsNullOrWhiteSpace($Content)) {
			[void]$Errors.Add("The GitHub update source returned an empty response.")
		}
		elseif (-not $VersionMatch.Success -or -not $HasPowerShellStructure) {
			$StatusCode = if ($null -ne $Response.StatusCode) { [string][int]$Response.StatusCode } else { "unknown" }
			$ContentType = if ($null -ne $Response.Headers['Content-Type']) { [string]$Response.Headers['Content-Type'] } else { "unknown" }
			[void]$Errors.Add("GitHub was reachable (HTTP $StatusCode, Content-Type '$ContentType'), but the response was not recognized as the Evergreen updater script.")
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
	if ($noGUI -eq $False) { Set-StartupStatus "Starting updated updater..." "Version $EvergreenVersion passed update validation. Skipping the second GitHub update check." 900 }
}
else {
	Set-StartupStatus "Checking update access..." "Validating access to the Evergreen updater on GitHub."
	do {
		$InternetResult = Test-EvergreenInternetConnection
		if ($InternetResult.Connected) { break }
		if ($NoGUI) { break }
		$InternetFailureDetail = if ($InternetResult.Errors.Count -gt 0) { "GitHub update source could not be validated: " + ($InternetResult.Errors -join " | ") + " You can retry, continue with the locally available updater files, or exit." } else { "GitHub update source could not be validated. You can retry, continue with the locally available updater files, or exit." }
		$InternetChoice = Wait-StartupInternetChoice $InternetFailureDetail
		if ($InternetChoice -eq "Exit") { Close-StartupWindow; Restore-StartupConsole; exit 1 }
		if ($InternetChoice -eq "Continue") { break }
		Set-StartupStatus "Retrying update access..." "Validating the Evergreen update source on GitHub again."
	} while ($true)
	$InternetCheck1 = if ($InternetResult.Connected) { "True" } else { "False" }
	$InternetCheck2 = $InternetCheck1
	if ($InternetResult.Connected) { Set-StartupStatus "Update source available" "The Evergreen updater script and its version were verified successfully." 900 }
	else { Set-StartupStatus "Continuing in offline mode" "The updater will use the locally available scripts and package information." 900 }
}
# ========================================================================================================================================



# Do you run the script as admin?
# ========================================================================================================================================
Set-StartupStatus "Checking permissions..." "Verifying that the updater is running with administrator rights."
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

IF ($myWindowsPrincipal.IsInRole($adminRole) -or $UpdateDryRun)
   {
    # OK, runs as admin
    Write-Host "OK, script is running with Admin rights"
    Write-Output ""
	if ($UpdateDryRun -and -not $myWindowsPrincipal.IsInRole($adminRole)) {
		Set-StartupStatus "Update dry run" "Administrator rights are not required because no file will be changed." 500
	}
	else { Set-StartupStatus "Administrator rights confirmed" "The updater has the required permissions." 500 }
   }

else
   {
    # Script doesn't run as admin, stop!
    Write-Host -ForegroundColor Red "Error! Script is NOT running with Admin rights!"
	if ($null -ne $script:StartupForm) {
		[void][System.Windows.Forms.MessageBox]::Show($script:StartupForm,"The Software Updater must be started with administrator rights.","Administrator rights required",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
	}
	Close-StartupWindow
	Restore-StartupConsole
	exit 1
   }
# ========================================================================================================================================


# The replacement script has parsed, opened its startup UI, passed the update-skip path,
# and completed the administrator check. Report transactional health now, before lengthy
# module and package preparation, so the previous updater process can close immediately.
if ($SkipUpdateCheck -and -not [String]::IsNullOrWhiteSpace($UpdateHealthCheckPath) -and -not [String]::IsNullOrWhiteSpace($UpdateHealthCheckToken)) {
	Write-EvergreenUpdateHealthCheck
}

# Is there a newer Evergreen Script version?
# ========================================================================================================================================

$WebVersion = ""
[bool]$NewerVersion = $false
$UpdateCandidate = $null
$UpdateDryRunResult = $null
if ($noGUI -eq $False -and -not $SkipUpdateCheck) {
	Set-StartupStatus "Checking the updater version..." "Comparing the local script with the published Evergreen version."
	if (-not [String]::IsNullOrWhiteSpace($UpdateManifestPath)) {
		try {
			Set-StartupStatus "Loading the test update manifest..." "No production files will be changed."
			$UpdateCandidate = Get-EvergreenUpdateCandidate $UpdateManifestPath "Updater"
			[version]$WebVersion = $UpdateCandidate.Version
			$NewerVersion = $WebVersion -gt $EvergreenVersion
			if ($UpdateDryRun -or $NewerVersion) {
				Set-StartupStatus "Validating updater update $WebVersion..." "Staging the package and checking SHA-256, version, and PowerShell syntax."
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
			Set-StartupStatus "Version check unavailable" "Local updater version: $EvergreenVersion. The locally available scripts can still be used." 1100
		}
	}
	if ($null -ne $UpdateDryRunResult) {
		if ($UpdateDryRunResult.Success) {
			if ($UpdateDryRun) { Set-StartupStatus "Dry run completed successfully" "Updater $($UpdateDryRunResult.Version): staging, SHA-256, version, and syntax checks passed. No file was replaced." 1500 }
			else { Set-StartupStatus "Update package validated" "Updater $($UpdateDryRunResult.Version) is ready for the transactional test update." 1200 }
		}
		else {
			Set-StartupStatus "Dry run validation failed" $UpdateDryRunResult.Message 1800
		}
	}
	elseif ($NewerVersion) {
		Set-StartupStatus "New updater version available" "Installed: $EvergreenVersion  |  Available: $WebVersion" 1200
	}
	elseif ($InternetResult.Connected -and -not [String]::IsNullOrWhiteSpace([string]$WebVersion)) {
		Set-StartupStatus "Updater is up to date" "Installed version: $EvergreenVersion" 1200
	}
	elseif (-not $InternetResult.Connected) {
		Set-StartupStatus "Version check skipped in offline mode" "Installed version: $EvergreenVersion" 1200
	}
}
elseif ($noGUI -eq $False) {
	Set-StartupStatus "Starting updated updater..." "Version $EvergreenVersion passed package validation. Waiting for the main GUI." 900
}


Clear-Host

Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------- "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " Software-Updater (Powered by Evergreen-Module) "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed "    © D. Mohrmann - Cancom GmbH - BU Mitte      "
Write-Host -ForegroundColor Gray -BackgroundColor DarkRed " ---------------------------------------------- "
Write-Output ""

Write-Host -ForegroundColor Cyan "Setting Variables"
Write-Output ""

# Variables
Set-StartupStatus "Preparing the updater..." "Loading paths, saved selections, and local package information."
$SoftwareFolder = ("$PSScriptRoot" + "\" + "Software\")
$ErrorActionPreference = "SilentlyContinue"
#$WarningPreference = "Continue"
$SoftwareToUpdate = "$SoftwareFolder\Software-to-update.xml"

if ($noGUI -eq $False -and -not $SkipUpdateCheck) {
Write-Host -Foregroundcolor Cyan "Current script version: $EvergreenVersion
Is there a newer Evergreen Script version?"
Write-Output ""
If ($null -ne $UpdateDryRunResult -and ($UpdateDryRun -or -not $UpdateDryRunResult.Success)) {
	$DryRunMessage = if ($UpdateDryRunResult.Success) { "Dry run passed for Updater $($UpdateDryRunResult.Version).`r`n`r`n$($UpdateDryRunResult.Message)`r`n`r`nNo file was replaced." } elseif ($UpdateDryRun) { "Dry run failed:`r`n`r`n$($UpdateDryRunResult.Message)`r`n`r`nNo file was replaced." } else { "Update package validation failed:`r`n`r`n$($UpdateDryRunResult.Message)`r`n`r`nNo file was replaced." }
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
        Write-Host -Foregroundcolor Red "Attention! There is a new version $WebVersion of the Evergreen Updater!"
        Write-Output ""
		Set-StartupStatus "A newer updater is available" "Version $WebVersion can be downloaded before continuing."
		if (-not [String]::IsNullOrWhiteSpace($UpdateManifestPath)) {
			if ($null -ne $UpdateDryRunResult -and $UpdateDryRunResult.Success -and $UpdateCandidate.Channel -eq "Test") {
				$AnswerPending = [System.Windows.Forms.MessageBox]::Show($script:StartupForm,"Updater $WebVersion passed all package checks.`r`n`r`nThe test update will create a backup, replace only this script, restart the GUI, and automatically roll back if the new GUI does not report a healthy start.`r`n`r`nStart the transactional test update now?","Validated test update",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
			}
			else {
				[void][System.Windows.Forms.MessageBox]::Show($script:StartupForm,"The manifest update was not started because validation failed or the manifest is not using the Test channel.","Test update blocked",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Warning)
				$AnswerPending = [System.Windows.Forms.DialogResult]::No
			}
		}
		elseif ($null -ne $script:StartupForm) {
			$AnswerPending = [System.Windows.Forms.MessageBox]::Show($script:StartupForm,"Evergreen Updater $WebVersion is available. Do you want to download it now?","New updater version",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
		}
		else {
			$AnswerPending = [System.Windows.Forms.MessageBox]::Show("Evergreen Updater $WebVersion is available. Do you want to download it now?","New updater version",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Information)
		}
			If ($AnswerPending -eq [System.Windows.Forms.DialogResult]::Yes) {
				if ([String]::IsNullOrWhiteSpace($UpdateManifestPath)) {
					Set-StartupStatus "Validating the new updater..." "Checking version metadata and PowerShell syntax before replacing any file."
					$UpdateDryRunResult = New-EvergreenValidatedUpdateFromContent $InternetResult.Content ([version]$WebVersion) "Updater"
				}
				if ($null -ne $UpdateDryRunResult -and $UpdateDryRunResult.Success) {
					Set-StartupStatus "Installing the validated updater..." "Creating a backup, replacing this script, and checking the restarted GUI."
					$UpdateInstallResult = Install-EvergreenValidatedUpdate $UpdateDryRunResult "Updater"
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

# General update logfile
$Date = $Date = Get-Date -UFormat "%d.%m.%Y"
$UpdateLog = "$SoftwareFolder\_Update Logs\Software Updates $Date.log"
$ModulesUpdateLog = "$SoftwareFolder\_Update Logs\Modules Updates $Date.log"

# Import values (selected software) from XML file
if (Test-Path -Path $SoftwareToUpdate) {$SoftwareSelection = Import-Clixml $SoftwareToUpdate}


# Call Form
if ($noGUI -eq $False) {
Set-StartupStatus "Opening software selection..." "The updater is ready."
gui_mode
	if ($script:GuiWorkflowStarted) {
		exit [int]$script:GuiWorkflowExitCode
	}
	exit 0
}

# Disable progress bar while downloading
$ProgressPreference = 'SilentlyContinue'

# Install/Update Evergreen and Nevergreen modules
# Start logfile Modules Update Log

IF ($InternetCheck1 -eq "True" -or $InternetCheck2 -eq "True") {
	Start-Transcript $ModulesUpdateLog | Out-Null
	Write-Host -ForegroundColor Cyan "Installing/updating Evergreen and Nevergreen... please wait"
	Write-Output ""

	if (Get-PSRepository | Where-Object { $_.Name -eq "PSGallery" -and $_.InstallationPolicy -ne "Trusted" }) {
		Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.208 -Force
		Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
	}

	IF (!(Test-Path -Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget")) {
		Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
		}
	IF (!(Get-Module -ListAvailable -Name Evergreen)) {
		Install-Module Evergreen -Force | Import-Module Evergreen
		}
	IF (!(Get-Module -ListAvailable -Name Nevergreen)) {
		Install-Module Nevergreen -Force | Import-Module Nevergreen
		}
	IF (!(Get-Module -ListAvailable -Name VcRedist)) {
		Install-Module VcRedist -Force | Import-Module VcRedist
		
		}
	# Check for Updates
	# Update-Module only works reliably for modules that were originally installed
	# with Install-Module. Evergreen can also exist from a manual/copy deployment.
	# Install-Module -Force handles both cases and avoids the non-terminating
	# "was not installed by using Install-Module" error in the Process results.
	$Installed = Get-Module -Name "Evergreen" -ListAvailable | `
    	Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
    	Select-Object -First 1
	$Published = Find-Module -Name "Evergreen" -Repository PSGallery -ErrorAction SilentlyContinue
	if ($Null -eq $Installed) {
		Install-Module -Name "Evergreen" -Repository PSGallery -Force -AllowClobber -ErrorAction Stop
	}
	elseif ($null -ne $Published -and [System.Version]$Published.Version -gt [System.Version]$Installed.Version) {
		Write-Host -ForegroundColor Yellow "Evergreen update available: $($Installed.Version) -> $($Published.Version)"
		Install-Module -Name "Evergreen" -Repository PSGallery -Force -AllowClobber -ErrorAction Stop
	}

	Import-Module Evergreen -Force -ErrorAction Stop
	Update-Evergreen

	<#
	$LocalEvergreenVersion = (Get-Module -Name Evergreen -ListAvailable | Select-Object -First 1).Version
	$CurrentEvergreenVersion = (Find-Module -Name Evergreen -Repository PSGallery).Version
	IF (($LocalEvergreenVersion -lt $CurrentEvergreenVersion)) {
		Update-Module Evergreen -force
		Update-Evergreen
	}
	#>

	$LocalNevergreenVersion = (Get-Module -Name Nevergreen -ListAvailable | Select-Object -First 1).Version
	$CurrentNevergreenVersion = (Find-Module -Name Nevergreen -Repository PSGallery).Version
	IF (($LocalNevergreenVersion -lt $CurrentNevergreenVersion)) {
		Update-Module Nevergreen -force
	}

	$LocalVcRedistVersion = (Get-Module -Name VcRedist -ListAvailable | Select-Object -First 1).Version
	$CurrentVcRedistVersion = (Find-Module -Name VcRedist -Repository PSGallery).Version
	IF (($LocalVcRedistVersion -lt $CurrentVcRedistVersion)) {
		Update-Module VcRedist -force
	}

	IF (!(Get-Module -ListAvailable -Name Evergreen)) {
		Write-Host -ForegroundColor Cyan "Evergreen module not found, check module installation!"
		BREAK
	}
	IF (!(Get-Module -ListAvailable -Name Nevergreen)) {
		Write-Host -ForegroundColor Cyan "Nevergreen module not found, check module installation!"
		BREAK
	}
	IF (!(Get-Module -ListAvailable -Name VcRedist)) {
		Write-Host -ForegroundColor Cyan "VcRedist module not found, check module installation!"
		BREAK
	}

	# Stop logfile Modules Update Log
	Stop-Transcript | Out-Null
	$Content = Get-Content -Path $ModulesUpdateLog | Select-Object -Skip 18
	Set-Content -Value $Content -Path $ModulesUpdateLog
}
ELSE {
	Write-Host -ForegroundColor Cyan "Powershell is NOT able to connect to the internet, the script will not update the Evergreen and Nevergreen Powershell modules!"
	Write-Output ""
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
    if ($notesIndex -gt 0) { $lastLineBeforeNotes = $scriptContent[$notesIndex - 1] }
}
Write-Output ""
if (-not [String]::IsNullOrWhiteSpace($lastLineBeforeNotes)) {
    Write-Host -Foregroundcolor Cyan "Last changes: $lastLineBeforeNotes"
} else {
    Write-Host -Foregroundcolor DarkGray "Last changes: release note information unavailable"
}
Write-Output ""

# Start logfile Update Log
Start-Transcript $UpdateLog | Out-Null

# Import selection
$SoftwareSelection = Import-Clixml $SoftwareToUpdate
Write-Host -ForegroundColor Cyan "Import selection"
Write-Output ""

# Write-Output "Evergreen Version: $EvergreenVersion" | Out-File $UpdateLog -Append
Write-Host -ForegroundColor Cyan "Starting downloads..."
Write-Output ""

# Create ADMX subfolder
IF (!(Test-Path -Path "$SoftwareFolder\_ADMX")) {
	New-Item -Path "$SoftwareFolder\_ADMX" -Type Directory -EA SilentlyContinue | Out-Null
}


# Download RemoteDesktopManager
IF ($SoftwareSelection.RemoteDesktopManager -eq $true) {
	$Product = "RemoteDesktopManager"
	$PackageName = "RemoteDesktopManagerFree"
	Try {
	$URLVersionRDM = "https://devolutions.net/remote-desktop-manager/release-notes/free/"
	$webRequestRDM = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionRDM) -SessionVariable websession
	$regexAppVersionRDM = "\d\d\d\d\.\d\.\d\d\.\d+"
	$webVersionRDM = $webRequestRDM.RawContent | Select-String -Pattern $regexAppVersionRDM -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	[Version]$VersionRDM = $webVersionRDM.Trim("</td>").Trim("</td>")
	$URL = "https://cdn.devolutions.net/download/Setup.RemoteDesktopManager.$VersionRDM.msi"
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionRDM"
	Write-Host "Current Version: $CurrentVersion"
	IF (!(Test-Path "$SoftwareFolder\$Product\windowsdesktop-runtime-10.0.8-win-x64.exe")) {
		Try {
		Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.8/windowsdesktop-runtime-10.0.8-win-x64.exe" -OutFile "$SoftwareFolder\$Product\windowsdesktop-runtime-10.0.8-win-x64.exe"
		} catch {
		throw $_.Exception.Message
		}
	}
	IF ($VersionRDM) {
		IF ($VersionRDM -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionRDM.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionRDM"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionRDM"
		#Invoke-WebRequest -UseBasicParsing -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download pdf24Creator
IF ($SoftwareSelection.pdf24Creator -eq $true) {
	$Product = "pdf24Creator"
	$PackageName = "pdf24Creator"
	Try {
	$URLVersion = "https://creator.pdf24.org/listVersions.php"
	$webRequest = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersion) -SessionVariable websession
	$regexAppVersionPDF2 = "\d\d\.\d\d\.\d+"
    $webVersionPDF24 = $webRequest.RawContent | Select-String -Pattern $regexAppVersionPDF2 -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1 -Skip 1
    [version]$VersionPDF24 = $webVersionPDF24
    #$regexAppVersionDL = "pdf24-creator-.*.msi"
    #$webVersionPDF24 = $webRequest.RawContent | Select-String -Pattern $regexAppVersionDL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    #$VersionPDF24DL = $webVersionPDF24.Split('"<')[0]
    $URL = "https://download.pdf24.org/pdf24-creator-$webVersionPDF24-x64.msi"
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionPDF24"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionPDF24) {
		IF ($VersionPDF24 -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionPDF24.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msi, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionPDF24"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionPDF24"
		#Invoke-WebRequest -UseBasicParsing -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Notepad ++
IF ($SoftwareSelection.NotePadPlusPlus -eq $true) {
    $Product = "NotePadPlusPlus"
	$PackageName = "NotePadPlusPlus_x64"
	Try {
		$Notepad = Get-EvergreenApp -Name NotepadPlusPlus | Where-Object {$_.Architecture -eq "x64" -and $_.URI -match ".exe"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
	}
	IF ($NotePad.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $Notepad.Version
		}
	# $Version = $Version.substring(1)
	$URL = $Notepad.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Get-ChildItem "$SoftwareFolder\$Product\" -Include *.exe, Version.txt, Download* -Recurse | Remove-Item -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Get-ChildItem "$SoftwareFolder\$Product\" -Include *.exe, Version.txt, Download* -Recurse | Remove-Item -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}



# Download Chrome
IF ($SoftwareSelection.GoogleChrome -eq $true) {
	$Product = "Google Chrome"
	$PackageName = "GoogleChromeStandaloneEnterprise64"
	Try {
	$Chrome = Get-EvergreenApp -Name GoogleChrome | Where-Object {$_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$VersionChrome = $Chrome.Version
	<#
	$URLChrome = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
	$webRequestChrome = Invoke-WebRequest -UseBasicParsing -Uri ($URLChrome) -SessionVariable websession
	$regexAppChrome = "<ChromeVer>([A-Za-z0-9]+(\.[A-Za-z0-9]+)+)</ChromeVer>"
	$UrlChrome = $webRequestChrome.RawContent | Select-String -Pattern $regexAppChrome -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    $UrlChrome = $UrlChrome.Split('"<')
    $UrlChrome = $UrlChrome.Split('">')
	$VersionChrome = $UrlChrome[2]
	#>
	$URL = $Chrome.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionChrome"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionChrome) {
		IF (!($CurrentVersion -eq $VersionChrome)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionChrome.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionChrome"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionChrome"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Edge
IF ($SoftwareSelection.MSEdge -eq $true) {
	$Product = "MS Edge"
	$PackageName = "MicrosoftEdgeEnterpriseX64"
	Try {
	$Edge = Get-EvergreenApp -Name MicrosoftEdge | Where-Object {$_.Channel -eq "stable" -and $_.Architecture -eq "x64" -and $_.Release -eq "Enterprise"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $Edge.Version
	$URL = $Edge.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue 
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS  | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download VLC Player
IF ($SoftwareSelection.VLCPlayer -eq $true) {
	$Product = "VLC Player"
	$PackageName = "VLC-Player"
	<#
	Try {
	$VLC = Get-EvergreenApp -Name VideoLanVlcPlayer | Where-Object {$_.Architecture -eq "x64" -and $_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	#>
	Try {
		$URLVLC = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
		$webRequestVLC = Invoke-WebRequest -UseBasicParsing -Uri ($URLVLC) -SessionVariable websession
		$regexAppVLC = "<VLCVer>([A-Za-z0-9]+(\.[A-Za-z0-9]+)+)</VLCVer>"
		$VerVLC = $webRequestVLC.RawContent | Select-String -Pattern $regexAppVLC -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
		$VerVLC = $VerVLC.Split('"<')
		$VerVLC = $VerVLC.Split('">')
		$VersionVLC = $VerVLC[2]
		$regexVLCURL = "<VLCx64Download>.*"
		$DLURLVLC = $webRequestVLC.RawContent | Select-String -Pattern $regexVLCURL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
		$DLURLVLC = $DLURLVLC.Split('"<')
		$DLURLVLC = $DLURLVLC.Split('">')
		$URL = $DLURLVLC[2]
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[version]$Version = $VersionVLC
	#$URL = $VLC.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product" 
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available" 
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Download Mozilaa Firefox
IF ($SoftwareSelection.Firefox -eq $true) {
	$Product = "Mozilla Firefox"
	Try {
		$Firefox = Get-EvergreenApp -Name MozillaFirefox | Where-Object {$_.Channel -eq "Current" -and $_.Architecture -eq "x64" -and $_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
	}
	[version]$Version = $Firefox.Version
	IF ($SoftwareSelection.FirefoxDE -eq $true) {
		$URL = 'https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=de'
		$PackageName = "Firefox_DE"
	}
	ELSE {
		$URL = $Firefox.uri
		$PackageName = "Firefox"
	}
	[version]$Version = $Version
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product" 
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available" 
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		IF (($SoftwareSelection.FirefoxEN -eq $true) -or ($SoftwareSelection.FirefoxDE -eq $true)) {
			Try {
				Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
			} catch {
				throw $_.Exception.Message
			}
		}
		ELSE {
			Write-Host -ForegroundColor Red "Download aborted, please select a language for $Product"
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Download FileZilla Client
IF ($SoftwareSelection.FileZilla -eq $true) {
	$Product = "FileZilla"
	$PackageName = "FileZilla"
	$URLFilezilla = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
	$webRequestFilezilla = Invoke-WebRequest -UseBasicParsing -Uri ($URLFilezilla) -SessionVariable websession
	$regexAppFilezilla = "<FileZillax64Download>.*"
	$UrlFilezilla = $webRequestFilezilla.RawContent | Select-String -Pattern $regexAppFilezilla -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
    $UrlFilezilla = $UrlFilezilla.Split('"<')
    $UrlFilezilla = $UrlFilezilla.Split('">')
	$UrlFilezilla = $UrlFilezilla[2]
	$FileZillaFileName = [System.IO.Path]::GetFileName($URLFilezilla)
	if ($FileZillaFileName -match '_([0-9.]+)_([a-zA-Z0-9-]+)\.exe') {
		$Version = $matches[1]
    }
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product" 
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available" 
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $UrlFilezilla -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging" 
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download BIS-F
IF ($SoftwareSelection.BISF -eq $true) {
	$Product = "BIS-F"
	$PackageName = "setup-BIS-F"
	Try {
	$BISF = Get-EvergreenApp -Name BISF -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($BISF.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {	
		[Version]$Version = $BISF.Version
		}
	$URL = $BISF.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.ps1, SubCall -Recurse
		Start-Transcript $LogPS
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.ps1, *.log, SubCall -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WorkspaceApp Current
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true) {
	$Product = "WorkspaceApp"
	$PackageName = "CitrixWorkspaceApp"
	Try {
	$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Stream -eq "Current"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[version]$Version = $WSA.Version
	$URL = $WSA.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product CR"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF (!(Test-Path "$SoftwareFolder\Citrix\$Product\Windows\Current\windowsdesktop-runtime-8.0.25-win-x86.exe")) {
			Try {
			Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.25/windowsdesktop-runtime-8.0.25-win-x86.exe" -OutFile "$SoftwareFolder\Citrix\$Product\Windows\Current\windowsdesktop-runtime-8.0.25-win-x86.exe"
			} catch {
			throw $_.Exception.Message
			}
		}

	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\Current")) {New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\Windows\Current\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\Windows\Current\*" -Exclude "windowsdesktop-runtime-8.0.25-win-x86.exe" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version Current Release"
		Try {
		Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\Windows\Current\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Copy-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\CitrixWorkspaceApp.exe" -Destination "$SoftwareFolder\Citrix\$Product\Windows\Current\CitrixWorkspaceAppWeb.exe" | Out-Null
		# MS Team VDI Plugin
		start-sleep 5
		Try {
			Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/0/e/30e54a38-eb74-44dc-9755-36dcac09656d/MsTeamsPluginCitrix.msi" -OutFile "$SoftwareFolder\Citrix\$Product\Windows\Current\MsTeamsPluginCitrix.msi"
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\Current\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Download Microsoft EdgeWebView2 Runtime
IF ($SoftwareSelection.WorkspaceApp_CR -eq $true -or $SoftwareSelection.WorkspaceApp_LTSR -eq $true -or $SoftwareSelection.MSEdge -eq $true) {
	$Product = "MS Edge WebView2 Runtime"
	$PackageName = "MicrosoftEdgeWebView2RuntimeInstallerX64"
	Try {
	$MEWV2RT = Get-EvergreenApp -Name MicrosoftEdgeWebView2Runtime | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MEWV2RT.Version
	$URL = $MEWV2RT.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		if (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version Current Release"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WorkspaceApp LTSR
IF ($SoftwareSelection.WorkspaceApp_LTSR -eq $true) {
	$Product = "WorkspaceApp"
	$PackageName = "CitrixWorkspaceApp"
	Try {
	$WSA = Get-EvergreenApp -Name CitrixWorkspaceApp | Where-Object {$_.Stream -eq "LTSR"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[version]$Version = $WSA.Version
	$URL = $WSA.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product LTSR"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF (!(Test-Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\windowsdesktop-runtime-10.0.12-win-x86.exe")) {
			Try {
			Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.12/windowsdesktop-runtime-10.0.12-win-x86.exe" -OutFile "$SoftwareFolder\Citrix\$Product\Windows\LTSR\windowsdesktop-runtime-10.0.12-win-x86.exe"
			} catch {
			throw $_.Exception.Message
			}
		}
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR")) {New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\Windows\LTSR\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\Windows\LTSR\*" -Exclude "windowsdesktop-runtime-10.0.12-win-x86.exe" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version LTSR Release"
		Try {
		Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\Windows\LTSR\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Copy-Item -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\CitrixWorkspaceApp.exe" -Destination "$SoftwareFolder\Citrix\$Product\Windows\LTSR\CitrixWorkspaceAppWeb.exe" | Out-Null
		# MS Team VDI Plugin
		start-sleep 5
		Try {
			Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/0/e/30e54a38-eb74-44dc-9755-36dcac09656d/MsTeamsPluginCitrix.msi" -OutFile "$SoftwareFolder\Citrix\$Product\Windows\LTSR\MsTeamsPluginCitrix.msi"
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\Windows\LTSR\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download 7-ZIP
IF ($SoftwareSelection.SevenZip -eq $true) {
	$Product = "7-Zip"
	$PackageName = "7-Zip_x64"
	Try {
	$7Zip = Get-EvergreenApp -Name 7zip | Where-Object {$_.Architecture -eq "x64" -and $_.Type -like "exe"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $7Zip.Version
	$URL = $7Zip.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Adobe Reader DC MUI Update
IF ($SoftwareSelection.AdobeReaderDC_MUI -eq $true) {
	$Product = "Adobe Reader DC MUI"
	$PackageName = "Adobe_DC_MUI_Update"
	Try {
	$Adobe = Get-EvergreenApp -Name AdobeAcrobatDC | Where-Object {$_.Architecture -eq "x86" -and $_.Product -eq "ReaderMUI"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product"
		}
	$Version = $Adobe.Version
	$URL = $Adobe.uri
	$InstallerType = "msp"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Adobe Reader DC MUI x64 Update
IF ($SoftwareSelection.AdobeReaderDCx64_MUI -eq $true) {
	$Product = "Adobe Reader DC x64 MUI"
	$PackageName = "Adobe_DC_MUI_x64_Update"
	Try {
		$Adobe = Get-EvergreenApp -Name AdobeAcrobatDC | Where-Object {$_.Architecture -eq "x64" -and $_.Product -eq "ReaderMUI"} -ErrorAction Stop
		} catch {
			Write-Warning "Failed to find update of $Product"
			}
		$Version = $Adobe.Version
		$URL = $Adobe.uri
		$InstallerType = "msp"
		$Source = "$PackageName" + "." + "$InstallerType"
		$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
		Write-Host -ForegroundColor Yellow "Download $Product"
		Write-Host "Download Version: $Version"
		Write-Host "Current Version: $CurrentVersion"
		IF ($Version) {
			IF (!($CurrentVersion -eq $Version)) {
			Write-Host -ForegroundColor Green "Update available"
			IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
			$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
			Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, *.log, Version.txt, Download* -Recurse
			Start-Transcript $LogPS | Out-Null
			New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
			Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
			Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
			#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
			Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
			Write-Host "Stop logging"
			IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
			Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
			Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
			}
			Stop-Transcript | Out-Null
			Write-Output ""
			}
			ELSE {
			Write-Host -ForegroundColor Yellow "No new version available"
			Write-Output ""
			}
		}
		ELSE {
			Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
			Write-Output ""
		}
	}


# Download FSLogix
IF ($SoftwareSelection.FSLogix -eq $true) {
	$Product = "FSLogix"
	$PackageName = "FSLogixAppsSetup"
	Try {
	$FSLogix = Get-EvergreenApp -Name MicrosoftFSLogixApps -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	[version]$Version = '3.26.826.17182' 
	$URL = $FSLogix.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Install\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\Install")) {New-Item -Path "$SoftwareFolder\$Product\Install" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\Install\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\Install\*" -Recurse
		New-Item -Path "$SoftwareFolder\$Product\Install" -ItemType Directory -EA SilentlyContinue
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product\Install" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Install\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\Install\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		expand-archive -path "$SoftwareFolder\$Product\Install\FSLogixAppsSetup.zip" -destinationpath "$SoftwareFolder\$Product\Install"
		Remove-Item -Path "$SoftwareFolder\$Product\Install\Win32" -Force -Recurse
        $FSLogixDir = (Get-ChildItem -Path "$SoftwareFolder\$Product\Install" -Directory).Name
		start-sleep -Seconds 5
		Remove-Item -Path "$SoftwareFolder\$Product\Install\FSLogixAppsSetup.zip" -Force
		Move-Item -Path "$SoftwareFolder\$Product\Install\$FSLogixDir\Release\*" -Destination "$SoftwareFolder\$Product\Install"
		Get-ChildItem -Path "$SoftwareFolder\$Product\Install\$FSLogixDir\*.adm*" | Copy-Item -Destination (New-Item -Type Directory -Force ("$SoftwareFolder\_ADMX\FSLogix")) -Force -EA SilentlyContinue
        Remove-Item -Path "$SoftwareFolder\$Product\Install\$FSLogixDir" -Force -Recurse
		Write-Host "Stop logging"
		IF (!(Get-ChildItem -Path "$SoftwareFolder\$Product\Install\*.exe")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\Install\*"  -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download NEW MS Teams
IF ($SoftwareSelection.NEWMSTeams -eq $true) {
	$Product = "MS Teams 2"
	$PackageName = "MSTeams-x64"
	Try {
	$NEWTeams = Get-EvergreenApp -Name MicrosoftTeams -WarningAction silentlyContinue | Where-Object { $_.Architecture -eq "x64" -and $_.Release -eq "Enterprise" -and $_.Type -eq "msix"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $NEWTeams.Version
	$URL = $NEWTeams.uri
	$InstallerType = "msix"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download MS Teams 2.x"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.msix, *.exe, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		[Console]::WriteLine()
		Write-Host -ForegroundColor Yellow "Download Microsoft Teams 2 Bootstrapper"
		Try {
			start-sleep -seconds 3
			Invoke-WebRequest -Uri  "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409" -OutFile ("$SoftwareFolder\$Product\teamsbootstrapper.exe")
		} catch {
		throw $_.Exception.Message
		}	
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msix, *.exe, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS OneDrive
IF ($SoftwareSelection.MSOneDrive -eq $true) {
	$Product = "MS OneDrive"
	$PackageName = "OneDriveSetup"
	Try {
	$OneDrive = Get-EvergreenApp -Name MicrosoftOneDrive | Where-Object {$_.Ring -eq "Production" -and $_.Type -eq "exe" -and $_.Architecture -eq "x64"} | Select-Object -First 1
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $OneDrive.Version
	$URL = $OneDrive.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS 365Apps Semi Annual Channel
IF ($SoftwareSelection.MS365Apps_SAC -eq $true) {
	$Product = "MS 365 Apps-Semi Annual Channel"
	$PackageName = "setup"
	Write-Host -ForegroundColor Red "$Product is not available anymore, please switch to monthly channel (create a new configuratiom XML file)"
	Write-Output ""
	IF (!(Test-Path -Path "$SoftwareFolder\MS 365 Apps-Monthly Enterprise Channel")) {New-Item -Path "$SoftwareFolder\MS 365 Apps-Monthly Enterprise Channel" -ItemType Directory | Out-Null}
<#
	Try {
	$MS365Apps_SAC = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "SemiAnnual"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MS365Apps_SAC.Version
	$URL = $MS365Apps_SAC.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MS365Apps_SACUpdate = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
#>
}


# Download MS 365Apps Monthly Enterprise Channel
IF ($SoftwareSelection.MS365Apps_MEC -eq $true) {
	$Product = "MS 365 Apps-Monthly Enterprise Channel"
	$PackageName = "setup"
	Try {
	$MS365Apps_MEC = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "MonthlyEnterprise"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MS365Apps_MEC.Version
	$URL = $MS365Apps_MEC.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MS365Apps_MECUpdate = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru 
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Office 2019 VL
IF ($SoftwareSelection.MSOffice2019 -eq $true) {
	$Product = "MS Office 2019"
	$PackageName = "setup"
	Try {
	$MSOffice2019 = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "PerpetualVL2019"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSOffice2019.Version
	$URL = $MSOffice2019.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MSOffice_Update = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Office 2021 VL
IF ($SoftwareSelection.MSOffice2021 -eq $true) {
	$Product = "MS Office 2021 LTSC"
	$PackageName = "setup"
	Try {
	$MSOffice2021 = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "PerpetualVL2021"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSOffice2021.Version
	$URL = $MSOffice2021.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MSOffice_Update = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Office 2024 VL
IF ($SoftwareSelection.MSOffice2024 -eq $true) {
	$Product = "MS Office 2024 LTSC"
	$PackageName = "setup"
	Try {
	$MSOffice2024 = Get-EvergreenApp -Name Microsoft365Apps | Where-Object {$_.Channel -eq "PerpetualVL2024"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSOffice2024.Version
	$URL = $MSOffice2024.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, *.txt -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version. Please wait, this can take a while..."
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		$ConfigurationXMLFile = (Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml).Name
			if (!(Get-ChildItem -Path "$SoftwareFolder\$Product" -Filter *.xml)) {
				Write-Output ""
				Write-Host -ForegroundColor DarkRed "Attention! No configuration file found, Office cannot be downloaded, please create a XML file!" }
			else {
				  $UpdateArgs = "/Download `"$SoftwareFolder\$Product\$ConfigurationXMLFile`""
				  $MSOffice_Update = Start-Process `"$SoftwareFolder\$Product\setup.exe`" -ArgumentList $UpdateArgs -Wait -PassThru
				  Get-ChildItem -Path "$SoftwareFolder\$Product\Office\Data" | where {$_.LastWriteTime -le $(get-date).Adddays(-40)} | Remove-Item -recurse
				  }
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.txt -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS Powershell
IF ($SoftwareSelection.MSPowershell -eq $true) {
	$Product = "MS Powershell"
	$PackageName = "Powershell"
	Try {
	$MSPowershell = Get-EvergreenApp -Name MicrosoftPowerShell | Where-Object {$_.Architecture -eq "x64" -and $_.Release -eq "Stable" -and $_.Type -eq "msi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
	}
	IF ($MSPowershell.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $MSPowershell.Version
		}
	$URL = $MSPowershell.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS .Net Desktop Runtime
IF ($SoftwareSelection.MSDotNetDesktopRuntime -eq $true) {
	$Product = "MS DotNet Desktop Runtime"
	$PackageName = "windowsdesktop-runtime-win-x86-runtime"
	Try {
	$MSDotNetDesktopRuntime = Get-EvergreenApp -Name Microsoft.NET | Where-Object {$_.Architecture -eq "x86" -and $_.Channel -eq "LTS" -and $_.Installer -eq "windowsdesktop"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSDotNetDesktopRuntime.Version
	$URL = $MSDotNetDesktopRuntime.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS .Net Runtime
IF ($SoftwareSelection.MSDotNetRuntime -eq $true) {
	$Product = "MS DotNet Runtime"
	$PackageName = "dotnet-runtime-win-x64-runtime"
	Try {
	$MSDotNetRuntime = Get-EvergreenApp -Name Microsoft.NET | Where-Object {$_.Architecture -eq "x64" -and $_.Channel -eq "LTS" -and $_.Installer -eq "runtime"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSDotNetRuntime.Version
	$URL = $MSDotNetRuntime.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS SQL Management Studio en
IF ($SoftwareSelection.MSSsmsEN -eq $true) {
	$Product = "MS SQL Management Studio EN"
	Write-Host -ForegroundColor Yellow "Download $Product"
	# Write-Host -ForegroundColor Red "Download for $Product currently not available, working on a solution for version 21.x"
	# Write-Output ""
	$PackageName = "vs_SSMS"
	Try {
	$MSSQLManagementStudioEN = Get-EvergreenApp -Name MicrosoftSsms -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSQLManagementStudioEN.Version
	$URL = $MSSQLManagementStudioEN.URI
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Start-sleep -s 5
		Write-Host -ForegroundColor Yellow "`nCreating layout for offline installation, please wait..."
		Try {
			Start-Process -FilePath "$SoftwareFolder\$Product\vs_SSMS.exe" -ArgumentList "--layout `"$SoftwareFolder\$Product\SSMS_Layout`" --lang en-us --quiet --wait" -Wait -WindowStyle Hidden -Verb RunAs
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MS SQL Management Studio de
IF ($SoftwareSelection.MSSsmsDE -eq $true) {
	$Product = "MS SQL Management Studio DE"
	Write-Host -ForegroundColor Yellow "Download $Product"
	# Write-Host -ForegroundColor Red "Download for $Product currently not available, working on a solution for version 21.x"
	# Write-Output ""
	$PackageName = "vs_SSMS"
	Try {
	$MSSQLManagementStudioDE = Get-EvergreenApp -Name MicrosoftSsms -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSQLManagementStudioDE.Version
	$URL = $MSSQLManagementStudioDE.URI
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Start-sleep -s 5
		Write-Host -ForegroundColor Yellow "`nCreating layout for offline installation, please wait..."
		Try {
			Start-Process -FilePath "$SoftwareFolder\$Product\vs_SSMS.exe" -ArgumentList "--layout `"$SoftwareFolder\$Product\SSMS_Layout`" --lang en-us --quiet --wait" -Wait -WindowStyle Hidden -Verb RunAs
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Download MS Sysinternals Suite
IF ($SoftwareSelection.MSSysinternals -eq $true) {
	$Product = "MS Sysinternals Suite"
	$PackageName = "SysinternalsSuite"
	Write-Host -ForegroundColor Red "Download for $Product currently not available, working on a solution..."
	Write-Output ""
	<#	
	Try {
	$MSSysinternals = Get-NevergreenApp -Name MicrosoftSysinternals | Where-Object {$_.Name -eq "Microsoft Sysinternals Suite" -and $_.Architecture -eq "Multi"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSSysinternals.Version
	$URL = $MSSysinternals.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
	#>
}


<#
# Download MS WVD Desktop Agent
IF ($SoftwareSelection.MSWVDDesktopAgent -eq $true) {
$Product = "MS WVD Desktop Agent"
$PackageName = "Microsoft.RDInfra.RDAgent.Installer-x64"
$MSWVDDesktopAgent = Get-EvergreenApp -Name MicrosoftWvdInfraAgent
$Version = $MSWVDDesktopAgent.Version
$URL = $MSWVDDesktopAgent.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor Green "Update available"
IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
Remove-Item "$SoftwareFolder\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}


# Download MS WVD Boot Loader
IF ($SoftwareSelection.MSWVDBootLoader -eq $true) {
$Product = "MS WVD Boot Loader"
$MSWVDBootLoader = Get-EvergreenApp -Name MicrosoftWvdBootloader
$PackageName = $MSWVDBootLoader.Filename
$URL = $MSWVDBootLoader.uri
Write-Host -ForegroundColor Yellow "Download $Product"
IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
Remove-Item "$SoftwareFolder\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
Write-Host -ForegroundColor Yellow "Starting Download of $Product"
#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($PackageName))
Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}


# Download MS WVD WebSocket Service
IF ($SoftwareSelection.MSWVDRTCService -eq $true) {
	$Product = "MS WVD RTC Service for Teams"
	$PackageName = "MsRdcWebRTCSvc_HostSetup_x64"
	Try {
	$MSWVDRTCService = Get-EvergreenApp -Name MicrosoftWvdRtcService
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
		$Version = $MSWVDRTCService.Version
		$URL = $MSWVDRTCService.uri
		$InstallerType = "msi"
		$Source = "$PackageName" + "." + "$InstallerType"
		$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
		Write-Host -ForegroundColor Yellow "Download $Product"
		Write-Host "Download Version: $Version"
		Write-Host "Current Version: $CurrentVersion"
		IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		Write-Host "Stop logging"
		Stop-Transcript | Out-Null
		Write-Output ""
		}
			ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}
#>

# Download Citrix VM Tools
IF ($SoftwareSelection.CitrixVMTools -eq $true) {
	$Product = "Citrix VM Tools"
	$PackageName = "managementagentx64"
	<#
	Try {
	$CitrixTools = Get-EvergreenApp -Name CitrixVMTools | Where-Object {$_.Architecture -eq "x64"} | Select-Object -First 1
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $CitrixTools.Version
	$URL = $CitrixTools.uri
	#>
	$URLVersionCitrixVMTools = "https://www.xenserver.com/downloads"
	$VersionCitrixVMTools = $null
	$URL = $null

	try {
		$ResponseCitrixVMTools = Invoke-WebRequest -UseBasicParsing -Uri $URLVersionCitrixVMTools -ErrorAction Stop

		$HtmlCitrixVMTools = [System.Net.WebUtility]::HtmlDecode(
			[string]$ResponseCitrixVMTools.Content
		)

		# Version aus dem Dateinamen managementagentx64-VERSION.msi lesen.
		# Das Versionsverzeichnis muss dabei nicht dem Dateinamen entsprechen.
		$PatternCitrixVMTools = 'https://downloads\.xenserver\.com/vm-tools-windows/[^/"\s]+/managementagentx64-(\d+(?:\.\d+){2,3})\.msi'

		$MatchCitrixVMTools = [regex]::Match(
			$HtmlCitrixVMTools,
			$PatternCitrixVMTools,
			[System.Text.RegularExpressions.RegexOptions]::IgnoreCase
		)

		if ($MatchCitrixVMTools.Success) {
			$VersionTextCitrixVMTools = $MatchCitrixVMTools.Groups[1].Value
			$ParsedVersionCitrixVMTools = $null

			if ([version]::TryParse($VersionTextCitrixVMTools, [ref]$ParsedVersionCitrixVMTools)) {
				$VersionCitrixVMTools = $ParsedVersionCitrixVMTools
				$URL = $MatchCitrixVMTools.Value

				Write-Host -ForegroundColor Green "Detected Citrix VM Tools version: $VersionCitrixVMTools"
				# Write-Host "Download URL: $URL"
			}
			else {
				Write-Host -ForegroundColor Red "Invalid Citrix VM Tools version: '$VersionTextCitrixVMTools'"
			}
		}
		else {
			Write-Host -ForegroundColor Red 'Not able to get version of Citrix VM Tools: x64 MSI link was not found.'
		}
	}
	catch {
		Write-Host -ForegroundColor Red "Not able to get version of Citrix VM Tools: $($_.Exception.Message)"
	}
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$URL = "https://downloads.xenserver.com/vm-tools-windows/9.6.0/managementagentx64-9.6.0.msi"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionCitrixVMTools"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionCitrixVMTools -and $URL) {
		IF ($VersionCitrixVMTools -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product")) {New-Item -Path "$SoftwareFolder\Citrix\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\" + "$Product $VersionCitrixVMTools.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -Value "$VersionCitrixVMTools"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionCitrixVMTools"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Citrix XenCenter
IF ($SoftwareSelection.CitrixXenCenter -eq $true) {
	$Product = "Citrix XenCenter"
	$PackageName = "XenCenter"
	$URLVersionCitrixXenCenter = 'https://www.xenserver.com/downloads'
	$VersionCitrixXenCenter = $null
	$URL = $null

	try {
		$ResponseCitrixXenCenter = Invoke-WebRequest -UseBasicParsing -Uri $URLVersionCitrixXenCenter -ErrorAction Stop

		$HtmlCitrixXenCenter = [System.Net.WebUtility]::HtmlDecode(
			[string]$ResponseCitrixXenCenter.Content
		)

		# Gruppe 1: Version im Verzeichnis.
		# Der Dateiname muss dieselbe Version enthalten.
		$PatternCitrixXenCenter = 'https://downloads\.xenserver\.com/xencenter/(\d+(?:\.\d+){2,3})/XenCenter-\1\.msi'

		$MatchCitrixXenCenter = [regex]::Match(
			$HtmlCitrixXenCenter,
			$PatternCitrixXenCenter,
			[System.Text.RegularExpressions.RegexOptions]::IgnoreCase
		)

		if ($MatchCitrixXenCenter.Success) {
			$ParsedVersionCitrixXenCenter = $null
			$VersionTextCitrixXenCenter = $MatchCitrixXenCenter.Groups[1].Value

			if ([version]::TryParse($VersionTextCitrixXenCenter, [ref]$ParsedVersionCitrixXenCenter)) {
				$VersionCitrixXenCenter = $ParsedVersionCitrixXenCenter
				$URL = $MatchCitrixXenCenter.Value

				Write-Host -ForegroundColor Green "Detected XenCenter version: $VersionCitrixXenCenter"
				#Write-Host "Download URL: $URL"
			}
			else {
				Write-Host -ForegroundColor Red "Invalid XenCenter version: '$VersionTextCitrixXenCenter'"
			}
		}
		else {
			Write-Host -ForegroundColor Red 'Not able to get version of Citrix XenCenter: MSI link was not found.'
		}
	}
	catch {
		Write-Host -ForegroundColor Red "Not able to get version of Citrix XenCenter: $($_.Exception.Message)"
	}
    $InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$URL = "https://downloads.xenserver.com/xencenter/$VersionCitrixXenCenter/XenCenter-$VersionCitrixXenCenter.msi"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionCitrixXenCenter"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionCitrixXenCenter -and $URL) {
		IF ($VersionCitrixXenCenter -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product")) {New-Item -Path "$SoftwareFolder\Citrix\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\Citrix\$Product\" + "$Product $VersionCitrixXenCenter.log"
		Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\Citrix\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\Citrix\$Product\Version.txt" -Value "$VersionCitrixXenCenter"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionCitrixXenCenter"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\Citrix\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\Citrix\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\Citrix\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download VMWareTools
IF ($SoftwareSelection.VMWareTools -eq $true) {
	$Product = "VMWare Tools"
	$PackageName = "VMWareTools"
	Try {
	$VMWareTools = Get-EvergreenApp -Name VMwareTools | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $VMWareTools.Version
	$URL = $VMWareTools.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download deviceTRUST
IF ($SoftwareSelection.deviceTRUST -eq $true) {
	$Product = "deviceTRUST"
	$PackageName = "deviceTRUST"
	Try {
	$deviceTRUST = Get-EvergreenApp -Name deviceTRUST  | Where-Object {$_.Platform -eq "Windows" -and $_.Type -eq "Bundle"} | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $deviceTRUST.Version
	$URL = $deviceTRUST.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
			} catch {
			throw $_.Exception.Message
		}
		expand-archive -path "$SoftwareFolder\$Product\deviceTRUST.zip" -destinationpath "$SoftwareFolder\$Product" -EA SilentlyContinue
		expand-archive -path "$SoftwareFolder\$Product\dtpolicydefinitions-$Version.zip" -destinationpath "$SoftwareFolder\$Product\ADMX" -EA SilentlyContinue
		start-sleep -Seconds 10
		Get-ChildItem -Path "$SoftwareFolder\$Product\ADMX" | Copy-Item -Destination (New-Item -Type directory -Force ("$SoftwareFolder\_ADMX\deviceTRUST")) -Force -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\deviceTRUST.zip" -Force -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\ADMX" -Force -Recurse -EA SilentlyContinue
		Remove-Item -Path "$SoftwareFolder\$Product\dtpolicydefinitions-$Version.zip" -Force -EA SilentlyContinue
		Get-ChildItem -Path "$SoftwareFolder\$Product" | Where-Object Name -like *"x86"* | Remove-Item -EA SilentlyContinue
		Write-Host "Stop logging"
		IF (!(Get-ChildItem -Path "$SoftwareFolder\$Product\*.msi")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Microsoft openJDK 21
IF ($SoftwareSelection.MicrosoftOpenJDK -eq $true) {
	$Product = "Microsoft OpenJDK 21"
	$PackageName = "MicrosoftOpenJDK"
	Try {
		$MicrosoftOpenJDK = Get-EvergreenApp -Name MicrosoftOpenJDK21 | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MicrosoftOpenJDK.version
		IF ($Version -like "*+*") {
			$Version = [version]$Version.Replace("+", ".")
		}
	$URL = $MicrosoftOpenJDK.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt"
		IF ((Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -Raw).Trim().Length -eq 0) {
			Remove-Item -Path "$SoftwareFolder\$Product\Version.txt" -Force
		}
		IF ($CurrentVersion -like "*+*") {
			$CurrentVersion = [version]$CurrentVersion.Replace("+", ".")
		}
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download OracleJava8 64-Bit
IF ($SoftwareSelection.OracleJava8 -eq $true) {
	$Product = "Oracle Java 8 x64"
	$PackageName = "Oracle Java 8 x64"
	Try {
	$OracleJava8 = Get-EvergreenApp -Name OracleJava8 | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$VersionOracle8_x64 = $OracleJava8.Version
	$VersionOracle8_x64 = $VersionOracle8_x64 -replace ".{4}$"
	#$VersionOracle8_x64 = $VersionOracle8_x64.Substring(2)
	[Version]$VersionOracle8_x64 = $VersionOracle8_x64 -replace "_","."
	$URL = $OracleJava8.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionOracle8_x64"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionOracle8_x64) {
		IF ($VersionOracle8_x64 -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionOracle8_x64.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionOracle8_x64"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionOracle8_x64"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download OracleJava8 32-Bit
IF ($SoftwareSelection.OracleJava8_32 -eq $true) {
	$Product = "Oracle Java 8 x86"
	$PackageName = "Oracle Java 8 x86"
	Try {
	$OracleJava8 = Get-EvergreenApp -Name OracleJava8 | Where-Object {$_.Architecture -eq "x86"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$VersionOracle8_x86 = $OracleJava8.Version
	$VersionOracle8_x86 = $VersionOracle8_x86 -replace ".{4}$"
	[Version]$VersionOracle8_x86 = $VersionOracle8_x86 -replace "_","."
	$URL = $OracleJava8.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	[Version]$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionOracle8_x86"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionOracle8_x86) {
		IF ($VersionOracle8_x86 -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionOracle8_x86.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionOracle8_x86"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionOracle8_x86"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download KeePass
IF ($SoftwareSelection.KeePass -eq $true) {
	$Product = "KeePass"
	$PackageName = "KeePass"
	Try {
	$KeePass = Get-EvergreenApp -Name KeePass | Where-Object {$_.Type -like "*exe*"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $KeePass.Version
	$URL = $KeePass.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download KeePassXC
IF ($SoftwareSelection.KeePassXC -eq $true) {
	$Product = "KeePassXC"
	$PackageName = "KeePassXC"
	Try {
	$KeePassXC = Get-EvergreenApp -Name KeePassXCTeamKeePassXC | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($KeePassXC.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $KeePassXC.Version
		}
	$URL = $KeePassXC.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, *.log, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download IGEL Universal Management Suite
IF ($SoftwareSelection.IGELUniversalManagementSuite -eq $true) {
	$Product = "IGEL Universal Management Suite"
	$PackageName = "setup-igel-ums-windows"
	Try {
	$IGELUniversalManagementSuite = Get-NevergreenApp -Name IGELUniversalManagementSuite -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $IGELUniversalManagementSuite.Version
	$URL = $IGELUniversalManagementSuite.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download mRemoteNG
IF ($SoftwareSelection.mRemoteNG -eq $true) {
	$Product = "mRemoteNG"
	$PackageName = "mRemoteNG"
	Try {
	$mRemoteNG = Get-EvergreenApp -Name mRemoteNG | Where-Object {$_.URI -like "*msi*"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($mRemoteNG.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $mRemoteNG.Version
		}
	$URL = $mRemoteNG.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Tree Size Free
IF ($SoftwareSelection.TreeSizeFree -eq $true) {
	$Product = "TreeSizeFree"
	$PackageName = "TreeSizeFree"
	Try {
	$TreeSizeFree = Get-EvergreenApp -Name JamTreeSizeFree -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $TreeSizeFree.Version
	$URL = $TreeSizeFree.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WinSCP
IF ($SoftwareSelection.WinSCP -eq $true) {
	$Product = "WinSCP"
	$PackageName = "WinSCP"
	Try {
		$URLWinSCP = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
		$webRequestWinSCP = Invoke-WebRequest -UseBasicParsing -Uri ($URLWinSCP) -SessionVariable websession
		$regexAppWinSCP = "<WinSCPVer>([A-Za-z0-9]+(\.[A-Za-z0-9]+)+)</WinSCPVer>"
		$UrlWinSCP = $webRequestWinSCP.RawContent | Select-String -Pattern $regexAppWinSCP -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
		$UrlWinSCP = $UrlWinSCP.Split('"<')
		$UrlWinSCP = $UrlWinSCP.Split('">')
		$VersionWinSCP = $UrlWinSCP[2]
		$regexAppWinSCPDL = "<WinSCPDownload>.*"
		$UrlWinSCPDL = $webRequestWinSCP.RawContent | Select-String -Pattern $regexAppWinSCPDL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
		$UrlWinSCPDL = $UrlWinSCPDL.Split('"<')
		$UrlWinSCPDL = $UrlWinSCPDL.Split('">')
		$UrlWinSCPDL = $UrlWinSCPDL[2]

	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionWinSCP"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionWinSCP) {
		IF ($VersionWinSCP -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionWinSCP.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionWinSCP"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionWinSCP"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $UrlWinSCPDL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


<#
# Download WinSCP
IF ($SoftwareSelection.WinSCP -eq $true) {
	$Product = "WinSCP"
	$PackageName = "WinSCP"
	Try {
	$WinSCP = Get-EvergreenApp -Name WinSCP | Where-Object {$_.Type -eq "exe"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $WinSCP.Version
	$URL = $WinSCP.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}
#>


# Download Putty
IF ($SoftwareSelection.Putty -eq $true) {
	$Product = "Putty"
	$PackageName = "Putty"
	Try {
	$putty = Get-EvergreenApp -Name PuTTY | Where-Object {$_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $putty.Version
	$URL = $putty.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}



# Download ControlUp Console
IF ($SoftwareSelection.ControlUpConsole -eq $true) {
	$Product = "ControlUp Console"
	$PackageName = "ControlUpConsole"
	Try {
	$ControlUpConsole = Get-EvergreenApp -Name ControlUpConsole -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ControlUpConsole.Version
	$URL = $ControlUpConsole.uri
	$InstallerType = "zip"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		#expand-archive -path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -destinationpath "$SoftwareFolder\$Product"  
		#start-sleep -Seconds 5
		#Remove-Item -Path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -Force
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download ControlUp DX client
IF ($SoftwareSelection.ControlUpRemoteDX -eq $true) {
	$Product = "ControlUp DX Client"
	$PackageName = "curdx_windows_citrix"
	Try {
	$ControlUpRemoteDX = Get-EvergreenApp -Name ControlUpRemoteDX | Where-Object {$_.Plugin -like "Citrix*"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ControlUpRemoteDX.Version
	$URL = $ControlUpRemoteDX.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		#expand-archive -path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -destinationpath "$SoftwareFolder\$Product"  
		#start-sleep -Seconds 5
		#Remove-Item -Path "$SoftwareFolder\$Product\Install\ControlUpConsole.zip" -Force
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Zoom VDI Installer
IF ($SoftwareSelection.ZoomVDI -eq $true) {
	$Product = "Zoom VDI Host"
	$PackageName = "ZoomInstallerVDI"
	Try {
	$ZoomVDI = Get-EvergreenApp -Name ZoomVDI | Where-Object {$_.Platform -eq "VDIClient" -and $_.Type -eq "msi" -and $_.Architecture -eq "x64"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$URLVersionZoom = "https://support.zoom.com/hc/de/article?id=zm_kb&sysparm_article=KB0063813#collapseGeneric52"
	$webRequestZoom = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionZoom) -SessionVariable websession
	$regexAppVersionZoom = "\d\.\d\d\.\d"
	$webVersionZoom = $webRequestZoom.RawContent | Select-String -Pattern $regexAppVersionZoom -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	[Version]$Version = $webVersionZoom.Trim("</td>").Trim("</td>")
	$URL = $ZoomVDI.Uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Zoom Citrix client
IF ($SoftwareSelection.ZoomCitrix -eq $true) {
	$Product = "Zoom Citrix Client"
	$PackageName = "ZoomCitrixHDXMediaPlugin"
	Try {
	$ZoomCitrix = Get-EvergreenApp -Name ZoomVDI | Where-Object {$_.Platform -eq "Citrix"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$URLVersionZoomCitrix = "https://support.zoom.com/hc/de/article?id=zm_kb&sysparm_article=KB0063813#collapseGeneric52"
	$webRequestZoomCitrix = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionZoomCitrix) -SessionVariable websession
	$regexAppVersionZoomCitrix = "\d\.\d\d\.\d"
	$webVersionZoomCitrix = $webRequestZoomCitrix.RawContent | Select-String -Pattern $regexAppVersionZoomCitrix -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	[Version]$Version = $webVersionZoomCitrix.Trim("</td>").Trim("</td>")
	$URL = $ZoomCitrix.Uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Zoom VMWare client
IF ($SoftwareSelection.ZoomVMWare -eq $true) {
	$Product = "Zoom VMWare Client"
	$PackageName = "ZoomVMWareMediaPlugin"
	Try {
	$ZoomVMWare = Get-NevergreenApp -Name Zoom | Where-Object {$_.Name -eq "Zoom VMWare Media Plugin"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $ZoomVMWare.Version
	$URL = $ZoomVMWare.Uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

<#
# Download Cisco WebEx Desktop
IF ($SoftwareSelection.CiscoWebExDesktop -eq $true) {
$Product = "Cisco WebEx Desktop"
$PackageName = "WebEx"
$CiscoWebExDesktop = Get-NevergreenApp -Name CiscoWebEx | Where-Object {$_.Language -eq "Multi" -and $_.Name -eq "Cisco Webex"}
$Version = $CiscoWebExDesktop.Version
$URL = $CiscoWebExDesktop.uri
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
Write-Host -ForegroundColor Yellow "Download $Product"
Write-Host "Download Version: $Version"
Write-Host "Current Version: $CurrentVersion"
IF (!($CurrentVersion -eq $Version)) {
Write-Host -ForegroundColor Green "Update available"
IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
Remove-Item "$SoftwareFolder\$Product\*" -Recurse
Start-Transcript $LogPS | Out-Null
New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source)) -EA SilentlyContinue
Write-Host "Stop logging"
Stop-Transcript | Out-Null
Write-Output ""
}
IF ($CurrentVersion -eq $Version) {
Write-Host -ForegroundColor Yellow "No new version available"
Write-Output ""
}
}
#>

# Download Cisco WebEx VDI Plugin
IF ($SoftwareSelection.CiscoWebExVDI -eq $true) {
	$Product = "Cisco WebEx VDI Plugin"
	Write-Host -ForegroundColor Red "$Product currently not available in Evergreen downloader, try again later!"
	Write-Output ""
	<#
	
	$PackageName = "WebExVDIPlugin"
	$URLVersionWebExVDI = "https://www.webex.com/downloads/teams-vdi.html"
	$webRequestWebExVDI = Invoke-WebRequest -UseBasicParsing -Uri ($URLVersionWebExVDI) -SessionVariable websession
	$regexAppVersionWebExVDI = '\(\d\d\.\d\.\d\.\d\d\d\d\d\)'
	$webVersionWebExVDI = $webRequestWebExVDI.RawContent | Select-String -Pattern $regexAppVersionWebExVDI -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	$webVersionWebExVDI = $webVersionWebExVDI.TrimEnd(')').Substring(1)
	[Version]$VersionWebExVDI  = $webVersionWebExVDI
	$regexLinkWebExVDI = '<td>Windows\s<a\shref=".*"\starget="_self">64-bit</a></td>'
	$URL = $webRequestWebExVDI.RawContent | Select-String -Pattern $regexLinkWebExVDI -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
	$URL = $URL.Split('"')
	$URL = $URL[1]
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionWebExVDI"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionWebExVDI) {
		IF ($VersionWebExVDI -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionWebExVDI.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionWebExVDI"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionWebExVDI"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
	#>
}


# Download ImageGlass
IF ($SoftwareSelection.ImageGlass -eq $true) {
	$Product = "ImageGlass"
	$PackageName = "ImageGlass"
	Try {
	$ImageGlass = Get-EvergreenApp -Name ImageGlass | Where-Object {$_.Type -eq "msi"} | Select-Object -First 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($ImageGlass.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $ImageGlass.Version
		}
	$URL = $ImageGlass.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download ShareX
IF ($SoftwareSelection.ShareX -eq $true) {
	$Product = "ShareX"
	$PackageName = "ShareX"
	Try {
	$ShareX = Get-EvergreenApp -Name ShareX | Where-Object {$_.Type -eq "exe"} -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($ShareX.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $ShareX.Version
		}
	$URL = $ShareX.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Include *.exe, Version.txt, Download* -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Include *.msp, Version.txt, Download* -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download Greenshot
IF ($SoftwareSelection.Greenshot -eq $true) {
	$Product = "Greenshot"
	$PackageName = "Greenshot"
	Try {
	$Greenshot = Get-EvergreenApp -Name Greenshot | Where-Object {$_.Type -eq "exe"} | Select-Object -Last 1 -ErrorAction Stop
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	IF ($Greenshot.Version -eq "RateLimited") {
		$Version = $null
		}
	ELSE {
		$Version = $Greenshot.Version
		}
	$URL = $Greenshot.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF (!($CurrentVersion -eq $Version)) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		#Invoke-WebRequest -Uri $URL -OutFile ("$SoftwareFolder\$Product\" + ($Source))
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download FoxItReader
IF ($SoftwareSelection.FoxItReader -eq $true) {
	$Product = "FoxitReader"
	$PackageName = "FoxIt-Reader"
	Write-Host -ForegroundColor Red "Download for $Product currently not available, working on a solution..."
	Write-Output ""
<#
	Try {
	$FoxItReader = Get-EvergreenApp -Name FoxItReader | Where-Object {$_.Language -eq "German"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $FoxItReader.Version
	$URL = $FoxItReader.uri
	$InstallerType = "msi"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
#>
}


# Download VcRedist x64
IF ($SoftwareSelection.VcRedist -eq $true) {
	$Product = "Microsoft Visual C++ Redistributable packages x64"
	$PackageName = "VC_redist_x64"
	Try {
	$VcRedist = Get-VcList | Where-Object {$_.Architecture -eq "x64"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $VcRedist.Version
	$URL = $VcRedist.URI
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download VcRedist x86
IF ($SoftwareSelection.VcRedist -eq $true) {
	$Product = "Microsoft Visual C++ Redistributable packages x86"
	$PackageName = "VC_redist_x86"
	Try {
	$VcRedist = Get-VcList | Where-Object {$_.Architecture -eq "x86"}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $VcRedist.Version
	$URL = $VcRedist.URI
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download WinRAR
IF ($SoftwareSelection.WinRAR -eq $true) {
	$Product = "WinRAR"
	$PackageName = "WinRAR"
	Try {
		$URLWinRAR = "https://patchmypc.com/freeupdater/definitions/definitions.xml"
		$webRequestWinRAR = Invoke-WebRequest -UseBasicParsing -Uri ($URLWinRAR) -SessionVariable websession
		$regexAppWinRAR = "<WinRARVer>([A-Za-z0-9]+(\.[A-Za-z0-9]+)+)</WinRARVer>"
		$UrlWinRAR = $webRequestWinRAR.RawContent | Select-String -Pattern $regexAppWinRAR -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
		$UrlWinRAR = $UrlWinRAR.Split('"<')
		$UrlWinRAR = $UrlWinRAR.Split('">')
		$VersionWinRAR = $UrlWinRAR[2]
		$regexAppWinRARDL = "<WinRAR64BitDownload>.*"
		$UrlWinRARDL = $webRequestWinRAR.RawContent | Select-String -Pattern $regexAppWinRARDL -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -First 1
		$UrlWinRARDL = $UrlWinRARDL.Split('"<')
		$UrlWinRARDL = $UrlWinRARDL.Split('">')
		$UrlWinRARDL = $UrlWinRARDL[2]
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $VersionWinRAR"
	Write-Host "Current Version: $CurrentVersion"
	IF ($VersionWinRAR) {
		IF ($VersionWinRAR -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $VersionWinRAR.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$VersionWinRAR"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $VersionWinRAR"
		Try {
			Get-FileFromWeb -Url $UrlWinRARDL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Download RD Analyzer
IF ($SoftwareSelection.RDAnalyzer -eq $true) {
	$Product = "RD Analyzer"
	$PackageName = "RemoteDisplayAnalyzer"
	Try {
	$RDAnalyzer = Get-EvergreenApp -Name RDAnalyzer
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $RDAnalyzer.Version
	$URL = $RDAnalyzer.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}


# Download MSVisualStudioCode 
IF ($SoftwareSelection.MSVisualStudioCode -eq $true) {
	$Product = "MS Visual Studio Code"
	$PackageName = "VSCodeUserSetup-x64"
	Try {
	$MSVisualStudioCode  = Get-EvergreenApp -Name MicrosoftVisualStudioCode | Where-Object {$_.Channel -eq 'Stable' -and $_.Platform -eq 'win32-x64'}
	} catch {
		Write-Warning "Failed to find update of $Product because $_.Exception.Message"
		}
	$Version = $MSVisualStudioCode.Version
	$URL = $MSVisualStudioCode.uri
	$InstallerType = "exe"
	$Source = "$PackageName" + "." + "$InstallerType"
	$CurrentVersion = Get-Content -Path "$SoftwareFolder\$Product\Version.txt" -EA SilentlyContinue
	Write-Host -ForegroundColor Yellow "Download $Product"
	Write-Host "Download Version: $Version"
	Write-Host "Current Version: $CurrentVersion"
	IF ($Version) {
		IF ($Version -gt $CurrentVersion) {
		Write-Host -ForegroundColor Green "Update available"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product")) {New-Item -Path "$SoftwareFolder\$Product" -ItemType Directory | Out-Null}
		$LogPS = "$SoftwareFolder\$Product\" + "$Product $Version.log"
		Remove-Item "$SoftwareFolder\$Product\*" -Recurse
		Start-Transcript $LogPS | Out-Null
		New-Item -Path "$SoftwareFolder\$Product" -Name "Download date $Date.txt" | Out-Null
		Set-Content -Path "$SoftwareFolder\$Product\Version.txt" -Value "$Version"
		Write-Host -ForegroundColor Yellow "Starting Download of $Product $Version"
		Try {
			Get-FileFromWeb -Url $URL -File ("$SoftwareFolder\$Product\" + ($Source))
		} catch {
			throw $_.Exception.Message
		}
		Write-Host "Stop logging"
		IF (!(Test-Path -Path "$SoftwareFolder\$Product\$Source")) {
        Write-Host -ForegroundColor Red "Error downloading '$Source', try again later or check log file"
        Remove-Item "$SoftwareFolder\$Product\*" -Exclude *.log -Recurse
        }
		Stop-Transcript | Out-Null
		Write-Output ""
		}
		ELSE {
		Write-Host -ForegroundColor Yellow "No new version available"
		Write-Output ""	
		}
	}
	ELSE {
		Write-Host -ForegroundColor Red "Not able to get version of $Product, try again later!"
		Write-Output ""
	}
}

# Stop UpdateLog
Stop-Transcript | Out-Null

# Format UpdateLog
$Content = Get-Content -Path $UpdateLog | Select-Object -Skip 18
Set-Content -Value $Content -Path $UpdateLog

if ($noGUI -eq $False) {
	pause}