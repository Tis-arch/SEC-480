function 480Banner(){
    Write-host "Hello SYS480-Devops"
}

function 480Connect([string] $server){
    $conn = $global:DefaultVIServer
    #are we already connected
    if ($conn){
        $msg = 'Already Connected to: {0}' -f $conn

        Write-Host -ForegroundColor Green $msg
    }
    else{
        $conn = Connect-VIServer -Server $server
        #if this fails, let Connect-VIServer handle the encryption
    }
    return $conn
}

function Get-480Config([string] $config_path){
    Write-Host "Reading " $config_path
    $conf = $null
    if (Test-Path $config_path){
        $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
        $msg = "Using configuration at {0}" -f $config_path
        Write-Host -ForegroundColor Green $msg
    }
    else{
        Write-Host -ForegroundColor "Yellow" "No Configurtion"
    }
    return $conf
}

function Select-VM([string] $folder){
    $selected_vm=$null
    try{
        $vms = Get-VM -Location $folder
        $index =1
        foreach($vm in $vms){
            Write-Host [$index] $vm.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        #480-TODO need to deal with an invalid index (consider making this check a function)
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.name
        #note this is a full on vm object that we can interact with
        return $selected_vm
    }

    catch{
        Write-Host "Invalid Folder: $folder" -ForegroundColor "Red"
    }
}

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
      Write-Host "Error with VM creation."
      exit
    }
  }
  
  function vSwitch([string] $vSwitchName, [string] $pGroupName, [string] $vServer){
    480Connect
    # It knows the host, and it retains, why can't it find the host????
    # Refer to https://vdc-download.vmware.com/vmwb-repository/dcr-public/73d6de02-05fd-47cb-8f73-99d1b33aea17/850c6b63-eb82-4d9c-bfcf-79279b5e5637/doc/New-VirtualSwitch.html
    try{
        Write-Host $vSwitchName
        Write-Host $pGroupName

        $virSwitch = New-VirtualSwitch -VMHost $vServer -Name $vSwitchName
        $vPG = New-VirtualPortGroup -Name $pGroupName -VirtualSwitch $virSwitch -Server $vServer
        return $vPG

    }
    catch {
      Write-Host "Error with VSwitch and Portgroup creation."
      exit
    }
}

function iDent(){
    try{

    }
    catch {
            Write-Host "Error with VM Identifier."
            exit
    }
}

function vmBoot(){
    try{

    }
    catch {
            Write-Host "Error with VM Identifier."
            exit
    }
}

function setNetwork(){
    try{

    }
    catch {
            Write-Host "Error with VM Identifier."
            exit
    }
}
