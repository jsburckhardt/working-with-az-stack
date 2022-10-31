# Create variables to store the location and resource group names.
$location = "local"
$ResourceGroupName = "myResourceGroup"
$StorageAccountName = "mystorageaccount"
$SkuName = "Standard_LRS"
$SubnetName = "myVirtualNetwork"
$SubnetPrefix = 192.168.1.0/24
$VirtualNetworkName = "myVnet"
$VirtualNetworkPrefix = 192.168.0.0/16
$NetworkSecurityGroupName = "myNetworkSecurityGroup"
$NicName = myNic
$Username = "myadmin"
$PlainTextPassword = "myPassword" #sample password
$VmName = "myVM"
$ComputerName = "myComputer"
$VmSize = "Standard_D2_v2"
$PublisherName = "MicrosoftWindowsServer"
$Offer = "WindowsServer"
$Skus = "2019-Datacenter"
$Version = "latest"


# validate if Resource Group exists and create if doesn't
if ((Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue) -eq $null) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $location
}

# validate if Storage Account exists and create if doesn't
# Create variables to store the storage account name and the storage account SKU information
if ((Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue) -eq $null) {
    $StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -SkuName $SkuName -Location $location
} else {
    $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
}
Set-AzCurrentStorageAccount -StorageAccountName $storageAccountName -ResourceGroupName $resourceGroupName

# create network resources
# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetPrefix
$vnet = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $location -Name $VirtualNetworkName -AddressPrefix $VirtualNetworkPrefix -Subnet $subnetConfig
$pip = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $location -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "mypublicdns$(Get-Random)"
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleRDP -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $location -Name $NetworkSecurityGroupName -SecurityRules $nsgRuleRDP
$nic = New-AzNetworkInterface -Name $NicName -ResourceGroupName $ResourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

# create virtual machine configuration
# Define a credential object to store the username and password for the VM
$Password=$PlainTextPassword| ConvertTo-SecureString -Force -AsPlainText
$Credential=New-Object PSCredential($UserName,$Password)

# Create the VM configuration object
$VirtualMachine = New-AzVMConfig -VMName $VmName -VMSize $VmSize
$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent
$VirtualMachine = Set-AzVMSourceImage `
  -VM $VirtualMachine `
  -PublisherName "MicrosoftWindowsServer" `
  -Offer "WindowsServer" `
  -Skus "2016-Datacenter" `
  -Version "latest"

# Sets the operating system disk properties on a VM.
$VirtualMachine = Set-AzVMOSDisk `
  -VM $VirtualMachine `
  -CreateOption FromImage | `
  Set-AzVMBootDiagnostic -ResourceGroupName $ResourceGroupName `
  -StorageAccountName $StorageAccountName -Enable |`
  Add-AzVMNetworkInterface -Id $nic.Id


# Create the VM.
New-AzVM `
  -ResourceGroupName $ResourceGroupName `
  -Location $location `
  -VM $VirtualMachine
