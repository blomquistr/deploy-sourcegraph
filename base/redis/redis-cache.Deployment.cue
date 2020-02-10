package base

deployment: "redis-cache": {
	metadata: {
		annotations: description: "Redis for storing short-lived caches."
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "redis-cache"
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
					env:                      null
					image:                    "index.docker.io/sourcegraph/redis-cache:20-02-03_da9d71ca@sha256:7820219195ab3e8fdae5875cd690fed1b2a01fd1063bd94210c0e9d529c38e56"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						initialDelaySeconds: 30
						tcpSocket: port: "redis"
					}
					ports: [{
						containerPort: 6379
						name:          "redis"
					}]
					readinessProbe: {
						initialDelaySeconds: 5
						tcpSocket: port: "redis"
					}
					resources: {
						limits: {
							cpu:    "1"
							memory: "6Gi"
						}
						requests: {
							cpu:    "1"
							memory: "6Gi"
						}
					}
					volumeMounts: [{
						mountPath: "/redis-data"
						name:      "redis-data"
					}]
				}, {
					image:                    "index.docker.io/sourcegraph/redis_exporter:18-02-07_bb60087_v0.15.0@sha256:282d59b2692cca68da128a4e28d368ced3d17945cd1d273d3ee7ba719d77b753"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "redis-exporter"
					ports: [{
						containerPort: 9121
						name:          "redisexp"
					}]
					resources: {
						limits: {
							cpu:    "10m"
							memory: "100Mi"
						}
						requests: {
							cpu:    "10m"
							memory: "100Mi"
						}
					}
				}]
				volumes: [{
					name: "redis-data"
					persistentVolumeClaim: claimName: "redis-cache"
				}]
			}
		}
	}
}
