{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "odoo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "odoo.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "odoo.postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "odoo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Odoo image name
*/}}
{{- define "odoo.image" -}}
{{- $tag := .Values.image.tag | toString -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository $tag -}}
{{- end -}}

{{/*
Return the PVC storage class name
*/}}
{{- define "odoo.storageClass" -}}
{{- default .Chart.Name .Values.persistence.storageClass | quote -}}
{{- end -}}

{{/*
Return the Odoo module to install
*/}}
{{- define "odoo.installModule" -}}
{{- $default_module := printf "%s_erp" .Release.Name -}}
{{- default $default_module .Values.odoo.module | quote -}}
{{- end -}}

{{/*
Return the Odoo database
*/}}
{{- define "odoo.database" -}}
{{- default .Release.Name .Values.odoo.database | quote -}}
{{- end -}}

{{/*
Return the ingress host name
*/}}
{{- define "odoo.hostname" -}}
{{- $default_name := printf "%s.%s" .Release.Name .Values.ingress.domain -}}
{{- default  $default_name .Values.ingress.name | quote -}}
{{- end -}}

{{/*
Return the odoo project source
*/}}
{{- define "odoo.repository1" -}}
{{- $branch := default .Values.image.tag .Values.git.branch -}}
{{- $proj := default .Release.Name .Values.git.project -}}
{{- $default_repo := printf "-b %s git@%s:%s/%s.git" $branch .Values.git.server .Values.git.group $proj -}}
{{- default $default_repo .Values.git.repo1 -}}
{{- end -}}

{{/*
Return the first dependency repo
*/}}
{{- define "odoo.repository2" -}}
{{- $branch := default .Values.image.tag .Values.git.branch -}}
{{- $proj := default "" .Values.git.depProject1 -}}
{{- $default_repo := and $proj (printf "-b %s git@%s:%s/%s.git" $branch .Values.git.server .Values.git.group .Values.git.depProject1) -}}
{{- default $default_repo .Values.git.repo2 -}}
{{- end -}}

{{/*
Return the second dependency repo
*/}}
{{- define "odoo.repository3" -}}
{{- $branch := default .Values.image.tag .Values.git.branch -}}
{{- $proj := default "" .Values.git.depProject2 -}}
{{- $default_repo := and $proj (printf "-b %s git@%s:%s/%s.git" $branch .Values.git.server .Values.git.group .Values.git.depProject2) -}}
{{- default $default_repo .Values.git.repo3 -}}
{{- end -}}

{{/*
Return the third dependency repo
*/}}
{{- define "odoo.repository4" -}}
{{- $branch := default .Values.image.tag .Values.git.branch -}}
{{- $proj := default "" .Values.git.depProject3 -}}
{{- $default_repo := and $proj (printf "-b %s git@%s:%s/%s.git" $branch .Values.git.server .Values.git.group .Values.git.depProject3) -}}
{{- default $default_repo .Values.git.repo4 -}}
{{- end -}}

{{/*
Override postgresql secret to use ours
*/}}
{{- define "postgresql.secretName" -}}
{{ include "postgresql.fullname" . }}
{{- end -}}
