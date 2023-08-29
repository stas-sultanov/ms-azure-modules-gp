metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

@description('Number of days to keep the logs. -1 for unlimited retention.')
@allowed([
  'CapacityReservation'
  'LACluster'
  'PerGB2018'
])
param sku string = 'PerGB2018'

@description('Number of days to keep the logs. -1 for unlimited retention.')
@minValue(-1)
@maxValue(730)
param retentionInDays int = 7

@description('Id of the Storage Account resource.')
param storageAccountId string

/* variables */

var extraTags = {
  displayName: name
}

var storageAccountId_split = split(storageAccountId, '/')

/* existing resources */

resource Storage_StorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountId_split[8]
  scope: resourceGroup(storageAccountId_split[4])
}

/* resources */

resource OperationalInsights_Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: union(tags, extraTags)
  properties: {
    sku: {
      name: sku
    }
    features: {
      disableLocalAuth: true
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: 'Disabled'
  }
}

resource OperationalInsights_Workspace_LinkedStorageAccount_Alerts 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = {
  parent: OperationalInsights_Workspace
  name: 'Alerts'
  properties: {
    storageAccountIds: [
      Storage_StorageAccount.id
    ]
  }
}

resource OperationalInsights_Workspace_LinkedStorageAccount_CustomLogs 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = {
  parent: OperationalInsights_Workspace
  name: 'CustomLogs'
  properties: {
    storageAccountIds: [
      Storage_StorageAccount.id
    ]
  }
}

resource OperationalInsights_Workspace_LinkedStorageAccount_Query 'Microsoft.OperationalInsights/workspaces/linkedStorageAccounts@2020-08-01' = {
  parent: OperationalInsights_Workspace
  name: 'Query'
  properties: {
    storageAccountIds: [
      Storage_StorageAccount.id
    ]
  }
}

resource Insights_DiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: OperationalInsights_Workspace
  name: 'System StorageAccount'
  properties: {
    storageAccountId: Storage_StorageAccount.id
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
      }
    ]
  }
}

/* outputs */

output id string = OperationalInsights_Workspace.id
