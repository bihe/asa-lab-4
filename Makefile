PROJECTNAME=$(shell basename "$(PWD)")

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all agent-cli dashboard-cli showarch build-container docker-run-dashboard kube-deploy-all kube-undeploy-all

## set the default architecture should work for most Linux systems
golang_arch := 'amd64'
dotnet_runtime_arch := 'alpine-x64'

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M), x86_64)
	dotnet_runtime_arch = 'linux-musl-x64'
	golang_arch = 'amd64'
endif
ifeq ($(UNAME_M), arm64)
	dotnet_runtime_arch = 'linux-musl-arm64'
	golang_arch = 'arm64'
endif

all: help

agent-cli: ## run agent via dapr-cli
	@echo "  >  Run the golang agent via dapr-cli ..."
	dapr run --app-id agent-golang --components-path ~/.dapr/components -- go run ./agent-golang/main.go

dashboard-cli: ## run dashboard via dapr-cli
	@echo "  >  Run the dashboard-dotnet via dapr-cli ..."
	dapr run --app-id dashboard-dotnet --app-port 9000 --components-path ~/.dapr/components -- dotnet run --project ./dashboard-dotnet/dashboard.csproj

showarch: ## show processor architecture and the values used for the container build
	echo 'The system is using the architecture:         --> $(UNAME_M)'
	echo 'Will use the following dotnet-runtime         --> $(dotnet_runtime_arch)'
	echo 'Will us the following golang architecture:    --> $(golang_arch)'

build-container: ## build the container-images
	@echo "  >  Building the container-image"
	@eval $$(minikube docker-env) ;\
	docker build -t dapr-demo/agent-python ./agent-python
	@eval $$(minikube docker-env) ;\
	docker build --build-arg golang_arch=$(golang_arch) -t dapr-demo/agent-golang ./agent-golang
	@eval $$(minikube docker-env) ;\
	docker build --build-arg dotnet_runtime_arch=$(dotnet_runtime_arch) -t dapr-demo/dashboard-dotnet ./dashboard-dotnet

docker-run-dashboard: ## run the container-image for the dashboard to check if the build works
	@echo "  >  Starting the container-image for the dashboard-dotnet"
	@eval $$(minikube docker-env) ;\
	docker run -it -p 9000:9000 dapr-demo/dashboard-dotnet

kube-deploy-all: ## deploy dapr pubsub (redis) and components (agent-golang, dashboard-dotnet)
	@echo " >  Deploy dapr pubsub (redis)"
	kubectl apply -f ./deployment/pubsub.yaml
	kubectl apply -f ./deployment/components.yaml

kube-undeploy-all: ## remove the k8s components for a fresh start
	@echo " >  Undeploy components for a fresh start"
	kubectl delete deployment agent-golang
	kubectl delete deployment agent-python
	kubectl delete deployment dashboard-dotnet
	kubectl delete service dashboard-service
	kubectl delete component pubsub


# internal tasks

## Help:
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

