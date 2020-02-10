package base

deployment: prometheus: {
	metadata: {
		annotations: description: "Collects metrics and aggregates them into graphs."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "prometheus"
		strategy: {
			rollingUpdate: {
				maxSurge:       1
				maxUnavailable: 1
			}
			type: "RollingUpdate"
		}
		template: {
			spec: {
				containers: [{
					image:                    "index.docker.io/sourcegraph/prometheus:10.0.7@sha256:22d54f27c7df8733a06c7ae8c2e851b61b1ed42f1f5621d493ef58ebd8d815e0"
					terminationMessagePolicy: "FallbackToLogsOnError"
					readinessProbe: {
						httpGet: {
							path: "/-/ready"
							port: 9090
						}
						initialDelaySeconds: 30
						timeoutSeconds:      30
					}
					livenessProbe: {
						httpGet: {
							path: "/-/healthy"
							port: 9090
						}
						initialDelaySeconds: 30
						timeoutSeconds:      30
					}
					ports: [{
						containerPort: 9090
						name:          "http"
					}]
					volumeMounts: [{
						mountPath: "/prometheus"
						name:      "data"
					}, {
						mountPath: "/sg_prometheus_add_ons"
						name:      "config"
					}]
					resources: {
						limits: {
							cpu:    "2"
							memory: "2G"
						}
						requests: {
							cpu:    "500m"
							memory: "500M"
						}
					}
				}]
				serviceAccountName: "prometheus"
				securityContext: fsGroup: 100
				volumes: [{
					name: "data"
					persistentVolumeClaim: claimName: "prometheus"
				}, {
					configMap: {
						defaultMode: 0o777
						name:        "prometheus"
					}
					name: "config"
				}]
			}
		}
	}
}
