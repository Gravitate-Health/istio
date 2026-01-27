{{/*
Expand the name of the chart.
*/}}
{{- define "istio-gravitatehealth.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "istio-gravitatehealth.fullname" -}}
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
{{- define "istio-gravitatehealth.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "istio-gravitatehealth.labels" -}}
helm.sh/chart: {{ include "istio-gravitatehealth.chart" . }}
{{ include "istio-gravitatehealth.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "istio-gravitatehealth.selectorLabels" -}}
app.kubernetes.io/name: {{ include "istio-gravitatehealth.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Gateway hosts
*/}}
{{- define "istio-gravitatehealth.hosts" -}}
{{- if .Values.gateway.useIP }}
{{- print "*" }}
{{- else }}
{{- join "," .Values.gateway.hosts }}
{{- end }}
{{- end }}

{{/*
Certificate DNS names
*/}}
{{- define "istio-gravitatehealth.certificateDnsNames" -}}
{{- toYaml .Values.certManager.certificate.dnsNames }}
{{- end }}

{{/*
Istio operator name
*/}}
{{- define "istio-gravitatehealth.operatorName" -}}
{{- printf "%s-operator" (include "istio-gravitatehealth.fullname" .) }}
{{- end }}
