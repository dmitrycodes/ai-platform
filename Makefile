CLUSTER_NAME := ai-platform
CLUSTER_CONFIG := cluster/kind-config.yaml
KUBECONFIG_FILE := $(HOME)/.kube/ai-platform.config

export KUBECONFIG := $(KUBECONFIG_FILE)

cluster:
	kind create cluster --name $(CLUSTER_NAME) --config $(CLUSTER_CONFIG)

down:
	kind delete cluster --name $(CLUSTER_NAME)

.PHONY: cluster down
