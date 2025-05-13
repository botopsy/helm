{{/*
Define the name of the chart/application.

As max lenght of resources in kubernetes is limited to 63 chars:
we should use only 21 chars in name;
up 32 chars more we expected for release name;
and 10 chars is left to use as sufixes;
*/}}

{{- define "application.name" -}}
    {{- default .Chart.Name .Values.applicationName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* 
Application Images. 
*/}}

{{- define "application.image" -}}
    {{- $repo := .Values.deployment.image.repository -}}
    {{- $tag := default .Chart.AppVersion .Values.deployment.image.tag -}}
    {{- printf "%s:%s" $repo $tag -}}
{{- end -}}

{{/* 
Application Image Pull Credentials. 
*/}}

{{- define "application.imagePullSecret" -}}
{{- with .Values.deployment.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}

{{- define "application.serviceAccount" -}}
    {{ default (include "application.name" .) .Values.serviceAccount.name }}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "application.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}

{{- define "application.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}

{{- define "application.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "application.selectorLabels" -}}
app: {{ include "application.name" . }}
release: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}

{{- define "application.labels" -}}
app.kubernetes.io/name: {{ include "application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/part-of: {{ include "application.name" . }}
helm.sh/chart: {{ include "application.chart" . }}
{{ include "application.selectorLabels" . }}
{{- end }}