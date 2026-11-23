# Databases

Single template to deploy multiple databases:

- PostgreSQL
- Redis

Postgres operator

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm repo update
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

pgbouncer: https://cloudnative-pg.io/docs/1.30/connection_pooling#pgbouncer-configuration-options