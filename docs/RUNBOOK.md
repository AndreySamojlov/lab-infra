# START / STOP

docker compose up -d  
docker compose down  
docker compose restart

# HEALTH-CHECK

|                      | cmd                                                                                                                   | check                                               | result              |
| -------------------- | --------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- | ------------------- |
| **Доступ к серверу** | ssh root@104.248.41.116                                                                                               | root@lab-01:~#                                      | → доступ есть       |
| **Контейнеры**       | docker ps                                                                                                             | lab-n8n Up  <br>lab-postgres Up  <br>lab-grafana Up | → все запущены      |
| **Ресурсы**          | docker stats                                                                                                          | CPU < 10%  <br>MEM < 50%  <br>нет аномалий          | → нагрузка норм     |
| **Локальная сеть**   | curl http://localhost:5678  <br>curl http://localhost:3000                                                            | HTTP response получен                               | → сервисы отвечают  |
| **Внешний доступ**   | http://104.248.41.116:5678  <br>http://104.248.41.116:3000                                                            | UI открывается                                      | → доступ извне есть |
| **База данных**      | docker exec -it lab-postgres psql -U admin -d n8n                                                                     | SELECT 1;                                           | → БД работает       |
| **Логи**             | docker logs -t --tail 10 lab-n8n  <br>docker logs -t --tail 10 lab-postgres  <br>docker logs -t --tail 10 lab-grafana | нет FATAL <br>/ crash<br>/ restart loop             | → сервисы стабильны |

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
## Git
git init  
git status                     # текущее состояние  
git add .                      # добавить изменения  
git commit -m "message"       # зафиксировать  
git log --oneline             # история
