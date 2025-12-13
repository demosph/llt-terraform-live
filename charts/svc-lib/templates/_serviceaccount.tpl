{{- define "svc.serviceaccount" -}}
{{- $sa := .Values.serviceAccount | default (dict "create" true "name" "") -}}
{{- if ($sa.create | default true) }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "svc.serviceAccountName" . }}
  labels:
    {{- include "svc.labels" . | nindent 4 }}
{{- end }}
{{- end }}