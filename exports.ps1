# Make vim the default editor
Set-Environment "EDITOR" "hx"
Set-Environment "GIT_EDITOR" $Env:EDITOR

# Disable the Progress Bar
$ProgressPreference='SilentlyContinue'
