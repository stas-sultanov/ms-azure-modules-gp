/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* scope */

targetScope = 'resourceGroup'

/* types */

type KeyValuePair = {
	key: string
	value: string
}

/* parameters */

@description('Collection of key-value pairs.')
param keyValuePairList KeyValuePair[]

@description('Name of the AppConfiguration/configurationStores resource.')
param storeName string

/* existing resources */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2024-05-01' existing = {
	name: storeName
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/keyvalues
resource AppConfiguration_configurationStores_keyValues_ 'Microsoft.AppConfiguration/configurationStores/keyValues@2024-05-01' = [
	for keyValuePair in keyValuePairList: {
		name: keyValuePair.key
		parent: AppConfiguration_configurationStores_
		properties: {
			value: keyValuePair.value
		}
	}
]
