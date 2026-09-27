@description('The Azure region where the Key Vault will be created.')
param location string

@description('The name of the Azure Key Vault.')
param keyVaultName string

@description('The Microsoft Entra tenant ID.')
param tenantId string

@description('Tags applied to the Key Vault.')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location

  properties: {
    tenantId: tenantId

    sku: {
      family: 'A'
      name: 'standard'
    }

    enableRbacAuthorization: true

    publicNetworkAccess: 'Enabled'
  }

  tags: tags
}

output keyVaultId string = keyVault.id

output keyVaultName string = keyVault.name

output keyVaultUri string = keyVault.properties.vaultUri
