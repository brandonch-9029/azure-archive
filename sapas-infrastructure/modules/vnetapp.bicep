param location string
param rgHubSeaID string


@description('Production Virtual Network SEA: vnet-sapas-prod-sea')
resource vnetProductionHub 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet-sapas-prod-sea'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.224.196.0/23'
      ]
    }
    subnets: [
      {
        name: 'snet-sapas-webapp'
        properties: {
          addressPrefix: '10.224.196.0/28'
          networkSecurityGroup: {
            id: nsgsapaswebapp.id
          }
          routeTable: {
            id: rtsapasnetworksea.id
          }
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

@description('Staging Virtual Network SEA: vnet-sapas-stag-sea')
resource vnetStagingHub 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet-sapas-stag-sea'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.224.198.0/23'
      ]
    }
    subnets: [
      {
        name: 'snet-sapas-webapp'
        properties: {
          addressPrefix: '10.224.198.0/28'
          networkSecurityGroup: {
            id: nsgsapaswebapp.id
          }
          routeTable: {
            id: rtsapasnetworksea.id
          }
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

resource stagtohubpeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: 'vnet-sapas-stag-sea/peering-sapasstag-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: rgHubSeaID
    }
  }
}

resource prodtohubpeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: 'vnet-sapas-prod-sea/peering-sapas-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: rgHubSeaID
    }
  }
}


@description('Route Table for Prod/Stag')
resource rtsapasnetworksea 'Microsoft.Network/routeTables@2022-01-01' = {
  name: 'rt-sapas-network-sea'
  location: location
  tags: {
  }
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'ToVPN'
        properties: {
          addressPrefix: '10.224.17.0/24'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.224.2.36'
          hasBgpOverride: false
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
      {
        name: 'ToSAP'
        properties: {
          addressPrefix: '10.224.192.0/22'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.224.2.36'
          hasBgpOverride: false
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
      {
        name: 'ToAzVPN'
        properties: {
          addressPrefix: '10.224.18.0/24'
          nextHopType: 'VirtualNetworkGateway'
          nextHopIpAddress: ''
          hasBgpOverride: false
        }
        type: 'Microsoft.Network/routeTables/routes'
      }
      {
        name: 'ToInternet'
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

@description('Network Security Group for sapas web app')
resource nsgsapaswebapp 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'nsg-sapas-webapp'
  location: location
  tags: {
  }
  properties: {
    securityRules: [
      {
        name: 'allow_ping'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'ICMP'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

output prodSubnet string = vnetProductionHub.properties.subnets[0].id
output stagSubnet string = vnetStagingHub.properties.subnets[0].id
