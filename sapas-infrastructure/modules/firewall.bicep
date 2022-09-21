param location string 
param firewallName string
param fwAdminUsername string
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
param fwAdminPassword string


@description('')
resource vmfwhubseaFGTA 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: firewallName
  location: location
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831VM'
  }
  plan: {
    name: 'fortinet_fg-vm'
    publisher: 'fortinet'
    product: 'fortinet_fortigate-vm_v5'
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
        offer: 'fortinet_fortigate-vm_v5'
        sku: 'fortinet_fg-vm'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: 'vmfwhubsea-FGT-A_OsDisk_1_a56da2b46441463babef02257b292fa8'
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
          name: 'vmfwhubsea-FGT-A_disk2_e9ca531a85c044d8ab024ccb37cd1595'
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
      computerName: 'vmfwhubsea-FGT-A'
      adminUsername: fwAdminUsername
      adminPassword: fwAdminPassword
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
          id: vmfwhubseaFGTANic1.id
          properties: {
            primary: true
          }
        }
        {
          id: vmfwhubseaFGTANic2.id
          properties: {
            primary: false
          }
        }
        {
          id: vmfwhubseaFGTANic3.id
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

//Firewall PIPs and Prefix

@description('pippfx-hub-sea')
resource pippfxhubsea 'Microsoft.Network/publicIPPrefixes@2022-01-01' = {
  name: 'pippfx-hub-sea'
  location: location
  tags: {
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    prefixLength: 29
    publicIPAddressVersion: 'IPv4'
    ipTags: []
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
@description('pip-hub-sea-01')
resource piphubsea1 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-hub-sea-01'
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '20.212.126.112'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    publicIPPrefix: {
      id: pippfxhubsea.id
    }
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
@description('pip-hub-sea-02')
resource piphubsea2 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-hub-sea-02'
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '20.212.126.113'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    publicIPPrefix: {
      id: pippfxhubsea.id
    }
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
@description('pip-hub-sea-03')
resource piphubsea3 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-hub-sea-03'
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '20.212.126.114'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    publicIPPrefix: {
      id: pippfxhubsea.id
    }
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}
@description('pip-fw-hub-sea-01')
resource pipfwhubsea 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-fw-hub-sea-01'
  location: location
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831VM'
  }
  properties: {
    ipAddress: '104.215.187.92'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: 'vmfwhubsea-fgt-a-dqzoo7isswmaa'
      fqdn: 'vmfwhubsea-fgt-a-dqzoo7isswmaa.southeastasia.cloudapp.azure.com'
    }
    ipTags: []
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}


// Firewall NSG
@description('Firewall NSG')
resource vmfwhubseadqzooisswmaaNSG 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'vmfwhubsea-dqzoo7isswmaa-NSG'
  location: location
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831VM'
  }
  properties: {
    securityRules: [
      {
        name: 'AllowAllInbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Allow all in'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
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
@description('FW NIC 1')
resource vmfwhubseaFGTANic1 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vmfwhubsea-FGT-A-Nic1'
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831VM'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.4'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: piphubsea1.id
          }
          subnet: {
            id: subnetArray[3]
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
      {
        name: 'ipconfig2'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.5'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: piphubsea2.id
          }
          subnet: {
            id: subnetArray[3]
          }
          primary: false
          privateIPAddressVersion: 'IPv4'
        }
      }
      {
        name: 'ipconfig3'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.6'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: piphubsea3.id
          }
          subnet: {
            id: subnetArray[3]
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
    enableIPForwarding: true
    networkSecurityGroup: {
      id: vmfwhubseadqzooisswmaaNSG.id
    }
    nicType: 'Standard'
  }
  location: location
}

@description('FW NIC 2')
resource vmfwhubseaFGTANic2 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vmfwhubsea-FGT-A-Nic2'
  tags: {
    provider: '6EB3B02F-50E5-4A3E-8CB8-2E12925831VM'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.36'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetArray[4]
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
    enableIPForwarding: true
    networkSecurityGroup: {
      id: vmfwhubseadqzooisswmaaNSG.id
    }
    nicType: 'Standard'
  }
  location: location
}

@description('HW NIC 3')
resource vmfwhubseaFGTANic3 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'vmfwhubsea-FGT-A-Nic3'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          privateIPAddress: '10.224.2.68'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: pipfwhubsea.id
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
      id: vmfwhubseadqzooisswmaaNSG.id
    }
    nicType: 'Standard'
  }
  location: location
}
