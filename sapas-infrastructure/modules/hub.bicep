param location string 

param testVMUsername string
@secure()
param testVMPassword string

@secure()
param fwAdminPassword string
@secure()
param wafAdminPassword string

module hubnetwork 'hubnetwork.bicep' = {
  name: 'hub-network'
  params: {
    location: location
  }
}

@description('Test Virtual Machine')
resource vmtesttemp 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: 'vmtest-temp01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: 'vmtest-temp01_OsDisk_1_57bfec826a324cb9a5a7cef2f1e60192'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: 'vmtest-temp01'
      adminUsername: testVMUsername
      adminPassword: testVMPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmtesttempNIC.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

@description('VM Test IP')
resource vmtesttempip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'vmtest-temp01-ip'
  location: location
  properties: {
    ipAddress: '20.212.39.139'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}
@description('VM Test NIC')
resource vmtesttempNIC 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vmtest-temp01430'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.0.4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: vmtesttempip.id
          }
          subnet: {
            id: 
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    nicType: 'Standard'
  }
  location: location
}

@description('Hub Storage Account')
resource consoledqzooisswmaa 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  name: 'consoledqzoo7isswmaa'
  location: location
  tags: {
  }
  properties: {
    minimumTlsVersion: 'TLS1_0'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

@description('Deploy Firewall Module')
module fw 'firewall.bicep' = {
  name: 'vmfwhubsea-FGT-A'
  params: {
    location: location
    firewallName: 'vmfwhubsea-FGT-A'
    fwAdminUsername: 'azureadm'
    fwAdminPassword: fwAdminPassword
  }
}
@description('Deploy WAF Module')
module waf 'waf.bicep' = {
  name: 'vmwafhubsea-FWB-A'
  params: {
    location: location
    wafName: 'vmfwhubsea-FGT-A'
    wafAdminUsername: 'azureadm'
    wafAdminPassword: wafAdminPassword
  }
}

