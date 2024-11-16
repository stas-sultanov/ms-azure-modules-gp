metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* imports */

import {
	ManagedIdentity
} from './../../common.bicep'

/* types */

type AzureDevOpsRepoConfiguration = {
	@description('Name of the Azure DevOps Organization.')
	organizationName: string

	@description('Name of the Project within the Azure DevOps Organization.')
	projectName: string

	@description('Name of the Repo within the Azure DevOps Project.')
	repositoryName: string

	@description('Folder within the Repository.')
	rootFolder: string
}

/* parameters */

@description('Managed Service Identity.')
param identity ManagedIdentity

@description('Location to deploy the resources.')
param location string

@description('Name of the resource.')
param name string

@description('Repository configuration.')
param repoConfiguration AzureDevOpsRepoConfiguration

@description('Tags to put on the resource.')
param tags object

@description('Id of the OperationalInsights/workspaces resource.')
param workspaceId string

/* variables */

var operationalInsights_workspaces__id_split = split(
	workspaceId,
	'/'
)

/* existing resources */

resource OperationalInsights_Workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(
		operationalInsights_workspaces__id_split[2],
		operationalInsights_workspaces__id_split[4]
	)
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.datafactory/factories
resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' = {
	identity: identity
	location: location
	name: name
	properties: {
		#disable-next-line BCP078
		repoConfiguration: (repoConfiguration == null)
			? {}
			: {
					accountName: repoConfiguration.organizationName
					collaborationBranch: 'main'
					disablePublish: true
					projectName: repoConfiguration.projectName
					repositoryName: repoConfiguration.repositoryName
					rootFolder: repoConfiguration.rootFolder
					type: 'FactoryVSTSConfiguration'
				}
	}
	tags: tags
}

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
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
				enabled: true
				timeGrain: 'PT1M'
			}
		]
		workspaceId: OperationalInsights_Workspace.id
	}
	scope: DataFactory_factories_
}

/* outputs */

output identity object = DataFactory_factories_.identity

output name string = DataFactory_factories_.name
