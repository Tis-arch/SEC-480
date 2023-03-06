Import-Module '480-utils' -Force
480Banner
$conf = Get-480Config -config_path "/home/wayche/Documents/GitHub/SEC-480/480.json"
Write-Host $conf.vcenter_server
480Connect -server $conf.vcenter_server
Write-Host "Virtual Switch and Portgroup creator active. Stop process to exit."
$vSwitchName = Read-Host -Prompt "Enter the name for the new Virtual Switch"
$pGroupName = Read-Host -Prompt "Enter the name for the new Portgroup"
vSwitch -vSwitchName $vSwitchName -pGroupName $pGroupName -vServer $conf.vcenter_server
Get-VirtualSwitch
Get-VirtualPortGroup
