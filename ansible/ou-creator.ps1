import-module activedirectory

# get the the ou
$scriptpath = Split-Path $($myInvocation.MyCommand.Path) -Parent
$ou_full = Get-Content -Path "$scriptpath\ou.txt"

foreach ($ou_path in $ou_full){
    # split the entire string by comma and make a blank array
    $path = $ou_path.Split(",")
    $root = @()
    foreach ($ou in $path){
        if ($ou -like "dc=*"){
            $root += $ou
        }
    }

    $rootlen = $root.Length
    $root = $root -join ","

    $path = $path | Select-Object -SkipLast $rootlen
    
    [array]::Reverse($path)

    foreach ($ou in $path){
        $tpath = "AD:\$ou,$root"
        Write-Output "[CREATING $tpath]"

        if (!$(Test-Path -Path $tpath)){
            
            $dir = mkdir $tpath
            
            # double check
            if ($(Test-Path -Path $tpath)){
                Write-Output "[FOUND $tpath]"
                
                $root = "$ou,$root"
            }
            else {
                Write-Output "[$tpath NOT CREATED]"
            }
        }

        # if the out already exists, tell the user
        else {
            Write-Output "[FOUND $tpath]"
            
            $root = "$ou,$root"
        }
    }
}
# Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase 'DC=BLUE1,DC=LOCAL' | Format-Table DistinguishedName