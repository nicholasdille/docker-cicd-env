[![Try in PWD](https://cdn.rawgit.com/play-with-docker/stacks/cff22438/assets/images/button.png)](http://play-with-docker.com?stack=https://github.com/nicholasdille/docker-cicd-env/raw/master/docker-compose.yml)

# Demo environment for CI/CD

The `docker-compose.yml` deploys a demo environment for testing and learning continuous integration and continuous delivery of containerized services. It container the following services:

- Docker registry with web frontend
- gitea
- Drone server
- Drone agent with mapped Docker socket
- InfluxDB
- Grafana

## Usage

The following commands build and deploy the environment:

```bash
docker-compose up -d
```

The sevices will then be available behind a reverse proxy (port 80) on your own domain with the following subdomains:

- Docker registry: registry.*
- Docker registry frontend: hub.*
- Gitea: git.*
- Drone server: ci.*
- Grafana: ops.*