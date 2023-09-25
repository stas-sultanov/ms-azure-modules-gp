metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the OperationalInsights/Workspace resource.')
param OperationalInsights_workspaces__id string

@description('The capacity mode for database operations.')
@allowed([
	'Static'
	'Autoscale'
	'Serverless'
])
param capacityMode string = 'Static'

@description('Enum to indicate the mode of account creation.')
@allowed([
	'Default'
	'Restore'
])
param createMode string = 'Default'

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

@description('Define if access from Public Network is allowed.')
@allowed([
	'Enabled'
	'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('The id of the restorable database account from which the restore has to be initiated.')
param restoreSourceId string = ''

@description('Point in time which to restore. Used if only create mode [Restore] is selected.')
param restoreTimestamp string = utcNow('u')

@description('Tags to put on the resource.')
param tags object

/* variables */

var capabilities = {
	Static: []
	Autoscale: []
	Serverless: [
		{
			name: 'EnableServerless'
		}
	]
}

var ipRules = {
	Enabled: []
	Disabled: [
		{
			ipAddressOrRange: '0.0.0.0'
		}
		{
			ipAddressOrRange: '104.42.195.92'
		}
		{
			ipAddressOrRange: '40.76.54.131'
		}
		{
			ipAddressOrRange: '52.176.6.30'
		}
		{
			ipAddressOrRange: '52.169.50.45'
		}
		{
			ipAddressOrRange: '52.187.184.26'
		}
	]
}

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

var restoreParameters = {
	Default: {}
	Restore: {
		restoreMode: 'PointInTime'
		restoreSource: restoreSourceId
		restoreTimestampInUtc: restoreTimestamp
	}
}

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
	name: name
	location: location
	tags: union(tags, { capacityMode: capacityMode })
	kind: 'GlobalDocumentDB'
	properties: {
		locations: [
			{
				locationName: location
			}
		]
		databaseAccountOfferType: 'Standard'
		ipRules: ipRules[publicNetworkAccess]
		capabilities: capabilities[capacityMode]
		backupPolicy: {
			type: 'Continuous'
		}
		publicNetworkAccess: publicNetworkAccess
		createMode: createMode
		restoreParameters: restoreParameters[createMode]
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	scope: DocumentDB_databaseAccounts_
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

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.security/advancedthreatprotectionsettings
resource Security_advancedThreatProtectionSettings_ 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
	scope: DocumentDB_databaseAccounts_
	name: 'current'
	properties: {
		isEnabled: true
	}
}

/* outputs */

output resourceId string = DocumentDB_databaseAccounts_.id

output restoreId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.DocumentDB/locations/${DocumentDB_databaseAccounts_.location}/restorableDatabaseAccounts/${DocumentDB_databaseAccounts_.properties.instanceId}'
