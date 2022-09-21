// Vnet Peering Resource IDs
// Main Vnet: vnet-hub-sea
//
// peering-hub-sapas - vnet-sapas-prod-sea > /subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-prod-sea
// peering-hub-sap - vnet-HEC53-GDC > /subscriptions/7c103b37-56da-4ea7-ada0-77d1dbaf6cb3/resourceGroups/HEC53-GDC-southeastasia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC53-GDC
// peering-hub-sapstag - vnet-sapas-stag-sea > /subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-sapas-network-sea/providers/Microsoft.Network/virtualNetworks/vnet-sapas-stag-sea
// peering-hub-sapdr - vnet-HEC55-GDC > /subscriptions/f778f7ee-f512-4c11-bc0e-0ee426e8414c/resourceGroups/HEC55-GDC-southindia-1/providers/Microsoft.Network/virtualNetworks/vnet-HEC55-GDC


@description('Set the local VNet name')
param existingLocalVirtualNetworkName string

@description('Set the remote VNet name')
param existingRemoteVirtualNetworkName string

@description('Sets the remote VNet Resource group')
param existingRemoteVirtualNetworkResourceGroupName string

resource existingLocalVirtualNetworkName_peering_to_remote_vnet 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: 'rg-hub-sea/${existingLocalVirtualNetworkName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId(existingRemoteVirtualNetworkResourceGroupName, 'Microsoft.Network/virtualNetworks', existingRemoteVirtualNetworkName)
    }
  }
}


