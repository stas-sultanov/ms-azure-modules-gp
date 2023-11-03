metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}
metadata copyright = '2023 Stas Sultanov'
metadata license = 'MIT'

/* parameters */

@description('Id of the Cdn/profiles resource.')
param Cdn_profiles__id string

@description('Name of the resource.')
param name string

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var cdn_profiles__id_split = split(Cdn_profiles__id, '/')

/* existing resources */

resource Cdn_profiles_ 'Microsoft.Cdn/profiles@2023-07-01-preview' existing = {
	name: cdn_profiles__id_split[8]
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/afdendpoints
resource Cdn_profiles_adfEndpoints_ 'Microsoft.Cdn/profiles/afdEndpoints@2023-07-01-preview' = {
	location: 'global'
	name: name
	parent: Cdn_profiles_
	properties: {
	}
	tags: tags
}
