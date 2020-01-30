cls

##  gives YES if the files match, NO if it doesn't matches and Not present if it is not present in that server.

##  Enter your csv file's path here ending with '\'
$csvPath = "D:\projects\File comparison\csvFiles\"

# If arguments (Paths) are passed while runnning the program 
if($args.Length -ne 0){
	$rootPathArr = $args
}
else{
	#  Enter the database paths here separated with ','ending with '\'
	$rootPathArr = "D:\SQL Folders\one\", 
	"D:\SQL Folders\two\"
}

# Starting with the primary folder/file to compare with
$primaryRoot = $rootPathArr[0]

 
$objArr  = New-Object System.Collections.Generic.List[System.Object]
# list for headers of excel sheet
$headers = New-Object System.Collections.Generic.List[System.Object]
# list for database array
$databaseArr = New-Object System.Collections.Generic.List[System.Object]
$rootArr = New-Object System.Collections.Generic.List[System.Object]
$LineNumber = ""
$Checked = New-Object System.Collections.Generic.List[System.Object]


function comparingFile($fullName, $index){

	$obj = New-Object psobject
	
	$databases = New-Object System.Collections.Generic.List[System.Object]
	$folders = New-Object System.Collections.Generic.List[System.Object]
	$files = New-Object System.Collections.Generic.List[System.Object]
	$matches = New-Object System.Collections.Generic.List[System.Object]
	$lineNumbers = New-Object System.Collections.Generic.List[System.Object] 
	$errorLines = New-Object System.Collections.Generic.List[System.Object]
	$exists = New-Object System.Collections.Generic.List[System.Object]
    
    # variable to save the line number if there is a mismatch
	$LineNumber = ""
    # variable to record if the file matches or not.
	$Match ="Yes"

	# to mark the current file as checked 
    $Checked.Add($file)
    # root1Path- stores the path of the file that is to be checked and compared in other folders 
    $root1Path = $rootPathArr[$index]
    # contains just the file name w/o the dir location.
	$file = $fullName.substring($root1Path.Length, ($fullName.Length - $root1Path.Length )) 
	$Checked.Add($file)
     
    # iterating over all the folders for comparison 
    # In this loop we just store all the comparison parameters in arrays
	for($i=0; $i -lt $rootPathArr.Length; $i++){
        # path of the 2nd file to be compared
        $root2Path = $rootPathArr[$i]
        # If the path including the dir location is same, that means we are comparing the file with itself.
		if($root2Path -eq $root1Path){
			$databases.Add(($file.Split("\")[-3]))
			$folders.Add($file.Split("\")[-2])
			$files.Add($file.Split("\")[-1])
			$exists.Add("1")
        }
		else{ 
		
			$databases.Add($file.Split("\")[-3])
			$folders.Add($file.Split("\")[-2])
			$files.Add($file.Split("\")[-1])
		
            # If the file exists in the second folder
			if(Test-Path -Path ($root2Path + $file)){

				$exists.Add("1")
                # get contents of both the files
                $gcfile1 = gc ($root1Path + $file)
				$gcfile2 = gc ($root2Path + $file)
                
                # comparing the contents of both files
				$a = Compare-Object $gcfile1 $gcfile2 -CaseSensitive | Sort { $_.InputObject.ReadCount } |
				Group-Object {$_.InputObject.ReadCount} | select Name;
                # -------------------------------------------------------------------------------------------Can be otimized by removing IF statement
                if($a.length -eq 0){    
                    # If the files have no difference, the value of Match variable is already set to "YES"
				}
				else{
                    Write-Output "The file differs"
                    $Match = "No"
					$LineNumber = $a[0].Name
				}	
            }
            # If the file does not exists in the second folder
			else{
				$exists.Add("0")
			}
		}
    }
    # iterating over all the folders and writing in the csv file
	for($i=0; $i -lt $rootPathArr.Length; $i++){
		
		$obj | Add-Member -MemberType NoteProperty -Name $databaseArr[$i] -Value $databases[$i]
		$obj | Add-Member -MemberType NoteProperty -Name ("Folder "+($i+1)) -Value $folders[$i]
		$obj | Add-Member -MemberType NoteProperty -Name ("File "+($i+1)) -Value $files[$i]
        
        # If the file exists
		if($exists[$i] -eq "1"){
			$obj | Add-Member -MemberType NoteProperty -Name ("Match "+($i+1)) -Value $Match					
			if($Match -eq "No"){
				$errorLine = ( gc ($rootPathArr[$i] + $file) | select -Index ($LineNumber-1))
				$obj | Add-Member -MemberType NoteProperty -Name ("Line No. "+($i+1)) -Value $LineNumber
				$obj | Add-Member -MemberType NoteProperty -Name ("Line in database "+($i+1)) -Value $errorLine
			}
			else{
				$obj | Add-Member -MemberType NoteProperty -Name ("Line No. "+($i+1)) -Value ""
				$obj | Add-Member -MemberType NoteProperty -Name ("Line in database "+($i+1)) -Value ""
			}
		}
		else{
			$obj | Add-Member -MemberType NoteProperty -Name ("Match "+($i+1)) -Value "Not present in Server"
			$obj | Add-Member -MemberType NoteProperty -Name ("Line No. "+($i+1)) -Value ""
			$obj | Add-Member -MemberType NoteProperty -Name ("Line in database "+($i+1)) -Value ""
		}
	}	
	$objArr.Add($obj)
}


function goInsideFolder1($rootArr, $path, $index){
    # Parameters: 
    # $rootArr - Array of all the files and folders in this directory
    # $path - path to the current file/directory
    # $index - folder number of the root folder that is to be compared, to set the values in the headers if the csv file. 
    
    # Looping over the all the contents (Files/Folders) 
    $rootArr | 
    ForEach-Object{
    
        # If it is a folder
        if(Test-Path -Path ($path + $_) -PathType Container){

            $folder = $_
            $tempRootArr  = New-Object System.Collections.Generic.List[System.Object]
            Get-ChildItem ($path+$_) | select name | 
            ForEach-Object {
                $tempRootArr.Add($_.Name)  
            }
            goInsideFolder1 $tempRootArr ($path + $_+ "\") $index
        }
        # If It is a file
        else{
            $file = ($path+$_).substring($rootPathArr[$index].Length, (($path+$_).Length - $rootPathArr[$index].Length))
            # Write-Output ($path+$_)		
            # $Checked stores the file names (not their dir location) that have been checked. 
            # If the file has already been checked
            if(-not($Checked -contains $file)){
				# Write-Output "Checking"
				Write-Output ($path+$_)		
                comparingFile ($path + $_) $index
            }
            else {
                # Write-Output "Already Checked"
            }
        }
    }
}



# $rootPathArr |
# ForEach-Object{
# 	if($_[$rootPathArr.Length])
# 	$databaseArr.Add($_.Split("\")[-2])
# }

for($i=0; $i -lt $rootPathArr.Length; $i++){
    if($rootPathArr[$i][-1] -ne '\'){
        $rootPathArr[$i] = $rootPathArr[$i] + '\'        
    }
	$databaseArr.Add($rootPathArr[$i].Split("\")[-2])
}

# adding '\' at the end of csv location if it doesn't already exists
if($csvPath[-1] -ne '\'){
	$csvPath = $csvPath + '\'        
}

Write-Output $databaseArr

# Loop over the number of folders selected
for($j=0; $j -lt $rootPathArr.Length; $j++ ){

	Write-Output ("************************ Path Arr: "+$rootPathArr[$j])
    
    # Adding the relevant headers to be set in the csv file for the current folder's iteration
	$headers.Add($databaseArr[$j])
	$headers.Add("Folder "+($j+1))
	$headers.Add("File "+($j+1))
	$headers.Add("Match "+($j+1))
	$headers.Add("Line No. "+($j+1))
	$headers.Add("Line in database "+($j+1))
    
    # Array that stores the folders or fies inside the current folder's iteration
	$rootArr  = New-Object System.Collections.Generic.List[System.Object]
	
	Get-ChildItem $rootPathArr[$j] | select name | 
	ForEach-Object {
	    $rootArr.Add($_.name)
    }    
	goInsideFolder1 $rootArr $rootPathArr[$j] $j
}


$csvName = "$((((Get-Date -format 'u') -replace ':','')-replace '\s','')-replace '-','').csv"

Write-Output $headers

$psObject = New-Object psobject
foreach($header in $headers)
{
 	Add-Member -InputObject $psobject -MemberType noteproperty -Name $header -Value ""
}
$psObject | Export-Csv ($csvPath+$csvName) -NoTypeInformation

$objArr | Export-Csv -append -Path ($csvPath+$csvName) -NoTypeInformation

start ($csvPath+$csvName)

Write-Output '$checked'
Write-Output $Checked



