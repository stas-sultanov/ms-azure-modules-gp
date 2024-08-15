/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* scope */

targetScope = 'resourceGroup'

/* parameters */

@description('The mode of database creation.')
@allowed([
	'Default'
	'Copy'
])
param createMode string = 'Default'

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Specifies the SKU of the sql database.')
@allowed([
	'Basic'
	'S0'
	'S1'
	'S2'
	'S3'
	'GP_Gen5_2'
	'GP_Gen5_4'
	'GP_Gen5_6'
	'GP_Gen5_8'
	'GP_Gen5_10'
	'GP_S_Gen5_1'
	'GP_S_Gen5_2'
	'GP_S_Gen5_4'
	'GP_S_Gen5_6'
	'GP_S_Gen5_8'
])
param sku string = 'Basic'

@description('Id of the Sql/servers/databases resource which is used by different creation modes.')
param sourceDatabaseId string = ''

@description('Name of the Sql/servers resource.')
param sqlServerName string

@description('Tags to put on the resource.')
param tags object

@description('Id of the OperationalInsights/Workspace resource.')
param workspaceId string

/* variables */

var databaseProperties = {
	Default: {
		createMode: 'Default'
	}
	Copy: {
		createMode: 'Copy'
		sourceDatabaseId: createMode == 'Default'
			? ''
			: Sql_servers_databases_Source.id
	}
}

var operationalInsights_workspaces__id_split = split(
	workspaceId,
	'/'
)

var sql_servers_databases_Source_id_split = split(
	sourceDatabaseId,
	'/'
)

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(
		operationalInsights_workspaces__id_split[2],
		operationalInsights_workspaces__id_split[4]
	)
}

resource Sql_servers_ 'Microsoft.Sql/servers@2021-11-01' existing = {
	name: sqlServerName
}

resource Sql_servers_databases_Source 'Microsoft.Sql/servers/databases@2021-11-01' existing = if (createMode != 'Default') {
	name: sql_servers_databases_Source_id_split[8]
	scope: resourceGroup(
		sql_servers_databases_Source_id_split[2],
		sql_servers_databases_Source_id_split[4]
	)
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
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
				enabled: true
				timeGrain: 'PT1M'
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Sql_servers_databases_
}

// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/databases
resource Sql_servers_databases_ 'Microsoft.Sql/servers/databases@2021-11-01' = {
	location: location
	name: name
	parent: Sql_servers_
	properties: databaseProperties[createMode]
	sku: {
		name: sku
	}
	tags: tags
}

// https://learn.microsoft.com/azure/templates/microsoft.sql/servers/databases/auditingsettings
resource Sql_servers_databases_auditingSettings_ 'Microsoft.Sql/servers/databases/auditingSettings@2021-11-01' = {
	name: 'default'
	parent: Sql_servers_databases_
	properties: {
		isAzureMonitorTargetEnabled: true
		state: 'Enabled'
	}
}

/* outputs */

output id string = Sql_servers_databases_.id

output name string = Sql_servers_databases_.name
