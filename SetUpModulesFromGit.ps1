function Install-ModulesFromGit {
	# Check if Git is installed
	if (!(Get-Command git -ErrorAction SilentlyContinue)) {
		Write-Host "Git is not installed. Please install Git and try again."
		return
	}
	# Hardcoded list of GitHub URLs
	$gitUrlsOfModules = @(
		'https://github.com/jmwatte/AudioAnalyses.git',
		'https://github.com/jmwatte/spotifyplaylists.git',
		'https://github.com/jmwatte/PlaylistModule.git',
		'https://github.com/jmwatte/VideoPeakAndExtraction.git',
		'https://github.com/jmwatte/scrapeWebsite.git',
		'https://github.com/jmwatte/PlaylistModule.git',
		'https://github.com/jmwatte/TTyping.git',
		'https://github.com/jmwatte/foxlines.git',
		'https://github.com/jmwatte/fakewords.git',
		'https://github.com/jmwatte/MKVHelpers.git',
		'https://github.com/jmwatte/SimpleSpotiPlaylistMaker.git'

		# Add more URLs as needed
	)

	foreach ($url in $gitUrlsOfModules) {
		# Extract the module name from the URL
		$moduleName = $url.Split('/')[-1].Replace('.git', '')

		# Check if the module is already installed
		if (!(Get-Module -ListAvailable -Name $moduleName)) {
			# Clone the repository to a temporary directory
			$tempDir = [System.IO.Path]::GetTempFileName()
			Remove-Item $tempDir
			#Write-Host "Cloning $moduleName from $url to $tempDir"
			git clone $url $tempDir

			# Copy the cloned repository to the PSModulePath
			Write-Host "Copying $moduleName to $env:PSModulePath"
			Copy-Item -Path $tempDir -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\$moduleName" -Recurse
			# Clean up the temporary directory
			Remove-Item -Path $tempDir -Recurse -Force
		}
	}
}
# import the installed modules found in the -Destination folder 

function Import-ModulesFromGit {
	$modules = Get-ChildItem -Path "$env:USERPROFILE\Documents\PowerShell\Modules" -Directory
	foreach ($module in $modules) {
		Import-Module $module.FullName
		Write-host "Imported module: $($module.Name)"
	}
}


Install-ModulesFromGit
Import-ModulesFromGit