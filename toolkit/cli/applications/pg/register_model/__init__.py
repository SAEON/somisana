from lib.log import log
from postgis import pool
import os
import json


def register_model(args):
    id = args.id
    current_dir = os.path.dirname(os.path.abspath(__file__))
    models_file = os.path.join(current_dir, "models.json")
    merge_details_file = os.path.join(current_dir, "upsert-details.sql")
    merge_coordinates_file = os.path.join(current_dir, "upsert-coordinates.sql")
    update_geospatial_fields_file = os.path.join(
        current_dir, "update-geospatial-fields.sql"
    )

    with open(os.path.abspath(models_file)) as f1:
        models = json.load(f1)
        model = [model for model in models if model.get("id") == id]
        model = model[0] if model and len(model) > 0 else None
        if model == None:
            log(
                f'Model id: "{id}" is not defined in the models.json configuration file - this needs to be specified manually'
            )
            exit()
        with open(merge_details_file) as f1:
            with open(merge_coordinates_file) as f2:
                with open(update_geospatial_fields_file) as f3:
                    sql1 = f1.read()
                    sql2 = f2.read()
                    sql3 = f3.read()
                    with pool().connection() as conn:
                        # First insert the model information
                        log("Upserting model information")
                        conn.execute(
                            sql1,
                            (
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
                            ),
                        )
                        log("Upserting model coordinates")
                        conn.execute(sql2, (id,))
                        log("Updated model geospatial extents")
                        conn.execute(sql3, (id,))
