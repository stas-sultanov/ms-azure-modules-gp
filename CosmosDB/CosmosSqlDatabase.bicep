/* Copyright © 2023 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__id string

@description('The capacity mode for database operations.')
@allowed([
	'Autoscale'
	'Serverless'
	'Static'
])
param capacityMode string = 'Serverless'

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Name of the resource.')
param name string

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
	Autoscale: {
		autoscaleSettings: {
			maxThroughput: throughputMax
		}
	}
	Serverless: {}
	Static: {
		throughput: throughput
	}
}

/* existing resources */

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' existing = {
	name: documentDB_databaseAccounts__id_split[8]
	// scope: resourceGroup(documentDB_databaseAccounts__id_split[4])
}

/* resources */

resource DocumentDB_databaseAccounts_sqlDatabases_ 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
	location: location
	name: name
	parent: DocumentDB_databaseAccounts_
	properties: {
		options: options[capacityMode]
		resource: {
			id: name
		}
	}
	tags: union(
		tags,
		{
			capacityMode: capacityMode
		}
	)
}

/* outputs */
