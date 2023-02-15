function cloner($toClone, $baseVM, $newName){
  try{
    Write-Host $toClone
    Write-Host $baseVM
    Write-Host $newName
  
    $vm = Get-VM -Name $toClone
    $snapshot = Get-Snapshot -VM $vm -Name $baseVM
    $vmhost = Get-VMHost -Name "192.168.7.21"
    $ds = Get-DataStore -Name "datastore2-super11"
    $linkedClone = "{0}.linked" -f $vm.name
    $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
    $newvm = New-VM -Name "$newName.base" -VM $linkedVM -VMHost $vmhost -Datastore $ds
    $newvm | New-Snapshot -Name "Base"
    $linkedvm | Remove-VM
  }
  catch {
    Write-Host "ERROR"
    exit
  }
}

#cloner -toClone "480-FW" -baseVM "Base" -newName "480-FW-2"
#cloner -toClone "xubuntu-wan" -baseVm "Base" -newName "xubuntu-wan-2"
cloner -toClone "dc1" -baseVM "Base" -newName "dc-base-2"
