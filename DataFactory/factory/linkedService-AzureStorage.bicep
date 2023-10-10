metadata author = {
  name: 'Stas Sultanov'
  profile: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Name of the resource.')
param name string

@description('Id of the Data Factory resource.')
param dataFactoryId string

@description('Id of the Storage resource.')
param storageAccountId string

/* existing resources */

resource Factory_DataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: split(dataFactoryId, '/')[8]
}

resource Storage_StorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: split(storageAccountId, '/')[8]
}

/* resources */

// resource info
// 
resource DataFactory_Factory_LinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: name
  parent: Factory_DataFactory
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      serviceEndpoint: Storage_StorageAccount.properties.primaryEndpoints.blob
      accountKind: Storage_StorageAccount.kind
    }
  }
}
