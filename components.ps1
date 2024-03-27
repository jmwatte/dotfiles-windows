# These components will be loaded for all PowerShell instances

Push-Location (Join-Path (Split-Path -parent $profile) "components")

# From within the ./components directory...
. .\coreaudio.ps1
. .\fzf.ps1
. .\terminal_icons.ps1
. .\git.ps1
. .\SetUpModulesFromGit.ps1
. .\strip-progress.ps1
Pop-Location
