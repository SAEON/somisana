# TODO
The pg_tileserv image can't take configuration via stack envs currently. This should be updated. In the meantime

```
docker run \
  -dt \
  --restart always \
  --name pg_tileserv \
  -p 7009:7800 \
  -e DATABASE_URL=postgres://admin:password@localhost:5432/somisana_local \
  pramsey/pg_tileserv:latest
```