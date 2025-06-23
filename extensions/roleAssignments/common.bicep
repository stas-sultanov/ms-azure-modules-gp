metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* types */

@export()
var StandardRoleDictionary = {
	'Contributor': 'b24988ac-6180-42a0-ab88-20f7382dd24c'
	'Owner': '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
	'Reader': 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
	'Role Based Access Control Administrator': 'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
	'User Access Administrator': '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
}

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
