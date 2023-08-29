metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

/* variables */

var extraTags = {
  displayName: name
}

/* resources */

resource Storage_StorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  location: location
  tags: union(tags, extraTags)
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
}

/* outputs */

output id string = Storage_StorageAccount.id

output primaryEndpointBlob string = Storage_StorageAccount.properties.primaryEndpoints.blob 
