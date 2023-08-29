metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

@description('Factory identity.')
param identity object = {
  type: 'SystemAssigned'
}

@description('Repo configuration.')
param repoConfiguration object = {}

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

resource DataFactory_Factory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  tags: union(tags, extraTags)
  identity: identity
  properties: {
    repoConfiguration: repoConfiguration
  }
}

resource Insights_DiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: DataFactory_Factory
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
    workspaceId: OperationalInsights_Workspace.id
  }
}

/* outputs */

output id string = DataFactory_Factory.id

output identityPrincipalId object = DataFactory_Factory.identity
