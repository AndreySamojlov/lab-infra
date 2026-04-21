# START / STOP
```bash
docker compose up -d  # Start all services
docker compose down  # Stop all service
docker compose restart  #Restart all services
```
# HEALTH-CHECK

|                             | cmd                                                                                                                                                                                                                                                                                                                                   | check                                                                                                                                                 | result                |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| **Доступ к серверу**        | ssh root@104.248.41.116<br>ssh root@lab-do                                                                                                                                                                                                                                                                                            | root@lab-01:~#                                                                                                                                        | → доступ есть         |
| **Контейнеры**              | docker ps                                                                                                                                                                                                                                                                                                                             | lab-n8n Up  <br>lab-postgres Up  <br>lab-grafana Up<br>lab-prometheus Up<br>lab-node-exporter Up<br>lab-cadvisor Up<br>lab-loki Up<br>lab-promtail Up | → все запущены        |
| **Ресурсы**                 | docker stats                                                                                                                                                                                                                                                                                                                          | CPU < 10%  <br>MEM < 50%  <br>нет аномалий                                                                                                            | → нагрузка норм       |
| **Локальная сеть (docker)** | docker exec lab-caddy wget -qO- http://n8n:5678  <br>docker exec lab-caddy wget -qO- http://grafana:3000                                                                                                                                                                                                                              | HTTP response получен                                                                                                                                 | → сервисы отвечают    |
| **Локальная сеть (caddy)**  | curl -vk --resolve n8n.samandrey.work:443:127.0.0.1 https://n8n.samandrey.work  <br>curl -vk --resolve grafana.samandrey.work:443:127.0.0.1 https://grafana.samandrey.work                                                                                                                                                            | Открыт UI                                                                                                                                             | → html получен        |
| **DNS**                     | nslookup n8n.samandrey.work                                                                                                                                                                                                                                                                                                           | Получен IP                                                                                                                                            | → IP = 104.248.41.116 |
| **Внешний доступ**          | https://n8n.samandrey.work/<br>https://grafana.samandrey.work/                                                                                                                                                                                                                                                                        | UI открывается                                                                                                                                        | → доступ извне есть   |
| **База данных**             | docker exec -it lab-postgres psql -U admin -d n8n                                                                                                                                                                                                                                                                                     | SELECT 1;                                                                                                                                             | → БД работает         |
| **Логи**                    | docker logs -t --tail 10 lab-n8n  <br>docker logs -t --tail 10 lab-postgres  <br>docker logs -t --tail 10 lab-grafana<br>docker logs -t --tail 10 lab-loki<br>docker logs -t --tail 10 lab-promtail<br>docker logs -t --tail 10 lab-prometheus<br>docker logs -t --tail 10 lab-node-exporter    docker logs -t --tail 10 lab-cadvisor | нет FATAL <br>/ crash<br>/ restart loop                                                                                                               | → сервисы стабильны   |



# COMMANDS

## Docker
docker compose up -d              # запуск всех сервисов  
docker compose down              # остановка  
docker compose restart           # перезапуск  
docker compose ps                # статус сервисов  
docker compose logs              # все логи (агрегировано)

docker compose up -d --force-recreate grafana   # пересоздать контейнер  
docker compose up -d --build                    # пересобрать (если есть build)

docker ps                      # список контейнеров  
docker stats                   # нагрузка (CPU / RAM)  
docker inspect lab-n8n         # подробности контейнера
## Logs
docker logs --tail 50 lab-n8n  
docker logs --tail 50 lab-n8n-mcp  
docker logs --tail 50 lab-postgres  
docker logs --tail 50 lab-grafana  
docker logs -f lab-n8n         # realtime
docker logs -f lab-n8n-mcp
## PostgreSQL
docker exec -it lab-postgres psql -U admin -d n8n
Внутри:
SELECT 1;        -- проверка  
\dt              -- список таблиц  
\q               -- выход

1. Start SSH tunnel: ssh -i ~/.ssh/id_ed25519 -L 15432:127.0.0.1:5432 root@104.248.41.116  
2. Connect from DBeaver:  
	- Host: localhost  
	- Port: 15432  
	- User: admin  
3. List databases: docker exec -it lab-postgres psql -U admin -l  
4. Backup database  
	- mkdir -p /opt/backups/postgres  
	- docker exec lab-postgres pg_dump -U admin -d career_upgrade_lab > /opt/backups/postgres/career_upgrade_lab.sql  
5. Restore database  
	- docker exec -i lab-postgres psql -U admin -d career_upgrade_lab < /opt/backups/postgres/career_upgrade_lab.sql  
6. Test restore: 
	- CREATE DATABASE career_upgrade_lab_test;  
	- docker exec -i lab-postgres psql -U admin -d career_upgrade_lab_test < backup.sql  
7. Basic checks:   
	- SELECT current_database();  
	- SELECT count(') FROM information_schema.tables;
8. Backup (manual)  
	  - cd /opt/lab-infra
	  - ./scripts/backup-postgres.sh  
	  - ls /opt/backups/postgres  
9. Restore (test)  
	  - CREATE DATABASE restore_test;  
	  - docker exec -i lab-postgres psql -U admin -d restore_test < /opt/backups/postgres/<...>.sql  
- Check:  
	- SELECT count(*) FROM information_schema.tables;

## Git
git init  
git status                     # текущее состояние  
git add .                      # добавить изменения  
git commit -m "message"       # зафиксировать  
git log --oneline             # история

## Monitoring  
**Prometheus**  
- UI: http://localhost:9090  
- health: curl http://localhost:9090/-/healthy  
**Node Exporter**  
- metrics endpoint:  http://localhost:9100/metrics  
**Grafana datasource**
- Prometheus URL inside docker network:  http://prometheus:9090
**Loki**
- health: curl http://localhost:3100/ready
- API labels: curl -G -s "http://localhost:3100/loki/api/v1/labels"
**Promtail**
- check logs: docker logs --tail 50 lab-promtail
**Grafana datasource**
- Loki URL inside docker network: http://loki:3100
**cAdvisor**
- UI / endpoint: http://localhost:8080
- container metrics source for Prometheus

## n8n-mcp
docker exec lab-caddy wget -qO- http://n8n-mcp:3000/health
curl -vk --resolve n8n-mcp.samandrey.work:443:127.0.0.1 https://n8n-mcp.samandrey.work/health
TOKEN=$(grep '^N8N_MCP_AUTH_TOKEN=' .env | cut -d= -f2-) && curl -i -X POST https://n8n-mcp.samandrey.work/mcp -H "Authorization: Bearer $TOKEN" -H "Accept: application/json, text/event-stream" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"curl-smoke-test","version":"1.0.0"}}}'
