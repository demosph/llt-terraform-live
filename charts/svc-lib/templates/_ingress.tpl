{{- define "svc.ingress" -}}
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "svc.fullname" . }}
  labels:
    {{- include "svc.labels" . | nindent 4 }}
  annotations:
    {{- with .Values.ingress.annotations }}{{ toYaml . | nindent 4 }}{{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className | quote }}
  tls:
    {{- with .Values.ingress.tls }}{{ toYaml . | nindent 2 }}{{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                name: {{ include "svc.fullname" $ }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}