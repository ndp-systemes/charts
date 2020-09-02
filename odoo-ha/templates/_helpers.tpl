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
Name of the postgresql service
*/}}
{{- define "odoo.postgresql.fullname" -}}
{{- printf "ndp-%s-postgresql" .Release.Name -}}
{{- end -}}

{{/*
Name of the postgresql secret
*/}}
{{- define "odoo.postgresql.secret" -}}
{{- printf "odoo.ndp-%s-postgresql.credentials.postgresql.acid.zalan.do" .Release.Name -}}
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

{{- define "odoo.repositories" -}}
{{- range $name, $repo := .Values.git.repositories }}
{{- $branch := coalesce $repo.branch $.Values.git.branch $.Values.image.tag }}
{{- $server := coalesce $repo.server $.Values.git.server }}
{{- $method := coalesce $repo.method "ssh" }}
{{- if or $repo.server $repo.httpsSecret }}{{ $method = "https"}}{{ end }}
{{- if eq $method "https" }}
{{- if $repo.httpsSecret }}
- name: HTTPS_USER_{{ $name | upper}}
  valueFrom:
    secretKeyRef:
      name: {{ $repo.httpsSecret | quote }}
      key: "username"
- name: HTTPS_PASSWORD_{{ $name | upper }}
  valueFrom:
    secretKeyRef:
      name: {{ $repo.httpsSecret | quote }}
      key: "password"
- name: {{ $name | upper }}
  value: {{ printf "-b %s --single-branch --depth=1 https://$(HTTPS_USER_%s):$(HTTPS_PASSWORD_%s)@%s/%s.git" $branch ($name | upper) ($name | upper) $server $repo.path | quote }}
{{- else }}
- name: {{ $name | upper }}
  value: {{ printf "-b %s --single-branch --depth=1 https://%s/%s.git" $branch $server $repo.path | quote }}
{{- end }}
{{- else }}
- name: {{ $name | upper }}
  value: {{ printf "-b %s --single-branch --depth=1 git@%s:%s.git" $branch $server $repo.path | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "odoo.queueJobVars" -}}
{{- if .Values.odoo.queueJobs.enabled }}
{{- $varName := "ODOO_QUEUE_JOB_CHANNELS" }}
{{- if or (eq .Values.image.tag "8.0") (eq .Values.image.tag "9.0") }}
{{- $varName = "ODOO_CONNECTOR_CHANNELS" }}
{{- end }}
- name: {{ $varName }}
  value: {{ .Values.odoo.queueJobs.channels }}
{{- end }}
{{- end }}

{{- define "odoo.loadModules" -}}
{{- $modules := "web" -}}
{{- if or (eq .Values.image.tag "7.0") (eq .Values.image.tag "8.0") (eq .Values.image.tag "9.0") (eq .Values.image.tag "10.0") }}
{{- $modules = "web,web_kanban" -}}
{{- end }}
{{- if .Values.odoo.queueJobs.enabled }}
{{- if or (eq .Values.image.tag "8.0") (eq .Values.image.tag "9.0") }}
{{- $modules = printf "%s,connector" $modules }}
{{- else }}
{{- $modules = printf "%s,queue_job" $modules }}
{{- end }}
{{- end }}
{{- if .Values.odoo.load }}
{{- $modules = printf "%s,%s" $modules .Values.odoo.load }}
{{- end }}
{{- $modules }}
{{- end }}

{{- define "odoo.redis.fullname" -}}
{{- printf "%s-redis-master" .Release.Name -}}
{{- end -}}

{{- define "odoo.redis.secret" -}}
{{- printf "%s-redis" .Release.Name -}}
{{- end -}}
