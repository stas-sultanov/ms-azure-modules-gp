/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

@description('The capacity mode for database operations.')
@allowed([
  'Static'
  'Autoscale'
  'Serverless'
])
param capacityMode string = 'Serverless'

@minValue(400)
@maxValue(5000)
@description('Request Units per second.')
param throughput int = 400

@minValue(4000)
@maxValue(10000)
@description('Maximal Request Units per second.')
param throughputMax int = 4000

@description('Id of the parent Cosmos account.')
param cosmosAccountId string

/* variables */

var extraTags = {
  displayName: 'Cosmos Database / ${name}'
  capacityMode: capacityMode
}

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

resource CosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-10-15' existing = {
  name: split(cosmosAccountId, '/')[8]
}

/* resources */ 

resource CosmosAccount_SqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-10-15' = {
  parent: CosmosAccount
  name: name
  location: location
  tags: union(tags, extraTags)
  properties: {
    resource: {
      id: name
    }
    options: options[capacityMode]
  }
}

/* outputs */
