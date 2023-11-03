/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the Cdn/profiles/afdEndpoints resource.')
param Cdn_profiles_afdEndpoints__id string

@description('Id of the Storage/storageAccounts resource.')
param Storage_storageAccounts__id string

@description('Name of the resource.')
param name string

/* variables */

var cdn_profiles_afdEndpoints__id_split = split(Cdn_profiles_afdEndpoints__id, '/')

var storage_StorageAccounts__id_split = split(Storage_storageAccounts__id, '/')

var storage_storageAccounts_primaryEndpoints_blob_hostName = replace(replace(Storage_storageAccounts_.properties.primaryEndpoints.blob, 'https://', ''), '/', '')

/* existing resources */

resource Cdn_profiles_ 'Microsoft.Cdn/profiles@2023-05-01' existing = {
	name: cdn_profiles_afdEndpoints__id_split[8]
}

resource Cdn_profiles_afdEndpoints_ 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' existing = {
	name: cdn_profiles_afdEndpoints__id_split[10]
	parent: Cdn_profiles_
}

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
	name: storage_StorageAccounts__id_split[8]
	scope: resourceGroup(storage_StorageAccounts__id_split[4])
}

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/afdendpoints/routes
resource Cdn_profiles_afdEndpoints_routes_ 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
	name: name
	parent: Cdn_profiles_afdEndpoints_
	properties: {
		cacheConfiguration: {
			queryStringCachingBehavior: 'IgnoreQueryString'
		}
		customDomains: []
		originGroup: {
			id: Cdn_profiles_originGroups_.id
		}
		originPath: null
		supportedProtocols: [
			'Http'
			'Https'
		]
		patternsToMatch: [
			'/*'
		]
		forwardingProtocol: 'MatchRequest'
		linkToDefaultDomain: 'Enabled'
		httpsRedirect: 'Disabled'
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/origingroups
resource Cdn_profiles_originGroups_ 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
	name: '${name}-storage'
	parent: Cdn_profiles_
	properties: {
		healthProbeSettings: {
			probeIntervalInSeconds: 120
			probePath: '/'
			probeProtocol: 'Http'
			probeRequestType: 'HEAD'
		}
		loadBalancingSettings: {
			additionalLatencyInMilliseconds: 50
			sampleSize: 4
			successfulSamplesRequired: 3
		}
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/origingroups/origins
resource Cdn_profiles_originGroups_origins_ 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
	name: Storage_storageAccounts_.name
	parent: Cdn_profiles_originGroups_
	properties: {
		hostName: storage_storageAccounts_primaryEndpoints_blob_hostName
		httpPort: 80
		httpsPort: 443
		originHostHeader: storage_storageAccounts_primaryEndpoints_blob_hostName
		priority: 1
		weight: 1000
	}
}
