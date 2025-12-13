{{- define "svc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "svc.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "svc.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end }}

{{- define "svc.labels" -}}
app.kubernetes.io/name: {{ include "svc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/part-of: travelfinder
{{- end }}

{{- define "svc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "svc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "svc.configmapName" -}}
{{- default (printf "%s-config" (include "svc.fullname" .)) .Values.configmap.name -}}
{{- end }}

{{- define "svc.serviceAccountName" -}}
{{- $sa := .Values.serviceAccount | default (dict "create" true "name" "") -}}
{{- if $sa.create | default true -}}
  {{- if $sa.name }}{{ $sa.name }}{{ else }}{{ include "svc.fullname" . }}{{ end -}}
{{- else -}}
  {{- default "default" $sa.name -}}
{{- end -}}
{{- end -}}