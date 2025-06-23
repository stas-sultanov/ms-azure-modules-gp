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

@description('Name of the Microsoft.ContainerRegistry/registries resource.')
param name string

/* variables */

var roleIdDictionary = union(
	StandardRoleDictionary,
	{
		'AcrDelete': 'c2f4ef07-c644-48eb-af81-4b1b4947fb11'
		'AcrImageSigner': '6cef56e8-d556-48e5-a04f-b8e64114680f'
		'AcrPull': '7f951dda-4ed3-4680-a7ca-43fe172d538d'
		'AcrPush': '8311e382-0749-4cb8-b61a-304f252e45ec'
		'AcrQuarantineReader': 'cdda3590-29a3-44f6-95f2-9f980659eb04'
		'AcrQuarantineWriter': 'c8d4ff99-41c3-41a8-9f60-21dfdad59608'
	}
)

/* existing resources */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-04-01' existing = {
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
			ContainerRegistry_registries_.id,
			roleAssignment.principalId,
			roleAssignment.roleDefinitionId
		)
		properties: roleAssignment
		scope: ContainerRegistry_registries_
	}
]
