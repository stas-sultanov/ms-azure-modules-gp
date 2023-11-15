/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the Cdn/profiles/afdEndpoints resource.')
param Cdn_profiles_afdEndpoints__id string

@description('Id of the Cdn/profiles/customDomains resource.')
param Cdn_profiles_customDomains__id string

param originGroupsName string

param originHostHeader string

param originHostName string

param originPath string?

param patternsToMatch string[]

@description('Name of the route.')
param routeName string

/* variables */

var cdn_profiles_afdEndpoints__id_split = split(Cdn_profiles_afdEndpoints__id, '/')

var cdn_profiles_customDomains__id_split = split(Cdn_profiles_customDomains__id, '/')

/* existing resources */

resource Cdn_profiles_ 'Microsoft.Cdn/profiles@2023-05-01' existing = {
	name: cdn_profiles_afdEndpoints__id_split[8]
}

resource Cdn_profiles_afdEndpoints_ 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' existing = {
	name: cdn_profiles_afdEndpoints__id_split[10]
	parent: Cdn_profiles_
}

resource Cdn_profiles_customDomains_ 'Microsoft.Cdn/profiles/customDomains@2023-05-01' existing = {
	name: cdn_profiles_customDomains__id_split[10]
	parent: Cdn_profiles_
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/afdendpoints/routes
resource Cdn_profiles_afdEndpoints_routes_ 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
	dependsOn: [
		Cdn_profiles_originGroups_origins_
	]
	name: routeName
	parent: Cdn_profiles_afdEndpoints_
	properties: {
		cacheConfiguration: {
			queryStringCachingBehavior: 'IgnoreQueryString'
		}
		customDomains: [
			{
				id: Cdn_profiles_customDomains_.id
			}
		]
		originGroup: {
			id: Cdn_profiles_originGroups_.id
		}
		originPath: originPath
		supportedProtocols: [
			'Https'
		]
		patternsToMatch: patternsToMatch
		forwardingProtocol: 'HttpOnly'
		linkToDefaultDomain: 'Disabled'
		httpsRedirect: 'Enabled'
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/origingroups
resource Cdn_profiles_originGroups_ 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
	name: originGroupsName
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
	name: replace(replace(originHostName, '.', '-'), '_', '-')
	parent: Cdn_profiles_originGroups_
	properties: {
		hostName: originHostName
		httpPort: 80
		httpsPort: 443
		originHostHeader: originHostHeader
		priority: 1
		weight: 1000
	}
}
