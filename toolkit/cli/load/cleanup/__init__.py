from datetime import datetime
from postgis import pool


def run(start_time, model):
    print(
        str(datetime.now() - start_time).split(".")[0],
        "::",
        "Cleaning up rasters table",
    )

    with pool().connection() as client:
        client.execute(
            """
            delete from public.rasters r
            where rid in (
              select
                x.rasterid
              from
                raster_xref_run x
              join
                runs r on r.id = x.runid
              join
                models m on m.id = r.modelid
              where
                m.name = %s )
            )""",
            (model,),
        )
