param location string

// Array of peering details for vnet-hub-sea
param vnetHubPeerings object = {
  peer1: {
    name: 'peering-hub-sapas'
    remoteVNet: 'vnet-sapas-prod-sea'
    resourceID: '/subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-prod-sea'
  }
  peer2: {
    name: 'peering-hub-sap'
    remoteVNet: 'vnet-HEC53-GDC'
    resourceID: '/subscriptions/7c103b37-56da-4ea7-ada0-77d1dbaf6cb3/resourceGroups/HEC53-GDC-southeastasia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC53-GDC'
  }
  peer3: {
    name: 'peering-hub-sapas-stag'
    remoteVNet: 'vnet-sapas-stag-sea'
    resourceID: '/subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-stag-sea'
  }
  peer4: {
    name: 'peering-hub-sapdr'
    remoteVNet: 'vnet-HEC55-GDC'
    resourceID: '/subscriptions/f778f7ee-f512-4c11-bc0e-0ee426e8414c/resourceGroups/HEC55-GDC-southindia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC55-GDC'
  }
}

// peering name prefix
var hubPeeringName = 'hub-peering-'

@description('Hub Virtual Network SEA: vnet-hub-sea')
resource vnethubsea 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet-hub-sea'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.224.0.0/20'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.224.1.0/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'temp'
        properties: {
          addressPrefix: '10.224.0.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'snet-hub-mgmt'
        properties: {
          addressPrefix: '10.224.2.64/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'snet-hub-firewall-external'
        properties: {
          addressPrefix: '10.224.2.0/27'
          routeTable: {
            id: rthubfirewallexternal.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'snet-hub-transit'
        properties: {
          addressPrefix: '10.224.2.32/27'
          routeTable: {
            id: rthubtransit.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'snet-hub-waf-internal'
        properties: {
          addressPrefix: '10.224.3.0/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    enableDdosProtection: false
  }
}

@description('Iterates through vnetHubPeerings array to define peerings')
module vnetPeeringsHub 'vnetPeeringTemplate.bicep' = [for i in items(vnetHubPeerings): {
  name: '${hubPeeringName}${i}'
  params: {
    existingLocalVirtualNetworkName: i.value.name
    existingRemoteVirtualNetworkResourceGroupName: i.value.remotevnet
    existingRemoteVirtualNetworkName: i.value.resourceID
  }
}]

@description('Route Table Hub Firewall External')
resource rthubfirewallexternal 'Microsoft.Network/routeTables@2022-01-01' = {
  name: 'rt-hub-firewall-external'
  location: location
  tags: {
  }
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
          nextHopIpAddress: ''
          hasBgpOverride: false
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
    ]
  }
}

@description('Route Table Hub Transit')
resource rthubtransit 'Microsoft.Network/routeTables@2022-01-01' = {
  name: 'rt-hub-transit'
  location: location
  tags: {
  }
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.224.2.36'
          hasBgpOverride: false
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
    ]
  }
}



@description('Generated from /subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-hub-sea/providers/Microsoft.Network/publicIPAddresses/pip-shared-hub-sea')
resource pipsharedhubsea 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pip-shared-hub-sea'
  location: location
  properties: {
    ipAddress: '207.46.237.148'
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

@description('vgw-shared-hub-sea')
resource vgwsharedhubsea 'Microsoft.Network/virtualNetworkGateways@2022-01-01' = {
  name: 'vgw-shared-hub-sea'
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'gwconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipsharedhubsea.id
          }
          subnet: {
            id: vnethubsea.properties.subnets[0].id // GatewaySubnet
          }
        }
      }
    ]
    natRules: []
    enableBgpRouteTranslationForNat: false
    disableIPSecReplayProtection: false
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '10.224.18.0/24'
        ]
      }
      vpnClientProtocols: [
        'OpenVPN'
      ]
      vpnAuthenticationTypes: [
        'AAD'
      ]
      vpnClientRootCertificates: []
      vpnClientRevokedCertificates: []
      vngClientConnectionConfigurations: []
      vpnClientConnectionHealth: {
        vpnClientConnectionsCount: 5
        allocatedIpAddresses: [
          '10.224.18.5'
          '10.224.18.2'
          '10.224.18.4'
          '10.224.18.3'
          '10.224.18.6'
        ]
        totalIngressBytesTransferred: 6540896761
        totalEgressBytesTransferred: 14593702811
      }
      radiusServers: []
      vpnClientIpsecPolicies: []
      aadTenant: 'https://login.microsoftonline.com/d1dbb6ae-7ad0-4ac9-92dc-defb3673faaa/'
      aadAudience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
      aadIssuer: 'https://sts.windows.net/d1dbb6ae-7ad0-4ac9-92dc-defb3673faaa/'
    }
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.224.1.30'
      peerWeight: 0
      bgpPeeringAddresses: [
        {
          ipconfigurationId: '/subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-hub-sea/providers/Microsoft.Network/virtualNetworkGateways/vgw-shared-hub-sea/ipConfigurations/gwconfig'
          customBgpIpAddresses: []
        }
      ]
    }
    customRoutes: {
      addressPrefixes: []
    }
    remoteVirtualNetworkPeerings: [
      {
        id: '/subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-prod-sea/virtualNetworkPeerings/peering-sapas-hub'
      }
      {
        id: '/subscriptions/7c103b37-56da-4ea7-ada0-77d1dbaf6cb3/resourceGroups/HEC53-GDC-southeastasia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC53-GDC/virtualNetworkPeerings/peering-sap-hub'
      }
      {
        id: '/subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-stag-sea/virtualNetworkPeerings/peering-sapasstag-hub'
      }
      {
        id: '/subscriptions/f778f7ee-f512-4c11-bc0e-0ee426e8414c/resourceGroups/HEC55-GDC-southindia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC55-GDC/virtualNetworkPeerings/vnet-HEC55-GDC-SG-SAPAS-VNET01'
      }
    ]
    vpnGatewayGeneration: 'Generation1'
  }
}
output hubVNetSubnetArray array = [
  resourceId('Microsoft.Network/VirtualNetworks/subnets', 'vnet-hub-sea', 'GatewaySubnet')
  resourceId('Microsoft.Network/VirtualNetworks/subnets', 'vnet-hub-sea', 'temp')
  resourceId('Microsoft.Network/VirtualNetworks/subnets', 'vnet-hub-sea', 'snet-hub-mgmt')
  resourceId('Microsoft.Network/VirtualNetworks/subnets', 'vnet-hub-sea', 'snet-hub-firewall-external')
  resourceId('Microsoft.Network/VirtualNetworks/subnets', 'vnet-hub-sea', 'snet-hub-transit')
  resourceId('Microsoft.Network/VirtualNetworks/subnets', 'vnet-hub-sea', 'snet-hub-waf-internal')
]

output rgHubSeaID string = vnethubsea.id
