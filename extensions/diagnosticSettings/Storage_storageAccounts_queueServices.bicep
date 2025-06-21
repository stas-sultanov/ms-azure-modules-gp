metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Name of the Microsoft.Storage/storageAccounts resource.')
param name string

@description('Id of the Microsoft.OperationalInsights/workspaces resource.')
param workspaceId string

/* variables */

var operationalInsights_workspaces__id_split = split(
	workspaceId,
	'/'
)

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(
		operationalInsights_workspaces__id_split[2],
		operationalInsights_workspaces__id_split[4]
	)
}

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
	name: name
	resource queueServices_ 'queueServices' existing = {
		name: 'default'
	}
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: OperationalInsights_workspaces_.name
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
	scope: Storage_storageAccounts_::queueServices_
}
