metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* types */

@export()
type AuthorizationPrincipalInfo = {
	id: string
	name: string?
	type: AuthorizationPrincipalType?
}

@export()
type AuthorizationPrincipalType = 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'

@description('Type of Azure Resource Identity.')
@export()
type ResourceIdentityType = 'None' | 'SystemAssigned' | 'SystemAssigned,UserAssigned' | 'UserAssigned'

@description('Configuration of Azure Resource Identity in EntraID.')
@export()
type ResourceIdentity = {
	@description('The identity type.')
	type: ResourceIdentityType

	@description('Identifiers of the user assigned identities to use.')
	userAssignedIdentities: object
}
