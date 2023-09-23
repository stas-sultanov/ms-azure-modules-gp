metadata author = {
  githubUrl: 'https://github.com/stas-sultanov'
  name: 'Stas Sultanov'
  profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* types */

type EntraIDPrincipalType = 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'

type EntraIDPrinicpal = {
  @description('Name of the principal within the EntraID tenant.')
  name: string

  @description('ObjectId of the principal within the EntraID tenant.')
  objecId: string

  @description('Id of the EntraID tenant.')
  tenantId: string

  @description('Type of the principal within the EntraID tenant.')
  type: EntraIDPrincipalType
}

/* parameters */

@description('Id of the OperationalInsights/Workspace resource.')
param OperationalInsights_workspaces__id string

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
param adminPrincipal EntraIDPrinicpal

/* variables */

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: operationalInsights_workspaces__id_split[8]
  scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.sql/servers
resource Sql_servers_ 'Microsoft.Sql/servers@2023-02-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: adminPrincipal.type
      login: adminPrincipal.name
      sid: adminPrincipal.objecId
      tenantId: adminPrincipal.tenantId
      azureADOnlyAuthentication: true
    }
  }
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/administrators
resource Sql_servers_administrators__ActiveDirectory 'Microsoft.Sql/servers/administrators@2023-02-01-preview' = {
  parent: Sql_servers_
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: adminPrincipal.name
    sid: adminPrincipal.objecId
    tenantId: adminPrincipal.tenantId
  }
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/auditingsettings
resource Sql_servers_auditingSettings__Default 'Microsoft.Sql/servers/auditingSettings@2023-02-01-preview' = {
  parent: Sql_servers_
  name: 'default'
  properties: {
    state: 'Enabled'
    isAzureMonitorTargetEnabled: true
  }
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/azureadonlyauthentications
resource Sql_servers_azureADOnlyAuthentications__Default 'Microsoft.Sql/servers/azureADOnlyAuthentications@2023-02-01-preview' = {
  parent: Sql_servers_
  name: 'Default'
  properties: {
    azureADOnlyAuthentication: true
  }
  dependsOn: [
    Sql_servers_administrators__ActiveDirectory
  ]
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/databases
resource Sql_servers_databases__Master 'Microsoft.Sql/servers/databases@2023-02-01-preview' = {
  parent: Sql_servers_
  name: 'master'
  location: location
  properties: {}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/firewallrules
resource Sql_servers_firewallRules__AllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2023-02-01-preview' = {
  parent: Sql_servers_
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/firewallrules
resource Sql_servers_firewallRules__AllowPublicNetworkAccess 'Microsoft.Sql/servers/firewallRules@2023-02-01-preview' = if (publicNetworkAccess == 'Enabled') {
  parent: Sql_servers_
  name: 'AllowPublicNetworkAccess'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insighs_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Sql_servers_databases__Master
  name: 'Log Analytics'
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
    ]
    workspaceId: OperationalInsights_workspaces_.id
  }
}

/* outputs */

output id string = Sql_servers_.id

output fullyQualifiedDomainName string = Sql_servers_.properties.fullyQualifiedDomainName

output identityPrincipalId string = Sql_servers_.identity.principalId
