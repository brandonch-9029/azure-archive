targetScope = 'subscription'
param location string 

@description('Deploys Resource Group rg-hub-sea')
resource rghubsea 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-hub-sea'
  location: location
}
@description('Deploys Resource Group rg-sapas-network-sea')
resource rgsapasnetworksea 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-sapas-network-sea'
  location: location
}
@description('Deploys Resource Group rg-sapas-prod-sea')
resource rgsapasprodsea 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-sapas-prod-sea'
  location: location
}
@description('Deploys Resource Group rg-sapas-stag-sea')
resource rgsapasstagsea 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-sapas-stag-sea'
  location: location
}
