// https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.compute/vm-simple-linux/main.bicep

var name              = 'beep-beeps'

param username string = 'blahaj'
@secure()
param public_key string

param location string = resourceGroup().location

var virtual_machine_size = 'Standard_B2ms'
var storage_account_type = 'Standard_LRS'

var virtual_network_address_prefix = '10.1.0.0/16'
var subnet_address_prefix          = '10.1.0.0/24'

var ubuntu_server_sku = '20.04 LTS'
var ubuntu_server_version = 'latest'

resource network_interface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: name
  location: location
  properties: {
    va
    ipConfigurations: [
      {
        name: name
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: public_ip_address.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: network_security_group.id
    }
  }
}

resource network_security_group 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: name
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource virtual_network 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtual_network_address_prefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: virtual_network
  name: name
  properties: {
    addressPrefix: subnet_address_prefix
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource public_ip_address 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: name 
    }
    idleTimeoutInMinutes: 4
  }
}

resource virtual_machine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtual_machine_size
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storage_account_type
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: ubuntu_server_sku
        version: ubuntu_server_version
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: network_interface_card.id
        }
      ]
    }
    osProfile: {
      computerName: name
      adminUsername: username
      adminPassword: public_key 
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${username}/.ssh/authorized_keys'
              keyData: public_key
            }
          ]
        }
      }
    }
  }
}

output ssh_command string = 'ssh ${username}@${public_ip_address.properties.dnsSettings.fqdn}'

