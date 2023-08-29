metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Location to deploy the resource.')
param location string = resourceGroup().location

@description('Tags to put on the resource.')
param tags object

@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('Name of the resource group.')
param managedResourceGroupName string

@description('Id of the OperationalInsights/Workspace resource.')
param operationalInsightsWorkspaceId string

/* variables */

var extraTags = {
  displayName: name
}

var operationalInsightsWorkspaceId_split = split(operationalInsightsWorkspaceId, '/')

/* existing resources */

resource OperationalInsights_Workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: operationalInsightsWorkspaceId_split[8]
  scope: resourceGroup(operationalInsightsWorkspaceId_split[4])
}

resource Resources_ResourceGroup_Managed 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  scope: subscription()
  name: managedResourceGroupName
}

/* resources */

resource Databricks_Workspace 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: name
  location: location
  tags: union(tags, extraTags)
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: Resources_ResourceGroup_Managed.id
    parameters: {
      enableNoPublicIp: {
        value: false
      }
    }
  }
}

resource Insights_DiagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: Databricks_Workspace
  name: 'Log Analytics'
  properties: {
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    workspaceId: OperationalInsights_Workspace.id
  }
}

/* outputs */
output id string = Databricks_Workspace.id
