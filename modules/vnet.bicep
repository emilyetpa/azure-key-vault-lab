@description('The Azure region where the virtual network will be created.')
param location string

@description('The name of the virtual network.')
param vnetName string

@description('The address space of the virtual network.')
param vnetAddressPrefix string

@description('The name of the VM subnet.')
param subnetName string

@description('The address prefix of the VM subnet.')
param subnetAddressPrefix string

@description('Tags applied to the virtual network.')
param tags object = {}


resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }

    subnets: [
      {
        name: subnetName

        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }

  tags: tags
}

output vnetId string = vnet.id

output subnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  subnetName
)
