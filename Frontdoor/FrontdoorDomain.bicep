/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the Cdn/profiles resource.')
param Cdn_profiles__id string

@description('Id of the Network/dnsZones resource.')
param Network_dnsZones__id string

//param cnameRecordName string

param name string

param dnsRecordTimeToLive int

/* variables */

var cdn_profiles__id_split = split(Cdn_profiles__id, '/')

var hostName = '${name}.${Network_DnsZones_.name}'

var network_dnsZones__id_split = split(Network_dnsZones__id, '/')

/* existing resources */

resource Cdn_profiles_ 'Microsoft.Cdn/profiles@2023-05-01' existing = {
	name: cdn_profiles__id_split[8]
}

resource Network_DnsZones_ 'Microsoft.Network/dnsZones@2018-05-01' existing = {
	name: network_dnsZones__id_split[8]
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/customdomains
resource Cdn_profiles_customDomains_ 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
	name: replace(hostName, '.', '-')
	parent: Cdn_profiles_
	properties: {
		hostName: hostName
		tlsSettings: {
			certificateType: 'ManagedCertificate'
			minimumTlsVersion: 'TLS12'
		}
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.network/dnszones/cname
/*
resource Network_dnsZones_cname_ 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
	parent: Network_DnsZones_
	name: cnameRecordName
	properties: {
		TTL: dnsRecordTimeToLive
		CNAMERecord: {
			cname: endpoint.properties.hostName
		}
	}
}
*/

// https://learn.microsoft.com/azure/templates/microsoft.network/dnszones/txt
resource Network_dnsZones_txt_ 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
	parent: Network_DnsZones_
	name: '_dnsauth.${name}'
	properties: {
		TTL: dnsRecordTimeToLive
		TXTRecords: [
			{
				value: [
					Cdn_profiles_customDomains_.properties.validationProperties.validationToken
				]
			}
		]
	}
}
