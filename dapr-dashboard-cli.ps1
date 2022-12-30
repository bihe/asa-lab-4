dotnet clean ./dashboard-dotnet/dashboard.csproj
dotnet build ./dashboard-dotnet/dashboard.csproj
dapr run --app-id dashboard-dotnet --app-port 9000 --components-path $env:USERPROFILE/.dapr/components -- dotnet run --project ./dashboard-dotnet/dashboard.csproj
