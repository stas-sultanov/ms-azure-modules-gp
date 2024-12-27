metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* scope */

targetScope = 'subscription'

/* parameters */

@description('Id of the Microsoft.OperationalInsights/Workspace resource.')
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
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_SubscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: OperationalInsights_workspaces_.name
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: [
			{
				category: 'Administrative'
				enabled: true
			}
			{
				category: 'Alert'
				enabled: true
			}
			{
				category: 'Autoscale'
				enabled: true
			}
			{
				category: 'Policy'
				enabled: true
			}
			{
				category: 'ResourceHealth'
				enabled: true
			}
			{
				category: 'Recommendation'
				enabled: true
			}
			{
				category: 'Security'
				enabled: true
			}
			{
				category: 'ServiceHealth'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
}
