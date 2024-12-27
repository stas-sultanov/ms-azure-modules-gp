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

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param name string

/* variables */

var roleIdDictionary = {
	'Cosmos DB Account Reader Role': 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8'
	'Cosmos DB Operator': '230815da-be43-4aae-9cb4-875f7bd000aa'
	'CosmosBackupOperator': '5432c526-bc82-444a-b7ba-57c5b0b5b34f'
	'CosmosRestoreOperator': '5432c526-bc82-444a-b7ba-57c5b0b5b34f'
	'DocumentDB Account Contributor': '5bd9cd88-fe45-4216-938b-f97437e15450'
}

/* existing resources */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
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
			DocumentDB_databaseAccounts_.id,
			roleAssignment.principalId,
			roleAssignment.roleDefinitionId
		)
		properties: roleAssignment
		scope: DocumentDB_databaseAccounts_
	}
]
