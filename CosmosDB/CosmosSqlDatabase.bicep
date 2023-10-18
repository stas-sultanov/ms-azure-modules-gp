/* parameters */

@description('Id of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__id string

@description('The capacity mode for database operations.')
@allowed([
	'Static'
	'Autoscale'
	'Serverless'
])
param capacityMode string = 'Serverless'

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

@minValue(400)
@maxValue(5000)
@description('Request Units per second.')
param throughput int = 400

@minValue(4000)
@maxValue(10000)
@description('Maximal Request Units per second.')
param throughputMax int = 4000

/* variables */

var documentDB_databaseAccounts__id_split = split(DocumentDB_databaseAccounts__id, '/')

var options = {
	Static: {
		throughput: throughput
	}
	Autoscale: {
		autoscaleSettings: {
			maxThroughput: throughputMax
		}
	}
	Serverless: {}
}

/* existing resources */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
	name: documentDB_databaseAccounts__id_split[8]
	// scope: resourceGroup(documentDB_databaseAccounts__id_split[4])
}

/* resources */

resource DocumentDB_databaseAccounts_sqlDatabases_ 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
	parent: DocumentDB_databaseAccounts_
	name: name
	location: location
	tags: union(tags, { capacityMode: capacityMode })
	properties: {
		resource: {
			id: name
		}
		options: options[capacityMode]
	}
}

/* outputs */
