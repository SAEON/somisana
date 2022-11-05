from datetime import datetime
from postgis import pool


def run(start_time, model, runid):
    print(
        str(datetime.now() - start_time).split(".")[0],
        "::",
        "Cleaning up rasters table",
    )

    with pool().connection() as client:
        # Remove raster files
        client.execute(
            """
          delete from public.rasters r
          where rid in (
              select
                x.rasterid
              from
                raster_xref_run x
              where
                x.runid = %s);
          """,
            (runid,),
        )

        # Mark this run as successful
        client.execute(
            """update public.runs set successful = true where id = %s;""", (runid,)
        )

        # Re-analyze the tables
        client.execute("analyze public.runs;")
        client.execute("analyze public.coordinates;")
        client.execute("analyze public.values;")
