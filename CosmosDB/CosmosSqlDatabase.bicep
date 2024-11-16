/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Name of the Microsoft.DocumentDB/databaseAccounts resource.')
param DocumentDB_databaseAccounts__name string

@description('The capacity mode for database operations.')
@allowed([
	'Autoscale'
	'Serverless'
	'Static'
])
param capacityMode string = 'Serverless'

@description('Location to deploy the resources.')
param location string

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

resource DocumentDB_databaseAccounts_ 'Microsoft.DocumentDB/databaseAccounts@2024-08-15' existing = {
	name: DocumentDB_databaseAccounts__name
}

/* resources */

resource DocumentDB_databaseAccounts_sqlDatabases_ 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-08-15' = {
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
