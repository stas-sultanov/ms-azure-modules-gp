metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* imports */

import {
	RoleAssignment
	ConvertToRoleAssignmentProperties
} from 'common.bicep'

/* parameters */

@description('Collection of roles assignments.')
param assignments RoleAssignment[]

@description('Name of the Microsoft.Storage/storageAccounts resource.')
param storageAccountName string

@description('Name of the Microsoft.Storage/storageAccounts/blobServices/containers resource.')
param storageContainerName string

/* variables */

var roleIdDictionary = {
	'Storage Blob Data Contributor': 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
	'Storage Blob Data Owner': 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
	'Storage Blob Data Reader': '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
	'Storage Blob Delegator': 'db58b8e5-c6ad-4a2a-8342-4190687cbf4a'
}

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
	name: storageAccountName
	resource blobServices_Default 'blobServices' existing = {
		name: 'default'
		resource containers_ 'containers' existing = {
			name: storageContainerName
		}
	}
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			Storage_storageAccounts_::blobServices_Default::containers_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: Storage_storageAccounts_::blobServices_Default::containers_
	}
]
