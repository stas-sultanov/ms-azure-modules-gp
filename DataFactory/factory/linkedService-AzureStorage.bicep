/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Name of the DataFactory/factories resource.')
param DataFactory_factories__name string

@description('Id of the Storage/storageAccounts resource.')
param Storage_storageAccounts__id string

@description('Name of the credential to use for authentiaction and authorization.')
param credentialName string

@description('Name of the resource.')
param name string

/* variables */

var storage_storageAccounts__Id_split = split(Storage_storageAccounts__id, '/')

/* existing resources */

resource DataFactory_factories_ 'Microsoft.DataFactory/factories@2018-06-01' existing = {
	name: DataFactory_factories__name
}

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
	name: storage_storageAccounts__Id_split[8]
	scope: resourceGroup(storage_storageAccounts__Id_split[2], storage_storageAccounts__Id_split[4])
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.datafactory/factories/linkedservices
resource DataFactory_factories_linkedService_ 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
	name: name
	parent: DataFactory_factories_
	properties: {
		type: 'AzureBlobStorage'
		typeProperties: {
			accountKind: Storage_storageAccounts_.kind
			credential: {
				referenceName: credentialName
				type: 'CredentialReference'
			}
			serviceEndpoint: Storage_storageAccounts_.properties.primaryEndpoints.blob
		}
	}
}
