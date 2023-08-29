metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Common tags to put on the resource.')
param tags object

@description('Define if access from Public Network is allowed.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Id of the Admin Identity within the Active Directory.')
param adminId string

@description('Name of the Admin Identity within the Active Directory.')
param adminName string

@description('Id of the OperationalInsights_Workspace resource.')
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

resource Sql_Server 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: name
  location: location
  tags: union(tags, extraTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: adminName
      sid: adminId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true
    }
  }
}

resource Sql_Server_Administrator_ActiveDirectory 'Microsoft.Sql/servers/administrators@2022-11-01-preview' = {
  parent: Sql_Server
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: adminName
    sid: adminId
  }
}

resource Sql_Server_AuditingSetting_Default 'Microsoft.Sql/servers/auditingSettings@2022-11-01-preview' = {
  parent: Sql_Server
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

resource Sql_Server_AzureADOnlyAuthentication 'Microsoft.Sql/servers/azureADOnlyAuthentications@2022-08-01-preview' = {
  parent: Sql_Server
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
  dependsOn: [
    Sql_Server_Administrator_ActiveDirectory
  ]
}

resource Sql_Server_Database_Master 'Microsoft.Sql/servers/databases@2022-11-01-preview' = {
  parent: Sql_Server
  name: 'master'
  location: location
  properties: {}
}

resource Sql_Server_FirewallRule_AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2022-11-01-preview' = {
  parent: Sql_Server
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource Sql_Server_FirewallRule_AllowPublicNetworkAccess 'Microsoft.Sql/servers/firewallRules@2022-11-01-preview' = if (publicNetworkAccess == 'Enabled') {
  parent: Sql_Server
  name: 'AllowPublicNetworkAccess'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource Insighs_DiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Sql_Server_Database_Master
  name: 'Log Analytics'
  properties: {
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
    ]
    workspaceId: OperationalInsights_Workspace.id
  }
}

/* outputs */

output id string = Sql_Server.id

output fullyQualifiedDomainName string = Sql_Server.properties.fullyQualifiedDomainName

output identityPrincipalId string = Sql_Server.identity.principalId
