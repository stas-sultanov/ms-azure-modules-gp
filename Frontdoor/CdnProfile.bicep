metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}
metadata copyright = '2023 Stas Sultanov'
metadata license = 'MIT'

/* parameters */

@description('Id of the OperationalInsights/workspaces resource.')
param OperationalInsights_workspaces__id string

@description('Name of the resource.')
param name string

@description('Send and receive timeout on forwarding request to the origin. When timeout is reached, the request fails and returns.')
@minValue(16)
param originResponseTimeoutSeconds int

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles
resource Cdn_profiles_ 'Microsoft.Cdn/profiles@2023-07-01-preview' = {
	location: 'global'
	name: name
	properties: {
		originResponseTimeoutSeconds: originResponseTimeoutSeconds
	}
	sku: {
		name: 'Standard_AzureFrontDoor'
	}
	tags: tags
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
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
				timeGrain: 'PT1M'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Cdn_profiles_
}

/* outputs */

output resourceId string = Cdn_profiles_.id
