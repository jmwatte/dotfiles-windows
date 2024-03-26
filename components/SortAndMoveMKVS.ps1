# this function will sort and move all mkv files in a directory to a new directory
# the mkv files all end on a 4digit number, the function will sort them by this number
# the mkv files that have a number lower then 2010  will move to a folder called old
# the mkv files that have a number higher then 2010 will move to a folder called new

function SortAndMoveMKVS($path){
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
	} else {
		# move the file to the new directory
		Move-Item $file.FullName E:\
	}
}


}
