param newBlobCreatedEventGridTopicName string
param orchtestrationFunctionAppName string
param storageAccountOutputContainerName string

resource orchtestrationFunction 'Microsoft.Web/sites@2021-01-15' existing = {
  name: orchtestrationFunctionAppName
}

resource newBlobCreatedEventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-06-01-preview' = {
  name: '${newBlobCreatedEventGridTopicName}/newBlobCreatedForRaiseEventFunctionAppEventSubscription'
  properties: {
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        resourceId: '${orchtestrationFunction.id}/functions/ComputeComplete'
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }
    filter: {
      subjectBeginsWith: '/blobServices/default/containers/${storageAccountOutputContainerName}'
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
    }
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}
