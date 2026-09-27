@description('The Azure region where the virtual machine will be created.')
param location string

@description('The name of the virtual machine.')
param vmName string

@description('The resource ID of the subnet where the VM will be deployed.')
param subnetId string

@description('The administrator username for the virtual machine.')
param adminUsername string

@description('The SSH public key used to authenticate to the virtual machine.')
param sshPublicKey string

@description('The size of the virtual machine.')
param vmSize string = 'Standard_B2s'

@description('The Linux distribution image publisher.')
param imagePublisher string = 'Canonical'

@description('The Linux distribution image offer.')
param imageOffer string = 'ubuntu-24_04-lts'

@description('The Linux distribution image SKU.')
param imageSku string = 'server'

@description('The Linux distribution image version.')
param imageVersion string = 'latest'

@description('Tags applied to the virtual machine.')
param tags object = {}


resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${vmName}-nic'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          subnet: {
            id: subnetId
          }

          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }

  tags: tags
}

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmName
  location: location

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }

      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername

      linuxConfiguration: {
        disablePasswordAuthentication: true

        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }

  tags: tags
}

output vmId string = vm.id

output vmName string = vm.name

output principalId string = vm.identity.principalId

output nicId string = nic.id
