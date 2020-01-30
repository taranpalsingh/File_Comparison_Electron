# param([Int32]$paramT)

cls


Write-Output 'Starting.......'
if($args.Length -ne 0){
    $a = $args
}
else{
    $a = "a","b"
}
# $a | ForEach-Object {
#     Write-Output $_
# }



Write-Output $a

