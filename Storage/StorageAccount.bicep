/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* types */

type SKU =
	| 'Standard_LRS'
	| 'Standard_ZRS'

/* parameters */

@description('Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key.')
param allowSharedKeyAccess bool = false

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
@minLength(3)
@maxLength(24)
param name string

@description('Name of the sku.')
param sku SKU

@description('Tags to put on the resource.')
param tags object

@description('Define if BlobService within the Account must be configured.')
param useBlobService bool

@description('Id of the OperationalInsights/workspaces resource.')
param workspaceId string

/* variables */

var operationalInsights_workspaces__id_split = split(
	workspaceId,
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

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_Storage_storageAccounts_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
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

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_Storage_storageAccounts_blobServices_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (useBlobService) {
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
				category: 'Transaction'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Storage_storageAccounts_blobServices_
}

// https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts
resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-05-01' = {
	kind: 'StorageV2'
	location: location
	name: name
	properties: {
		accessTier: 'Hot'
		allowBlobPublicAccess: false
		allowCrossTenantReplication: false
		allowSharedKeyAccess: allowSharedKeyAccess
		defaultToOAuthAuthentication: true
		minimumTlsVersion: 'TLS1_2'
		supportsHttpsTrafficOnly: false
	}
	sku: {
		name: sku
	}
	tags: tags
}

// https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices
resource Storage_storageAccounts_blobServices_ 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = if (useBlobService) {
	parent: Storage_storageAccounts_
	name: 'default'
}

/* outputs */

output id string = Storage_storageAccounts_.id

output name string = Storage_storageAccounts_.name

output properties object = {
	primaryEndpoints: Storage_storageAccounts_.properties.primaryEndpoints
}
