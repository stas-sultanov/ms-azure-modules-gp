metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import { IpSecurityRestriction } from './../types.bicep'

/* types */

@export()
@description('dotNet Framework version.')
type DotNetVersion = 'v6.0' | 'v7.0' | 'v8.0'

@export()
@description('AppService parameters.')
type AppServiceParameters = {
	@description('true if Always On is enabled; otherwise, false')
	alwaysOn: bool

	@description('OpenApi definition path')
	apiDefinition: string?

	@description('true to enable client affinity; false to stop sending session affinity cookies, which route client requests in the same session to the same instance')
	clientAffinityEnabled: bool

	@description('List of origins that should be allowed to make cross-origin calls. Use "*" to allow all')
	corsAllowedOrigins: string[]

	@description('Maximum number of workers that a site can scale out to')
	@minValue(0)
	@maxValue(200)
	functionAppScaleLimit: int?

	@description('Allow clients to connect over http2.0')
	http20Enabled: bool

	@description('HttpsOnly: configures a web site to accept only https requests. Issues redirect for http requests')
	httpsOnly: bool

	@description('List of allowed IP addresses')
	ipSecurityRestrictions: IpSecurityRestriction[]

	@description('dotNet Framework version.')
	netFrameworkVersion: DotNetVersion

	@description('true if remote debugging is enabled; otherwise, false.')
	remoteDebuggingEnabled: bool

	@description('true to use 32-bit worker process; otherwise, false')
	use32BitWorkerProcess: bool

	@description('true if WebSocket is enabled; otherwise, false')
	webSocketsEnabled: bool
}
