/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* scope */

targetScope = 'resourceGroup'

/* types */

type EntraParameters = {
	@description('Entra Application ClientId')
	applicationClientId: string

	@description('Entra Application Secret')
	@secure()
	applicationSecret: string

	@description('Entra Application Scopes')
	applicationScopes: string

	@description('Entra Application Token Exchange Url')
	applicationTokenExchangeUrl: string?

	@description('Entra Tenant Id')
	tenantId: string
}

/* parameters */

@description('Name of the BotService/botServices resource.')
param botServiceName string

@description('Name of the resource.')
param name string

@description('Entra Parameters')
param parameters EntraParameters

@description('Tags to put on the resource.')
param tags object = {}

/* existing resources */

resource BotService_botServices_ 'Microsoft.BotService/botServices@2022-09-15' existing = {
	name: botServiceName
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.botservice/botservices
resource BotService_botServices_connections_ 'Microsoft.BotService/botServices/connections@2022-09-15' = {
	location: 'global'
	name: name
	parent: BotService_botServices_
	properties: {
		clientId: parameters.applicationClientId
		clientSecret: parameters.applicationSecret
		parameters: [
			{
				key: 'tokenExchangeUrl'
				value: contains(
						parameters,
						'applicationTokenExchangeUrl'
					)
					? parameters.applicationTokenExchangeUrl
					: null
			}
			{
				key: 'tenantId'
				value: parameters.tenantId
			}
		]
		scopes: parameters.applicationScopes
		serviceProviderDisplayName: 'Azure Active Directory v2'
		serviceProviderId: '30dd229c-58e3-4a48-bdfd-91ec48eb906c'
	}
	tags: tags
}
