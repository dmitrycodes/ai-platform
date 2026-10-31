# ai-platform

A learning project: an agentic platform on a local Kubernetes cluster, built step by step.
Components: [kagent](https://kagent.dev) (agents), agentgateway (LLM and MCP gateway),
tracing and observability, and secrets management. Only kagent is installed so far.

## Prerequisites

- Docker Desktop with about 6 CPUs and 8 GB of memory
- [kind](https://kind.sigs.k8s.io) v0.33.0
- kubectl v1.37.2
- [helm](https://helm.sh) v4.3.1
- An Anthropic API key (from the Anthropic Console, separate from a Claude subscription)

## Versions

| Component | Version |
|---|---|
| Kubernetes (kind node image) | v1.36.4, pinned by digest in `cluster/kind-config.yaml` |
| kagent | 0.10.4 (`KAGENT_VERSION` in the `Makefile`) |
| Jaeger (Helm chart) | 4.16.1 (app 2.22.0), `JAEGER_VERSION` in the `Makefile` |
| OpenTelemetry Collector (Helm chart) | 0.178.1 (app 0.163.2), `OTELCOL_VERSION` in the `Makefile` |

## Kubeconfig

Everything uses a dedicated kubeconfig, `~/.kube/ai-platform.config`. The `Makefile`
sets `KUBECONFIG` for its targets, so your other clusters are never touched. To run
`kubectl` or `helm` by hand in a terminal, export it first:

```bash
export KUBECONFIG=~/.kube/ai-platform.config
```

## Build from scratch

| Command | What it does |
|---|---|
| `make cluster` | Creates the kind cluster `ai-platform` |
| `make tracing` | Installs Jaeger and the OpenTelemetry Collector in the `observability` namespace |
| `make kagent-secret` | Asks for your Anthropic API key (hidden input) and stores it as a Kubernetes Secret |
| `make kagent` | Installs the kagent CRDs and kagent (values in `kagent/values.yaml`) and waits until ready |
| `make kagent-ui` | Port-forwards the kagent UI to http://localhost:8080 |
| `make jaeger-ui` | Port-forwards the Jaeger UI to http://localhost:16686 |
| `make down` | Deletes the cluster |

Build in this order: `make cluster`, `make tracing`, `make kagent-secret`, `make kagent`.
The UI targets (`make kagent-ui`, `make jaeger-ui`) can be run any time after their
component is installed, and `make down` deletes everything. The API key is never stored
in this repository.

## Repository safeguards

The repo is public. A `.gitignore` and a gitleaks pre-commit hook guard against committed
secrets. Enable the hook after cloning:

```bash
pre-commit install
```
