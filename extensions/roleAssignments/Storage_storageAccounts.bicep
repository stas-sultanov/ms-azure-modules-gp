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

@description('Name of the Microsoft.Storage/storageAccounts resource.')
param name string

/* variables */

var roleIdDictionary = union(
	StandardRoleDictionary,
	{
		'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
		'Storage Blob Data Reader': '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
		'Storage Queue Data Contributor': '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
		'Storage Queue Data Message Processor': '8a0f0c08-91a1-4084-bc3d-661d67233fed'
		'Storage Queue Data Message Sender': 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
		'Storage Queue Data Reader': '19e7f393-937e-4f77-808e-94535e297925'
		'Storage Table Data Contributor': '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
		'Storage Table Data Reader': '76199698-9eea-4c19-bc75-cec21354c6b6'
	}
)

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
	name: name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			Storage_storageAccounts_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: Storage_storageAccounts_
	}
]
