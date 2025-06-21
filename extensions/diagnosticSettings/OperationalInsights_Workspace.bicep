metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Name of the Microsoft.OperationalInsights/Workspace resource.')
param name string

@description('Id of the Microsoft.Storage/storageAccounts resource.')
param storageAccountId string

/* variables */

var storage_StorageAccounts__id_split = split(
	storageAccountId,
	'/'
)

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
	name: storage_StorageAccounts__id_split[8]
	scope: resourceGroup(
		storage_StorageAccounts__id_split[2],
		storage_StorageAccounts__id_split[4]
	)
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces
resource OperationalInsights_workspaces_ 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
	name: name
}

// https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings
#disable-next-line use-recent-api-versions
resource Insights_diagnosticSettings_ 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
	name: Storage_storageAccounts_.name
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
