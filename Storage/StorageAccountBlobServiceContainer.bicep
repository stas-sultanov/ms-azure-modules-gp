/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import { AuthorizationPrincipalInfo } from './../types.bicep'

/* types */

type Authorization = {
	description: string?
	principal: AuthorizationPrincipalInfo
	role: RoleName
}

type RoleName = 'BlobDataContributor' | 'BlobDataReader'

/* parameters */

@description('Id of the Storage/storageAccounts resource.')
param Storage_storageAccounts__id string

@description('Collection of authorizations.')
param authorizationList Authorization[]

param name string

/* variables */

var roleId = {
	BlobDataContributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
	BlobDataReader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

var storage_StorageAccounts__id_split = split(Storage_storageAccounts__id, '/')

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
	name: storage_StorageAccounts__id_split[8]
}

resource Storage_storageAccounts_blobServices_ 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
	name: 'default'
	parent: Storage_storageAccounts_
}

/* resources */

// provision Container
// https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices/containers
resource Storage_storageAccounts_blobServices_containers_ 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
	name: name
	parent: Storage_storageAccounts_blobServices_
}

// provision Container authorizations
// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
for authorization in authorizationList: {
	name: guid(
		subscription().id,
		Storage_storageAccounts_.id,
		name,
		authorization.role,
		authorization.principal.id
	)
	properties: {
		description: (!contains(authorization, 'description') || empty(authorization.description)) 
		 ? '${authorization.role} role for ${(!contains(authorization.principal, 'name') || empty(authorization.principal.name)) ? authorization.principal.id : authorization.principal.name}.' 
		 : authorization.description
		principalId: authorization.principal.id
		principalType: authorization.principal.type
		roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId[authorization.role])
	}
	scope: Storage_storageAccounts_blobServices_containers_
}
]
