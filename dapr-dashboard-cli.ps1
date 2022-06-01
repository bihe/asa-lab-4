dotnet clean ./dashboard/dashboard.csproj
dotnet build ./dashboard/dashboard.csproj
dapr run --app-id dashboard --app-port 9000 --components-path $env:USERPROFILE/.dapr/components -- dotnet run --project ./dashboard/dashboard.csproj
