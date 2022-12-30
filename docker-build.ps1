minikube docker-env --shell powershell | Invoke-Expression
docker build -t dapr-demo/agent-golang ./agent-golang
docker build -t dapr-demo/dashboard-dotnet ./dashboard-dotnet
