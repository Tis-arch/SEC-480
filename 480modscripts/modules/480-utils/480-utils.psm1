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

function Select-VM(){
    $selected_vm=$null
    try{
        $folder = Read-Host "Enter the folder name."
        $vms = Get-VM -Location $folder
        $index =1
        foreach($vm in $vms){
            Write-Host [$index] $vm.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        #480-TODO need to deal with an invalid index (consider making this check a function)
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked" $selected_vm.name
        #note this is a full on vm object that we can interact with
        return $selected_vm
    }

    catch{
        Write-Host "Invalid Folder: $folder" -ForegroundColor "Red"
    }
}

function linkedCloner(){
    try{

    $toClone = Select-VM
    $baseVM = Read-Host "Enter base snapshot name."
    $vmhost = Get-VMHost -Name $conf.vm_host
    $ds = Get-DataStore -Name $conf.storage
    $vm = Get-VM -Name $toClone.name
    $snapshot = Get-Snapshot -VM $vm -Name $baseVM
    $linkedClone = "{0}.linked" -f $vm.name
    New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
    
    }
    catch {
      Write-Host "Error with VM linked clone creation."
      exit
    }
  }

  function cloner($toClone, $baseVM, $newName){
    try{
      Write-Host $toClone
      Write-Host $baseVM
      Write-Host $newName
    
      $vm = Get-VM -Name $toClone
      $snapshot = Get-Snapshot -VM $vm -Name $baseVM
      $vmhost = Get-VMHost -Name $conf.vm_host
      $ds = Get-DataStore -Name $conf.storage
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
  
  
  function vSwitch([string] $vSwitchName, [string] $pGroupName, [string] $vHost, [string] $vServer){
    480Connect #Just making sure the connection works
    
    try{
        Write-Host $vSwitchName
        Write-Host $pGroupName

        $virSwitch = New-VirtualSwitch -VMHost $vHost -Name $vSwitchName
        $vPG = New-VirtualPortGroup -Name $pGroupName -VirtualSwitch $virSwitch -Server $vServer
        return $vPG

    }
    catch {
      Write-Host "Error with VSwitch and Portgroup creation."
      exit
    }
}

function Get-VMInfo([string] $vServer){
    #Can probably be done with a single command consolidated into Get-VM, will try later.
    try{  
        $selected_vm = Select-VM
        Get-VM -Name $selected_vm.Name | Select-Object Name, @{N="IP";E={$_.Guest.IPAddress[0]}}
        Get-NetworkAdapter -Server $vServer -VM $selected_vm.Name | Format-Table -AutoSize
    }
    catch {
            Write-Host "Error with VM Identifier."
            exit
    }
}

function VMStatus([string] $Name){
    Get-VM -Name $Name
}

function VMStart([string] $Name){
    try{
        Get-VM -Name $Name
        Start-VM -VM $Name -Confirm
    }
    catch {
        Write-Host "Your VM is already on"
    }
}

function VMStop([string] $Name){
    try{
        Get-VM -Name $vmToStop
        Stop-VM -VM $vmToStop -Confirm -Kill
    }
    catch {
        Write-Host "Your VM is already off"
    }
}

function VMBoot(){
    try{
        $selected_vm = Select-VM
        #Show if the VM is powered on or off
        $powrState = $selected_vm.PowerState
        Write-Host "This VM is currently" $powrState
        if ($powrState -eq "PoweredOff"){
            VMStart -Name $selected_vm.Name
        }
        if ($powrState -eq "PoweredOn"){
            VMStop -Name $selected_vm.Name
        }
    }
catch {
    Write-Host "Error with VM Booter"
    exit
    }
    return $powrState
}


function Set-Network([string] $vServer){
    #Add selecting adapters later, had a problem that I couldn't figure out.
    try{
        $selected_vm = Select-VM
        $virtualNetworks = Get-VirtualNetwork -Server $conf.vcenter_server
        Write-Host $virtualNetworks
        $index =1
        foreach($network in $virtualNetworks){
            Write-Host [$index] $network.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        $selected_network = $virtualNetworks[$pick_index -1]
        Write-Host "You picked" $selected_network.name
        $virtNet = Get-VirtualNetwork -Name $selected_network.Name
        Get-VM -Name $selected_vm.name | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $virtNet -Confirm:$false
        <#
     
        Set-NetworkAdapter -Server $vServer -VM $selected_vm.Name -Portgroup $selected_network.name WhatIf
        
         Write-Host $virtAdapter
        $index =1
        foreach($adapter in $virtAdapter){
            Write-Host [$index] $adapter.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        $selected_adapter = $virtAdapter[$pick_index -1]
        Write-Host "You picked" $selected_adapter.name
        $virtualNetworks = Get-VirtualNetwork -Server $conf.vcenter_server
        Write-Host $virtualNetworks
        $index =1
        foreach($network in $virtualNetworks){
            Write-Host [$index] $network.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        $selected_network = $virtualNetworks[$pick_index -1]
        Write-Host "You picked" $selected_network.name
        Get-VM -Name $selected_vm.Name | Get-NetworkAdapter | Set-NetworkAdapter -VM $selected_vm.Name -NetworkAdapter $selected_adapter.name -Portgroup $selected_network.Name -WhatIf -Confirm 
        #>
    }
    catch {
            Write-Host "Error with Set-Network."
            exit
    }
}

function Edit-VM([string] $vmName, [int] $memAmt, [int] $cpuAmt){
    $vm = Get-VM -Name $vmName
    VMStop -vmToStop $vm
    Get-VM -Name $vm | Select-Object Name, PowerState, MemoryGB, NumCpu, VMHost, Version
    Get-VM -Name $vm | Set-VM -MemoryGB $memAmt -NumCpu $cpuAmt -Confirm:$false
    Write-Host "Memory and CPU Upgrade Complete" -ForegroundColor Green
}