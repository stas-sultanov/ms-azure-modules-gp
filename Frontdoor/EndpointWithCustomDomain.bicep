/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

targetScope = 'resourceGroup'

/* parameters */

@description('Id of the Cdn/profiles resource.')
param Cdn_profiles__id string

@description('Id of the Network/dnsZones resource.')
param Network_dnsZones__id string

@description('Id of the Network/frontDoorWebApplicationFirewallPolicies resource.')
param Network_frontDoorWebApplicationFirewallPolicies__id string

param name string

param dnsRecordTimeToLive int = 3600

@description('Tags to put on the resources.')
param tags object

/* variables */

var cdn_profiles__id_split = split(Cdn_profiles__id, '/')

var hostName = '${name}.${Network_dnsZones_.name}'

var network_dnsZones__id_split = split(Network_dnsZones__id, '/')

var network_frontDoorWebApplicationFirewallPolicies__id_split = split(Network_frontDoorWebApplicationFirewallPolicies__id, '/')

/* existing resources */

resource Cdn_profiles_ 'Microsoft.Cdn/profiles@2023-05-01' existing = {
	name: cdn_profiles__id_split[8]
}

resource Network_dnsZones_ 'Microsoft.Network/dnsZones@2018-05-01' existing = {
	name: network_dnsZones__id_split[8]
}

resource Network_frontDoorWebApplicationFirewallPolicies_ 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' existing = {
	name: network_frontDoorWebApplicationFirewallPolicies__id_split[8]
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/afdendpoints
resource Cdn_profiles_afdEndpoints_ 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
	location: 'global'
	name: name
	parent: Cdn_profiles_
	properties: {
		autoGeneratedDomainNameLabelScope: 'ResourceGroupReuse'
	}
	tags: tags
}

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/customdomains
resource Cdn_profiles_customDomains_ 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
	name: replace(hostName, '.', '-')
	parent: Cdn_profiles_
	properties: {
		azureDnsZone: {
			id: Network_dnsZones_.id
		}
		hostName: hostName
		tlsSettings: {
			certificateType: 'ManagedCertificate'
			minimumTlsVersion: 'TLS12'
		}
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/securitypolicies
resource Cdn_profiles_securityPolicies_ 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = {
	name: name
	parent: Cdn_profiles_
	properties: {
		parameters: {
			associations: [
				{
					domains: [
						{
							id: Cdn_profiles_afdEndpoints_.id
						}
					]
					patternsToMatch: [
						'/*'
					]
				}
			]
			type: 'WebApplicationFirewall'
			wafPolicy: {
				id: Network_frontDoorWebApplicationFirewallPolicies_.id
			}
		}
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.network/dnszones/txt
resource Network_dnsZones_txt_Validation 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
	name: '_dnsauth.${name}'
	parent: Network_dnsZones_
	properties: {
		TTL: 3600
		TXTRecords: [
			{
				value: [
					Cdn_profiles_customDomains_.properties.validationProperties.validationToken
				]
			}
		]
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.network/dnszones/cname
resource Network_dnsZones_cname_ 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
	name: name
	parent: Network_dnsZones_
	properties: {
		CNAMERecord: {
			cname: Cdn_profiles_afdEndpoints_.properties.hostName
		}
		TTL: dnsRecordTimeToLive
	}
}

/* outputs */

output Cdn_profiles_afdEndpoints__id string = Cdn_profiles_afdEndpoints_.id

output Cdn_profiles_customDomains__id string = Cdn_profiles_customDomains_.id

output Cdn_profiles_securityPolicies__id string = Cdn_profiles_securityPolicies_.id

output Network_dnsZones_cname__id string = Network_dnsZones_cname_.id

output Network_dnsZones_txt_Validation_id string = Network_dnsZones_txt_Validation.id
