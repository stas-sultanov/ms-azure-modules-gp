/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* types */

@export()
type Authorization = {
	description: string?
	principalId: string
	principalName: string?
	principalType: AuthorizationPrincipalType?
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
@description('dotNet Framework version.')
type DotNetVersion =
	| 'v6.0'
	| 'v7.0'
	| 'v8.0'
	| 'v9.0'

type IpSecurityRestrictionAction =
	| 'Allow'
	| 'Deny'

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
type ManagedIdentityType =
	| 'SystemAssigned'
	| 'SystemAssigned,UserAssigned'
	| 'UserAssigned'

@description('Managed Service Identity via Entra.')
@export()
type ManagedIdentity = {
	@description('The identity type.')
	type: ManagedIdentityType

	@description('Identifiers of the user assigned identities to use.')
	userAssignedIdentities: object?
}
