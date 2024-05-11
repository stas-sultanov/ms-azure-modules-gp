/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* scope */

targetScope = 'resourceGroup'

/* imports */

import { AuthorizationPrincipalInfo } from './../types.bicep'

/* types */

type Authorization = {
	description: string?
	principal: AuthorizationPrincipalInfo
	role: AuthorizationRoleName
}

type AuthorizationRoleName = 'BlobDataContributor' | 'BlobDataReader' | 'QueueDataContributor' | 'QueueDataMessageProcessor' | 'QueueDataMessageSender' | 'QueueDataReader' | 'TableDataReader'

/* parameters */

@description('Name of the Storage/storageAccounts resource.')
param Storage_storageAccounts__name string

@description('Collection of authorizations.')
param authorizationList Authorization[]

/* variables */

var roleId = {
	BlobDataContributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
	BlobDataReader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
	QueueDataContributor: '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
	QueueDataMessageProcessor: '8a0f0c08-91a1-4084-bc3d-661d67233fed'
	QueueDataMessageSender: 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
	QueueDataReader: '19e7f393-937e-4f77-808e-94535e297925'
	TableDataContributor: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
	TableDataReader: '76199698-9eea-4c19-bc75-cec21354c6b6'
}

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
	name: Storage_storageAccounts__name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
for authorization in authorizationList: {
	name: guid(
		subscription().id,
		resourceGroup().name,
		Storage_storageAccounts_.name,
		roleId[authorization.role],
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
	scope: Storage_storageAccounts_
}
]
