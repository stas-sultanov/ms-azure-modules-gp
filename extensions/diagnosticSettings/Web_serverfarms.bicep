metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Name of the Microsoft.Web/serverfarms resource.')
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

resource Web_serverFarms_ 'Microsoft.Web/serverfarms@2024-11-01' existing = {
	name: name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: OperationalInsights_workspaces_.name
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
	scope: Web_serverFarms_
}
