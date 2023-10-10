metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}
/* imports */

import { AuthorizationPrincipalInfo } from './../types.bicep'

/* types */

type Authorization = {
	description: string?
	principal: AuthorizationPrincipalInfo
	role: AuthorizationRoleName
}

type AuthorizationRoleName = 'ApplicationInsightsComponentContributor' | 'ApplicationInsightsSnapshotDebugger' | 'MonitoringContributor' | 'MonitoringMetricsPublisher' | 'MonitoringReader' | 'WorkbookContributor' | 'WorkbookReader'

/* parameters */

@description('Id of the Insights/components resource.')
param Insights_components__id string

@description('Collection of authorizations.')
param authorizationList Authorization[]

/* variables */

var roleId = {
	ApplicationInsightsComponentContributor: 'ae349356-3a1b-4a5e-921d-050484c6347e'	// Can manage Application Insights components.
	ApplicationInsightsSnapshotDebugger: '08954f03-6346-4c2e-81c0-ec3a5cfae23b'		// Gives user permission to view and download debug snapshots collected with the Application Insights Snapshot Debugger.
	MonitoringContributor: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'					// Can read all monitoring data and edit monitoring settings.
	MonitoringMetricsPublisher: '3913510d-42f4-4e42-8a64-420c390055eb'				// Enables publishing metrics against Azure resources.
	MonitoringReader: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'						// Can read all monitoring data.
	WorkbookContributor: 'e8ddcd69-c73f-4f9f-9844-4100522f16ad'						// Can save shared workbooks.
	WorkbookReader: 'b279062a-9be3-42a0-92ae-8b3cf002ec4d'							// Can read workbooks.
}

var insights_components__id_split = split(Insights_components__id, '/')

/* existing resources */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: insights_components__id_split[8]
}

/* resources */

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
for authorization in authorizationList: {
	scope: Insights_components_
	name: guid(Insights_components_.id, roleId[authorization.role], authorization.principal.id)
	properties: {
		roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId[authorization.role])
		principalId: authorization.principal.id
		principalType: authorization.principal.type
		description: (!contains(authorization, 'description') || empty(authorization.description)) 
		 ? '${authorization.role} role for ${(!contains(authorization.principal, 'name') || empty(authorization.principal.name)) ? authorization.principal.id : authorization.principal.name}.' 
		 : authorization.description
	}
}
]
