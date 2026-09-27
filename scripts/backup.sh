#!/usr/bin/env bash
# Logical backup of the bookstore database to ./backups on the host. Credentials stay inside the container.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p backups
file="backups/bookstore-$(date -u +%Y%m%d-%H%M%S).sql"
docker compose exec -T database sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysqldump -uroot --single-transaction --routines --triggers bookstore' > "$file"
grep -q "Dump completed" "$file" || { echo "Backup incomplete: $file"; exit 1; }
echo "Backup created: $file ($(du -h "$file" | cut -f1))"
