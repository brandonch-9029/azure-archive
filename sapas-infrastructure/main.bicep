param location string = 'southeastasia'

@secure()
param sqlStagingPassword string
@secure()
param sqlProductionPassword string

@secure()
@description('Password for Test VM')
param testVMPassword string

@secure()
@description('Password for firewall')
param fwAdminPassword string

@secure()
@description('Password for WAF')
param wafAdminPassword string

module rg 'modules/rg.bicep' = {
  name: 'resourceGroupDeploy'
  scope: subscription('0276fc85-2ee5-498c-910b-b0bc6173cf54')
  params: {
    location: location
  }
}

module vnethub 'modules/vnethub.bicep' = {
  name: 'vnetHubDeploy'
  scope: resourceGroup('rg-hub-sea')
  params: {
    location: location
  }
}

module vnetapp 'modules/vnetapp.bicep' = {
  name: 'vnetAppDeploy'
  scope: resourceGroup('rg-sapas-network-sea')
  params: {
    location: location
    rgHubSeaID: vnethub.outputs.rgHubSeaID
  }
}

module storageaccount 'modules/storage.bicep' = {
  name: 'consoledqzooisswmaa'
  scope: resourceGroup('rg-hub-sea')
  params: {
    location: location
  }
}

module firewallDeploy 'modules/firewall.bicep' = {
  name: 'firewallDeploy'
  scope: resourceGroup('rg-hub-sea')
  params: {
    firewallName: 'vmfwhubsea-FGT-A'
    fwAdminPassword: fwAdminPassword
    fwAdminUsername: 'azureadmin'
    location: location
    subnetArray: vnethub.outputs.hubVNetSubnetArray
  }
}

/* Subnet Array = [
  0. GatewaySubnet, 
  1. temp, 
  2. snet-hub-mgmt, 
  3. snet-hub-firewall-external, 
  4. snet-hub-transit, 
  5. snet-hub-waf-internal]
*/

module wafDeploy 'modules/waf.bicep' = {
  name: 'wafDeploy'
  scope: resourceGroup('rg-hub-sea')
  params: {
    location: location
    wafAdminPassword: wafAdminPassword
    wafAdminUsername: 'azureadmin'
    wafName: 'vmwafhubsea-FWB-A'
    subnetArray: vnethub.outputs.hubVNetSubnetArray
  }
}

module stagWebApp 'modules/stagWebApp.bicep' = {
  name: 'app-deploy-stag'
  scope: resourceGroup('rg-sapas-stag-sea')
  params: {
    location: location
    sqlVirtualMachinePasswordStaging: sqlStagingPassword
    sqlVirtualMachineUsernameStaging: 'azureadmin'
    stagSubnetID: vnetapp.outputs.stagSubnet
  }
}

module prodWebApp 'modules/prodWebApp.bicep'= {
  name: 'app-deploy-prod'
  scope: resourceGroup('rg-sapas-prod-sea')
  params: {
    location: location
    prodSubnetID: vnetapp.outputs.prodSubnet
    sqlVirtualMachinePasswordProduction: sqlProductionPassword
    sqlVirtualMachineUsernameProduction: 'azureadmin'
  }
}
