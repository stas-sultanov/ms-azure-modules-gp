metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import{IpSecurityRestriction, ManagedServiceIdentity}from'./../types.bicep'

/* types */

type Parameters = {
	@description('true if Always On is enabled; otherwise, false')
	alwaysOn: bool

	@description('OpenApi defintion path')
	apiDefinition: string?

	@description('true to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance')
	clientAffinityEnabled: bool

	@description('List of origins that should be allowed to make cross-origin calls. Use "*" to allow all')
	corsAllowedOrigins: string[]

	@description('Maximum number of workers that a site can scale out to')
	@minValue(0)
	@maxValue(200)
	functionAppScaleLimit: int

	@description('Allow clients to connect over http2.0')
	http20Enabled: bool

	@description('HttpsOnly: configures a web site to accept only https requests. Issues redirect for http requests')
	httpsOnly: bool

	@description('List of allowed IP addresses')
	ipSecurityRestrictions: IpSecurityRestriction[]

	@description('true to use 32-bit worker process; otherwise, false')
	use32BitWorkerProcess: bool

	@description('true if WebSocket is enabled; otherwise, false')
	webSocketsEnabled: bool
}

/* parameters */

@description('Id of the Insights/components resource.')
param Insights_components__id string

@description('Id of the OperationalInsights/workspaces resource.')
param OperationalInsights_workspaces__id string

@description('Id of the Web/serverfarms resource.')
param Web_serverFarms__id string

@description('Application settings.')
param appSettings object = {}

@description('Managed Service Identity.')
param identity ManagedServiceIdentity

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

param parameters Parameters

@description('Current platform.')
@allowed([ 'dotNet', 'nodeJS' ])
param platform string

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var commonAppSettings = {
	APPLICATIONINSIGHTS_CONNECTION_STRING: Insights_components_.properties.ConnectionString
	ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
	FUNCTIONS_EXTENSION_VERSION: '~4'
	XDT_MicrosoftApplicationInsights_Mode: 'default'
}

var insights_components__id_split = split(Insights_components__id, '/')

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

var platformStack = {
	dotNet: 'dotnet'
	nodeJS: 'node'
}

var platformVersion = {
	dotNet: 'v7.0'
	nodeJS: '~18'
}

var platformAppSettings = {
	dotNet: {}
	nodeJS: {
		WEBSITE_NODE_DEFAULT_VERSION: platformVersion.nodeJS
		XDT_MicrosoftApplicationInsights_Mode: 'default'
		XDT_MicrosoftApplicationInsights_NodeJS: '1'
	}
}

var web_serverfarms__id_split = split(Web_serverFarms__id, '/')

/* existing resources */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: insights_components__id_split[8]
	scope: resourceGroup(insights_components__id_split[4])
}

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

resource ServerFarm 'Microsoft.Web/serverfarms@2022-09-01' existing = {
	name: web_serverfarms__id_split[8]
	scope: resourceGroup(web_serverfarms__id_split[4])
}

/* resources */

resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	scope: Web_sites_
	name: 'Log Analytics'
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: [
			{
				category: 'AppServiceHTTPLogs'
				enabled: true
			}
			{
				category: 'AppServiceConsoleLogs'
				enabled: true
			}
			{
				category: 'AppServiceAppLogs'
				enabled: true
			}
			{
				category: 'AppServiceAuditLogs'
				enabled: true
			}
			{
				category: 'AppServiceIPSecAuditLogs'
				enabled: true
			}
			{
				category: 'AppServicePlatformLogs'
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
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.web/sites
resource Web_sites_ 'Microsoft.Web/sites@2022-09-01' = {
	name: name
	location: location
	tags: tags
	kind: 'functionapp'
	properties: {
		clientAffinityEnabled: parameters.clientAffinityEnabled
		serverFarmId: ServerFarm.id
		httpsOnly: parameters.httpsOnly
	}
	identity: identity
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-appsettings
resource Web_sites_config__AppSettings 'Microsoft.Web/sites/config@2022-09-01' = {
	parent: Web_sites_
	name: 'appsettings'
	properties: union(
		commonAppSettings,
		appSettings,
		platformAppSettings[platform]
	)
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-metadata
resource Web_sites_config__Metadata 'Microsoft.Web/sites/config@2022-09-01' = {
	parent: Web_sites_
	name: 'metadata'
	properties: {
		CURRENT_STACK: platformStack[platform]
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-web
resource Web_sites_config__Web 'Microsoft.Web/sites/config@2022-09-01' = {
	parent: Web_sites_
	name: 'web'
	properties: {
		alwaysOn: parameters.alwaysOn
		apiDefinition:{
			url: empty(parameters.apiDefinition) ? null : 'https://${Web_sites_.properties.defaultHostName}${parameters.apiDefinition}'
		}
		cors: {
			allowedOrigins: parameters.corsAllowedOrigins
		}
		defaultDocuments: []
		ftpsState: 'Disabled'
		functionAppScaleLimit: parameters.functionAppScaleLimit
		http20Enabled: parameters.http20Enabled
		ipSecurityRestrictions: parameters.ipSecurityRestrictions
		netFrameworkVersion: (platform == 'dotNet') ? platformVersion.dotNet : null
		nodeVersion: (platform == 'nodeJS') ? platformVersion.nodeJS : null
		phpVersion: 'OFF'
		use32BitWorkerProcess: parameters.use32BitWorkerProcess
		webSocketsEnabled: parameters.webSocketsEnabled
	}
}

/* outputs */

output defaultHostName string = Web_sites_.properties.defaultHostName

output identity object = Web_sites_.identity

output resourceId string = Web_sites_.id
