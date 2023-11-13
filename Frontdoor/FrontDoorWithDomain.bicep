/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the Network/dnsZones resource.')
param Network_dnsZones__id string

@description('Id of the OperationalInsights/workspaces resource.')
param OperationalInsights_workspaces__id string

@description('Name of the resource.')
param name string

@description('Send and receive timeout on forwarding request to the origin. When timeout is reached, the request fails and returns.')
@minValue(16)
param originResponseTimeoutSeconds int

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var network_dnsZones__id_split = split(Network_dnsZones__id, '/')

var operationalInsights_workspaces__id_split = split(OperationalInsights_workspaces__id, '/')

/* existing resources */

resource Network_DnsZones_ 'Microsoft.Network/dnsZones@2018-05-01' existing = {
	name: network_dnsZones__id_split[8]
}

resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles
resource Cdn_profiles_ 'Microsoft.Cdn/profiles@2023-05-01' = {
	location: 'global'
	name: name
	properties: {
		originResponseTimeoutSeconds: originResponseTimeoutSeconds
	}
	sku: {
		name: 'Standard_AzureFrontDoor'
	}
	tags: tags
}

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/customdomains
resource Cdn_profiles_customDomains_ 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
	name: replace(Network_DnsZones_.name, '.', '-')
	parent: Cdn_profiles_
	properties: {
		azureDnsZone: {
			id: Network_DnsZones_.id
		}
		hostName: Network_DnsZones_.name
		tlsSettings: {
			certificateType: 'ManagedCertificate'
			minimumTlsVersion: 'TLS12'
		}
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: 'Log Analytics'
	properties: {
		logAnalyticsDestinationType: 'Dedicated'
		logs: [
			{
				categoryGroup: 'allLogs'
				enabled: true
			}
		]
		metrics: [
			{
				timeGrain: 'PT1M'
				enabled: true
			}
		]
		workspaceId: OperationalInsights_workspaces_.id
	}
	scope: Cdn_profiles_
}

// https://learn.microsoft.com/azure/templates/microsoft.network/dnszones/txt
resource Network_dnsZones_txt_ 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
	parent: Network_DnsZones_
	name: '_dnsauth'
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

/* outputs */

output id string = Cdn_profiles_.id
