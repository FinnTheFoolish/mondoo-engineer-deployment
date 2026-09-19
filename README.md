# Mondoo Engineer — Deployment

Deployment configuration for the Mondoo Engineer Go application.

This repository deliberately separates application source from container and Kubernetes configuration.

## Architecture

```text
Application repository
        |
        | GitHub Release
        v
Released Linux binary
        |
        | repository_dispatch
        v
Deployment repository
        |
        +--> Docker build
        |
        +--> cnspec validation
        |
        +--> GHCR
        |
        v
Kubernetes
```

The deployment repository consumes a released application artifact rather than rebuilding the application from source.

This provides a clear separation between:

* building and releasing application artifacts
* packaging artifacts into containers
* deploying containers

## Docker

### Installation

Install Docker using the official Docker documentation for your operating system.

Verify the installation:

```bash
docker --version
docker run hello-world
```

### Build locally

Download a Linux amd64 binary from the application GitHub release and place it in the build context as:

```text
build/mondoo-engineer-linux-amd64
```

Then run:

```bash
docker build \
  --build-arg BINARY=build/mondoo-engineer-linux-amd64 \
  -t mondoo-engineer:local \
  .
```

Run the container:

```bash
docker run --rm -p 8080:8080 mondoo-engineer:local
```

Verify:

```bash
curl http://localhost:8080
```

Expected response:

```text
Hello from Mondoo Engineer!
```

## Container registry

GitHub Container Registry (GHCR) is used instead of Docker Hub.

The project is already hosted on GitHub, so GHCR allows the source repository, release workflow, package permissions and container registry to remain within the same platform.

The image is published as:

```text
ghcr.io/YOUR_USERNAME/mondoo-engineer:<version>
```

For example:

```text
ghcr.io/YOUR_USERNAME/mondoo-engineer:v1.0.0
```

The release version is retained as the container tag so that an application release can be traced to the corresponding container image.

## Cross-repository automation

The application repository sends a GitHub `repository_dispatch` event after a successful release.

The event contains the release version:

```json
{
  "event_type": "application-release",
  "client_payload": {
    "version": "v1.0.0"
  }
}
```

The deployment workflow receives the event, downloads the exact released binary and packages it into a container.

This avoids rebuilding source code in the deployment repository.

### Security

The credential used to trigger the deployment repository should be narrowly scoped to the required repository and action permissions.

A broad personal access token should not be used.

## Dockerfile design

The runtime image uses a minimal non-root base image.

The container does not need a shell, package manager or compiler, so these components are deliberately excluded from the runtime environment.

The application binary is copied to:

```text
/app/mondoo-engineer
```

and the container documents HTTP port:

```text
8080
```

The image runs as a non-root user.

## Kubernetes

Raw Kubernetes YAML is used rather than Helm.

The application has only a Deployment and Service and therefore does not currently justify Helm's templating and release-management features.

Deploy:

```bash
kubectl apply -f k8s/
```

The Deployment starts two replicas and exposes port `8080` through a ClusterIP Service.

The image version should be explicitly updated when deploying a new release.

## Trade-offs

### Artifact promotion

The deployment pipeline consumes the binary produced by the application release.

This is preferable to rebuilding source during containerisation because the container represents a previously tested and released artifact.

### GHCR

GHCR reduces the number of external systems involved and integrates directly with GitHub Actions authentication.

### Raw Kubernetes YAML

Helm was intentionally not introduced because this challenge only requires a small, static deployment definition. If the application later required environment-specific configuration, multiple deployments or reusable packaging, Kustomize or Helm would become more compelling.

### cnspec

cnspec is used as a policy-as-code gate before a container is published. The objective is to validate the resulting deployment artifact rather than relying solely on source-level tests.

Further cnspec checks can be extended to the container image and Kubernetes manifests.