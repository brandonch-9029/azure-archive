param location string 
param wafName string
param wafAdminUsername string
param subnetArray array
/* Subnet Array = [
  0. GatewaySubnet, 
  1. temp, 
  2. snet-hub-mgmt, 
  3. snet-hub-firewall-external, 
  4. snet-hub-transit, 
  5. snet-hub-waf-internal]
*/

@secure()
param wafAdminPassword string

@description('')
resource vmwafhubseaFWBA 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: wafName
  location: location
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831FWBVM'
  }
  plan: {
    name: 'fortinet_fw-vm'
    publisher: 'fortinet'
    product: 'fortinet_fortiweb-vm_v5'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'fortinet'
        offer: 'fortinet_fortiweb-vm_v5'
        sku: 'fortinet_fw-vm'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: 'vmwafhubsea-FWB-A_OsDisk_1_da7e42cfcb5948b8b12be12e2e5f8a56'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Detach'
        diskSizeGB: 2
      }
      dataDisks: [
        {
          lun: 0
          name: 'vmwafhubsea-FWB-A_disk2_ded5b1599da148238fd0caf8938f26d7'
          createOption: 'Empty'
          caching: 'None'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          deleteOption: 'Detach'
          diskSizeGB: 30
          toBeDetached: false
        }
      ]
    }
    osProfile: {
      computerName: 'vmwafhubsea-FWB-A'
      adminUsername: wafAdminUsername
      adminPassword: wafAdminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmwafhubseaFWBANic1.id
          properties: {
            primary: true
          }
        }
        {
          id: vmwafhubseaFWBANic2.id
          properties: {
            primary: false
          }
        }
        {
          id: vmwafhubseaFWBANic3.id
          properties: {
            primary: false
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        #disable-next-line no-hardcoded-env-urls
        storageUri: 'https://consoledqzoo7isswmaa.blob.core.windows.net/'
      }
    }
  }
}

// WAF PIP

@description('pip-waf-hub-sea-01')
resource pipwafhubsea 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-waf-hub-sea-01'
  location: location
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831FWBVM'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '20.205.221.189'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

// Firewall NSG
@description('NSG Firewall')
resource vmwafhubseadqzooisswmaaNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'vmwafhubsea-dqzoo7isswmaa-NSG'
  location: location
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831FWBVM'
  }
  properties: {
    securityRules: [
      {
        name: 'AllowSSHInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow SSH In'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowHTTPInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow 80 In'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowHTTPSInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow 443 In'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowDevRegInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow 514 in for device registration'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '514'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowMgmtHTTPInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow 8080 In'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 140
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowMgmtHTTPSInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow 8443 In'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 150
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAllOutbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow all out'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 105
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}


// Firewall NICs
@description('vmwafhubsea-FWB-A-Nic1')
resource vmwafhubseaFWBANic1 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vmwafhubsea-FWB-A-Nic1'
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831FWBVM'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.37'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetArray[4]
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
      {
        name: 'ipconfig2'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.38'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetArray[4]
          }
          primary: false
          privateIPAddressVersion: 'IPv4'
        }
      }
      {
        name: 'ipconfig3'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.39'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetArray[4]
          }
          primary: false
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: vmwafhubseadqzooisswmaaNSG.id
    }
    nicType: 'Standard'
  }
  location: location
}


@description('vmwafhubsea-FWB-A-Nic2')
resource vmwafhubseaFWBANic2 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vmwafhubsea-FWB-A-Nic2'
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831FWBVM'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.3.4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetArray[5]
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: vmwafhubseadqzooisswmaaNSG.id
    }
    nicType: 'Standard'
  }
  location: location
}


@description('vmwafhubsea-FWB-A-Nic3')
resource vmwafhubseaFWBANic3 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vmwafhubsea-FWB-A-Nic3'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.69'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: pipwafhubsea.id
          }
          subnet: {
            id: subnetArray[2]
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: vmwafhubseadqzooisswmaaNSG.id
    }
    nicType: 'Standard'
  }
  location: location
}


