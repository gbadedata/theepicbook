# EpicBook: Health Checks and Startup Order

Prepared by Oluwagbade Odimayo.

## Health check per service

- **database:** `mysqladmin ping -h 127.0.0.1` as the application user, with the password passed through the container's own environment (`MYSQL_PWD`), so it never appears in the Compose file. Using TCP matters: during first-time initialisation MySQL runs a temporary server with networking disabled, so a socket-based `localhost` ping would report healthy before the real server is accepting connections.
- **backend:** `wget http://127.0.0.1:8080/health`. The `/health` route runs `sequelize.authenticate()` and returns 200 `{"status":"ok","database":"up"}`, or 503 `{"status":"error","database":"down"}` if MySQL is unreachable. It is a readiness check, so the backend only counts as healthy when it can actually serve data.
- **frontend:** `wget http://127.0.0.1/assets/css/style.css`, which proves Nginx is up and serving the real static files, not just listening.
- **reverse-proxy:** `wget http://127.0.0.1/proxy-health`, a route answered by Nginx itself. It checks the proxy only, so a backend problem shows up as an unhealthy backend, not as an unhealthy proxy.

## Startup order

1. **database** starts first and must pass its health check.
2. **backend** waits for `database: condition: service_healthy`.
3. **frontend** has no dependencies and starts in parallel.
4. **reverse-proxy** waits for both `frontend` and `backend` to be `service_healthy`, so the public port only opens when the whole stack can serve requests.

Plain `depends_on` only waits for a container to start, not for the application inside it to be ready; `condition: service_healthy` waits for the health check to pass. All services use `restart: unless-stopped`, so a crashed container is restarted automatically.
