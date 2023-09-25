/* parameters */

@description('Id of the Cosmos Account resource.')
param cosmosAccountId string

@description('The unique identifier for the associated Role Definition.')
param roleDefinitionId string

@description('Collection of the principals.')
param principals array

/* variables */

/* existing resources */

resource CosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' existing = {
  name: split(cosmosAccountId, '/')[8]
}

/* resources */

@batchSize(1)
resource CosmosAccount_SqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-11-15-preview' = [for principal in principals: {
  parent: CosmosAccount
  name: guid(CosmosAccount.id, roleDefinitionId, principal.Id)
  properties: {
    principalId: principal.Id
    roleDefinitionId: roleDefinitionId
    scope: CosmosAccount.id
  }
}]
