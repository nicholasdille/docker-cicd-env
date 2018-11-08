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

## Usage

The following commands build and deploy the environment:

```bash
docker-compose build
docker-compose up -d
```

The sevices will then be available behind a reverse proxy on port 80 with the following names:

- Docker registry: registry.example.com
- Docker registry frontend: hub.example.com
- Gitea: git.example.com
- GoCD server: gocd.example.com
- Drone server: ci.example.com
- Grafana: grafana.example.com

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
