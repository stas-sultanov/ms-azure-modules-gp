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
param tags object

/* variables */

var operationalInsights_workspaces__id_split = split(
	OperationalInsights_workspaces__id,
	'/'
)

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: 'Log Analytics'
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		metrics: [
			{
				enabled: true
				timeGrain: 'PT1M'
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Storage_storageAccounts_
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts
resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-01-01' = {
	kind: 'StorageV2'
	location: location
	name: name
	properties: {
		accessTier: 'Hot'
		allowBlobPublicAccess: false
		allowCrossTenantReplication: false
		allowSharedKeyAccess: false
		defaultToOAuthAuthentication: true
		minimumTlsVersion: 'TLS1_2'
		supportsHttpsTrafficOnly: false
	}
	sku: {
		name: 'Standard_LRS'
	}
	tags: tags
}

/* outputs */

output primaryEndpoints object = Storage_storageAccounts_.properties.primaryEndpoints

output resourceId string = Storage_storageAccounts_.id
