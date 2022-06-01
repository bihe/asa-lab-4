PROJECTNAME=$(shell basename "$(PWD)")

# Make is verbose in Linux. Make it silent.
MAKEFLAGS += --silent

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all agent-cli dashboard-cli build-container build-container-arm check-run-dashboard kube-deploy

all: help

agent-cli: ## run agent via dapr-cli
	@echo "  >  Run the agent via dapr-cli ..."
	dapr run --app-id agent --components-path ~/.dapr/components -- go run ./agent/main.go

dashboard-cli: ## run dashboard via dapr-cli
	@echo "  >  Run the dashboard via dapr-cli ..."
	dapr run --app-id dashboard --app-port 9000 --components-path ~/.dapr/components -- dotnet run --project ./dashboard/dashboard.csproj

build-container: ## build the container-images
	@echo "  >  Building the container-image"
	docker build -t dapr-demo/agent ./agent
	docker build -t dapr-demo/dashboard ./dashboard

build-container-arm: ## build the container-images using arm64
	@echo "  >  Building the container-images"
	docker build --build-arg buildtime_variable_arch=arm64 -t dapr-demo/agent ./agent
	docker build --build-arg buildtime_variable_arch=alpine-arm64 -t dapr-demo/dashboard ./dashboard

check-run-dashboard: ## run the container-image for the dashboard to check if the build works
	@echo "  >  Starting the container-image for the dashboard"
	docker run -it -p 9000:9000 dapr-demo/dashboard

kube-deploy: ## deploy the necessary dapr components to kubernetes
	@echo " >  Deploy dapr components"
	kubectl apply -f ./deployment/pubsub.yaml

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

