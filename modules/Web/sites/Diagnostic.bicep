metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Name of the Web/sites resource.')
param siteName string

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

resource Web_sites_ 'Microsoft.Web/sites@2024-04-01' existing = {
	name: siteName
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
				category: 'FunctionAppLogs'
				enabled: true
			}
		]
		metrics: [
			{
				category: 'AllMetrics'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Web_sites_
}
