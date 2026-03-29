# 🧠 Local AI Infrastructure Setup (Ollama + Open WebUI + VS Code)

This setup allows you to run a fully local AI-powered DevOps/SRE lab.

## Architecture

VS Code → Open WebUI → Ollama → Local Models

## Prerequisites

-   Docker
-   Docker Compose
-   VS Code

## docker-compose.yml

version: "3.8"

services: ollama: image: ollama/ollama container_name: ollama ports: -
"11434:11434" volumes: - ollama:/root/.ollama restart: unless-stopped

open-webui: image: ghcr.io/open-webui/open-webui:main container_name:
open-webui ports: - "3000:8080" environment: -
OLLAMA_BASE_URL=http://ollama:11434 - WEBUI_AUTH=true -
ENABLE_API_KEY=true - ENABLE_API_KEY_GENERATION=true volumes: -
open-webui:/app/backend/data depends_on: - ollama restart:
unless-stopped

volumes: ollama: open-webui:

## Start

docker-compose up -d

## Access

http://localhost:3000

## Pull Model

docker exec -it ollama ollama pull phi3:mini

## VS Code Config (\~/.continue/config.yaml)

name: DevOps Local AI version: 1.0.0 schema: v1

models: - name: devops-local provider: openai model: phi3:mini apiBase:
http://localhost:3000/api apiKey: YOUR_API_KEY

defaultModel: devops-local

## Philosophy

Use AI to accelerate learning, not replace thinking.