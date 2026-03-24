# START / STOP

docker compose up -d  
docker compose down  
docker compose restart

# HEALTH-CHECK

|                      | cmd                                                                                                                                                                                                                                                                                                                                   | check                                                                                                                                                 | result              |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| **Доступ к серверу** | ssh root@104.248.41.116                                                                                                                                                                                                                                                                                                               | root@lab-01:~#                                                                                                                                        | → доступ есть       |
| **Контейнеры**       | docker ps                                                                                                                                                                                                                                                                                                                             | lab-n8n Up  <br>lab-postgres Up  <br>lab-grafana Up<br>lab-prometheus Up<br>lab-node-exporter Up<br>lab-cadvisor Up<br>lab-loki Up<br>lab-promtail Up | → все запущены      |
| **Ресурсы**          | docker stats                                                                                                                                                                                                                                                                                                                          | CPU < 10%  <br>MEM < 50%  <br>нет аномалий                                                                                                            | → нагрузка норм     |
| **Локальная сеть**   | curl http://localhost:5678  <br>curl http://localhost:3000<br>curl http://localhost:9090<br>curl http://localhost:3100                                                                                                                                                                                                                | HTTP response получен                                                                                                                                 | → сервисы отвечают  |
| **Внешний доступ**   | http://104.248.41.116:5678  <br>http://104.248.41.116:3000<br>http://104.248.41.116:9090                                                                                                                                                                                                                                              | UI открывается                                                                                                                                        | → доступ извне есть |
| **База данных**      | docker exec -it lab-postgres psql -U admin -d n8n                                                                                                                                                                                                                                                                                     | SELECT 1;                                                                                                                                             | → БД работает       |
| **Логи**             | docker logs -t --tail 10 lab-n8n  <br>docker logs -t --tail 10 lab-postgres  <br>docker logs -t --tail 10 lab-grafana<br>docker logs -t --tail 10 lab-loki<br>docker logs -t --tail 10 lab-promtail<br>docker logs -t --tail 50 lab-prometheus<br>docker logs -t --tail 50 lab-node-exporter    docker logs -t --tail 50 lab-cadvisor | нет FATAL <br>/ crash<br>/ restart loop                                                                                                               | → сервисы стабильны |



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
docker logs --tail 50 lab-postgres  
docker logs --tail 50 lab-grafana  
docker logs -f lab-n8n         # realtime
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
