# Laravel Docker Setup

## Requirements
- Docker
- Docker Compose
- Git

## Setup

Clone the project:

```bash
git clone <repo-url>
cd <project-folder>
```

## Make setup script executable:
```
chmod +x setup.sh
```

## Run setup:
```
./setup.sh
```

## What it does
- Clones Laravel app into `app/`
- Creates `.env`
- Builds Docker containers
- Installs Composer dependencies
- Runs migrations
- Sets permissions

## Access URLs
- Application: http://localhost:9080
- phpMyAdmin: http://localhost:9090

## Notes
- Make sure Docker is running before executing setup
- If ports are busy, update them in `docker-compose.yml`