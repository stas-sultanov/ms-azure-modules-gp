/* parameters */

@description('Id of the parent Cosmos account.')
param cosmosAccountId string

@description('Name of the resource.')
param name string

/* variables */

/* existing resources */

resource CosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: split(cosmosAccountId, '/')[8]
}

/* resources */

resource CosmosAccount_SqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2023-09-15' = {
  name: guid(
    subscription().id,
    CosmosAccount.id,
    name
  )
  parent: CosmosAccount
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
