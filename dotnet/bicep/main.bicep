param username string

@secure()
param publicKey string

param primaryRegion string
param failoverRegion string

var name = 'blahaj'

param virtualMachineSize string
param storageAccountType string

param virtualNetworkAddressPrefix string
param subnetAddressPrefix string

param ubuntuServerOffer string
param ubuntuServerSku string
param ubuntuServerVersion string

resource public_ip_address 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: name
  location: primaryRegion
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

resource network_security_group 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: name
  location: primaryRegion
  properties: {
    securityRules: [ {
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
      } ]
  }
}

resource application_security_group 'Microsoft.Network/applicationSecurityGroups@2022-07-01' = {
  name: name
  location: primaryRegion
}

resource virtual_network 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: name
  location: primaryRegion
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [ {
        name: name
        properties: {
          addressPrefix: subnetAddressPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: network_security_group.id
          }
        }
      } ]
  }
}

resource private_dns_zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.mongo.cosmos.azure.com'
  location: 'global'

  resource virtual_network_link 'virtualNetworkLinks@2020-06-01' = {
    name: name
    location: 'global'
    properties: {
      registrationEnabled: true
      virtualNetwork: {
        id: virtual_network.id
      }
    }
  }
}

resource network_interface 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: name
  location: primaryRegion
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
          applicationSecurityGroups: [ {
              id: application_security_group.id
            } ]
        }
      }
    ]
    networkSecurityGroup: {
      id: network_security_group.id
    }
  }
}

resource virtual_machine 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: name
  location: primaryRegion
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: ubuntuServerOffer
        sku: ubuntuServerSku
        version: ubuntuServerVersion
      }
    }
    networkProfile: {
      networkInterfaces: [ {
          id: network_interface.id
        } ]
    }
    osProfile: {
      computerName: name
      adminUsername: username
      adminPassword: publicKey
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${username}/.ssh/authorized_keys'
              keyData: publicKey
            }
          ]
        }
      }
    }
  }
}

resource database_account 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' = {
  name: name
  location: primaryRegion
  kind: 'MongoDB'
  properties: {
    apiProperties: {
      serverVersion: '4.2'
    }
    capabilities: [
      {
        name: 'DisableRateLimitingResponses'
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Eventual'
    }
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: true
    locations: [
      {
        locationName: failoverRegion
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    publicNetworkAccess: 'Disabled'
  }

  resource database 'mongodbDatabases@2022-05-15' = {
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
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: name
  location: primaryRegion
  properties: {
    subnet: filter(virtual_network.properties.subnets, subnet => subnet.name == name)[0]
    privateLinkServiceConnections: [
      {
        name: name
        properties: {
          privateLinkServiceId: database_account.id
          groupIds: [
            'MongoDB'
          ]
        }
      }
    ]
  }

  resource private_dns_zone_group 'privateDnsZoneGroups@2022-07-01' = {
    name: name
    properties: {
      privateDnsZoneConfigs: [
        {
          name: name
          properties: {
            privateDnsZoneId: private_dns_zone.id
          }
        }
      ]
    }
  }
}

output ssh_command string = 'ssh ${username}@${public_ip_address.properties.dnsSettings.fqdn}'
