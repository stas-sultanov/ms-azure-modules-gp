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
	AuthorizationPrincipalType
} from './../types.bicep'

/* types */

type Authorization = {
	description: string?
	principalId: string
	principalName: string?
	principalType: AuthorizationPrincipalType?
	roleName: AuthorizationRoleName
}

type AuthorizationRoleName =
	| 'Application Insights Component Contributor'
	| 'Application Insights Snapshot Debugger'
	| 'Monitoring Metrics Publisher'

/* parameters */

@description('Collection of authorizations.')
param authorizationList Authorization[]

@description('Name of the Insights/components resource.')
param componentName string

/* variables */

var roleId = {
	'Application Insights Component Contributor': 'ae349356-3a1b-4a5e-921d-050484c6347e' // Can manage Application Insights components.
	'Application Insights Snapshot Debugger': '08954f03-6346-4c2e-81c0-ec3a5cfae23b' // Gives user permission to view and download debug snapshots collected with the Application Insights Snapshot Debugger.
	'Monitoring Metrics Publisher': '3913510d-42f4-4e42-8a64-420c390055eb' // Enables publishing metrics against Azure resources.
}

/* existing resources */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: componentName
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for authorization in authorizationList: {
		name: guid(
			Insights_components_.id,
			roleId[authorization.roleName],
			authorization.principalId
		)
		properties: {
			description: empty(authorization.description)
				? '${authorization.roleName} role assigment for ${empty(authorization.principalName) ? authorization.principalId : authorization.principalName}.'
				: authorization.description
			principalId: authorization.principalId
			principalType: authorization.principalType
			roleDefinitionId: subscriptionResourceId(
				'Microsoft.Authorization/roleDefinitions',
				roleId[authorization.roleName]
			)
		}
		scope: Insights_components_
	}
]
