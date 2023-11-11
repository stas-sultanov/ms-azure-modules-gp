/* Copyright © 2023 Stas Sultanov */

metadata author = {
  githubUrl: 'https://github.com/stas-sultanov'
  name: 'Stas Sultanov'
  profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Name of the resource.')
param name string

@description('Tags to put on the resource.')
param tags object

/* variables */

var extraTags = {
  displayName: name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.network/dnszones
resource Network_DnsZones_ 'Microsoft.Network/dnsZones@2023-07-01-preview' = {
  name: name
  location: 'global'
  tags: union(tags, extraTags)
  properties: {
    zoneType: 'Public'
  }
}

/* outputs */

output id string = Network_DnsZones_.id

output nameServers array = Network_DnsZones_.properties.nameServers
