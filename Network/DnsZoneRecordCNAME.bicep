metadata author = {
  name: 'Stas Sultanov'
  profile: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Name of the resource.')
param name string

@description('The time to live of the record.')
param ttl int = 3600

@description('Value of the record.')
param value string

@description('Id of the Network/dnsZore resource.')
param dnsZoneId string

/* variables */

var dnsZoneId_split = split(dnsZoneId, '/')

/* existing resources */

resource Network_DnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: dnsZoneId_split[8]
}

/* resources */

resource Network_DnsZone_CNAME 'Microsoft.Network/dnsZones/CNAME@2023-07-01-preview' = {
  parent: Network_DnsZone
  name: name
  properties: {
    TTL: ttl
    CNAMERecord: {
      cname: value
    }
  }
}

/* outputs */

output id string = Network_DnsZone_CNAME.id
