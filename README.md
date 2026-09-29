# postgres
Base PostgreSQL image for digital applications. Includes: postgis, pg_cron, pgvector, pg_stat_statements

`pg_stat_statements` and `pg_cron` are loaded via `shared_preload_libraries` by default (see Dockerfile `CMD`); deployments can override this. Run `CREATE EXTENSION pg_stat_statements;` (and `CREATE EXTENSION pg_cron;`) in each database that needs them.
