param appName string
param environment string
param location string

var longName = '${appName}-${location}-${environment}'
var orchtestrationFunctionAppName = 'func-${longName}'

module loggingDeployment 'logging.bicep' = {
  name: 'loggingDeployment'
  params: {
    longName: longName
    orchtestrationFunctionAppName: orchtestrationFunctionAppName
  }
}

module storageDeployment 'storage.bicep' = {
  name: 'storageDeployment'
  params: {
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
  }
}

module containerRegistryDeployment 'acr.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    longName: longName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
  }
}

module functionDeployment 'func.bicep' = {
  name: 'functionDeployment'
  params: {
    longName: longName
    storageAccountInputContainerName: storageDeployment.outputs.inputContainerName
    logAnalyticsWorkspaceName: loggingDeployment.outputs.logAnalyticsWorkspaceName
    orchtestrationFunctionAppName: orchtestrationFunctionAppName
    appInsightsName: loggingDeployment.outputs.appInsightsName
    storageAccountQueueName: storageDeployment.outputs.inputQueueName
    storageAccountName: storageDeployment.outputs.storageAccountName
  }
}

output storageAccountName string = storageDeployment.outputs.storageAccountName
output storageAccountInputContainerName string = storageDeployment.outputs.inputContainerName
output storageAccountInputQueueName string = storageDeployment.outputs.inputQueueName
output storageAccountOutputContainerName string = storageDeployment.outputs.outputContainerName
output containerRegistryName string = containerRegistryDeployment.outputs.containerRegistryName
output logAnalyticsWorkspaceName string = loggingDeployment.outputs.logAnalyticsWorkspaceName
output appInsightsName string = loggingDeployment.outputs.appInsightsName
output newBlobCreatedEventGridTopicName string = storageDeployment.outputs.newBlobCreatedEventGridTopicName
output orchtestrationFunctionAppName string = orchtestrationFunctionAppName
