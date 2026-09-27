#!/usr/bin/env bash
# Restore the bookstore database from a backup file created by scripts/backup.sh.
set -euo pipefail
cd "$(dirname "$0")/.."
file="${1:?usage: scripts/restore.sh backups/<file>.sql}"
[ -s "$file" ] || { echo "Backup file not found or empty: $file"; exit 1; }
docker compose exec -T database sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot bookstore' < "$file"
echo "Restore completed from: $file"
