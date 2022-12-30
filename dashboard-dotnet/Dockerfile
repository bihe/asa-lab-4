## build-phase
## --------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build-env

ARG dotnet_runtime_arch=alpine-x64
ENV runtime_arch=${dotnet_runtime_arch}

WORKDIR /build-env
COPY . ./

RUN dotnet publish -c Release --self-contained --runtime ${runtime_arch} -o ./dist "dashboard.csproj"

## runtime
## --------------------------------------------------------------------------
FROM alpine:latest

# additonal packages necessary during runtime
# ---------------------------------------------------------------------------
# need the icu-libs for Globalization and c runtime as well
RUN apk add --no-cache icu-libs libintl libgcc libstdc++ ca-certificates krb5-libs libssl1.1

# create a user for the app so it does not run with root
# ---------------------------------------------------------------------------
RUN addgroup -g 1000 -S dashboard && \
    adduser -u 1000 -S dashboard -G dashboard

# environment settings
# ---------------------------------------------------------------------------
# info: https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-environment-variables
#
# DOTNET_HOSTBUILDER__RELOADCONFIGONCHANGE:
#  - to prevent to create an unnecessary amount of inotify instances/events
# ref:
#  - https://anthonyliriano.com/2021/04/08/21-configured-user-limit-128-on-the-number-of-inotify-instances-has-been-reached.html
#  - https://docs.microsoft.com/de-de/aspnet/core/fundamentals/host/generic-host?view=aspnetcore-6.0#disable-app-configuration-reload-on-change
#  - https://stackoverflow.com/questions/43469400/asp-net-core-the-configured-user-limit-128-on-the-number-of-inotify-instance
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_RUNNING_IN_CONTAINERS=true \
	DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    DOTNET_USE_POLLING_FILE_WATCHER=1 \
	DOTNET_HOSTBUILDER__RELOADCONFIGONCHANGE=false \
    ASPNETCORE_URLS=http://+:9000

WORKDIR /opt/dashboard
RUN mkdir -p /opt/dashboard
COPY --from=build-env /build-env/dist /opt/dashboard
RUN chown -R dashboard:dashboard /opt/dashboard

USER dashboard
EXPOSE 9000
CMD ["/opt/dashboard/dashboard", "--urls", "http://+:9000"]
