from lib.log import log


async def upsert_model_info(
    pool,
    id,
    model,
    merge_details,
    merge_coordinates,
    update_geospatial_fields,
):
    async with pool.acquire() as conn:
        async with conn.transaction():
            q1 = await conn.prepare(merge_details)
            await q1.fetch(
                id,
                model["title"],
                model["description"],
                model["creator"],
                model["creator_contact_email"],
                model["type"],
                model["grid_width"],
                model["grid_height"],
                model["sigma_levels"],
                model["min_x"],
                model["max_x"],
                model["min_y"],
                model["max_y"],
            )
            log(f"Upserted {id} info")
            q2 = await conn.prepare(merge_coordinates)
            await q2.fetch(id)
            log(f"Upserted {id} coordinates")
            q3 = await conn.prepare(update_geospatial_fields)
            await q3.fetch(id)
            log(f"Upserted {id} geospatial info")
