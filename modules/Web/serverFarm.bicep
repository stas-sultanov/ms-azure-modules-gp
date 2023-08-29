metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

@description('The SKU capability.')
@allowed([
  'Y1'
  'EP1'
  'D1'
  'F1'
  'B1'
  'S1'
  'P1V3'
])
param sku string = 'Y1'

@description('Id of the OperationalInsights/Workspace resource.')
param operationalInsightsWorkspaceId string

/* variables */

var extraTags = {
  displayName: 'Server Farm'
}

var operationalInsightsWorkspaceId_split = split(operationalInsightsWorkspaceId, '/')

/* existing resources */

resource OperationalInsights_Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: operationalInsightsWorkspaceId_split[8]
  scope: resourceGroup(operationalInsightsWorkspaceId_split[4])
}

/* resources */

resource Web_ServerFarm 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: union(tags, extraTags)
  sku: {
    name: sku
  }
}

resource Insighs_DiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Web_ServerFarm
  name: 'Log Analytics'
  properties: {
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

output id string = Web_ServerFarm.id
