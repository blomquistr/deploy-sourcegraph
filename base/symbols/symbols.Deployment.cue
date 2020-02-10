package base

deployment: symbols: {
	metadata: {
		annotations: description: "Backend for symbols operations."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "symbols"
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
					env: [{
						name:  "SYMBOLS_CACHE_SIZE_MB"
						value: "100000"
					}, {
						name: "POD_NAME"
						valueFrom: fieldRef: fieldPath: "metadata.name"
					}, {
						name:  "CACHE_DIR"
						value: "/mnt/cache/$(POD_NAME)"
					}]
					image:                    "index.docker.io/sourcegraph/symbols:3.12.6@sha256:ebe2e2f770b3952c8626a1621ce16f19e15538e2e3477217d211dd77dc000172"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						initialDelaySeconds: 60
						timeoutSeconds:      5
					}
					readinessProbe: {
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						periodSeconds:  5
						timeoutSeconds: 5
					}
					ports: [{
						containerPort: 3184
						name:          "http"
					}, {
						containerPort: 6060
						name:          "debug"
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
					volumeMounts: [{
						mountPath: "/mnt/cache"
						name:      "cache-ssd"
					}]
				}]
				volumes: [{
					emptyDir: {}
					name: "cache-ssd"
				}]
			}
		}
	}
}
