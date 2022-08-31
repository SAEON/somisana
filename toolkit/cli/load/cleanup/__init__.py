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
              select rid from raster_xref_model x
              join models m on m.id = x.modelid 
              where m.name = %s 
            )""",
            (model,),
        )
