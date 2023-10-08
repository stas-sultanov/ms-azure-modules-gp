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

type IpSecurityRestrictionAction = 'Allow' | 'Deny'

@export()
type IpSecurityRestriction = {
	@description('Allow or Deny access for this IP range.')
	action: IpSecurityRestrictionAction

	@description('Information.')
	description: string?

	@description('IP address the security restriction is valid for.')
	ipAddress: string

	@description('IP restriction rule name.')
	name: string
}

@description('Type of Azure Resource Identity.')
@export()
type ManagedServiceIdentityType = 'None' | 'SystemAssigned' | 'SystemAssigned,UserAssigned' | 'UserAssigned'

@description('Managed Service Identity via Entra.')
@export()
type ManagedServiceIdentity = {
	@description('The identity type.')
	type: ManagedServiceIdentityType

	@description('Identifiers of the user assigned identities to use.')
	userAssignedIdentities: object?
}
