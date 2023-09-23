metadata author = {
  githubUrl: 'https://github.com/stas-sultanov'
  name: 'Stas Sultanov'
  profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

metadata resource_info = 'https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments'

/* types */

type Authorization = {
  description: string
  principal: PrincipalInfo
  role: RoleName
}

type PrincipalInfo = {
  id: string
  name: string?
  type: PrincipalType?
}

type PrincipalType = 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'

type RoleName = 'BlobDataContributor' | 'BlobDataReader'

/* parameters */

@description('Id of the Storage/storageAccounts resource.')
param Storage_storageAccounts__id string

@description('Collection of authorizations.')
param authorizationList Authorization[]

param name string

/* variables */

var roleId = {
  BlobDataContributor: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  BlobDataReader: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
}

var storage_StorageAccounts__id_split = split(Storage_storageAccounts__id, '/')

/* existing resources */

resource Storage_storageAccounts_ 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storage_StorageAccounts__id_split[8]
}

resource Storage_storageAccounts_blobServices_ 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  name: 'default'
  parent: Storage_storageAccounts_
}

/* resources */

// provision Container
// resource info:
// 
resource Storage_storageAccounts_blobServices_containers_ 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: name
  parent: Storage_storageAccounts_blobServices_
}

// provision Container authorizations
// resource info:
// 
resource Authorization_roleAssignments_ 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for authorization in authorizationList: {
  scope: Storage_storageAccounts_blobServices_containers_
  name: guid(subscription().id, Storage_storageAccounts_.id, name, authorization.role, authorization.principal.id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId[authorization.role])
    principalId: authorization.principal.id
    principalType: authorization.principal.type
    description: authorization.description
  }
}]
