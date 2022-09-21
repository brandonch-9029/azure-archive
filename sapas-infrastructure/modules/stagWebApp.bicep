param location string
param sqlVirtualMachineUsernameStaging string
param stagSubnetID string

@secure()
param sqlVirtualMachinePasswordStaging string



@description('vm-sapas-webapp-stag-01 Virtual Machine')
resource vmsapaswebappstag 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: 'vm-sapas-webapp-stag-01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_E2bs_v5'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftsqlserver'
        offer: 'sql2019-ws2019'
        sku: 'standard-gen2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: 'vm-sapas-webapp-stag-01_OsDisk_1_498ee96ed99a4a2684dd7117d252f50b'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: [
        {
          lun: 0
          name: 'vm-sapas-webapp-stag-01_DataDisk_0'
          createOption: 'Attach'
          caching: 'ReadOnly'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          deleteOption: 'Detach'
          diskSizeGB: 32
          toBeDetached: false
        }
        {
          lun: 1
          name: 'vm-sapas-webapp-stag-01_DataDisk_1'
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          deleteOption: 'Detach'
          diskSizeGB: 16
          toBeDetached: false
        }
        {
          lun: 2
          name: 'vm-sapas-webapp-stag-01_DataDisk_2'
          createOption: 'Attach'
          caching: 'None'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          deleteOption: 'Detach'
          diskSizeGB: 256
          toBeDetached: false
        }
      ]
    }
    osProfile: {
      computerName: 'vm-sapas-webapp'
      adminUsername: sqlVirtualMachineUsernameStaging
      adminPassword: sqlVirtualMachinePasswordStaging
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
          id: vmsapaswebappstagNIC.id
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
    licenseType: 'Windows_Server'
  }
}

@description('vm-sapas-webapp-stag-01 SQL VM')
resource vmsapaswebappstagSQL 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2022-07-01-preview' = {
  properties: {
    virtualMachineResourceId: vmsapaswebappstag.id
    sqlImageOffer: 'SQL2019-WS2019'
    sqlServerLicenseType: 'AHUB'
    sqlManagement: 'Full'
    leastPrivilegeMode: 'NotSet'
    sqlImageSku: 'Standard'
  }
  location: location
  name: 'vm-sapas-webapp-stag-01'
}


@description('Generated from /subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-sapas-stag-sea/providers/Microsoft.Network/networkInterfaces/vm-sapas-webapp-s725')
resource vmsapaswebappstagNIC 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vm-sapas-webapp-s725'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.198.4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: stagSubnetID
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: [
        '10.224.198.4'
      ]
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    nicType: 'Standard'
  }
  location: location
  kind: 'Regular'
}
