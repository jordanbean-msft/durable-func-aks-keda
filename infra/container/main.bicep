param appName string
param containerRegistryName string
param environment string
param location string
param logAnalyticsWorkspaceName string
param newBlobCreatedEventGridTopicName string
param orchtestrationFunctionAppName string
param storageAccountName string
param storageAccountOutputContainerName string

var longName = '${appName}-${location}-${environment}'

module eventSubscriptionDeployment 'eventSubscription.bicep' = {
  name: 'eventSubscriptionDeployment'
  params: {
    orchtestrationFunctionAppName: orchtestrationFunctionAppName
    storageAccountOutputContainerName: storageAccountOutputContainerName
    newBlobCreatedEventGridTopicName: newBlobCreatedEventGridTopicName
  }
}

module aksDeployment 'aks.bicep' = {
  name: 'aksDeployment'
  params: {
    containerRegistryName: containerRegistryName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    longName: longName
    storageAccountName: storageAccountName
  }
}

output aksName string = aksDeployment.outputs.aksName
