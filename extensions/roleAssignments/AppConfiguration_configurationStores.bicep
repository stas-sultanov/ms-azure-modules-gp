metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* imports */

import {
	ConvertToRoleAssignmentProperties
	RoleAssignment
	StandardRoleDictionary
} from 'common.bicep'

/* parameters */

@description('Collection of roles assignments.')
param assignments RoleAssignment[]

@description('Name of the Microsoft.AppConfiguration/configurationStores resource.')
param name string

/* variables */

var roleIdDictionary = union(
	StandardRoleDictionary,
	{
		'App Configuration Contributor': 'fe86443c-f201-4fc4-9d2a-ac61149fbda0'
		'App Configuration Data Owner': '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'
		'App Configuration Data Reader': '516239f1-63e1-4d78-a4de-a74fb236a071'
		'App Configuration Reader': '175b81b9-6e0d-490a-85e4-0d422273c10c'
	}
)

/* existing resources */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-06-01' existing = {
	name: name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for roleAssignment in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			AppConfiguration_configurationStores_.id,
			roleAssignment.principalId,
			roleAssignment.roleDefinitionId
		)
		properties: roleAssignment
		scope: AppConfiguration_configurationStores_
	}
]
