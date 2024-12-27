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

@description('Name of the Microsoft.Storage/storageAccounts/queueServices/queues resource.')
param storageQueueName string

/* variables */

var roleIdDictionary = {
	'Storage Queue Data Contributor': '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
	'Storage Queue Data Message Processor': '8a0f0c08-91a1-4084-bc3d-661d67233fed'
	'Storage Queue Data Message Sender': 'c6a89b2d-59bc-44d0-9896-0f6e12d7b80a'
	'Storage Queue Data Reader': '19e7f393-937e-4f77-808e-94535e297925'
}

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
	name: storageAccountName
	resource queueServices_Default 'queueServices' existing = {
		name: 'default'
		resource queues_ 'queues' existing = {
			name: storageQueueName
		}
	}
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for roleAssignmentProperties in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			Storage_storageAccounts_::queueServices_Default::queues_.id,
			roleAssignmentProperties.principalId,
			roleAssignmentProperties.roleDefinitionId
		)
		properties: roleAssignmentProperties
		scope: Storage_storageAccounts_::queueServices_Default::queues_
	}
]
