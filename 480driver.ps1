Import-Module '480-utils' -Force
480Banner
$conf = Get-480Config -config_path "/home/wayche/Documents/GitHub/SEC-480"
480Connect -server $conf.vcenter_server
Write-Host "CHOOSE YOUR FIGHTER"
Select-VM -folder "Base"
Write-Host "VM Cloner Active. Stop process to exit."
$toClone = Read-Host -Prompt "Enter the name of the target to clone."
$baseVM = Read-Host -Prompt "Enter the name of the snapshot you wish to clone (preferably Base)."
$newName = Read-Host -Prompt "Enter the new VM's name."

cloner -toClone $toClone -baseVM $baseVM -newName $newName
Get-VM