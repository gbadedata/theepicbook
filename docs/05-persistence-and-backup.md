# EpicBook: Persistence, Backup and Restore

Prepared by Oluwagbade Odimayo.

## What persists

MySQL stores its data in the `db_data` named volume (`/var/lib/mysql`). `docker compose down` removes containers and networks but keeps `db_data`; `docker compose down -v` deletes it and must only be used for a deliberate full reset, after taking a backup.

## Backup plan

- **Method:** logical backup with `mysqldump --single-transaction`, which takes a consistent snapshot without locking the tables.
- **Command:** `scripts/backup.sh`, which writes `backups/bookstore-<UTC timestamp>.sql` on the host and checks the dump completed.
- **When:** before any change to the stack or database, and on a schedule (for example daily via cron).
- **Where:** the host `backups/` directory, which is excluded from Git; copy backups off the VM (for example to S3) so they survive the loss of the VM.
- **Credentials:** the root password is read inside the container from its own environment and never appears in commands, logs or files.

## Restore procedure

1. Confirm the stack is running and the database is healthy: `docker compose ps`.
2. Choose the backup: `ls -lh backups/`.
3. Restore: `scripts/restore.sh backups/<file>.sql`.
4. Verify the data with a query against the restored tables, then load the application through the reverse proxy.

## Drill performed

A test author record was inserted, a backup was taken, the record was deleted to simulate data loss, and the backup was restored. The record was present again after the restore, and the data also survived a non-destructive `docker compose down` / `up` cycle.
