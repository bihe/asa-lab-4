## build-phase
## --------------------------------------------------------------------------
FROM golang:alpine AS build-env

ARG buildtime_variable_arch=amd64
ENV ARCH=${buildtime_variable_arch}

WORKDIR /build-env
COPY ./go.mod ./
COPY ./main.go ./

RUN GOOS=linux GOARCH=${ARCH} go build -ldflags="-w -s" -o agent ./main.go
## --------------------------------------------------------------------------

## runtime
## --------------------------------------------------------------------------
FROM alpine:latest
WORKDIR /opt/agent
RUN mkdir -p /opt/agent
COPY --from=build-env /build-env/agent /opt/agent

# Do not run as root user
## alpine specific user/group creation
RUN addgroup -g 1000 -S agent && \
    adduser -u 1000 -S agent -G agent

RUN chown -R agent:agent /opt/agent
USER agent

CMD ["/opt/agent/agent"]
