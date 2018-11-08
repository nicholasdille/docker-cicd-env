# Demo environment for CI/CD

The `docker-compose.yml` deploys a demo environment for testing and learning continuous integration and continuous delivery of containerized services. It container the following services:

- Docker registry with web frontend
- gitea
- GoCD server
- GoCD agent with Docker-in-Docker sidekick
- Drone server
- Drone agent with mapped Docker socket
- InfluxDB
- Grafana

[![Try in PWD](https://cdn.rawgit.com/play-with-docker/stacks/cff22438/assets/images/button.png)](http://play-with-docker.com?stack=https://raw.githubusercontent.com/nicholasdille/docker-ci-cd-demo/traefik/docker-compose.yml)

## Usage

The following commands build and deploy the environment:

```bash
docker-compose build
docker-compose up -d
```

The sevices will then be available behind a reverse proxy (port 80) on your own domain with the following subdomains:

- Docker registry: registry.*
- Docker registry frontend: hub.*
- Gitea: git.*
- GoCD server: gocd.*
- Drone server: ci.*
- Grafana: ops.*

If required, all services are made available on a dedicated port after running:

```bash
docker-compose --file docker-compose.yml --file docker-compose.expose.yml up -d
```

- Docker registry: `localhost:5000`
- Docker registry frontend: `localhost:8080`
- gitea: `localhost:3000`
- GoCD server: `localhost:8153`
- Drone: `localhost:8000`
- Grafana: `localhost:3001`

The GoCD agent will be able to access the registry under the name `registry:5000` and the Docker-in-Docker sidekick under `dind:2375`.

Telegraf will be able to access InfluxDB under `influxdb:8086`.

Grafana will be able to access InfluxDB under `influxdb:8086`
