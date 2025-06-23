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

@description('Name of the Microsoft.ContainerService/managedClusters resource.')
param name string

/* variables */

var roleIdDictionary = union(
	StandardRoleDictionary,
	{
		'Azure Kubernetes Fleet Manager Contributor Role': '63bb64ad-9799-4770-b5c3-24ed299a07bf'
		'Azure Kubernetes Fleet Manager RBAC Admin': '434fb43a-c01c-447e-9f67-c3ad923cfaba'
		'Azure Kubernetes Fleet Manager RBAC Cluster Admin': '18ab4d3d-a1bf-4477-8ad9-8359bc988f69'
		'Azure Kubernetes Fleet Manager RBAC Reader': '30b27cfc-9c84-438e-b0ce-70e35255df80'
		'Azure Kubernetes Fleet Manager RBAC Writer': '5af6afb3-c06c-4fa4-8848-71a8aee05683'
		'Azure Kubernetes Service Cluster Admin Role': '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8'
		'Azure Kubernetes Service Cluster Monitoring User': '1afdec4b-e479-420e-99e7-f82237c7c5e6'
		'Azure Kubernetes Service Cluster User Role': '4abbcc35-e782-43d8-92c5-2d3f1bd2253f'
		'Azure Kubernetes Service Contributor Role': 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8'
		'Azure Kubernetes Service RBAC Admin': '3498e952-d568-435e-9b2c-8d77e338d7f7'
		'Azure Kubernetes Service RBAC Cluster Admin': 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
		'Azure Kubernetes Service RBAC Reader': '7f6c6a51-bcf8-42ba-9220-52d62157d7db'
		'Azure Kubernetes Service RBAC Writer': 'a7ffa36f-339b-4b5c-8bdf-e2c188b2c0eb'
	}
)

/* existing resources */

resource ContainerService_managedClusters_ 'Microsoft.ContainerService/managedClusters@2025-03-01' existing = {
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
			ContainerService_managedClusters_.id,
			authorization.principalId,
			authorization.roleDefinitionId
		)
		properties: authorization
		scope: ContainerService_managedClusters_
	}
]
