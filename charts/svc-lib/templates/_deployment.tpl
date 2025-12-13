{{- define "svc.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "svc.fullname" . }}
  labels:
    {{- include "svc.labels" . | nindent 4 }}
spec:
  replicas: {{ default 2 .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "svc.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "svc.selectorLabels" . | nindent 8 }}
        {{- with .Values.podLabels }}{{ toYaml . | nindent 8 }}{{- end }}
      annotations:
        {{- with .Values.podAnnotations }}{{ toYaml . | nindent 8 }}{{- end }}
    spec:
      serviceAccountName: {{ default (include "svc.fullname" .) include "svc.serviceAccountName" . }}
      {{- if .Values.podSecurityContext.enabled }}
      securityContext:
        fsGroup: {{ .Values.podSecurityContext.fsGroup | default 1001 }}
      {{- end }}
      containers:
        - name: {{ include "svc.name" . }}
          image: "{{ required "image.repository is required" .Values.image.repository }}:{{ required "image.tag is required" .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" }}
          ports:
            - name: http
              containerPort: {{ required "service.port is required" .Values.service.port }}
              protocol: TCP
          envFrom:
            {{- if .Values.configmap.create }}
            - configMapRef:
                name: {{ include "svc.configmapName" . }}
            {{- end }}
            {{- range .Values.envFrom }}
            - {{- toYaml . | nindent 14 }}
            {{- end }}
          env:
            {{- range .Values.env }}
            - {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- if .Values.livenessProbe.enabled }}
          livenessProbe:
            {{- toYaml .Values.livenessProbe | nindent 12 }}
          {{- end }}
          {{- if .Values.readinessProbe.enabled }}
          readinessProbe:
            {{- toYaml .Values.readinessProbe | nindent 12 }}
          {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            {{- with .Values.extraVolumeMounts }}{{ toYaml . | nindent 12 }}{{- end }}
      volumes:
        {{- with .Values.extraVolumes }}{{ toYaml . | nindent 8 }}{{- end }}
      nodeSelector:
        {{- with .Values.nodeSelector }}{{ toYaml . | nindent 8 }}{{- end }}
      tolerations:
        {{- with .Values.tolerations }}{{ toYaml . | nindent 8 }}{{- end }}
      affinity:
        {{- with .Values.affinity }}{{ toYaml . | nindent 8 }}{{- end }}
{{- end }}