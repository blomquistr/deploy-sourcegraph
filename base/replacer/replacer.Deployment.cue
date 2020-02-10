package base

deployment: replacer: {
	metadata: {
		annotations: description: "Backend for replace operations."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "replacer"
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
						name:  "REPLACER_CACHE_SIZE_MB"
						value: "100000"
					}, {
						name: "POD_NAME"
						valueFrom: fieldRef: fieldPath: "metadata.name"
					}, {
						name:  "CACHE_DIR"
						value: "/mnt/cache/$(POD_NAME)"
					}]
					image:                    "index.docker.io/sourcegraph/replacer:3.12.6@sha256:19949f96fe1ae999092fc1226b61d4b2f1b218c1ae4fddc3dd1be185aaec6361"
					terminationMessagePolicy: "FallbackToLogsOnError"
					ports: [{
						containerPort: 3185
						name:          "http"
					}, {
						containerPort: 6060
						name:          "debug"
					}]
					readinessProbe: {
						failureThreshold: 1
						httpGet: {
							path:   "/healthz"
							port:   "http"
							scheme: "HTTP"
						}
						periodSeconds: 1
					}
					resources: {
						limits: {
							cpu:    "4"
							memory: "500M"
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
