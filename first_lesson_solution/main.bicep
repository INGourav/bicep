// The below code is for VNet and Two Subnet

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'biceptestvnet'
  location: 'eastus'
  tags: {
    createdby: 'Gourav'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
    subnets: [
      {
        name: 'biceptestsubnet1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'biceptestsubnet2'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'biceptestsubnet3'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

// The below code is for PublicIP and attached to First NIC

resource pip 'Microsoft.Network/publicIPAddresses@2020-05-01' = {
  name: 'biceptestpip'
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
  name: 'biceptestnic1'
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
            id: vnet.properties.subnets[0].id
            //id: '${vnet.id}/subnets/${biceptestsubnet1}'
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
  name: 'biceptestnic2'
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
            id: vnet.properties.subnets[1].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// The below code is for Storage account that is used for Diagnostic settings

resource sa 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: 'biceptestsa'
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
  name: 'biceptestavset'
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
  name: 'biceptestvm1'  
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
      vmSize: 'Standard_A2_v2'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    osProfile: {
      adminUsername: 'biceptestvm1-adm'
      adminPassword: 'Test@1111122222'
      computerName: 'biceptestvm1'
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
        name: 'biceptestvm1-os'
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
          name: 'biceptestvm1-data1'  
        }
      ]   
    } 
  }
}

// The below code is for Second VM

resource secondvm 'Microsoft.Compute/virtualMachines@2019-12-01' = {
  name: 'biceptestvm2'
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
      vmSize: 'Standard_A2_v2'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: secondnic.id
        }
      ]
    }
    osProfile: {
      adminUsername: 'biceptestvm2-adm'
      adminPassword: 'Test@1111122222'
      computerName: 'biceptestvm2'
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
        name: 'biceptestvm2-os'
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
          name: 'biceptestvm2-data1'  
        }
      ]   
    } 
  }
}