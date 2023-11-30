/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* types */

type ApplicationType = 'MultiTenant' | 'SingleTenant' | 'UserAssignedMSI'

type Application = {
	@description('Application client id.')
	clientId: string

	@description('Identifier of the application Entra tenant.')
	tenantId: string?

	@description('Type of the application.')
	type: ApplicationType

	@description('Microsoft App Managed Identity Resource Id for the bot')
	MSIResourceId: string?
}

/* parameters */

@description('Api Key of the Insights/components resource.')
param Insights_components__apiKey string = ''

@description('Id of the Insights/components resource.')
param Insights_components__id string

@description('Id of the OperationalInsights/workspaces resource.')
param OperationalInsights_workspaces__id string

@description('Application settings.')
param application Application

@description('The description of the bot.')
param descriptionText string

@description('The Name of the bot.')
param displayName string

@description('Bot Application endpoint.')
param endpoint string

@description('Name of the resource.')
param name string

@description('SKU of the resource.')
@allowed([ 'F0', 'S1' ])
param sku string = 'F0'

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var insights_components__id_split = split(Insights_components__id, '/')

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

/* existing resources */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: insights_components__id_split[8]
	scope: resourceGroup(insights_components__id_split[2], insights_components__id_split[4])
}

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[2], operationalInsights_workspaces__id_split[4])
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.botservice/botservices
resource BotService_botServices_ 'Microsoft.BotService/botServices@2022-09-15' = {
	kind: 'azurebot'
	location: 'global'
	name: name
	properties: {
		developerAppInsightKey: Insights_components_.properties.InstrumentationKey
		developerAppInsightsApiKey: Insights_components__apiKey
		developerAppInsightsApplicationId: Insights_components_.properties.AppId
		displayName: displayName
		disableLocalAuth: true
		description: descriptionText
		endpoint: endpoint
		#disable-next-line use-resource-id-functions
		msaAppId: application.clientId
		msaAppType: application.type
		msaAppTenantId: contains(application, 'tenantId') 
		 ? application.tenantId 
		 : null
		msaAppMSIResourceId: contains(application, 'MSIResourceId') 
		 ? application.MSIResourceId 
		 : null
	}
	sku: {
		name: sku
	}
	tags: tags
}

// DirectLine is enabled by default. No known way to disable. Set no sites.
// https://learn.microsoft.com/azure/templates/microsoft.botservice/botservices/channels
resource BotService_botServices_channels_DirectLineChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = {
	location: 'global'
	name: 'DirectLineChannel'
	parent: BotService_botServices_
	properties: {
		channelName: 'DirectLineChannel'
		properties: {
			sites: []
		}
	}
	tags: tags
}

// Provision channel
// https://learn.microsoft.com/azure/templates/microsoft.botservice/botservices/channels
resource BotService_botServices_channels_MsTeamsChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = {
	location: 'global'
	name: 'MsTeamsChannel'
	parent: BotService_botServices_
	properties: {
		channelName: 'MsTeamsChannel'
	}
	tags: tags
}

// WebChat is enabled by default. No known way to disable. Set no sites.
// https://learn.microsoft.com/azure/templates/microsoft.botservice/botservices/channels
resource BotService_botServices_channels_WebChatChannel 'Microsoft.BotService/botServices/channels@2022-09-15' = {
	location: 'global'
	name: 'WebChatChannel'
	parent: BotService_botServices_
	properties: {
		channelName: 'WebChatChannel'
		properties: {
			sites: []
		}
	}
	tags: tags
}

// Provision Diagnostic
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insights_diagnosticSetting_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: 'Log Analytics'
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: [
			{
				category: 'BotRequest'
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
	scope: BotService_botServices_
}

/* outputs */

output id string = BotService_botServices_.id
