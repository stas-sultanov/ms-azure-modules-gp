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

@description('The SKU capability.')
@allowed([
  'B1' // Basic
  'D1' // Shared
  'EP1' // ElasticPremium
  'F1' // Free
  'P1V3' // PremiumV3
  'S1' // Standard
  'U1' // Compute
  'Y1' // Dynamic
])
param sku string = 'Y1'

@description('Tags to put on the resource.')
param tags object

/* variables */

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: operationalInsights_workspaces__id_split[8]
  scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insighs_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Web_serverfarms_
  name: 'Log Analytics'
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
      }
    ]
    workspaceId: OperationalInsights_workspaces_.id
  }
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms
resource Web_serverfarms_ 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
}

/* outputs */

output resourceId string = Web_serverfarms_.id
