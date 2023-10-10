metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

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

	@description('Entra Teanant Id')
	tenantId: string
}

/* parameters */

@description('Id of the BotService/botServices resource.')
param BotService_botServices__id string

@description('Name of the resource.')
param name string

@description('Entra Parameters')
param parameters EntraParameters

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var botService_botServices__id_split = split(BotService_botServices__id, '/')

/* existing resources */

resource BotService_botServices_ 'Microsoft.BotService/botServices@2022-09-15' existing = {
	name: botService_botServices__id_split[8]
	//scope: resourceGroup(botService_botServices__id_split[4])
}

/* resources */

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.botservice/botservices
resource BotService_botServices_connections_ 'Microsoft.BotService/botServices/connections@2022-09-15' = {
	parent: BotService_botServices_
	name: name
	location: 'global'
	tags: tags
	properties: {
		clientId: parameters.applicationClientId
		clientSecret: parameters.applicationSecret
		parameters: [
			{
				key: 'tokenExchangeUrl'
				value: contains(parameters, 'applicationTokenExchangeUrl') 
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
}
