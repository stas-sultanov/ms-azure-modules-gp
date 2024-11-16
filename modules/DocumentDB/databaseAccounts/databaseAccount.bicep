metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
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

@description('Location to deploy the resources.')
param location string

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
			ipAddressOrRange: '40.76.54.131'
		}
		{
			ipAddressOrRange: '52.169.50.45'
		}
		{
			ipAddressOrRange: '52.176.6.30'
		}
		{
			ipAddressOrRange: '52.187.184.26'
		}
		{
			ipAddressOrRange: '104.42.195.92'
		}
	]
}

var operationalInsights_workspaces__id_split = split(
	OperationalInsights_workspaces__id,
	'/'
)

var restoreParameters = {
	Default: {}
	Restore: {
		restoreMode: 'PointInTime'
		restoreSource: restoreSourceId
		restoreTimestampInUtc: restoreTimestamp
	}
}

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(
		operationalInsights_workspaces__id_split[2],
		operationalInsights_workspaces__id_split[4]
	)
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts
resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2024-08-15' = {
	kind: 'GlobalDocumentDB'
	location: location
	name: name
	properties: {
		backupPolicy: {
			type: 'Continuous'
		}
		capabilities: capabilities[capacityMode]
		createMode: createMode
		databaseAccountOfferType: 'Standard'
		ipRules: ipRules[publicNetworkAccess]
		locations: [
			{
				locationName: location
			}
		]
		publicNetworkAccess: publicNetworkAccess
		restoreParameters: restoreParameters[createMode]
	}
	tags: union(
		tags,
		{
			capacityMode: capacityMode
		}
	)
}

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
		]
		metrics: [
			{
				enabled: true
				timeGrain: 'PT1M'
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: DocumentDB_databaseAccounts_
}

// https://learn.microsoft.com/azure/templates/microsoft.security/advancedthreatprotectionsettings
resource Security_advancedThreatProtectionSettings_ 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
	name: 'current'
	properties: {
		isEnabled: true
	}
	scope: DocumentDB_databaseAccounts_
}

/* outputs */

output id string = DocumentDB_databaseAccounts_.id

output name string = DocumentDB_databaseAccounts_.name

output restoreId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.DocumentDB/locations/${DocumentDB_databaseAccounts_.location}/restorableDatabaseAccounts/${DocumentDB_databaseAccounts_.properties.instanceId}'
