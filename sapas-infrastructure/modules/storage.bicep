param location string


@description('Generated from /subscriptions/0276fc85-2ee5-498c-910b-b0bc6173cf54/resourceGroups/rg-hub-sea/providers/Microsoft.Storage/storageAccounts/consoledqzoo7isswmaa')
resource consoledqzooisswmaa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
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
