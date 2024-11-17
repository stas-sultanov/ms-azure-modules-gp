metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* imports */

import {
	DotNetVersion
	IpSecurityRestriction
	ManagedIdentity
} from './../../common.bicep'

/* types */

@description('Version of TLS required for SSL requests.')
type TlsVersion =
	| '1.1'
	| '1.2'
	| '1.3'

@description('FunctionApp properties.')
type SiteConfig = {
	@description('OpenApi definition path.')
	apiDefinition: string?

	@description('Application settings to be used as Environment Variables.')
	appSettings: object

	@description('List of origins that should be allowed to make cross-origin calls. Use "*" to allow all.')
	corsAllowedOrigins: string[]

	@description('Maximum number of workers that a site can scale out to.')
	@minValue(0)
	@maxValue(200)
	functionAppScaleLimit: int?

	@description('Health check path.')
	healthCheckPath: string?

	@description('Allow clients to connect over http2.0')
	http20Enabled: bool

	@description('List of allowed IP addresses.')
	ipSecurityRestrictions: IpSecurityRestriction[]

	@description('Minimum version of TLS required for SSL requests.')
	minTlsVersion: TlsVersion

	@description('dotNet Framework version.')
	netFrameworkVersion: DotNetVersion

	@description('true if remote debugging is enabled; otherwise, false.')
	remoteDebuggingEnabled: bool

	@description('true to use 32-bit worker process; otherwise, false')
	use32BitWorkerProcess: bool
}

@description('FunctionApp properties.')
type Properties = {
	@description('Enable administrative endpoints for functions.')
	functionsRuntimeAdminIsolationEnabled: bool

	@description('HttpsOnly: configures a web site to accept only https requests. Issues redirect for http requests.')
	httpsOnly: bool

	siteConfig: SiteConfig
}

/* parameters */

@description('Managed Service Identity.')
param identity ManagedIdentity

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Service properties.')
param properties Properties

@description('Id of the Web/serverfarms resource.')
param serverFarmId string

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var web_serverfarms__id_split = split(
	serverFarmId,
	'/'
)

/* existing resources */

resource Web_serverFarms_ 'Microsoft.Web/serverfarms@2024-04-01' existing = {
	name: web_serverfarms__id_split[8]
	scope: resourceGroup(
		web_serverfarms__id_split[2],
		web_serverfarms__id_split[4]
	)
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.web/sites
resource Web_sites_ 'Microsoft.Web/sites@2024-04-01' = {
	identity: identity
	kind: 'functionapp'
	location: location
	name: name
	properties: {
		autoGeneratedDomainNameLabelScope: 'TenantReuse'
		#disable-next-line BCP037 // bicep has only old api
		functionsRuntimeAdminIsolationEnabled: properties.functionsRuntimeAdminIsolationEnabled
		httpsOnly: properties.httpsOnly
		serverFarmId: Web_serverFarms_.id
		#disable-next-line BCP073 // in API definition this property is read only
		state: 'Stopped'
	}
	tags: tags
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/basicpublishingcredentialspolicies-ftp
resource Web_sites_basicPublishingCredentialsPolicies__FTP 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01' = {
	name: 'ftp'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/basicpublishingcredentialspolicies-scm
resource Web_sites_basicPublishingCredentialsPolicies__SCM 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2024-04-01' = {
	name: 'scm'
	parent: Web_sites_
	properties: {
		allow: false
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-appsettings
resource Web_sites_config__AppSettings 'Microsoft.Web/sites/config@2024-04-01' = {
	name: 'appsettings'
	parent: Web_sites_
	properties: union(
		properties.siteConfig.appSettings,
		{
			FUNCTIONS_EXTENSION_VERSION: '~4'
			FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-metadata
resource Web_sites_config__Metadata 'Microsoft.Web/sites/config@2024-04-01' = {
	name: 'metadata'
	parent: Web_sites_
	properties: {
		CURRENT_STACK: 'dotnet'
	}
}

// https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-web
resource Web_sites_config__Web 'Microsoft.Web/sites/config@2024-04-01' = {
	name: 'web'
	parent: Web_sites_
	properties: {
		apiDefinition: {
			url: (!contains(
					properties,
					'apiDefinition'
				) || empty(properties.siteConfig.apiDefinition))
				? null
				: 'https://${Web_sites_.properties.defaultHostName}${properties.siteConfig.apiDefinition}'
		}
		cors: {
			allowedOrigins: properties.siteConfig.corsAllowedOrigins
		}
		defaultDocuments: []
		ftpsState: 'Disabled'
		functionAppScaleLimit: properties.siteConfig.functionAppScaleLimit
		healthCheckPath: properties.siteConfig.?healthCheckPath
		http20Enabled: properties.siteConfig.http20Enabled
		ipSecurityRestrictions: properties.siteConfig.ipSecurityRestrictions
		minTlsVersion: properties.siteConfig.minTlsVersion
		netFrameworkVersion: properties.siteConfig.netFrameworkVersion
		remoteDebuggingEnabled: properties.siteConfig.remoteDebuggingEnabled
		use32BitWorkerProcess: properties.siteConfig.use32BitWorkerProcess
	}
}

resource ManagedIdentity_identities_ 'Microsoft.ManagedIdentity/identities@2023-01-31' existing = {
	scope: Web_sites_
	name: 'default'
}

/* outputs */

output id string = Web_sites_.id

output identity object = union(
	Web_sites_.identity,
	{
		clientId: ManagedIdentity_identities_.?properties.?clientId
	}
)

output properties object = {
	defaultHostName: Web_sites_.properties.defaultHostName
}
