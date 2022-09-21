param location string
param testVMUsername string

@secure()
param testVMPassword string
param subnetArray array
/* Subnet Array = [
  0. GatewaySubnet, 
  1. temp, 
  2. snet-hub-mgmt, 
  3. snet-hub-firewall-external, 
  4. snet-hub-transit, 
  5. snet-hub-waf-internal]
*/

@description('vmtest-temp01')
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


@description('vmtest-temp01NIC')
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
            id: subnetArray[1]
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
  kind: 'Regular'
}


@description('vmtest-temp01-ip')
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
