metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

metadata resource_info = 'https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules'

/* parameters */

@description('Id of the Insights/actionGroups resource.')
param Insights_actionGroups__id string

@description('Id of the Insights/components resource.')
param Insights_components__id string

@description('A base to generate names of the resources.')
param baseName string

@description('Common tags to put on the resource.')
param customWebhookPayload string = ''

@description('Common tags to put on the resource.')
param tags object = {}

/* variables */

var insights_actionGroups__id_split = split(Insights_actionGroups__id, '/')

var insights_components__id_split = split(Insights_components__id, '/')

/* existing resources */

resource Insights_components_ 'Microsoft.Insights/components@2020-02-02' existing = {
	name: insights_components__id_split[8]
	scope: resourceGroup(insights_components__id_split[4])
}

resource Insights_actionGroup_ 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
	name: insights_actionGroups__id_split[8]
	scope: resourceGroup(insights_actionGroups__id_split[4])
}

/* resources */

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_AnomaliesAlert 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-FailureAnomaliesDetector'
	location: 'global'
	tags: tags
	properties: {
		actionGroups: {
			customWebhookPayload: empty(customWebhookPayload) 
			 ? null 
			 : customWebhookPayload
			groupIds: [ Insights_actionGroup_.id ]
		}
		frequency: 'PT1M'
		description: 'Detects an unusual rise in the rate in failed HTTP requests or dependency calls.'
		detector: {
			id: 'FailureAnomaliesDetector'
		}
		scope: [ Insights_components_.id ]
		severity: 'Sev3'
		state: 'Enabled'
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules 
resource alertsManagement_smartDetectorAlertRules_RequestPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-RequestPerformanceDegradationDetector'
	location: 'global'
	tags: tags
	properties: {
		description: 'Detects an unusual increase in requests processing time.'
		state: 'Enabled'
		severity: 'Sev3'
		frequency: 'PT24H'
		detector: {
			id: 'RequestPerformanceDegradationDetector'
		}
		scope: [ Insights_components_.id ]
		actionGroups: {
			customWebhookPayload: empty(customWebhookPayload) 
			 ? null 
			 : customWebhookPayload
			groupIds: [ Insights_actionGroup_.id ]
		}
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_DependencyPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-DependencyPerformanceDegradationDetector'
	location: 'global'
	tags: tags
	properties: {
		description: 'Detects an unusual increase in dependencies requests processing time.'
		state: 'Enabled'
		severity: 'Sev3'
		frequency: 'PT24H'
		detector: {
			id: 'DependencyPerformanceDegradationDetector'
		}
		scope: [ Insights_components_.id ]
		actionGroups: {
			customWebhookPayload: empty(customWebhookPayload) 
			 ? null 
			 : customWebhookPayload
			groupIds: [ Insights_actionGroup_.id ]
		}
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_TraceSeverityDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-TraceSeverityDetector'
	location: 'global'
	tags: tags
	properties: {
		description: 'Detects an unusual increase in the severity of the traces.'
		state: 'Enabled'
		severity: 'Sev3'
		frequency: 'PT24H'
		detector: {
			id: 'TraceSeverityDetector'
		}
		scope: [ Insights_components_.id ]
		actionGroups: {
			customWebhookPayload: empty(customWebhookPayload) 
			 ? null 
			 : customWebhookPayload
			groupIds: [ Insights_actionGroup_.id ]
		}
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_ExceptionVolumeChangedDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-ExceptionVolumeChangedDetector'
	location: 'global'
	tags: tags
	properties: {
		description: 'Detects an unusual increase in the rate of exceptions.'
		state: 'Enabled'
		severity: 'Sev3'
		frequency: 'PT24H'
		detector: {
			id: 'ExceptionVolumeChangedDetector'
		}
		scope: [ Insights_components_.id ]
		actionGroups: {
			groupIds: [ Insights_actionGroup_.id ]
		}
	}
}

// resource info:
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_MemoryLeakDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-MemoryLeakDetector'
	location: 'global'
	tags: tags
	properties: {
		description: 'Detects an unusual increase in memory consumption pattern.'
		state: 'Enabled'
		severity: 'Sev3'
		frequency: 'PT24H'
		detector: {
			id: 'MemoryLeakDetector'
		}
		scope: [ Insights_components_.id ]
		actionGroups: {
			customWebhookPayload: empty(customWebhookPayload) 
			 ? null 
			 : customWebhookPayload
			groupIds: [ Insights_actionGroup_.id ]
		}
	}
}
