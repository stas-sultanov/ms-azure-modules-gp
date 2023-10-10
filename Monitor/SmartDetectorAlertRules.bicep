metadata author = {
	githubUrl: 'https://github.com/stas-sultanov'
	name: 'Stas Sultanov'
	profileUrl: 'https://www.linkedin.com/in/stas-sultanov'
}

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

var actionGroupInformation = {
	customWebhookPayload: empty(customWebhookPayload) ? null : customWebhookPayload
	groupIds: [ Insights_actionGroup_.id ]
}

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

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_AnomaliesAlert 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-FailureAnomaliesDetector'
	location: 'global'
	tags: tags
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual rise in the rate in failed HTTP requests or dependency calls.'
		detector: {
			id: 'FailureAnomaliesDetector'
		}
		frequency: 'PT1M'
		scope: [ Insights_components_.id ]
		severity: 'Sev3'
		state: 'Enabled'
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules 
resource alertsManagement_smartDetectorAlertRules_RequestPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-RequestPerformanceDegradationDetector'
	location: 'global'
	tags: tags
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in requests processing time.'
		detector: {
			id: 'RequestPerformanceDegradationDetector'
		}
		frequency: 'PT24H'
		scope: [ Insights_components_.id ]
		severity: 'Sev3'
		state: 'Enabled'
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_DependencyPerformanceDegradation 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-DependencyPerformanceDegradationDetector'
	location: 'global'
	tags: tags
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in dependencies requests processing time.'
		detector: {
			id: 'DependencyPerformanceDegradationDetector'
		}
		frequency: 'PT24H'
		scope: [ Insights_components_.id ]
		severity: 'Sev3'
		state: 'Enabled'
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_TraceSeverityDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-TraceSeverityDetector'
	location: 'global'
	tags: tags
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in the severity of the traces.'
		detector: {
			id: 'TraceSeverityDetector'
		}
		frequency: 'PT24H'
		scope: [ Insights_components_.id ]
		severity: 'Sev3'
		state: 'Enabled'
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_ExceptionVolumeChangedDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-ExceptionVolumeChangedDetector'
	location: 'global'
	tags: tags
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in the rate of exceptions.'
		detector: {
			id: 'ExceptionVolumeChangedDetector'
		}
		frequency: 'PT24H'
		scope: [ Insights_components_.id ]
		severity: 'Sev3'
		state: 'Enabled'
	}
}

// resource info
// https://learn.microsoft.com/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules
resource alertsManagement_smartDetectorAlertRules_MemoryLeakDetector 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
	name: '${baseName}-MemoryLeakDetector'
	location: 'global'
	tags: tags
	properties: {
		actionGroups: actionGroupInformation
		description: 'Detects an unusual increase in memory consumption pattern.'
		detector: {
			id: 'MemoryLeakDetector'
		}
		frequency: 'PT24H'
		scope: [ Insights_components_.id ]
		severity: 'Sev3'
		state: 'Enabled'
	}
}
