{{- define "svc.configmap" -}}
{{- if .Values.configmap.create }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "svc.configmapName" . }}
  labels:
    {{- include "svc.labels" . | nindent 4 }}
data:
  {{- range $k, $v := .Values.configmap.data }}
  {{ $k }}: {{ $v | quote }}
  {{- end }}
  {{- if .Values.configmap.files }}
{{ (.Files.Glob .Values.configmap.files).AsConfig | indent 2 }}
  {{- end }}
{{- end }}
{{- end }}