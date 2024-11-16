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
} from './../../common.bicep'

/* parameters */

@description('Collection of authorizations.')
param authorizationList Authorization[]

@description('Name of the Microsoft.Storage/storageAccounts/blobServices/containers resource.')
param containerName string

@description('Name of the Microsoft.Storage/storageAccounts resource.')
param storageAccountName string

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
}

resource Storage_storageAccounts_blobServices_ 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' existing = {
	name: 'default'
	parent: Storage_storageAccounts_
}

resource Storage_storageAccounts_blobServices_containers_ 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' existing = {
	name: containerName
	parent: Storage_storageAccounts_blobServices_
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in ConvertToRoleAssignmentProperties(
		authorizationList,
		roleIdDictionary
	): {
		name: guid(
			Storage_storageAccounts_blobServices_containers_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: Storage_storageAccounts_blobServices_containers_
	}
]
