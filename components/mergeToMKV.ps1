# This function searches through the folders in the given path and finds the videofile in each folder and merges the srtfile inthe folder with the video to a new mkv file. The srt file is set to default and to the english language. The function also checks to see if the neceassary programs are inthe path
# The function uses the following programs:
# mkvmerge

# The function takes the following parameters:
# $path: The path to the folder where the function should search for video files and srt files
# $outputPath: The path to the folder where the new mkv files should be saved

function MergeToMKV {
	
	param(
		[string]$path,
		[string]$outputPath
	)
	set-executionpolicy -ExecutionPolicy Bypass -Scope Process
	# Check if mkvmerge is available
	if (-not (Get-Command mkvmerge -ErrorAction SilentlyContinue)) {
		Write-Error "mkvmerge is not found. Please install MKVToolNix."
		return
	}

	# Get all subfolders
	$folders = Get-ChildItem -Path $path -Directory -Recurse


	foreach ($folder in $folders) {
		Write-Host "Processing folder: $($folder.Name)"
		# Get the video and srt files
	$videoFile = Get-ChildItem -LiteralPath $folder.FullName -File | Where-Object { $_.Extension -match "\.(avi|mp4|mkv)$" } | Select-Object -First 1
	$srtFile = Get-ChildItem -LiteralPath $folder.FullName -File | Where-Object { $_.Extension -match "\.srt$" } | Select-Object -First 1	
		if ($videoFile -and $srtFile) {
			Write-Host "found $($videoFile.Name)"
			Write-Host "found $($srtFile.Name)"
			# Construct the output file path
			$outputFile = Join-Path -Path $outputPath -ChildPath ("{0}.mkv" -f $videoFile.BaseName)
			# Merge the video and srt files
			& mkvmerge  -o $outputFile --default-track 0 --language 0:eng $videoFile.FullName $srtFile.FullName
			write-host "merged $outputFile"
		} elseif ($videoFile) {
			Write-Host "No srt file found for $($videoFile.Name)"
			Write-Host "Copying video file to output folder: $($folder.Full)"
			# if the video file is mkv, we can just copy it to the output folder else make a mkv and copy it to the output folder
			if ($videoFile.Extension -eq ".mkv") {
				Copy-Item -Path $videoFile.FullName -Destination $outputPath
			} else {
				$outputFile = Join-Path -Path $outputPath -ChildPath ("{0}.mkv" -f $videoFile.BaseName)
				& mkvmerge  -o $outputFile $videoFile.FullName
			}
		}  else {
			Write-Host "No video or srt file found in $($folder.FullName)"
		}
		
	}
}
#MergeToMKV -path "C:\Users\resto\Downloads\DownloadsComplete\test" -outputPath "C:\Users\resto\Downloads\DownloadsComplete\test\Output" 
