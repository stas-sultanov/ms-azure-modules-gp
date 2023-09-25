metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import{ResourceIdentity}from'./../types.bicep'

/* types */

type AzureDevOpsRepoConfiguration = {
	@description('Name of the Azure DevOps Organisation.')
	organisationName: string

	@description('Name of the Project within the Azure DevOps Organisation.')
	projectName: string

	@description('Name of the Repo within the Azure DevOps Project.')
	repositoryName: string

	@description('Folder within the Repository.')
	rootFolder: string
}

/* parameters */

@description('Id of the OperationalInsights/workspaces resource.')
param OperationalInsights_workspaces__id string

@description('EntraID Identity of the resource.')
param identity ResourceIdentity

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

@description('Repository configuration.')
param repoConfiguration AzureDevOpsRepoConfiguration

@description('Tags to put on the resource.')
param tags object

/* variables */

var operationalInsights_workspaces__id_split = split(
	OperationalInsights_workspaces__id,
	'/'
)

/* existing resources */

resource OperationalInsights_Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: operationalInsights_workspaces__id_split[8]
	scope: resourceGroup(operationalInsights_workspaces__id_split[4])
}

/* resources */

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.datafactory/factories
resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' = {
	name: name
	location: location
	tags: tags
	identity: identity
	properties: {
		repoConfiguration: (repoConfiguration == null) 
		 ? {} 
		 : {
			accountName: repoConfiguration.organisationName
			collaborationBranch: 'main'
			disablePublish: true
			projectName: repoConfiguration.projectName
			repositoryName: repoConfiguration.repositoryName
			rootFolder: repoConfiguration.rootFolder
			type: 'FactoryVSTSConfiguration'
		}
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
resource Insighs_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	scope: DataFactory_factories_
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
		workspaceId: OperationalInsights_Workspace.id
	}
}

/* outputs */

output resourceId string = DataFactory_factories_.id

output identity object = DataFactory_factories_.identity
