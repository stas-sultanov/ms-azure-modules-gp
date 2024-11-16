/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* scope */

targetScope = 'resourceGroup'

/* imports */

import {
	AuthorizationPrincipalInfo
} from './../types.bicep'

/* types */

type Authorization = {
	description: string?
	principal: AuthorizationPrincipalInfo
	role: AuthorizationRoleName
}

type AuthorizationRoleName =
	| 'CosmosDBAccountReaderRole'
	| 'CosmosDBOperator'
	| 'CosmosRestoreOperator'
	| 'DocumentDBAccountContributor'

/* parameters */

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__name string

@description('Collection of authorizations.')
param authorizationList Authorization[]

/* variables */

var roleId = {
	CosmosDBAccountReaderRole: 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8'
	CosmosDBOperator: '230815da-be43-4aae-9cb4-875f7bd000aa'
	CosmosRestoreOperator: '5432c526-bc82-444a-b7ba-57c5b0b5b34f'
	DocumentDBAccountContributor: '5bd9cd88-fe45-4216-938b-f97437e15450'
}

/* existing resources */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2024-08-15' existing = {
	name: DocumentDB_databaseAccounts__name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in authorizationList: {
		name: guid(
			subscription().id,
			DocumentDB_databaseAccounts_.id,
			roleId[authorization.role],
			authorization.principal.id
		)
		properties: {
			description: (!contains(
					authorization,
					'description'
				) || empty(authorization.description))
				? '${authorization.role} role for ${(!contains(authorization.principal, 'name') || empty(authorization.principal.name)) ? authorization.principal.id : authorization.principal.name}.'
				: authorization.description
			principalId: authorization.principal.id
			principalType: authorization.principal.type
			roleDefinitionId: subscriptionResourceId(
				'Microsoft.Authorization/roleDefinitions',
				roleId[authorization.role]
			)
		}
		scope: DocumentDB_databaseAccounts_
	}
]
