# TODO
schedule a cleanup of public.values table. Currently the command must be run manually. Either this should be added to a CRON or specified in the web app. Be careful not to delete all the public.values rows in the case that this query gets run twice in quick succession.

This can definitely be simpliefied

```sh
docker \
  run \
  -d \
  -i \
  --name delete_values \
  --net pg \
  ghcr.io/saeon/postgis:latest \
    sh -c \
      "psql \
        postgresql://username:password@hostname:port/dbname \
        -c 'with recent_successful_runs as ( \
              select \
                id, \
                modelid, \
                row_number() over (partition by modelid order by id desc) as row_num \
              from public.runs \
              where successful = true ) \
            ,run_stats as ( \
              select \
                modelid, \
                max(id) target_runid, \
                min(id) oldest_runid, \
                max(row_num) max_row_num, \
                min(row_num) max_row_num \
              from recent_successful_runs \
              where row_num > 10 \
              group by modelid \
              having max(id) > min(id) ) \
            ,oldest_useful_run as ( \
              select min(runid) runid \
              from ( \
                select min(target_runid) runid \
                from run_stats \
                union \
                select id runid from runs where successful = false ) r ) \
            delete from public."values" v \
            where v.runid < (select runid from oldest_useful_run);'"
```