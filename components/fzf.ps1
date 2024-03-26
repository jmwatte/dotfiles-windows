if (((Get-Command fzf*.exe) -ne $null) -and ((Get-Module -ListAvailable PSFzf -ErrorAction SilentlyContinue) -ne $null)) {
  Import-Module PSFzf
}
$env:FZF_CTRL_T_COMMAND='fd -H'
# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion -EnableAliasFuzzyEdit -EnableAliasFuzzyHistory -EnableAliasFuzzySetLocation -EnableAliasFuzzySetEverything  -EnableFd -GitKeyBindings -EnableAliasFuzzyGitStatus
 
Set-Alias ff Invoke-PSFzfRipgrep

function femf(){ 
Invoke-FuzzyEdit -wait
}

Set-Alias fem femf
