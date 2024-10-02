/* Copyright © 2024 Stas Sultanov */

metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

/* imports */

import {
	PowerPlatformLocation
} from './types.bicep'

/* parameters */

param location PowerPlatformLocation

@description('Name of the resource.')
param name string

@description('List of Id of the Microsoft.Network/virtualNetworks/subnets resource. Must be minimum 2.')
@minLength(2)
param subnetIdList string[]

@description('Tags to put on the resource.')
param tags object

/* variables */

var subnetIdSplitList = [
	for subnetId in subnetIdList: split(
		subnetId,
		'/'
	)
]

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.powerplatform/enterprisepolicies
#disable-next-line BCP081
resource PowerPlatform_enterprisePolicies_ 'Microsoft.PowerPlatform/enterprisePolicies@2020-10-30' = {
	kind: 'NetworkInjection'
	location: location
	name: name
	properties: {
		networkInjection: {
			virtualNetworks: [
				for subnetIdSplit in subnetIdSplitList: {
					id: resourceId(
						subnetIdSplit[2],
						subnetIdSplit[4],
						'Microsoft.Network/virtualNetworks',
						subnetIdSplit[8]
					)
					subnet: {
						name: subnetIdSplit[10]
					}
				}
			]
		}
	}
	tags: tags
}

/* outputs */

output id string = PowerPlatform_enterprisePolicies_.id
