metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* imports */

import {
	RoleAssignment
	ConvertToRoleAssignmentProperties
} from 'common.bicep'

/* parameters */

@description('Collection of roles assignments.')
param assignments RoleAssignment[]

@description('Name of the Microsoft.ContainerRegistry/registries resource.')
param name string

/* variables */

var roleIdDictionary = {
	'Container Registry Cache Rule Administrator': 'df87f177-bb12-4db1-9793-a413691eff94'
	'Container Registry Cache Rule Reader': 'c357b964-0002-4b64-a50d-7a28f02edc52'
	'Container Registry Configuration Reader and Data Access Configuration Reader': '69b07be0-09bf-439a-b9a6-e73de851bd59'
	'Container Registry Contributor and Data Access Configuration Administrator': '3bc748fc-213d-45c1-8d91-9da5725539b9'
	'Container Registry Credential Set Administrator': 'f094fb07-0703-4400-ad6a-e16dd8000e14'
	'Container Registry Credential Set Reader': '29093635-9924-4f2c-913b-650a12949526'
	'Container Registry Data Importer and Data Reader': '577a9874-89fd-4f24-9dbd-b5034d0ad23a'
	'Container Registry Repository Catalog Lister': 'bfdb9389-c9a5-478a-bb2f-ba9ca092c3c7'
	'Container Registry Repository Contributor': '2efddaa5-3f1f-4df3-97df-af3f13818f4c'
	'Container Registry Repository Reader': 'b93aa761-3e63-49ed-ac28-beffa264f7ac'
	'Container Registry Repository Writer': '2a1e307c-b015-4ebd-883e-5b7698a07328'
	'Container Registry Tasks Contributor': 'fb382eab-e894-4461-af04-94435c366c3f'
	'Container Registry Transfer Pipeline Contributor': 'bf94e731-3a51-4a7c-8c54-a1ab9971dfc1'
}

/* existing resources */

resource ContainerRegistry_registries_ 'Microsoft.ContainerRegistry/registries@2025-04-01' existing = {
	name: name
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.authorization/roleassignments
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
	for roleAssignment in ConvertToRoleAssignmentProperties(
		assignments,
		roleIdDictionary
	): {
		name: guid(
			ContainerRegistry_registries_.id,
			roleAssignment.principalId,
			roleAssignment.roleDefinitionId
		)
		properties: roleAssignment
		scope: ContainerRegistry_registries_
	}
]
