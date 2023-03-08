Import-Module '480-utils' -Force
480Banner
$conf = Get-480Config -config_path "/home/wayche/Documents/GitHub/SEC-480/480modscripts/480.json"
480Connect -server $conf.vcenter_server
<#
Write-Host "Virtual Switch and Portgroup creator active. Stop process to exit."
$vSwitchName = Read-Host -Prompt "Enter the name for the new Virtual Switch"
$pGroupName = Read-Host -Prompt "Enter the name for the new Portgroup"
vSwitch -vSwitchName $vSwitchName -pGroupName $pGroupName -vHost $conf.vm_host -vServer $conf.vcenter_server
Get-VirtualSwitch
Get-VirtualPortGroup

Get-VMInfo -vServer $conf.vcenter_server

Set-Network -vServer $conf.vcenter_server

VMBoot

linkedCloner
#>

Get-VMInfo -vServer $conf.vcenter_server


