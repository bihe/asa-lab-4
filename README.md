# Adaptive Architecture with dapr

![dapr-loge](./.images/dapr.png)

**Dapr** is a portable, event-driven runtime that makes it easy for any
developer to build resilient, stateless and stateful applications that run on the cloud and edge and embraces the diversity of languages and
developer frameworks.

**Dapr** codifies the best practices for building microservice applications into open, independent, building blocks that enable you to build portable applications with the language and framework of your choice.

https://docs.dapr.io/concepts/overview/


# Setup
The following components are necessary to run the example.

- Container runtime (Docker): https://www.docker.com/get-started/
- Portable, event-driven runtime (dapr): https://docs.dapr.io/getting-started/install-dapr-cli/
- Single node k8s (minikube): https://minikube.sigs.k8s.io/docs/start/
- Kubernetes package manager (helm): https://helm.sh/

If you want to build/run the examples using `apr-cli` the following sdks are needed.

- The programming language with the nice mascot **golang**: https://go.dev/dl/
- The versatile technology from Microsoft **.NET**: https://dotnet.microsoft.com/en-us/download
- The ubiquitous scripting langauge **python**: https://www.python.org/

## Windows Notes
To execute the commands a decent shell/terminal is needed. In a Unix-like environment like Mac/Linux typically a good shell is available out of the box (bash, zsh) in combination with a terminal (terminal, iTerm, Konsole, gnome-terminal, ...). For **Windows** a good combination of shell/terminal is [PowerShell](https://github.com/PowerShell/PowerShell)/[Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/). The commands below either work directly in PowerShell or there is a variant for PowerShell displayed. If you use [cmd.exe](https://en.wikipedia.org/wiki/Cmd.exe), you are without help. Nobody shoul use this old command-interpreter any more!

**Powershell**: For windows users it is quite helpful to set the execution-policy for powershell:

```bash
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Package Managers**: Windows users should use a **package manager**  to simplify installation. [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) / [Scoop](https://scoop.sh/) / [Chocolaty](https://chocolatey.org/) are excellent choices.


# dapr cli
This section is **only needed** if you have the local sdks installed and want to build/run dapr without kubernetes.
To start, the installation is straight-forward, just follow the instructions mentioned above.

0. Dapr init

The first step is to initialize dapr. As a result dapr itself and the corresponding dapr runtime is installed.

**Hint**: Docker needs to run!

```bash
# kick-start dapr
dapr init

# check the version (as of May 2024)
dapr --version
CLI version: 1.13.0
Runtime version: 1.13.3
```

With this output the `dapr-cli` setup is done.

After the initial dapr setup the example can be executed using the `dapr-cli`. This is only relevant/necessary when local development and dev-sdks are available. A prerequisite for this step is the installation of the golang/.NET SDKs (again see above for the installation link/info).

1. Via Makefile (Unix-like systems)

To simplify this process open two terminal windows and execute the following make commands.

```bash
# terminal1
make agent-cli

# terminal2
make dashboard-cli
```

To verify if all works as expected open a browser windows with the following URL: ```http://localhost:9000```.

**HINT**: If you get an error concerning the port this might be caused by a process already having possession of the port :9000.

2. Via Powershell (Windows)

For the Windows-people the process works the same, open two terminal/powershell/... windows and execute the powershell scripts.

```bash
# terminal1
.\dapr-agent-cli.ps1

# terminal2
.\dapr-dashboard-cli.ps1
```

Again verify the correct execution of the processes by opening a browser window with the URL: ```http://localhost:9000```.

The output will be similar to this:

![dapr-cli-output](./.images/dapr_cli_output.png)

# dapr on k8s (no local development SDKs needed)

Kubernetes is also called `k8s` => starting with `k`, `8 characters` and ending with `s`.
The easiest way to work with kubernetes/k8s is to locally install minikube, a single-node kubernetes "cluster". The installation is again rather simple and can be easily performed on Windows, Mac, Linux.

1. minikube

Install minikube according to documentation: https://minikube.sigs.k8s.io/docs/start/

Afterwards startup minikube. The output will be similar to the one shown below:

```bash
# versions as of May 2024
> minikube start

😄  minikube v1.33.1 on Darwin 14.5 (arm64)
✨  Using the docker driver based on existing profile
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.44 ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.30.0 on Docker 26.1.1 ...
🔎  Verifying Kubernetes components...
💡  After the addon is enabled, please run "minikube tunnel" and your ingress resources would be available at "127.0.0.1"
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
    ▪ Using image docker.io/kubernetesui/dashboard:v2.7.0
    ▪ Using image registry.k8s.io/ingress-nginx/controller:v1.10.1
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1
    ▪ Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
    ▪ Using image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

	minikube addons enable metrics-server

🔎  Verifying ingress addon...
🌟  Enabled addons: storage-provisioner, dashboard, default-storageclass, ingress
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

To work with k8s/minikube `kubectl` is needed. Minikube provides a kubectl `minikube kubectl -- <kubectl commands>`. In addition it is possible to install a plain kubectl. This can be done by typical packages managers.

```bash
# Mac
brew install kubectl

# Windows has a couple of package manager

# using winget
winget install -e --id Kubernetes.kubectl

# using scoop
scoop install kubectl

# using chocolatey
choco install kubernetes-cli
```

This is optional, because the minikube-provided kubectl can also be used, or aliased to "feel" like a standalone kubectl (https://minikube.sigs.k8s.io/docs/handbook/kubectl/).


2. dapr on k8s

The process is again quite easy. More information is available on the dapr website: https://docs.dapr.io/operations/hosting/kubernetes/cluster/setup-minikube/.
The following additional components are installed on minikube:

```bash
minikube addons enable dashboard # provides a kubernetes dashboard
minikube addons enable ingress # provides a reverse proxy using nginx to expose services
```

The finial step to initialize dapr on kubernetes (k8s) / minikube is done via the `dapr-cli`.

```bash
# the command initializes dapr on kubernetes by provisioning a couple of containers
dapr init -k
```

This command deploys the necessary containers to have the dapr environment available on minikube.

3. dapr components pubsub

A pubsub component is needed on k8s/minikube for this example. The easiest way is to install `redis` by using the `helm-cli` (dapr-docu: https://docs.dapr.io/getting-started/tutorials/configure-state-pubsub/)

3.1 Install helm-cli

We use `helm` because it simplifies the installation process of components to kubernetes.
The helm-documentation lists a number of options how to install helm for different operating-systems: https://helm.sh/docs/intro/install/
Again the easiest way is to use a package manager:

```bash
# Mac
brew install helm

# Windows has a couple of package manager

# using winget
winget install Helm.Helm

# using scoop
scoop install helm

# using chocolatey
choco install kubernetes-helm
```

3.2 Install redis

To install redis on `k8s/minikube` we use **helm** (=the kubernetes package manager). This is similar to `apt` for Debian-based Linux systems (https://wiki.debian.org/AptCLI)

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis bitnami/redis
```

Once the commands executed successfully check the relevant pods are running (be patient, this takes a couple of seconds. The result is the main noder and 3 replicas.):

```bash
> kubectl get pods
NAME               READY   STATUS    RESTARTS      AGE
redis-master-0     1/1     Running   1 (35m ago)   2d23h
redis-replicas-0   1/1     Running   2 (34m ago)   2d23h
redis-replicas-1   1/1     Running   2 (34m ago)   2d23h
redis-replicas-2   1/1     Running   2 (34m ago)   2d23h
```

3.3 dapr pubsub component

The last step is to "introduce" the pubsub dapr component to k8s. Redis has an extension `Redis Streams` which we use for [publish-subscribe](https://docs.dapr.io/reference/components-reference/supported-pubsub/setup-redis-pubsub/). The definition of the component is stored in `deployment/pubsub.yaml`.

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub
  namespace: default
spec:
  type: pubsub.redis
  version: v1
  metadata:
  - name: redisHost
    value: redis-master.default.svc.cluster.local:6379
  - name: redisPassword
    secretKeyRef:
      name: redis
      key: redis-password
 # uncomment below for connecting to redis cache instances over TLS (ex - Azure Redis Cache)
  # - name: enableTLS
  #   value: true

```

Kubernetes uses a lot of yaml, someone working with kubernetes is sometimes called a "**YAML Engineer**". This yaml structure is applied via `kubectl` using the following command:

```bash
kubectl apply -f ./deployment/pubsub.yaml
```

Again this can be done by using the `Makefile`:

```bash
make kube-deploy-pubsub
```

Or for the `Windows` by using the following powershell script:

```bash
.\k8s-deploy-pubsub.ps1
```

The result can be verified by listing the component via `kubectl`:

```bash
> kubectl get components
NAME     AGE
pubsub   2d23h
```

4. deploy components and service

**NOTE**: We need to **build the container-images** before we can deploy the application components. The process is described in the section **Build local images**.

**TL;DR**

```bash
# unix-like
## we need to tell docker where the images are stored - this is necessary for minikube to find the images used in the pods
eval $(minikube docker-env)
make build-container

# windows
## set docker-env variables to "redirect" the images towards minikube
minikube docker-env --shell powershell | Invoke-Expression
.\docker-build.ps1
```

To deploy the logic as containers to k8s/minikube another yaml definition is needed. The yaml files creates deployments for two pods and a service to access the dashboard (via ingress). The syntax is typical k8s-yaml (https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/) with some dapr-extensions:

```yaml
# example and parts of the components yaml file
...
annotations:
    dapr.io/enabled: "true"
    dapr.io/app-id: "dashboard-dotnet"
    dapr.io/app-port: "9000"
spec:
    containers:
    - name: dashboard-dotnet
      image: dapr-demo/dashboard-dotnet:latest
      ports:
      - containerPort: 9000
      imagePullPolicy: Never
...
```

The `app-port` and `containerPort` are kind of used twice, just ensure that the same ports are used. The deployment file is available at: `deployment/components.yaml` and is applied via

```bash
kubectl apply -f ./deployment/components.yaml

# unix-like
make kube-deploy-all

# windows
.\k8s-deploy-components.ps1
```

The logs of the containers within the pods (stdout) can be shown via kubectl:

```bash
# show the agent output
kubectl logs -f --selector app=agent-golang -c agent-golang

# show the output of the dashboard
kubectl logs -f --selector app=dashboard-dotnet -c dashboard-dotnet
```

The `selector` and/or `container` need to be specified, because of the dapr [sidecar pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/sidecar). The deployed pod contains two containers. The application container and the dapr sidecar.

```bash
> kubectl logs -f dashboard-dotnet-<random>-<id>
error: a container name must be specified for pod dashboard-dotnet-<random>-<id>, choose one of: [dashboard-dotnet daprd]
```

The log-output of the dapr sidecar can also be shown:

```bash
> kubectl logs -f dashboard-<random>-<id> -c daprd
time="2022-06-02T17:01:19.962046863Z" level=info msg="starting Dapr Runtime -- version 1.7.4 -- commit 9b3512921bb52af190a2474f3d31f39a1a7a9879" app_id=dashboard instance=dashboard-<random>-<id> scope=dapr.runtime type=log ver=1.7.4
time="2022-06-02T17:01:19.962091072Z" level=info msg="log level set to: info" app_id=dashboard instance=dashboard-<random>-<id> scope=dapr.runtime type=log ver=1.7.4
time="2022-06-02T17:01:19.962208472Z" level=info msg="metrics server started on :9090/" app_id=dashboard instance=dashboard-<random>-<id> scope=dapr.metrics type=log ver=1.7.4
time="2022-06-02T17:01:19.962333421Z" level=info msg="loading default configuration" app_id=dashboard instance=dashboard-<random>-<id> scope=dapr.runtime type=log ver=1.7.4
time="2022-06-02T17:01:19.962372471Z" level=info msg="kubernetes mode configured" app_id=dashboard instance=dashboard-<random>-<id> scope=dapr.runtime type=log ver=1.7.4
time="2022-06-02T17:01:19.962380871Z" level=info msg="app id: dashboard" app_id=dashboard instance=dashboard-<random>-<id> scope=dapr.runtime type=log ver=1.7.4

```


To access the dashboard a k8s service is defined:

```yaml
...
apiVersion: v1
kind: Service
metadata:
  name: dashboard-service
  labels:
    app: dashboard-service
spec:
  selector:
    app: dashboard
  ports:
  - protocol: TCP
    port: 9000
    targetPort: 9000
  type: LoadBalancer
  ...
```

The service definition **exposes a TCP port** which binds/forwars to the node and port of the container. This is necessary to access the system and the logic within the container from the "outside".

Minikube has a specialty, that additional work is needed to access services, because no "public IP" is created with minikube (this is different with other k8s implementations). But there is an easy way to access the service - minikube has a `service` command which establishes a connection to the exposed service. In fact it creates a ip-mapping to the LoadBalancer where services are exposed (https://minikube.sigs.k8s.io/docs/commands/service/)

```bash
minikube service dashboard-service
```

![k8s deployment works](./.images/k8s_deployment.png)


## Build local images
The application images are not published to dockerhub or any other container-registry, because this would just be waste for this demo-purpose. Instead the images are held locally and k8s is instructed to **not pull** the images!

To build locally a Makefile is available:

```bash
# unix-like
make build-container

# windows
.\docker-build.ps1
```
creates the local images.


```yaml
containers:
- name: dashboard
  image: dapr-demo/dashboard:latest
  ports:
  - containerPort: 9000
  imagePullPolicy: Never
```

The important part is the **imagePullPolicy**. To actually enable this, it is not sufficient to just build the images locally, because minikube does not access those local images. As usual there is an [StackOverflow answer](https://stackoverflow.com/questions/56392041/getting-errimageneverpull-in-pods) how to give the images to minikube!

The trick is to set some relevant ENVs via minikube and build again:

```
eval $(minikube docker-env)
```

On __Windows__ and __powershell__ this translates to

```
minikube docker-env --shell powershell | Invoke-Expression
```

## Cleanup

By executing the powershell script `k8s-undeploy.ps1` or `make kube-undeploy-all` the resources are removed from k8s and a fresh start can be done.

This can be verified by checking the pods:

```bash
> kubectl get pods
NAME                         READY   STATUS        RESTARTS        AGE
agent-666d89fb8f-mg5wh       2/2     Terminating   1 (3m34s ago)   3m35s
dashboard-5bd6c7697f-ztbx5   2/2     Terminating   0               3m35s
redis-master-0               1/1     Running       2 (22h ago)     3d23h
redis-replicas-0             1/1     Running       3 (5m16s ago)   3d23h
redis-replicas-1             1/1     Running       3 (5m16s ago)   3d23h
redis-replicas-2             1/1     Running       3 (5m16s ago)   3d23h

```

The output shows, that the application pods are in the process of being removed from k8s.
