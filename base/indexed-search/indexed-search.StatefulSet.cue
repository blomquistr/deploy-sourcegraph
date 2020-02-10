package base

statefulSet: "indexed-search": {
	metadata: {
		annotations: description: "Backend for indexed text search operations."
	}
	spec: {
		template: {
			spec: {
				containers: [{
					image:                    "index.docker.io/sourcegraph/zoekt-webserver:0.0.20200127195558-ca66753@sha256:f15faab65d5e398656d0c9100eab9264eb976ef00d03e1aaf5b6d3e1aa05e9db"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "zoekt-webserver"
					ports: [{
						containerPort: 6070
						name:          "http"
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
							cpu:    "2"
							memory: "4G"
						}
						requests: {
							cpu:    "500m"
							memory: "2Gi"
						}
					}
					volumeMounts: [{
						mountPath: "/data"
						name:      "data"
					}]
				}, {
					env:                      null
					image:                    "index.docker.io/sourcegraph/zoekt-indexserver:0.0.20200127195718-ca66753@sha256:b50c1a6922a936fd07df2fea0800b4cfdf0e021bb9801ed81a00ac1a6cd6e061"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "zoekt-indexserver"
					ports: [{
						containerPort: 6072
						name:          "index-http"
					}]
					resources: {
						// zoekt-indexserver is CPU bound. The more CPU you allocate to it, the
						// lower lag between a new commit and it being indexed for search.
						limits: {
							cpu:    "8"
							memory: "8G"
						}
						requests: {
							cpu:    "4"
							memory: "4G"
						}
					}
					volumeMounts: [{
						mountPath: "/data"
						name:      "data"
					}]
				}]
				securityContext: fsGroup: 100
				volumes: [{
					name: "data"
				}]
			}
		}
		updateStrategy: type: "RollingUpdate"
		volumeClaimTemplates: [{
			metadata: {
				labels: deploy: "sourcegraph"
				name: "data"
			}
			spec: {
				accessModes: [
					"ReadWriteOnce",
				]
				resources: requests: {
					// The size of disk to used for search indexes.
					// This should typically be gitserver disk size multipled by the number of gitserver shards.
					storage: "200Gi"
				}
				storageClassName: "sourcegraph"
			}
		}]
	}
}
