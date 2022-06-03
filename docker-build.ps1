minikube docker-env --shell powershell | Invoke-Expression
docker build -t dapr-demo/agent ./agent
docker build -t dapr-demo/dashboard ./dashboard
