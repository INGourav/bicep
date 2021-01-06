// Variable that we need to change

var vnetname = 'biceptestvnet'
var vnetrange = '10.0.0.0/16'

var subnetName1 = 'biceptestsubnet1'
var subnetName2 = 'biceptestsubnet2'
var subnetName3 = 'biceptestsubnet3'

var subnet1range = '10.0.0.0/24'
var subnet2range = '10.0.1.0/24'
var subnet3range = '10.0.2.0/24'

var pipname = 'biceptestpip'

var nic1name = 'biceptestnic1'
var nic2name = 'biceptestnic2'

var storageacc = 'biceptestsa'

var avsetname = 'biceptestavset'

var vm1name = 'biceptestvm1'
var vm2name = 'biceptestvm2'

// The below code is for VNet and Two Subnet

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetname
  location: resourceGroup().location
  tags: {
    createdby: 'Gourav'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetrange
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
  }
}

resource subnet 'Microsoft.Network/virtualnetworks/subnets@2015-05-01-preview' = {
  name: '${vnet.name}/subnetName1'  // https://github.com/Azure/bicep/issues/1259
   properties: {
     addressPrefix: subnet1range    
   }
   dependsOn:[
     vnet
   ]
}


resource subnet2 'Microsoft.Network/virtualnetworks/subnets@2015-05-01-preview' = {
  name: '${vnet.name}/subnetName2' // https://github.com/Azure/bicep/issues/1259 
   properties: {
     addressPrefix: subnet2range 
   }
   dependsOn: [
     vnet
   ]
}


// The below code is for PublicIP and attached to First NIC

resource pip 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: pipname
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
  tags: {
    createdby: 'Gourav'
  }
}

// The below code is for first Network Interface

resource nic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nic1name
  location: resourceGroup().location
  tags: {
    createdby: 'Gourav'
  }
  properties: {
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            //id: vnet.properties.subnets[0].id
            //id: '${vnet.id}/subnets/${subnetName1}'
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
  }
}

// The below code is for Second Network Interface

resource secondnic 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: nic2name
  location: resourceGroup().location
  tags: {
    createdby: 'Gourav'
  }
  properties: {
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            //id: vnet.properties.subnets[1].id
            //id: '${vnet.id}/subnets/${subnetName2}'
            id: subnet2.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// The below code is for Storage account that is used for Diagnostic settings

resource sa 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageacc
  location: resourceGroup().location
  tags: {
    createdby: 'Gourav'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

// The below code is for avset that contains both of our VMs

resource avset 'Microsoft.Compute/availabilitySets@2019-12-01' = {
  name: avsetname
  location: resourceGroup().location
  tags: {
    createdby: 'Gourav'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 3
  }
  sku: {
    name: 'Aligned'
  }
}

// The below code is for first Virtual Machine that has PIP with it

resource vm 'Microsoft.Compute/virtualMachines@2019-12-01' = {
  name: vm1name
  location: resourceGroup().location
  tags: {
    createdby: 'Gourav'
  }
  properties: {
    availabilitySet: {
      id: avset.id
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: sa.properties.primaryEndpoints.blob
      }
    }
    hardwareProfile: {
      //vmSize: 'Standard_A2_v2'
      vmSize: 'Standard_F4s_v2'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      adminUsername: '${vm1name}-adm'
      adminPassword: 'Test@1111122222'
      computerName: vm1name
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        timeZone: 'UTC'
      }
    }
    storageProfile: {
      imageReference: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vm1name}-os'
        caching: 'None'
        createOption: 'FromImage'
        diskSizeGB: 127
        osType: 'Windows'
      }
      dataDisks: [
        {
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 100
          lun: 0
          name: '${vm1name}-data1'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
            //storageAccountType: 'Standard_LRS'
          }
        }
      ]
    }
  }
}

// The below code is for Second VM

resource secondvm 'Microsoft.Compute/virtualMachines@2019-12-01' = {
  name: vm2name
  location: resourceGroup().location
  tags: {
    createdby: 'Gourav'
  }
  properties: {
    availabilitySet: {
      id: avset.id
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: sa.properties.primaryEndpoints.blob
      }
    }
    hardwareProfile: {
      //vmSize: 'Standard_A2_v2'
      vmSize: 'Standard_F4s_v2'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: secondnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: '${vm2name}-adm'
      adminPassword: 'Test@1111122222'
      computerName: vm2name
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        timeZone: 'UTC'
      }
    }
    storageProfile: {
      imageReference: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vm2name}-os'
        caching: 'None'
        createOption: 'FromImage'
        diskSizeGB: 127
        osType: 'Windows'
      }
      dataDisks: [
        {
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: 100
          lun: 0
          name: '${vm2name}-data1'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
            //storageAccountType: 'Standard_LRS' 
          }
        }
      ]
    }
  }
}