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

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: 'aci-${longName}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    containers: [for i in range(0, numberOfContainersToCreate): {
        name: '${imageName}${i}'
        properties: {
          image: '${containerRegistry.name}.azurecr.io/${imageName}:${imageVersion}'
          environmentVariables: [
            {
              name: 'AZURE_STORAGE_CONNECTION_STRING'
              secureValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccount.name), '2019-06-01').keys[0].value}'
            }
            {
              name: 'AZURE_STORAGE_QUEUE_NAME'
              value: inputQueueName
            }
            {
              name: 'AZURE_STORAGE_INPUT_BLOB_CONTAINER_NAME'
              value: inputStorageContainerName
            }
            {
              name: 'AZURE_STORAGE_OUTPUT_BLOB_CONTAINER_NAME'
              value: outputStorageContainerName
            }
            {
              name: 'MAX_IDLE_TIME_IN_MINUTES'
              value: '${maxIdleTimeInMinutes}'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }]
    osType: 'Linux'
    restartPolicy: 'Never'
    imageRegistryCredentials: [
      {
        server: '${containerRegistry.name}.azurecr.io'
        username: listCredentials(containerRegistry.id, containerRegistry.apiVersion).username
        password: listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords[0].value
      }
    ]
  }
}

resource aciConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'aci'
  location: resourceGroup().location
  properties: {
     api: {
       id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${uriComponent(resourceGroup().location)}/managedApis/aci'
     }
     displayName: 'aci'
     parameterValues: {       
     }
  }
}

output containerInstanceName string = containerInstance.name
