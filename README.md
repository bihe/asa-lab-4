# Adaptive Architecture with dapr

Intro to dapr - https://docs.dapr.io/concepts/overview/

# Setup

- Install --> dapr: https://docs.dapr.io/getting-started/install-dapr-cli/
- Golang --> https://go.dev/dl/
- .NET --> https://dotnet.microsoft.com/en-us/download
- Docker --> https://www.docker.com/get-started/
- Minikube --> https://minikube.sigs.k8s.io/docs/start/

# dapr cli

0. Dapr init

Hint: Docker needs to run!

```
dapr init
```

1. Via Makefile

- console1 - ```make agent-cli```
- console2 - ```make dashboard-cli```

2. Open Browser and go to ```http://localhost:5000```


# dapr on k8s

1. minikube

Install minikube according to documentation: https://minikube.sigs.k8s.io/docs/start/

2. dapr on k8s

Check the documentation: https://docs.dapr.io/operations/hosting/kubernetes/cluster/setup-minikube/

```
dapr init -k
```

https://docs.dapr.io/getting-started/tutorials/configure-state-pubsub/
