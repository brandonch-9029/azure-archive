param location string

param subscriptionid string

// Array of peering details for vnet-hub-sea
param vnetHubPeerings object = {
  peer1: {
    name: 'peering-hub-sapas'
    remoteVNet: 'vnet-sapas-prod-sea'
    resourceID: '/subscriptions/${subscriptionid}/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-prod-sea'
  }
  peer2: {
    name: 'peering-hub-sap'
    remoteVNet: 'vnet-HEC53-GDC'
    resourceID: '/subscriptions/${subscriptionid}/resourceGroups/HEC53-GDC-southeastasia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC53-GDC'
  }
  peer3: {
    name: 'peering-hub-sapas-stag'
    remoteVNet: 'vnet-sapas-stag-sea'
    resourceID: '/subscriptions/${subscriptionid}/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-stag-sea'
  }
  peer4: {
    name: 'peering-hub-sapdr'
    remoteVNet: 'vnet-HEC55-GDC'
    resourceID: '/subscriptions/${subscriptionid}/resourceGroups/HEC55-GDC-southindia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC55-GDC'
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


@description('')
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
      radiusServers: []
      vpnClientIpsecPolicies: []
      #disable-next-line no-hardcoded-env-urls
      aadTenant: 'hidden'
      aadAudience: 'hidden'
      aadIssuer: 'hidden'
    }
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.224.1.30'
      peerWeight: 0
    }
    customRoutes: {
      addressPrefixes: []
    }
    vpnGatewayGeneration: 'Generation1'
  }
}
output hubVNetSubnetArray array = [
  vnethubsea.properties.subnets[0].id
  vnethubsea.properties.subnets[1].id
  vnethubsea.properties.subnets[2].id
  vnethubsea.properties.subnets[3].id
  vnethubsea.properties.subnets[4].id
  vnethubsea.properties.subnets[5].id
]

output rgHubSeaID string = vnethubsea.id
