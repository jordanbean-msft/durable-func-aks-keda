param logAnalyticsWorkspaceName string
param longName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: toLower(replace('sa${longName}', '-', ''))
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

var inputQueueName = 'input'

resource inputQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-04-01' = {
  name: '${storageAccount.name}/default/${inputQueueName}'
}

var inputContainerName = 'input'

resource inputContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/${inputContainerName}'
}

var outputContainerName = 'output'

resource outputContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/${outputContainerName}'
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource storageDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: storageAccount
  properties: {
    workspaceId: logAnalytics.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource storageBlobDiagnosticSettings 'Microsoft.Storage/storageAccounts/blobServices/providers/diagnosticsettings@2017-05-01-preview' = {
  name: '${storageAccount.name}/default/Microsoft.Insights/Logging'
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource storageTableDiagnosticSettings 'Microsoft.Storage/storageAccounts/tableServices/providers/diagnosticsettings@2017-05-01-preview' = {
  name: '${storageAccount.name}/default/Microsoft.Insights/Logging'
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource storageQueueDiagnosticSettings 'Microsoft.Storage/storageAccounts/queueServices/providers/diagnosticsettings@2017-05-01-preview' = {
  name: '${storageAccount.name}/default/Microsoft.Insights/Logging'
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource blobCreatedEventGridTopic 'Microsoft.EventGrid/systemTopics@2021-06-01-preview' = {
  name: 'egt-NewInputBlobCreated-${longName}'
  location: resourceGroup().location
  properties: {
    source: storageAccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  } 
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource blobCreatedEventGridTopicDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: blobCreatedEventGridTopic
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DeliveryFailures'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource eventGridConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azureeventgrid'
  location: resourceGroup().location
  properties: {
     api: {
       name: 'azureeventgrid'
       id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${uriComponent(resourceGroup().location)}/managedApis/azureeventgrid'
       type: 'Microsoft.Web/locations/managedApis'
     }
     displayName: 'azureeventgrid'
  }
}

output storageAccountName string = storageAccount.name
output inputContainerName string = inputContainerName
output outputContainerName string = outputContainerName
output inputQueueName string = inputQueueName
output newBlobCreatedEventGridTopicName string = blobCreatedEventGridTopic.name
