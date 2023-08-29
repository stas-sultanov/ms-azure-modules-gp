metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

@description('The SKU name.')
@allowed([
  'Free'
  'Standard'
])
param skuName string = 'Free'

@description('Id of the OperationalInsights/Workspace resource.')
param operationalInsightsWorkspaceId string

/* variables */

var extraTags = {
  displayName: name
}

var operationalInsightsWorkspaceId_split = split(operationalInsightsWorkspaceId, '/')

/* existing resources */

resource OperationalInsights_Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: operationalInsightsWorkspaceId_split[8]
  scope: resourceGroup(operationalInsightsWorkspaceId_split[4])
}

/* resources */

resource AppConfiguration_ConfigurationStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: name
  location: location
  tags: union(tags, extraTags)
  properties: {}
  sku: {
    name: skuName
  }
}

resource Insights_DiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: AppConfiguration_ConfigurationStore
  name: 'Log Analytics'
  properties: {
    logs: [
      {
        category: 'HttpRequest'
        enabled: true
      }
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
    workspaceId: OperationalInsights_Workspace.id
  }
}

/* outputs */

output id string = OperationalInsights_Workspace.id

output endpoint string = AppConfiguration_ConfigurationStore.properties.endpoint
