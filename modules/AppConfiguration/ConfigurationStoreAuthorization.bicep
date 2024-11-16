metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* scope */

targetScope = 'resourceGroup'

/* imports */

import {
	Authorization
	ConvertToRoleAssignmentProperties
} from './../common.bicep'

/* parameters */

@description('Collection of authorizations.')
param authorizationList Authorization[]

@description('Name of the AppConfiguration/configurationStores resource.')
param storeName string

/* variables */

var roleIdDictionary = {
	'App Configuration Contributor': 'fe86443c-f201-4fc4-9d2a-ac61149fbda0'
	'App Configuration Data Owner': '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'
	'App Configuration Data Reader': '516239f1-63e1-4d78-a4de-a74fb236a071'
	'App Configuration Reader': '175b81b9-6e0d-490a-85e4-0d422273c10c'
}

/* existing resources */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = {
	name: storeName
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in ConvertToRoleAssignmentProperties(
		authorizationList,
		roleIdDictionary
	): {
		name: guid(
			AppConfiguration_configurationStores_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: AppConfiguration_configurationStores_
	}
]
