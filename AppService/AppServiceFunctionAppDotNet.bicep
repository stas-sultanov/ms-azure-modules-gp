/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import { DotNetVersion, IpSecurityRestriction, ManagedServiceIdentity } from './../types.bicep'

/* types */

@description('FunctionApp properties.')
type Properties = {

	@description('OpenApi definition path')
	apiDefinition: string?

	@description('List of origins that should be allowed to make cross-origin calls. Use "*" to allow all')
	corsAllowedOrigins: string[]

	@description('Maximum number of workers that a site can scale out to.')
	@minValue(0)
	@maxValue(200)
	functionAppScaleLimit: int?

	@description('Allow clients to connect over http2.0')
	http20Enabled: bool

	@description('HttpsOnly: configures a web site to accept only https requests. Issues redirect for http requests')
	httpsOnly: bool

	@description('List of allowed IP addresses')
	ipSecurityRestrictions: IpSecurityRestriction[]

	@description('dotNet Framework version.')
	netFrameworkVersion: DotNetVersion

	@description('true if remote debugging is enabled; otherwise, false.')
	remoteDebuggingEnabled: bool

	@description('true to use 32-bit worker process; otherwise, false')
	use32BitWorkerProcess: bool
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

@description('Application settings to be used as Environment Variables.')
param appSettings object = {}

@description('Managed Service Identity.')
param identity ManagedServiceIdentity

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

@description('Service properties.')
param properties Properties

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

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
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

// https://learn.microsoft.com/azure/templates/microsoft.web/sites
resource Web_sites_ 'Microsoft.Web/sites@2022-09-01' = {
	identity: identity
	kind: 'functionapp'
	location: location
	name: name
	properties: {
		httpsOnly: properties.httpsOnly
		serverFarmId: Web_serverFarms_.id
		#disable-next-line BCP073 // in API definition this property is read only
		state: 'Stopped'
	}
	tags: tags
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/basicpublishingcredentialspolicies-ftp
resource Web_sites_basicPublishingCredentialsPolicies__FTP 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
	name: 'ftp'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/basicpublishingcredentialspolicies-scm
resource Web_sites_basicPublishingCredentialsPolicies__SCM 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
	name: 'scm'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-appsettings
resource Web_sites_config__AppSettings 'Microsoft.Web/sites/config@2022-09-01' = {
	name: 'appsettings'
	parent: Web_sites_
	properties: union(
		appSettings,
		{
			FUNCTIONS_EXTENSION_VERSION: '~4'
			FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
			WEBSITE_RUN_FROM_PACKAGE: '${Storage_storageAccounts_.properties.primaryEndpoints.blob}${appPackPath}'
			WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID: 'SystemAssigned'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-metadata
resource Web_sites_config__Metadata 'Microsoft.Web/sites/config@2022-09-01' = {
	name: 'metadata'
	parent: Web_sites_
	properties: {
		CURRENT_STACK: 'dotnet'
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-web
resource Web_sites_config__Web 'Microsoft.Web/sites/config@2022-09-01' = {
	name: 'web'
	parent: Web_sites_
	properties: {
		apiDefinition: {
			url: (!contains(properties, 'apiDefinition') || empty(properties.apiDefinition)) ? null : 'https://${Web_sites_.properties.defaultHostName}${properties.apiDefinition}'
		}
		cors: {
			allowedOrigins: properties.corsAllowedOrigins
		}
		defaultDocuments: []
		ftpsState: 'Disabled'
		functionAppScaleLimit: properties.functionAppScaleLimit
		http20Enabled: properties.http20Enabled
		ipSecurityRestrictions: properties.ipSecurityRestrictions
		netFrameworkVersion: properties.netFrameworkVersion
		use32BitWorkerProcess: properties.use32BitWorkerProcess
	}
}

/* outputs */

output defaultHostName string = Web_sites_.properties.defaultHostName

output identity object = Web_sites_.identity

output resourceId string = Web_sites_.id
