# Demo environment for CI/CD

The `docker-compose.yml` deploys a demo environment for testing and learning continuous integration and continuous delivery of containerized services. It container the following services:

- Docker registry with web frontend
- gitea
- GoCD server
- GoCD agent with Docker-in-Docker sidekick
- InfluxDB
- Grafana

## Usage

The following commands build and deploy the environment:

```
docker-compose build
docker-compose up -d
```

The sevices will then be available under the following URLs:

- Docker registry: `localhost:5000`
- Docker registry frontend: `localhost:8080`
- gitea: `localhost:3000`
- GoCD server: `localhost:8153`
- Grafana: `localhost:3001`

The GoCD agent will be able to access the registry under the name `registry:5000` and the Docker-in-Docker sidekick under `dind:2375`.

Telegraf will be able to access InfluxDB under `influxdb:8086`.

Grafana will be able to access InfluxDB under `influxdb:8086`
