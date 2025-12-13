{{- if .Values.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "svc.fullname" . }}
  namespace: {{ default .Release.Namespace .Values.serviceMonitor.namespace }}
  labels:
    {{- include "svc.labels" . | nindent 4 }}
    {{- toYaml .Values.serviceMonitor.labels | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "svc.selectorLabels" . | nindent 6 }}
  namespaceSelector:
    matchNames:
      - {{ .Release.Namespace }}
  endpoints:
    - port: http
      interval: {{ .Values.serviceMonitor.interval }}
      path: /metrics
{{- end }}