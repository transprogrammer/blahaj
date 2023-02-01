param username string = 'uwu'

@secure()
param public_key string

param location string = resourceGroup().location
param failover_location string = 'westus2'

var name = 'blahaj'

var virtual_machine_size = 'Standard_B2ms'
var storage_account_type = 'Standard_LRS'

var virtual_network_address_prefix = '10.1.0.0/16'
var subnet_address_prefix          = '10.1.0.0/24'

var ubuntu_server_offer = '0001-com-ubuntu-server-focal'
var ubuntu_server_sku = '20_04-lts-gen2'
var ubuntu_server_version = 'latest'

resource network_interface 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: name
        properties: {
          subnet: {
              id: filter(virtual_network.properties.subnets, subnet => subnet.name == name)[0].id
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
    subnets: [{
      name: name
      properties: {
        addressPrefix: subnet_address_prefix
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        networkSecurityGroup: {
          id: network_security_group.id
        }
      }
    }]
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
        offer: ubuntu_server_offer
        sku: ubuntu_server_sku
        version: ubuntu_server_version
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: network_interface.id
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

//param accountName string = 'mongodb-${uniqueString(resourceGroup().id)}'

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' = {
  name: name
  location: location
  kind: 'MongoDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Eventual'
    }
    locations: [
      {
        locationName: failover_location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: true
    apiProperties: {
      serverVersion: '4.2'
    }
    capabilities: [
      {
        name: 'DisableRateLimitingResponses'
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2022-05-15' = {
  parent: account
  name: name
  properties: {
    resource: {
      id: name
    }
    options: {
      throughput: 400
    }
  }
}

output ssh_command string = 'ssh ${username}@${public_ip_address.properties.dnsSettings.fqdn}'

