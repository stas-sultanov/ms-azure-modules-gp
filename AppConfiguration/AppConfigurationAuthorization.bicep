metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import{AuthorizationPrincipalInfo}from'./../types.bicep'

/* types */

type Authorization = {
	description: string?
	principal: AuthorizationPrincipalInfo
	role: AuthorizationRoleName
}

type AuthorizationRoleName = 'AppConfigurationDataOwner' | 'AppConfigurationDataReader'

/* parameters */

@description('Id of the AppConfiguration/configurationStores resource.')
param AppConfiguration_configurationStores__id string

@description('Collection of authorizations.')
param authorizationList Authorization[]

/* variables */

var roleId = {
	AppConfigurationDataOwner: '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'
	AppConfigurationDataReader: '516239f1-63e1-4d78-a4de-a74fb236a071'
}

/* existing resources */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' existing = {
	name: split(AppConfiguration_configurationStores__id, '/')[8]
}

/* resources */

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
for authorization in authorizationList: {
	scope: AppConfiguration_configurationStores_
	name: guid(AppConfiguration_configurationStores_.id, roleId[authorization.role], authorization.principal.id)
	properties: {
		roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId[authorization.role])
		principalId: authorization.principal.id
		principalType: authorization.principal.type
		description: (!contains(authorization, 'description') || empty(authorization.description)) 
		 ? '${authorization.role} role for ${(!contains(authorization.principal, 'name') || empty(authorization.principal.name)) ? authorization.principal.id : authorization.principal.name}.' 
		 : authorization.description
	}
}
]