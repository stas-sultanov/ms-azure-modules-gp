/* parameters */

@description('Name of the resource.')
param name string

@description('Id of the parent Cosmos account.')
param cosmosAccountId string

/* variables */

/* existing resources */

resource CosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' existing = {
  name: split(cosmosAccountId, '/')[8]
}

/* resources */

resource CosmosAccount_SqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-10-15' = {
  parent: CosmosAccount
  name: guid(CosmosAccount.id, name)
  properties: {
    assignableScopes: [
      CosmosAccount.id
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

/* outputs */
