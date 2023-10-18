metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import { IpSecurityRestriction, ManagedServiceIdentity } from './../types.bicep'

/* types */

type AssignedManagedServiceIdentity = ManagedServiceIdentity // <-- creating an alias for use in param and output statements avoids the issue

@description('dotNet Framework version.')
type DotNetVersion = 'v6.0' | 'v7.0' | 'v8.0'

type Parameters = {
	@description('true if Always On is enabled; otherwise, false')
	alwaysOn: bool

	@description('OpenApi definition path')
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

	@description('dotNet Framework version.')
	netFrameworkVersion: DotNetVersion

	@description('true to use 32-bit worker process; otherwise, false')
	use32BitWorkerProcess: bool

	@description('true if WebSocket is enabled; otherwise, false')
	webSocketsEnabled: bool
}

/* parameters */

@description('Id of the OperationalInsights/workspaces resource.')
param OperationalInsights_workspaces__id string

@description('Id of the Storage/storageAccounts resource.')
param Storage_storageAccounts__id string

@description('Id of the Web/serverfarms resource.')
param Web_serverFarms__id string

@description('Application package path within the storage.')
param appPackPath string

@description('Application settings to be used Environment Variables.')
param appSettings object = {}

@description('Managed Service Identity.')
param identity AssignedManagedServiceIdentity

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

@description('Configuration parameters.')
param parameters Parameters

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

var storage_StorageAccounts__id_split = split(Storage_storageAccounts__id, '/')

var web_serverfarms__id_split = split(Web_serverFarms__id, '/')

/* existing resources */

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
	name: storage_StorageAccounts__id_split[8]
	scope: resourceGroup(storage_StorageAccounts__id_split[4])
}

resource Web_serverFarms_ 'Microsoft.Web/serverfarms@2022-09-01' existing = {
	name: web_serverfarms__id_split[8]
	scope: resourceGroup(web_serverfarms__id_split[4])
}

/* resources */

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	scope: Web_sites_
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
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites
resource Web_sites_ 'Microsoft.Web/sites@2022-09-01' = {
	name: name
	location: location
	tags: tags
	kind: 'functionapp'
	properties: {
		clientAffinityEnabled: parameters.clientAffinityEnabled
		serverFarmId: Web_serverFarms_.id
		httpsOnly: parameters.httpsOnly
	}
	identity: identity
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/basicpublishingcredentialspolicies-ftp
resource Web_sites_basicPublishingCredentialsPolicies__FTP 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
	name: 'ftp'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/basicpublishingcredentialspolicies-scm
resource Web_sites_basicPublishingCredentialsPolicies__SCM 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
	name: 'scm'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-appsettings
resource Web_sites_config__AppSettings 'Microsoft.Web/sites/config@2022-09-01' = {
	parent: Web_sites_
	name: 'appsettings'
	properties: union(appSettings, {
			FUNCTIONS_EXTENSION_VERSION: '~4'
			FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
			WEBSITE_RUN_FROM_PACKAGE: '${Storage_storageAccounts_.properties.primaryEndpoints.blob}${appPackPath}'
			WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID: 'SystemAssigned'
		})
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-metadata
resource Web_sites_config__Metadata 'Microsoft.Web/sites/config@2022-09-01' = {
	parent: Web_sites_
	name: 'metadata'
	properties: {
		CURRENT_STACK: 'dotnet'
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-web
resource Web_sites_config__Web 'Microsoft.Web/sites/config@2022-09-01' = {
	parent: Web_sites_
	name: 'web'
	properties: {
		alwaysOn: parameters.alwaysOn
		apiDefinition: {
			url: (!contains(parameters, 'apiDefinition') || empty(parameters.apiDefinition)) ? null : 'https://${Web_sites_.properties.defaultHostName}${parameters.apiDefinition}'
		}
		cors: {
			allowedOrigins: parameters.corsAllowedOrigins
		}
		defaultDocuments: []
		functionAppScaleLimit: parameters.functionAppScaleLimit
		http20Enabled: parameters.http20Enabled
		ipSecurityRestrictions: parameters.ipSecurityRestrictions
		netFrameworkVersion: parameters.netFrameworkVersion
		use32BitWorkerProcess: parameters.use32BitWorkerProcess
		webSocketsEnabled: parameters.webSocketsEnabled
	}
}

/* outputs */

output defaultHostName string = Web_sites_.properties.defaultHostName

output identity object = Web_sites_.identity

output resourceId string = Web_sites_.id
