/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__name string

@description('Collection of the principals.')
param principals array

@description('The unique identifier for the associated Role Definition.')
param roleDefinitionId string

/* existing resources */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
  name: DocumentDB_databaseAccounts__name
}

/* resources */

@batchSize(1)
resource CosmosAccount_SqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-09-15' = [
for principal in principals: {
  name: guid(subscription().id, DocumentDB_databaseAccounts_.id, roleDefinitionId, principal.Id)
  parent: DocumentDB_databaseAccounts_
  properties: {
    principalId: principal.Id
    roleDefinitionId: roleDefinitionId
    scope: DocumentDB_databaseAccounts_.id
  }
}]
