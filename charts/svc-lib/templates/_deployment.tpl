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
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      serviceAccountName: {{ include "svc.serviceAccountName" . }}
      {{- $psc := default (dict) .Values.podSecurityContext -}}
      {{- if (default false $psc.enabled) }}
      securityContext:
        fsGroup: {{ default 1001 $psc.fsGroup }}
      {{- end }}
      containers:
        - name: {{ include "svc.name" . }}
          image: "{{ required "image.repository is required" .Values.image.repository }}:{{ required "image.tag is required" .Values.image.tag }}"
          imagePullPolicy: {{ default "IfNotPresent" .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ required "service.port is required" .Values.service.port }}
              protocol: TCP

          {{- /* ---- envFrom (уніфікований список) ---- */ -}}
          {{- $extraEnvFrom := default (list) .Values.envFrom -}}
          {{- $EF := list -}}
          {{- if .Values.configmap.create -}}
            {{- $EF = append $EF (dict "configMapRef" (dict "name" (include "svc.configmapName" .))) -}}
          {{- end -}}
          {{- $EF = concat $EF $extraEnvFrom -}}
          {{- if gt (len $EF) 0 }}
          envFrom:
{{ toYaml $EF | nindent 12 }}
          {{- end }}

          {{- /* ---- env ---- */ -}}
          {{- with (default (list) .Values.env) }}
          {{- if gt (len .) 0 }}
          env:
{{ toYaml . | nindent 12 }}
          {{- end }}
          {{- end }}

          {{- /* ---- probes без поля enabled ---- */ -}}
          {{- $lp := default (dict "enabled" false) .Values.livenessProbe -}}
          {{- if $lp.enabled }}
          livenessProbe:
{{ omit $lp "enabled" | toYaml | nindent 12 }}
          {{- end }}

          {{- $rp := default (dict "enabled" false) .Values.readinessProbe -}}
          {{- if $rp.enabled }}
          readinessProbe:
{{ omit $rp "enabled" | toYaml | nindent 12 }}
          {{- end }}

          resources:
{{- toYaml .Values.resources | nindent 12 }}

          {{- with .Values.extraVolumeMounts }}
          volumeMounts:
{{ toYaml . | nindent 12 }}
          {{- end }}
      {{- with .Values.extraVolumes }}
      volumes:
{{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
{{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
{{ toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
{{ toYaml . | nindent 8 }}
      {{- end }}
{{- end }}