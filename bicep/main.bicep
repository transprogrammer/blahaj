targetScope = 'managementGroup'

param billingScope string

var name = 'beep-boops'
var desc = 'Beep Boops'

resource subscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: name
  properties: {
    workload: 'Production'
    displayName: desc
    billingScope: billingScope
  }
}

