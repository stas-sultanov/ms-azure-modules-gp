metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

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

resource Network_DnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' = {
  name: name
  location: 'global'
  tags: union(tags, extraTags)
  properties: {
    zoneType: 'Public'
  }
}

/* outputs */

output id string = Network_DnsZone.id

output nameServers array = Network_DnsZone.properties.nameServers
