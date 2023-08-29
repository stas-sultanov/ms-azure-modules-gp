metadata author = 'Stas Sultanov'
metadata author_profile = 'https://www.linkedin.com/in/stas-sultanov'

/* parameters */

@description('Name of the resource.')
param name string

@description('Tags to put on the resource.')
param tags object

@description('Default action group name.')
param groupName string

@description('Collection of email address to send alerts.')
param emailList array

@description('Collection of web hooks to send alerts.')
param webhookList array

/* variables */

var extraTags = {
  displayName: name
}

var emailReceivers = [for email in emailList: {
  name: email.Name
  emailAddress: email.EmailAddress
  useCommonAlertSchema: true
}]

var webhookReceivers = [for webhook in webhookList: {
  name: webhook.Name
  serviceUri: webhook.ServiceUri
  useCommonAlertSchema: true
}]

/* resources */

resource Insights_ActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: name
  location: 'global'
  tags: union(tags, extraTags)
  properties: {
    groupShortName: groupName
    enabled: true
    emailReceivers: emailReceivers
    webhookReceivers: webhookReceivers
    armRoleReceivers: [
      {
        name: 'Monitoring Contributor'
        roleId: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        useCommonAlertSchema: true
      }
      {
        name: 'Monitoring Reader'
        roleId: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        useCommonAlertSchema: true
      }
    ]
  }
}

/* outputs */

output id string = Insights_ActionGroup.id
