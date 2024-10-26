/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('The SKU name.')
@allowed([
	'Free'
	'Standard'
])
param skuName string = 'Free'

@description('Tags to put on the resource.')
param tags object

@description('Id of the OperationalInsights/Workspace resource.')
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

// https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores
resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
	location: location
	name: name
	properties: {
		disableLocalAuth: true
	}
	sku: {
		name: skuName
	}
	tags: tags
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
	scope: AppConfiguration_configurationStores_
}

/* outputs */

output id string = AppConfiguration_configurationStores_.id

output name string = AppConfiguration_configurationStores_.name

output properties object = {
	endpoint: AppConfiguration_configurationStores_.properties.endpoint
}
