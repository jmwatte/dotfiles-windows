# Requiers mkvpropedit.exe comes bundled with MKVToolNix
# Function: Replaces title of all mkv files in a folder with their file names.
# Steps:
# 2. Copy the file in same folder as desired mkv files and run it.
# Starting MKVtitle *****
$begin_time = get-date -format "yyyy-MM-dd HH:mm:ss"
#search for mkvpropedit.exe
write-host "searching for mkvpropedit.exe"
$a = get-command mkvpropedit.exe -ErrorAction SilentlyContinue
if ($null -eq $a) { write-host "mkvpropedit.exe not found"; return }
#search for mkvpropedit.exe
write-host "searching for ffprobe.exe"
$b = get-command ffprobe.exe -ErrorAction SilentlyContinue
if ($null -eq $b) { write-host "ffprobe.exe not found"; return }
#set the path to mkvpropedit.exe
$mkvprop = $a
$ffprobe = $b

<# if ($null -ne (fd.exe --version)) { 
	
	try {
		$a = fd.exe mkvpropedit.exe c:\\
		$b = fd.exe ffprobe.exe c:\\
		if ($a.GetType() -eq [array])
		{ $a = $a[0] }
		if ($b.GetType() -eq [array])
		{ $b = $b[0] }
		 
	
	}
	catch {
		write-host "no fd.exe ?"
	}	
	
	 write-host "fd.exe found mkvpropedit.exe at $a" 
	write-host "fd.exe found ffprobe.exe at $b"
}

else {
 $a = Get-PSDrive -PSProvider 'FileSystem' |
 ForEach-Object {
	 Get-ChildItem -Path $_.Root -Recurse -ErrorAction SilentlyContinue -Filter "*.exe"| Where-Object { $_.Name -eq "mkvpropedit.exe" } }
	$a = $a[0].FullName
	write-host "Get-PSDrive found mkvpropedit.exe at $a" 
	$b = Get-PSDrive -PSProvider 'FileSystem' |
	ForEach-Object {
	 Get-ChildItem -Path $_.Root -Recurse -ErrorAction SilentlyContinue -Filter "*.exe"| Where-Object { $_.Name -eq "ffprobe.exe" } }
} #>
#check if mkvpropedit.exe is found, if not exit
#if ($null -eq $a) { write-host "mkvpropedit.exe not found"; return }
#if ($null -eq $b) { write-host "ffprobe.exe not found"; return }
#set the path to mkvpropedit.exe
#$mkvprop = $a
#$ffprobe = $b
$MKVS = Get-ChildItem -path .\ -Filter *.mkv 
mkdir ffmpegout -f > null
$k =1
$kk = $MKVS.count
foreach ($file in $MKVS) {
	$length =ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal $file.FullName

	$Start_time_now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	Write-Host -ForegroundColor Blue "Starting $k/$kk at $Start_time_now *****"
	#change the title to the filename
	$filename = [System.IO.Path]::GetFileNameWithoutExtension($file)
	Write-Host "writing title for $filename *****"
	$parm = @($file, "-e", "info", "-s", "title=$filename", "-q")
	& $mkvprop $parm
	$audioInfo = & $ffprobe -v error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 $file.FullName
	#do the downmixes
	switch ($audioInfo) {
		{"2","1" -eq $_} {
			Write-Host "Compressed Stereo($audioInfo) building $filename.mkv($length)"
			ffmpeg -v quiet -stats -y -i $file -map 0:v -c:v copy -map 0:a:0? -c:a:0 copy -map 0:a:0? -c:a:1 aac -ac 2 -filter:a:1 "acompressor=ratio=5,loudnorm" -ar:a:1 48000 -b:a:1 192k -metadata:s:a:1 title="Eng 2.0 Stereo DRC" -metadata:s:a:1 language=eng -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -map 0:a:6? -c:a:7 copy -map 0:s? -c:s copy "ffmpegOut/$filename.mkv"
		}
		{ "6", "8" -eq $_ } {


			Write-Host "Mixing down ($audioInfo) to Stereo $filename ($length) temp.mkv"
			ffmpeg -v quiet -stats -y -i $file -map 0:v -c:v copy -map 0:a:0? -c:a:0 copy -map 0:a:0? -c:a:1 aac -ac 2 -filter:a:1 "loudnorm" -ar:a:1 48000 -b:a:1 192k -metadata:s:a:1 title="Eng 2.0 Stereo" -metadata:s:a:1 language=eng -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -map 0:a:6? -c:a:7 copy -map 0:s? -c:s copy "ffmpegOut/$filename temp.mkv"
			Write-Host "Compresed Stereo building $filename.mkv($length)"
			ffmpeg -v quiet -stats -y -i "ffmpegOut/$filename temp.mkv" -map 0:v -c:v copy -map 0:a:0? -c:a:0 copy -map 0:a:0? -c:a:1 aac -ac 2 -filter:a:1 "acompressor=ratio=5,loudnorm" -ar:a:1 48000 -b:a:1 192k -metadata:s:a:1 title="DRC Eng 2.0 Stereo" -metadata:s:a:1 language=eng -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -map 0:a:6? -c:a:7 copy -map 0:s? -c:s copy "ffmpegOut/$filename.mkv"
			Remove-Item "ffmpegOut/$filename temp.mkv"
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