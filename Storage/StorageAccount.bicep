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

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insighs_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	scope: Storage_storageAccounts_
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
// https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts
resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-01-01' = {
	name: name
	sku: {
		name: 'Standard_LRS'
	}
	kind: 'StorageV2'
	location: location
	tags: tags
	properties: {
		accessTier: 'Hot'
		allowBlobPublicAccess: false
		allowSharedKeyAccess: false
		supportsHttpsTrafficOnly: true
		minimumTlsVersion: 'TLS1_2'
		defaultToOAuthAuthentication: true
	}
}

/* outputs */

output primaryEndpoints object = Storage_storageAccounts_.properties.primaryEndpoints

output resourceId string = Storage_storageAccounts_.id
