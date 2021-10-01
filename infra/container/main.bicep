param aciConnectionName string
param appName string
param containerRegistryName string
param environment string
param eventGridConnectionName string
param imageName string
param imageVersion string
param inputQueueName string
param inputStorageContainerName string
param location string
param logAnalyticsWorkspaceName string
param maxIdleTimeInMinutes int
param newBlobCreatedEventGridTopicName string
param numberOfContainersToCreate int
param orchtestrationFunctionAppName string
param outputStorageContainerName string
param storageAccountInputContainerName string
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

module containerInstanceDeployment 'aci.bicep' = {
  name: 'containerInstanceDeployment'
  params: {
    longName: longName
    storageAccountName: storageAccountName
    inputQueueName: inputQueueName
    containerRegistryName: containerRegistryName
    inputStorageContainerName: inputStorageContainerName
    outputStorageContainerName: outputStorageContainerName
    numberOfContainersToCreate: numberOfContainersToCreate
    imageName: imageName
    imageVersion: imageVersion
    maxIdleTimeInMinutes: maxIdleTimeInMinutes
  }
}

module logicAppDeployment 'logic.bicep' = {
  name: 'logicAppDeployment'
  params: {
    containerInstanceName: containerInstanceDeployment.outputs.containerInstanceName
    longName: longName
    newBlobCreatedEventGridTopicName: newBlobCreatedEventGridTopicName
    storageAccountName: storageAccountName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    storageAccountInputContainerName: storageAccountInputContainerName
    aciConnectionName: aciConnectionName
    eventGridConnectionName: eventGridConnectionName
  }
}

output containerInstanceName string = containerInstanceDeployment.outputs.containerInstanceName
