targetScope = 'resourceGroup'

@description('The Azure region where resources will be deployed.')
param location string = resourceGroup().location

@description('The deployment environment.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('The name of the virtual network.')
param vnetName string = 'vnet-kv-${environment}'

@description('The address space of the virtual network.')
param vnetAddressPrefix string = '10.30.0.0/16'

@description('The name of the VM subnet.')
param subnetName string = 'snet-vm'

@description('The address prefix of the VM subnet.')
param subnetAddressPrefix string = '10.30.1.0/24'

@description('The name of the Ubuntu virtual machine.')
param vmName string = 'vm-kv-${environment}'

@description('The administrator username for the virtual machine.')
param adminUsername string = 'azureuser'

@description('The SSH public key used to authenticate to the virtual machine.')
param sshPublicKey string

@description('The name of the Azure Key Vault.')
param keyVaultName string

@description('Tags applied to Azure resources.')
param tags object = {
  Environment: environment
  Project: 'Azure-Key-Vault-Lab'
}

var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
resource existingKeyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

module keyVault './modules/key-vault.bicep' = {
  name: 'deploy-key-vault'
  params: {
    location: location
    keyVaultName: keyVaultName
    tenantId: subscription().tenantId
    tags: tags
  }
}

module vnet './modules/vnet.bicep' = {
  name: 'deploy-vnet'
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
    tags: tags
  }
}

module vm './modules/vm.bicep' = {
  name: 'deploy-vm'
  params: {
    location: location
    vmName: vmName
    subnetId: vnet.outputs.subnetId
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    tags: tags
  }
}

resource keyVaultSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    subscription().id,
    keyVaultName,
    keyVaultSecretsUserRoleId
  )

  scope: existingKeyVault

  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      keyVaultSecretsUserRoleId
    )

    principalId: vm.outputs.principalId

    principalType: 'ServicePrincipal'
  }

  dependsOn: [
    keyVault
  ]
}
