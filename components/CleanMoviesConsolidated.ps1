









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
		}
		elseif ($videoFile) {
			Write-Host "No srt file found for $($videoFile.Name)"
			Write-Host "Copying video file to output folder: $($folder.Full)"
			# if the video file is mkv, we can just copy it to the output folder else make a mkv and copy it to the output folder
			if ($videoFile.Extension -eq ".mkv") {
				Copy-Item -Path $videoFile.FullName -Destination $outputPath
			}
			else {
				$outputFile = Join-Path -Path $outputPath -ChildPath ("{0}.mkv" -f $videoFile.BaseName)
				& mkvmerge  -o $outputFile $videoFile.FullName
			}
		}
  else {
			Write-Host "No video or srt file found in $($folder.FullName)"
		}
		
	}
}

# Requiers mkvpropedit.exe comes bundled with MKVToolNix
# Function: Replaces title of all mkv files in a folder with their file names.
# Steps:
# 2. Copy the file in same folder as desired mkv files and run it.
# Starting MKVtitle *****
function ProcessMkVFiles($path) {
	$begin_time = get-date -format "yyyy-MM-dd HH:mm:ss"
	
	$mkvprop = "mkvpropedit.exe"
	$ffprobe = "ffprobe.exe"
	
	$MKVS = Get-ChildItem -path $path -Filter *.mkv 
	mkdir $path\ffmpegout -f > null
	$k = 1
	$kk = $MKVS.count
	foreach ($file in $MKVS) {
		$length = ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal $file.FullName
	
		$Start_time_now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		Write-Host -ForegroundColor Blue "Starting $k/$kk at $Start_time_now *****"
		#change the title to the filename
		$filename = [System.IO.Path]::GetFileNameWithoutExtension($file)
		Write-Host "writing title for $filename *****"
		$parm = @($file, "-e", "info", "-s", "title=$filename", "-q")
		mkvpropedit $parm
		$audioInfo = ffprobe -v error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 $file.FullName
		#do the downmixes
		switch ($audioInfo) {
			{ "2", "1" -eq $_ } {
				Write-Host "Compressed Stereo($audioInfo) building $filename.mkv($length)"
				ffmpeg -v quiet -stats -y -i $file -map 0:v -c:v copy -map 0:a:0? -c:a:0 copy -map 0:a:0? -c:a:1 aac -ac 2 -filter:a:1 "acompressor=ratio=5,loudnorm" -ar:a:1 48000 -b:a:1 192k -metadata:s:a:1 title="Eng 2.0 Stereo DRC" -metadata:s:a:1 language=eng -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -map 0:a:6? -c:a:7 copy -map 0:s? -c:s copy "$path/ffmpegOut/$filename.mkv"
			}
			{ "6", "8" -eq $_ } {
	
	
				Write-Host "Mixing down ($audioInfo) to Stereo $filename ($length) temp.mkv"
				ffmpeg -v quiet -stats -y -i $file -map 0:v -c:v copy -map 0:a:0? -c:a:0 copy -map 0:a:0? -c:a:1 aac -ac 2 -filter:a:1 "loudnorm" -ar:a:1 48000 -b:a:1 192k -metadata:s:a:1 title="Eng 2.0 Stereo" -metadata:s:a:1 language=eng -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -map 0:a:6? -c:a:7 copy -map 0:s? -c:s copy "$path/ffmpegOut/$filename temp.mkv"
				Write-Host "Compressing Stereo $filename.mkv($length)"
				ffmpeg -v quiet -stats -y -i "$path/ffmpegOut/$filename temp.mkv" -map 0:v -c:v copy -map 0:a:0? -c:a:0 copy -map 0:a:0? -c:a:1 aac -ac 2 -filter:a:1 "acompressor=ratio=5,loudnorm" -ar:a:1 48000 -b:a:1 192k -metadata:s:a:1 title="DRC Eng 2.0 Stereo" -metadata:s:a:1 language=eng -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -map 0:a:6? -c:a:7 copy -map 0:s? -c:s copy "$path/ffmpegOut/$filename.mkv"
				Remove-Item "$path/ffmpegOut/$filename temp.mkv"
			}
			Default { Write-Host -ForegroundColor Red "#####    $file : $audioInfo" }
		}
		$End_time_now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		$Time_taken = New-TimeSpan -Start $Start_time_now -End $End_time_now 
		##format the time taken
		$Time_taken = "{0:00}:{1:00}:{2:00}" -f $Time_taken.Hours, $Time_taken.Minutes, $Time_taken.Seconds
		Write-host -ForegroundColor Green "#### Done with $filename in $Time_taken  *****" 
		$k++
	}
	$stop_time = get-date -format "yyyy-MM-dd HH:mm:ss"
	Write-host "Start time: $begin_time"
	Write-host "Stop time: $stop_time"
	$job_time = New-TimeSpan -Start $begin_time -End $stop_time
	Write-host -ForegroundColor Green "#### ${$MKVs.count} files done in $job_time  *****" 
}


# this function will sort and move all mkv files in a directory to a new directory
# the mkv files all end on a 4digit number, the function will sort them by this number
# the mkv files that have a number lower then 2010  will move to a folder called old
# the mkv files that have a number higher then 2010 will move to a folder called new

function SortAndMoveMKVS($path) {
	# get all mkv files in the directory
	$MKVS = Get-ChildItem -path $path -Filter *.mkv
	# loop through all the mkv files
	foreach ($file in $MKVS) {
		# get the number from the file name
		$number = $file.Name -replace '.*?(\d{4})\.mkv', '$1'
		# check if the number is lower then 2010
		if ($number -lt 2010) {
			# move the file to the old directory
			Move-Item $file.FullName D:\
		}
		else {
			# move the file to the new directory
			Move-Item $file.FullName E:\
		}
	}
	
	
}
	
# Check if mkvmerge is available
if (-not (Get-Command mkvmerge -ErrorAction SilentlyContinue)) {
	Write-Error "mkvmerge is not found. Please install MKVToolNix."
	return
}
# Check if mkvpropedit.exe is available
if (-not (Get-Command mkvpropedit.exe -ErrorAction SilentlyContinue)) {
	Write-Error "mkvpropedit.exe is not found. Please install MKVToolNix."
	return
}
# Check if ffprobe.exe is available
if (-not (Get-Command ffprobe.exe -ErrorAction SilentlyContinue)) {
	Write-Error "ffprobe.exe is not found. Please install ffmpeg."
	return
}



$downloadFolder= $env:UserProfile + "\Downloads\Complete\movies"

MergeToMKV -path $downloadFolder -outputPath "$downloadFolder\Output" 
ProcessMkVFiles -path "$downloadFolder\Output"
SortAndMoveMKVS -path "$downloadFolder\Output\ffmpegOut"
