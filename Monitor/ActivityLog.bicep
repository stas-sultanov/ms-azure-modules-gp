/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* scope */

targetScope = 'subscription'

/* parameters */

@description('Id of the OperationalInsights/Workspace resource.')
param OperationalInsights_workspaces__id string

/* variables */

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: 'Log Analytics'
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: [
			{
				category: 'Administrative'
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
			{
				category: 'Alert'
				enabled: true
			}
			{
				category: 'Recommendation'
				enabled: true
			}
			{
				category: 'Policy'
				enabled: true
			}
			{
				category: 'Autoscale'
				enabled: true
			}
			{
				category: 'ResourceHealth'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
}
