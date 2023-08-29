metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Common tags to put on the resource.')
param tags object

@description('Specifies the SKU of the sql database.')
@allowed([
  'Basic'
  'S0'
  'S1'
  'S2'
  'GP_Gen5_2'
  'GP_Gen5_4'
  'GP_Gen5_6'
  'GP_S_Gen5_1'
  'GP_S_Gen5_2'
  'GP_S_Gen5_4'
])
param sku string = 'Basic'

@description('The mode of database creation.')
@allowed([
  'Default'
  'Copy'
])
param createMode string = 'Default'

@description('The resource identifier of the source database associated with create operation of this database.')
param sourceId string = ''

@description('Id of the OperationalInsights/Workspace resource.')
param operationalInsightsWorkspaceId string

@description('Id of the parent Server resource.')
param sqlServerId string

/* variables */

var extraTags = {
  displayName: '${split(sqlServerId, '/')[8]} / ${name}'
}

var databaseProperties = {
  Default: {
    createMode: 'Default'
  }
  Copy: {
    createMode: 'Copy'
    sourceDatabaseId: sourceId
  }
}

var operationalInsightsWorkspaceId_split = split(operationalInsightsWorkspaceId, '/')

/* existing resources */

resource OperationalInsights_Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: operationalInsightsWorkspaceId_split[8]
  scope: resourceGroup(operationalInsightsWorkspaceId_split[4])
}

resource Sql_Server 'Microsoft.Sql/servers@2022-11-01-preview' existing = {
  name: split(sqlServerId, '/')[8]
}

/* resources */

resource Sql_Server_Database 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent: Sql_Server
  name: name
  location: location
  tags: union(tags, extraTags)
  sku: {
    name: sku
  }
  properties: databaseProperties[createMode]
}

resource Sql_Server_Database_AuditingSetting_Default 'Microsoft.Sql/servers/databases/auditingSettings@2022-08-01-preview' = {
  parent: Sql_Server_Database
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource Insights_DiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Sql_Server_Database
  name: 'Log Analytics'
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
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

output id string = Sql_Server_Database.id

output name string = name
