metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__name string

@description('Name of the resource.')
param name string

/* existing resources */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' existing = {
	name: DocumentDB_databaseAccounts__name
}

/* resources */

resource CosmosAccount_SqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-11-15' = {
	name: guid(
		subscription().id,
		DocumentDB_databaseAccounts_.id,
		name
	)
	parent: DocumentDB_databaseAccounts_
	properties: {
		assignableScopes: [
			DocumentDB_databaseAccounts_.id
		]
		permissions: [
			{
				dataActions: [
					'Microsoft.DocumentDB/databaseAccounts/readMetadata'
					'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
					'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
				]
				notDataActions: []
			}
		]
		roleName: name
		type: 'CustomRole'
	}
}
