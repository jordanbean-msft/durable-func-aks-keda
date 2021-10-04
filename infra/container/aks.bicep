param containerRegistryName string
param longName string
param storageAccountName string
param logAnalyticsWorkspaceName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: 'aks-${longName}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osDiskSizeGB: 60
        osDiskType: 'Ephemeral'
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: true
        osType: 'Linux'
        osSKU: 'Ubuntu'
        minCount: 1
        maxCount: 5
        mode: 'System'
      }
    ]
    addonProfiles: {
      azurepolicy: {
        enabled: true
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }
    }
    enableRBAC: true
    dnsPrefix: longName
  }
}

resource aksComputeAgentPool 'Microsoft.ContainerService/managedClusters/agentPools@2021-07-01' = {
  name: '${aks.name}/computepool'
  properties: {
    count: 1
    vmSize: 'Standard_D8s_v3'
    osDiskSizeGB: 60
    osDiskType: 'Ephemeral'
    type: 'VirtualMachineScaleSets'
    minCount: 1
    maxCount: 100
    enableAutoScaling: true
    mode: 'User'
    osType: 'Linux'
    osSKU: 'Ubuntu'
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid('${longName}-AcrPullRole')
  scope: containerRegistry
  properties: {
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

output aksName string = aks.name
