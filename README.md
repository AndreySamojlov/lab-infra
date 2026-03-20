# Lab Infra  
Self-hosted platform for automation and analytics:  
n8n + PostgreSQL + Grafana
  
## Architecture (high-level)  
- n8n → orchestration
- postgres → storage
- grafana → dashboards / observability UI
- prometheus → metrics storage
- node-exporter → host metrics
- cadvisor → container metrics
- loki → log storage
- promtail → log collection

## Quick start 
git clone _repo_  
cd lab-infra  
cp .env.example .env  
docker compose up -d

## Access
- cloud: http://104.248.41.116
- n8n: [http://localhost:5678](http://localhost:5678)
- grafana: [http://localhost:3000](http://localhost:3000)
- prometheus: http://localhost:9090
- loki: http://localhost:3100
- cadvisor: http://localhost:8080
- node-exporter: http://localhost:9100

### Monitoring / Logging
- Prometheus collects host/container metrics
- Grafana visualizes metrics and logs
- Loki stores centralized logs
- Promtail collects Docker logs
- node-exporter exposes VM metrics
- cadvisor exposes container metrics
## Configuration
All variables are defined in `.env`
See `.env.example` for reference

## Documentation
lab-infra/
├── README.md
└── docs/
    └── RUNBOOK.md

## Notes
- Do not commit `.env`
- System is fully reproducible from this repository
