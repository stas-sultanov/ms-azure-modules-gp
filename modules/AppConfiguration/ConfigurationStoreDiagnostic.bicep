metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Name of the AppConfiguration/configurationStores resource.')
param storeName string

@description('Id of the OperationalInsights/Workspace resource.')
param workspaceId string

/* variables */

var operationalInsights_workspaces__id_split = split(
	workspaceId,
	'/'
)

/* existing resources */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = {
	name: storeName
}

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
