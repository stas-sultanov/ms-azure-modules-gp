metadata author = {
  name: 'Stas Sultanov'
  profile: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

param name string

@description('Id of the Data Factory resource.')
param dataFactoryId string

@description('Id of the SQL Server resource.')
param sqlServerId string

@description('Id of the SQL Database resource.')
param sqlServerDatabaseId string

@description('The length of time (in seconds) to wait for a connection to the server before terminating the attempt and generating an error.')
@minValue(5)
@maxValue(60)
param connectionTimeout int = 30

/* existing resources */

resource DataFactory_Factory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: split(dataFactoryId, '/')[8]
}

resource Sql_Server 'Microsoft.Sql/servers@2022-08-01-preview' existing = {
  name: split(sqlServerId, '/')[8]
}

resource Sql_Server_Database 'Microsoft.Sql/servers/databases@2022-08-01-preview' existing = {
  name: split(sqlServerDatabaseId, '/')[10]
  parent: Sql_Server
}

/* resources */

// resource info:
// 
resource DataFactory_Factory_LinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: name
  parent: DataFactory_Factory
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: 'Integrated Security=False;Encrypt=True;Connection Timeout=${connectionTimeout};Data Source=${Sql_Server.properties.fullyQualifiedDomainName};Initial Catalog=${Sql_Server_Database.name}'
    }
  }
}
