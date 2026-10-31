CLUSTER_NAME := ai-platform
CLUSTER_CONFIG := cluster/kind-config.yaml
KUBECONFIG_FILE := $(HOME)/.kube/ai-platform.config
KAGENT_VERSION := 0.10.4
JAEGER_VERSION := 4.16.1
OTELCOL_VERSION := 0.178.1

export KUBECONFIG := $(KUBECONFIG_FILE)

.PHONY: cluster down kagent-secret kagent kagent-ui tracing jaeger-ui

cluster:
	kind create cluster --name $(CLUSTER_NAME) --config $(CLUSTER_CONFIG)

down:
	kind delete cluster --name $(CLUSTER_NAME)

kagent-secret:
	kubectl create namespace kagent \
		--dry-run=client -o yaml | kubectl apply -f -
	
	bash -c ' \
		read -s -p "Anthropic API key: " ANTHROPIC_API_KEY; echo; \
		kubectl create secret generic kagent-anthropic \
			-n kagent \
			--from-literal=ANTHROPIC_API_KEY="$$ANTHROPIC_API_KEY" \
			--dry-run=client -o yaml | kubectl apply -f -; \
		unset ANTHROPIC_API_KEY; \
	'

kagent:
	helm upgrade --install kagent-crds oci://ghcr.io/kagent-dev/kagent/helm/kagent-crds \
		--version $(KAGENT_VERSION) --namespace kagent
	
	helm upgrade --install kagent oci://ghcr.io/kagent-dev/kagent/helm/kagent \
		--version $(KAGENT_VERSION) --namespace kagent -f kagent/values.yaml \
		--wait --timeout 10m

kagent-ui:
	kubectl port-forward -n kagent svc/kagent-ui 8080:8080

tracing:
	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
	helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
	helm repo update
	helm upgrade --install jaeger jaegertracing/jaeger \
		--version $(JAEGER_VERSION) --namespace observability --create-namespace \
		--wait --timeout 10m
	helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
		--version $(OTELCOL_VERSION) --namespace observability \
		-f tracing/otel-collector-values.yaml \
		--wait --timeout 10m

jaeger-ui:
	kubectl port-forward -n observability svc/jaeger 16686:16686
