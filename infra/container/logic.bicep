param aciConnectionName string
param containerInstanceName string
param eventGridConnectionName string
param logAnalyticsWorkspaceName string
param longName string
param newBlobCreatedEventGridTopicName string
param storageAccountInputContainerName string
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource newBlobCreatedEventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-06-01-preview' = {
  name: '${newBlobCreatedEventGridTopicName}/newBlobCreatedForStartAciLogicAppEventSubscription'
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
        endpointUrl: listCallbackUrl(resourceId('Microsoft.Logic/workflows/triggers', logicApp.name, logicAppTriggerName), '2019-05-01').value
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
      subjectBeginsWith: '/blobServices/default/containers/${storageAccountInputContainerName}'
    }
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}

resource aciConnection 'Microsoft.Web/connections@2016-06-01' existing = {
  name: aciConnectionName
}

resource eventGridConnection 'Microsoft.Web/connections@2016-06-01' existing = {
  name: eventGridConnectionName
}

var logicAppTriggerName = 'When_a_resource_event_occurs'

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'logic-${longName}'
  location: resourceGroup().location
  properties: {    
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        '${logicAppTriggerName}': {
          splitOn: '@triggerBody()'
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              properties: {
                destination: {
                  endpointType: 'webhook'
                  properties: {
                    endpointUrl: '@{listCallbackUrl()}'
                  }
                }
                filter: {
                  includedEventTypes: [
                    'Microsoft.Storage.BlobCreated'
                  ]
                }
                topic: storageAccount.id
              }
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azureeventgrid\'][\'connectionId\']'
              }
            }
            path: '/subscriptions/${subscription().subscriptionId}/providers/${uriComponent('Microsoft.Storage.StorageAccounts')}/resource/eventSubscriptions'
            queries: {
              'x-ms-api-version': '2017-09-15-preview'
            }
          }
        }
      }
      actions: {
        'Start_containers_in_a_container_group': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'aci\'][\'connectionId\']'
              }
            }
            method: 'post'
            path: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${uriComponent(resourceGroup().name)}/providers/Microsoft.ContainerInstance/containerGroups/${uriComponent(containerInstanceName)}/start'
            queries: {
              'x-ms-api-version': '2019-12-01'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {
     '$connections': {
       value: {
         aci: {
           connectionId: aciConnection.id
           connectionName: 'aci'
           id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${uriComponent(resourceGroup().location)}/managedApis/aci'
         }
         azureeventgrid: {
           connectionId: eventGridConnection.id
           connectionName: 'azureeventgrid'
           id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${uriComponent(resourceGroup().location)}/managedApis/azureeventgrid'
         }
       }
     } 
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Logging'
  scope: logicApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'WorkflowRuntime'
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

output logicAppName string = logicApp.name
