/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the Cosmos Account resource.')
param cosmosAccountId string

@description('Collection of the principals.')
param principals array

@description('The unique identifier for the associated Role Definition.')
param roleDefinitionId string

/* variables */

/* existing resources */

resource CosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: split(cosmosAccountId, '/')[8]
}

/* resources */

@batchSize(1)
resource CosmosAccount_SqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-09-15' = [
for principal in principals: {
  name: guid(
    subscription().id,
    CosmosAccount.id,
    roleDefinitionId,
    principal.Id
  )
  parent: CosmosAccount
  properties: {
    principalId: principal.Id
    roleDefinitionId: roleDefinitionId
    scope: CosmosAccount.id
  }
}]
