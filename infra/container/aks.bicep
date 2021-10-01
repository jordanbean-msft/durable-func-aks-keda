param containerRegistryName string
param imageName string
param imageVersion string
param inputQueueName string
param inputStorageContainerName string
param longName string
param maxIdleTimeInMinutes int
param numberOfContainersToCreate int
param outputStorageContainerName string
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: 'aks-${longName}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
    tier: 'Free'
  }
  properties: {
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: 1
        enableAutoScaling: true        
      }
    ]
  }
}
