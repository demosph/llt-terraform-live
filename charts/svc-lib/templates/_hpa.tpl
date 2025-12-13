{{- define "svc.hpa" -}}
{{- $a := default (dict "enabled" false "minReplicas" 2 "maxReplicas" 5 "targetCPUUtilizationPercentage" 70) .Values.autoscaling -}}
{{- if $a.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "svc.fullname" . }}
  labels:
    {{- include "svc.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "svc.fullname" . }}
  minReplicas: {{ default 2 $a.minReplicas }}
  maxReplicas: {{ default 5 $a.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ default 70 $a.targetCPUUtilizationPercentage }}
    {{- if $a.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ $a.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
{{- end }}