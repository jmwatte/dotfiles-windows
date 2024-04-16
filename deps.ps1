# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}


### Update Help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


### Package Providers
Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
Get-PackageProvider NuGet -Force | Out-Null

winget install junegunn.fzf --silent --accept-package-agreements
winget install Microsoft.PowerToys -s winget

### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
winget install JanDeDobbeleer.OhMyPosh --silent --accept-package-agreements
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force
#Install-Module -Name PSGitDotfiles -force
#Install-Module -Name PSReadLine -RequiredVersion 2.2.6
Install-Module -Name PSFzf -force 
Install-Module -Name Spotishell -force
Install-Module -Name InstallModuleFromGitHub -force
Install-Module PSEverything



# system and cli
#winget install Microsoft.WebPICmd                        --silent --accept-package-aaaaaaaaaa
winget install Git.Git                                   --silent --accept-package-agreements --override "/VerySilent /NoRestart /o:PathOption=CmdTools /Components=""icons,assoc,assoc_sh,gitlfs"""
#winget install OpenJS.NodeJS                             --silent --accept-package-agreements
winget install Python.Python.3                           --silent --accept-package-agreements
#winget install RubyInstallerTeam.Ruby                    --silent --accept-package-agreements
 

winget install JanDeDobbeleer.OhMyPosh --silent --accept-package-agreements
winget install codesector.teracopy --silent --accept-package-agreements
# browsers              --silent --accept-package-agreements
#winget install Google.Chrome                             --silent --accept-package-agreements
#winget install Mozilla.Firefox                           --silent --accept-package-agreements
#winget install Opera.Opera                               --silent --accept-package-agreements
winget install Brave.brave.beta				  --silent --accept-package-agreements
Write-Host -ForegroundColor Yellow "🌋 Force reinstall of VS-Code to ensure Path and Shell integration"
winget install --force Microsoft.VisualStudioCode --override '/VERYSILENT /SP- /MERGETASKS="!runcode,!desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'

# dev tools and frameworks
winget install Microsoft.PowerShell                      --silent --accept-package-agreements
#winget install Microsoft.SQLServer.2019.Developer        --silent --accept-package-agreements
#winget install Microsoft.SQLServerManagementStudio       --silent --accept-package-agreements
#winget install Microsoft.VisualStudio.2022.Professional  --silent --accept-package-agreements --override "--wait --quiet --norestart --nocache --addProductLang En-us --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.NetWeb"
#winget install JetBrains.dotUltimate                     --silent --accept-package-agreements --override "/SpecificProductNames=ReSharper;dotTrace;dotCover /Silent=True /VsVersion=17.0"
#winget install Vim.Vim                                   --silent --accept-package-agreements
#winget install WinMerge.WinMerge                         --silent --accept-package-agreements
#winget install Microsoft.AzureCLI                        --silent --accept-package-agreements
#winget install Microsoft.AzureStorageExplorer            --silent --accept-package-agreements
#winget install Microsoft.AzureStorageEmulator            --silent --accept-package-agreements
#winget install Microsoft.ServiceFabricRuntime            --silent --accept-package-agreements
#winget install Microsoft.ServiceFabricExplorer           --silent --accept-package-agreements
winget install  Helix.Helix				  --silent --accept-package-agreements

winget install Gyan.FFmpeg    --silent --accept-package-agreements 
winget install qBittorrent.qBittorrent			  --silent --accept-package-agreements
winget install voidtools.Everything.Alpha		          --silent --accept-package-agreements
winget install MKVToolNix				--silent --accept-package-agreements
winget install Googl.AndroidStudio    --silent --accept-package-agreements
winget install Microsoft.OpenJDK.21    --silent --accept-package-agreements
winget install sharkdp.bat
winget install sharkdp.fd
winget install  Nilesoft.Shell --silent --accept-package-agreements
winget install XBMCFoundation.Kodi --silent --accept-package-agreements
winget install Gyan.FFmpeg --silent --accept-package-agreements
winget install glazeWm --silent --accept-package-agreements
$FontName = 'meslo'
$NerdFontsURI = 'https://github.com/ryanoasis/nerd-fonts/releases'

$WebResponse = Invoke-WebRequest -Uri "$NerdFontsURI/latest" -MaximumRedirection 0 -ErrorAction SilentlyContinue

$LatestVersion = Split-Path -Path $WebResponse.Headers['Location'] -Leaf

Invoke-WebRequest -Uri "$NerdFontsURI/download/$LatestVersion/$FontName.zip" -OutFile "$FontName.zip"

Expand-Archive -Path "$FontName.zip"

$ShellApplication = New-Object -ComObject shell.application
$Fonts = $ShellApplication.NameSpace(0x14)

Get-ChildItem -Path ".\$FontName" -Include '*.ttf' -Recurse | ForEach-Object -Process {
    $Fonts.CopyHere($_.FullName)
}














Refresh-Environment

#gem pristine --all --env-shebang

### Node Packages
#Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
#if (which npm) {
#    npm update npm
#    npm install -g yo
#}

### Janus for vim
#Write-Host "Installing Janus..." -ForegroundColor "Yellow"
#if ((which curl) -and (which vim) -and (which rake) -and (which bash)) {
#    curl.exe -L https://bit.ly/janus-bootstrap | bash
#
#    cd ~/.vim/
#    git submodule update --remote
#}

