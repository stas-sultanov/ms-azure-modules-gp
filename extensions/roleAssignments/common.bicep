metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* types */

@export()
type RoleAssignment = {
	description: string?
	principalId: string
	principalName: string?
	principalType: AuthorizationPrincipalType
	roleName: string
}

@export()
type AuthorizationPrincipalType =
	| 'Device'
	| 'ForeignGroup'
	| 'Group'
	| 'ServicePrincipal'
	| 'User'

@export()
func ConvertToRoleAssignmentProperties(
	authorizations RoleAssignment[],
	roleIdDictionary object
) RoleAssignmentProperties[] =>
	map(
		authorizations,
		authorization => {
			description: authorization.?description ?? '${authorization.roleName} role assignment for ${authorization.?principalName ?? authorization.principalId}.'
			principalId: authorization.principalId
			principalType: authorization.principalType
			roleDefinitionId: subscriptionResourceId(
				'Microsoft.Authorization/roleDefinitions',
				roleIdDictionary[authorization.roleName]
			)
		}
	)

type RoleAssignmentProperties = {
	description: string
	principalId: string
	principalType: AuthorizationPrincipalType?
	roleDefinitionId: string
}
