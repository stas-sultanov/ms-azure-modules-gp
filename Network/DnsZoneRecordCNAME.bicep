/* Copyright © 2023 Stas Sultanov */

metadata author = {
  githubUrl: 'https://github.com/stas-sultanov'
  name: 'Stas Sultanov'
  profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* parameters */

@description('Id of the Network/dnsZone resource.')
param Network_dnsZone__id string

@description('Name of the resource.')
param name string

@description('The time to live of the record.')
param ttl int = 3600

@description('Value of the record.')
param value string

/* variables */

var dnsZoneId_split = split(Network_dnsZone__id, '/')

/* existing resources */

resource Network_DnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: dnsZoneId_split[8]
}

/* resources */

resource Network_DnsZone_CNAME 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: name
  parent: Network_DnsZone
  properties: {
    CNAMERecord: {
      cname: value
    }
    TTL: ttl
  }
}

/* outputs */

output id string = Network_DnsZone_CNAME.id
