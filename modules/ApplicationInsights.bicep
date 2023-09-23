metadata author = {
  githubUrl: 'https://github.com/stas-sultanov'
  name: 'Stas Sultanov'
  profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the OperationalInsights/workspaces resource.')
param OperationalInsights_workspaces__id string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: operationalInsights_workspaces__id_split[8]
  scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.insights/components
resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: OperationalInsights_workspaces_.id
  }
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Insights_components_
  name: 'Log Analytics'
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
      }
    ]
    workspaceId: OperationalInsights_workspaces_.id
  }
}

/* outputs */

output id string = Insights_components_.id

output instrumentationKey string = Insights_components_.properties.InstrumentationKey

output appId string = Insights_components_.properties.AppId
