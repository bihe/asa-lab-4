# Run the agent

```
dapr run --app-id agent --app-protocol http --dapr-http-port 3500 --components-path ~/.dapr/components -- go run main.go
```