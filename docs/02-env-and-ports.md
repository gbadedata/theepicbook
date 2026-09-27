# EpicBook: Environment Variables, Ports, Persistence and Health Checks

Prepared by Oluwagbade Odimayo. Values are never stored in Git: real secrets live only in `.env` on the server, and `.env.example` holds placeholders.

## Environment variables

| Variable | Used by | Purpose |
|---|---|---|
| `MYSQL_ROOT_PASSWORD` | database | MySQL root password (backups and restores only) |
| `MYSQL_USER` | database, backend | Application database user |
| `MYSQL_PASSWORD` | database, backend | Application database user's password |
| `MYSQL_DATABASE` | database | Fixed to `bookstore`, because the seed SQL runs `USE bookstore;` |
| `NODE_ENV` | backend | `production`, so the app reads its connection from `JAWSDB_URL` |
| `PORT` | backend | Port the Node app listens on (`8080`) |
| `JAWSDB_URL` | backend | Connection URL built by Compose from the variables above; never written to logs |
| `DB_LOG_SQL` | backend | Optional; `true` turns on SQL statement logging for debugging |

## Ports

| Service | Internal port | Published to the host | Networks |
|---|---|---|---|
| reverse-proxy (Nginx) | 80 | **80 (the only public port)** | front-tier |
| frontend (Nginx, static files) | 80 | No | front-tier |
| backend (Node.js, Express) | 8080 | No | front-tier, back-tier |
| database (MySQL 8.4) | 3306 | No | back-tier (internal) |

On the VM, the security group allows 80 from anywhere and 22 from my IP only.

## Persistent data

- `db_data` named volume, mounted at `/var/lib/mysql`: all book, author, cart and checkout data.
- `./logs/proxy` host directory, mounted at `/var/log/nginx`: reverse-proxy access and error logs.
- `./backups` host directory: SQL dumps created by `scripts/backup.sh`.
- The SQL files in `db/` are mounted read-only into `/docker-entrypoint-initdb.d/` and only run when `db_data` is empty.

## Health-check method

| Service | Method |
|---|---|
| database | `mysqladmin ping` over TCP (127.0.0.1) as the application user |
| backend | `GET /health` returns 200 only when the app can reach MySQL (503 otherwise) |
| frontend | Fetches `/assets/css/style.css` from its own Nginx |
| reverse-proxy | Fetches its own `/proxy-health` endpoint |
