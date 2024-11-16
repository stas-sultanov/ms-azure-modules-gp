metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Name of the OperationalInsights/Workspace resource.')
param workspaceName string

@description('Id of the Storage/storageAccounts resource.')
param storageAccountId string

/* variables */

var storage_StorageAccounts__id_split = split(
	storageAccountId,
	'/'
)

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
	name: storage_StorageAccounts__id_split[8]
	scope: resourceGroup(
		storage_StorageAccounts__id_split[2],
		storage_StorageAccounts__id_split[4]
	)
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces
resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
	name: workspaceName
}

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: 'Storage'
	properties: {
		storageAccountId: Storage_storageAccounts_.id
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
	}
	scope: OperationalInsights_workspaces_
}
