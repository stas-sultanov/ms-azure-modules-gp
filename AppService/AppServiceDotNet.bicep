metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import { AppServiceParameters } from 'AppServiceTypes.bicep'

import { ManagedServiceIdentity } from './../types.bicep'

/* types */

type _AppServiceParameters = AppServiceParameters // <-- creating an alias for use in param and output statements avoids the issue

type _ManagedServiceIdentity = ManagedServiceIdentity // <-- creating an alias for use in param and output statements avoids the issue

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
param identity _ManagedServiceIdentity

param kind string 

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

@description('Configuration parameters.')
param parameters _AppServiceParameters

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

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites
resource Web_sites_ 'Microsoft.Web/sites@2022-09-01' = {
	identity: identity
	kind: kind
	location: location
	name: name
	properties: {
		clientAffinityEnabled: parameters.clientAffinityEnabled
		httpsOnly: parameters.httpsOnly
		serverFarmId: Web_serverFarms_.id
	}
	tags: tags
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

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-metadata
resource Web_sites_config__Metadata 'Microsoft.Web/sites/config@2022-09-01' = {
	name: 'metadata'
	parent: Web_sites_
	properties: {
		CURRENT_STACK: 'dotnet'
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-web
resource Web_sites_config__Web 'Microsoft.Web/sites/config@2022-09-01' = {
	name: 'web'
	parent: Web_sites_
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
