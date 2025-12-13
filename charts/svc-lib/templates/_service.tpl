{{- define "svc.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "svc.fullname" . }}
  labels:
    {{- include "svc.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type | default "ClusterIP" }}
  selector:
    {{- include "svc.selectorLabels" . | nindent 4 }}
  ports:
    - name: http
      port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
{{- end }}