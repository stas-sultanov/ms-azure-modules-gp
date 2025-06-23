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
} from 'common.bicep'

/* parameters */

@description('Collection of roles assignments.')
param assignments RoleAssignment[]

@description('Name of the Microsoft.Network/virtualNetworks resource.')
param virtualNetworkName string

@description('Name of the Microsoft.Network/virtualNetworks/subnets resource.')
param virtualNetworkSubnetName string

/* variables */

var roleIdDictionary = {
	'Network Contributor': '4d97b98b-1d4f-4787-a291-c67834d212e7'
}

/* existing resources */

resource Network_virtualNetworks_ 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
	name: virtualNetworkName
	resource subnets_ 'subnets' existing = {
		name: virtualNetworkSubnetName
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
			Network_virtualNetworks_::subnets_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: Network_virtualNetworks_::subnets_
	}
]
