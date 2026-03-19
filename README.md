# Lab Infra  
Self-hosted platform for automation and analytics:  
n8n + PostgreSQL + Grafana  
  
## Architecture (high-level)  
n8n → orchestration  
postgres → storage  
grafana → dashboards  
  
## Quick start 
git clone _repo_  
cd lab-infra  
cp .env.example .env  
docker compose up -d

## Access
- cloud: http://104.248.41.116
- n8n: [http://localhost:5678](http://localhost:5678)
- grafana: [http://localhost:3000](http://localhost:3000)

## Configuration
All variables are defined in `.env`
See `.env.example` for reference

## Documentation
lab-infra/  
├── .gitignore  
├── .env.example  
├── README.md  
├── docker-compose.yml  
└── RUNBOOK.md

## Notes
- Do not commit `.env`
- System is fully reproducible from this repository
