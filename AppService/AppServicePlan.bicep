/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* types */

@description('App Service Plan Properties.')
type Properties = {
	@description('true if Elastic Scale is enabled; otherwise, false')
	elasticScaleEnabled: bool

	@description('Maximum number of total workers allowed for this App Service Plan with ElasticScaleEnabled = true')
	maximumElasticWorkerCount: int

	@description('If true, apps assigned to this App Service plan can be scaled independently. If false, apps assigned to this App Service plan will scale to all instances of the plan.')
	perSiteScaling: bool
}

/* parameters */

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Service properties.')
param properties Properties = {
	elasticScaleEnabled: false
	maximumElasticWorkerCount: 30
	perSiteScaling: false
}

@description('The SKU capability.')
@allowed([
	'B1' // Basic
	'D1' // Shared
	'EP1' // ElasticPremium
	'F1' // Free
	'P0V3' // Premium:v3 vCPU:1 RAM:4
	'P1' // Premium:v1 vCPU:1 RAM:1.75
	'P1V2' // Premium:v2 vCPU:1 RAM:3.5
	'P1V3' // Premium:v3 vCPU:2 RAM:8
	'S1' // Standard
	'U1' // Compute
	'Y1' // Dynamic
])
param sku string

@description('Tags to put on the resource.')
param tags object

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
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
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
	scope: Web_serverfarms_
}

// https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms
resource Web_serverfarms_ 'Microsoft.Web/serverfarms@2023-12-01' = {
	location: location
	name: name
	properties: properties
	sku: {
		name: sku
	}
	tags: tags
}

/* outputs */

output id string = Web_serverfarms_.id

output name string = Web_serverfarms_.name
