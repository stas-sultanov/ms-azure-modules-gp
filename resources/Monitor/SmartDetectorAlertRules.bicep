metadata author = {
	name: 'Stas Sultanov'
	urls: {
		gitHub: 'https://github.com/stas-sultanov'
		linkedIn: 'https://www.linkedin.com/in/stas-sultanov'
	}
}

/* parameters */

@description('Id of the Insights/actionGroups resource.')
param actionGroupId string

@description('Name of the Insights/components resource.')
param componentName string

@description('Common tags to put on the resource.')
param customWebhookPayload string = ''

@description('Location to deploy the resources.')
param location string

@description('A prefix to use to generate names of the resources.')
param namePrefix string

@description('Tags to put on the resource.')
param tags object = {}

/* variables */

var actionGroupInformation = {
	customWebhookPayload: empty(customWebhookPayload)
		? null
		: customWebhookPayload
	groupIds: [
		Insights_actionGroup_.id
	]
}

var insights_actionGroups__id_split = split(
	actionGroupId,
	'/'
)

/* existing resources */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: componentName
}

resource Insights_actionGroup_ 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
	name: insights_actionGroups__id_split[8]
	scope: resourceGroup(
		insights_actionGroups__id_split[2],
		insights_actionGroups__id_split[4]
	)
}

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
@description('Failure Anomalies')
resource alertsManagement_smartDetectorAlertRules_Anomalies 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: '${namePrefix}fa'
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual rise in the rate in failed HTTP requests or dependency calls.'
		detector: {
			id: 'FailureAnomaliesDetector'
		}
		frequency: 'PT1M'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: union(
		tags,
		{
			'hidden-title': 'failure anomalies'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
@description('Dependency Performance Degradation')
resource alertsManagement_smartDetectorAlertRules_DependencyPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: '${namePrefix}dpd'
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in dependencies requests processing time.'
		detector: {
			id: 'DependencyPerformanceDegradationDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: union(
		tags,
		{
			'hidden-title': 'dependency performance degradation'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
@description('Exception Volume Changed')
resource alertsManagement_smartDetectorAlertRules_ExceptionVolumeChangedDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: '${namePrefix}evc'
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in the rate of exceptions.'
		detector: {
			id: 'ExceptionVolumeChangedDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: union(
		tags,
		{
			'hidden-title': 'exception volume changed'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
@description('Memory Leak')
resource alertsManagement_smartDetectorAlertRules_MemoryLeakDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: '${namePrefix}ml'
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in memory consumption pattern.'
		detector: {
			id: 'MemoryLeakDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: union(
		tags,
		{
			'hidden-title': 'memory leak'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
@description('Request Performance Degradation')
resource alertsManagement_smartDetectorAlertRules_RequestPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: '${namePrefix}rpd'
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in requests processing time.'
		detector: {
			id: 'RequestPerformanceDegradationDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: union(
		tags,
		{
			'hidden-title': 'request performance degradation'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
@description('Trace Severity')
resource alertsManagement_smartDetectorAlertRules_TraceSeverityDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	location: 'global'
	name: '${namePrefix}ts'
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in the severity of the traces.'
		detector: {
			id: 'TraceSeverityDetector'
		}
		frequency: 'PT24H'
		scope: [
			Insights_components_.id
		]
		severity: 'Sev3'
		state: 'Enabled'
	}
	tags: union(
		tags,
		{
			'hidden-title': 'trace severity'
		}
	)
}

// https://learn.microsoft.com/azure/templates/microsoft.insights/components/proactivedetectionconfigs
#disable-next-line use-recent-api-versions
resource Insights_components_ProactiveDetectionConfig_MigrationToAlertRulesCompleted 'Microsoft.Insights/components/ProactiveDetectionConfigs@2018-05-01-preview' = {
	dependsOn: [
		alertsManagement_smartDetectorAlertRules_Anomalies
		alertsManagement_smartDetectorAlertRules_DependencyPerformanceDegradation
		alertsManagement_smartDetectorAlertRules_ExceptionVolumeChangedDetector
		alertsManagement_smartDetectorAlertRules_MemoryLeakDetector
		alertsManagement_smartDetectorAlertRules_RequestPerformanceDegradation
		alertsManagement_smartDetectorAlertRules_TraceSeverityDetector
	]
	location: location
	name: 'migrationToAlertRulesCompleted'
	parent: Insights_components_
	properties: {
		customEmails: []
		enabled: true
		ruleDefinitions: null
		sendEmailsToSubscriptionOwners: false
	}
}
