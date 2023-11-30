/* Copyright © 2023 Stas Sultanov */

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

@description('Name of the AppConfiguration/configurationStores resource.')
param AppConfiguration_configurationStores__name string

@description('Collection of key-value pairs.')
param keyValuePairList KeyValuePair[]

/* existing resources */

resource AppConfiguration_configurationStores_ 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
	name: AppConfiguration_configurationStores__name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/keyvalues
resource AppConfiguration_configurationStores_keyValues_ 'Microsoft.AppConfiguration/configurationStores/keyValues@2023-03-01' = [
for keyValuePair in keyValuePairList: {
	name: keyValuePair.key
	parent: AppConfiguration_configurationStores_
	properties: {
		value: keyValuePair.value
	}
}
]
