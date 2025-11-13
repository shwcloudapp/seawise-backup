{{/*
Expand the name of the chart.
*/}}
{{- define "seawise-dashboard.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "seawise-dashboard.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "seawise-dashboard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "seawise-dashboard.labels" -}}
helm.sh/chart: {{ include "seawise-dashboard.chart" . }}
{{ include "seawise-dashboard.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "seawise-dashboard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "seawise-dashboard.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "seawise-dashboard.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "seawise-dashboard.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "seawise-dashboard.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
*/}}
{{- define "seawise-dashboard.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}

{{/*
Return the namespace
*/}}
{{- define "seawise-dashboard.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{/*
Return the PVC name
*/}}
{{- define "seawise-dashboard.pvcName" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- printf "%s-pvc" (include "seawise-dashboard.fullname" .) }}
{{- end }}
{{- end }}
