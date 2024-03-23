function Strip-Progress {
    param(
        [ScriptBlock]$ScriptBlock
    )

    # Regex pattern to match spinner characters and progress bar patterns
    $progressPattern = 'Γû[Æê]|^\s+[-\\|/]\s+$'

    # Corrected regex pattern for size formatting, ensuring proper capture groups are utilized
    $sizePattern = '(\d+(\.\d{1,2})?)\s+(B|KB|MB|GB|TB|PB) /\s+(\d+(\.\d{1,2})?)\s+(B|KB|MB|GB|TB|PB)'

    $previousLineWasEmpty = $false # Track if the previous line was empty

    & $ScriptBlock 2>&1 | ForEach-Object {
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            "ERROR: $($_.Exception.Message)"
        } elseif ($_ -match '^\s*$') {
            if (-not $previousLineWasEmpty) {
                Write-Output ""
                $previousLineWasEmpty = $true
            }
        } else {
            $line = $_ -replace $progressPattern, '' -replace $sizePattern, '$1 $3 / $4 $6'
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                $previousLineWasEmpty = $false
                $line
            }
        }
    }
}
#Strip-Progress -ScriptBlock { winget install GIMP.GIMP --accept-package-agreements --accept-source-agreements --force | tee output.txt }
