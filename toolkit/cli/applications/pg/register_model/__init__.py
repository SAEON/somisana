from lib.log import log
import os
import json


def register_model(args):
    id = args.id
    current_dir = os.path.dirname(os.path.abspath(__file__))
    models_file = os.path.join(current_dir, "models.json")
    with open(os.path.abspath(models_file)) as f:
        models = json.load(f)
        model = [model for model in models if model.get("id") == id]
        model = model[0] if model and len(model) > 0 else None
        if model == None:
            log(
                f'Model id: "{id}" is not defined in the models.json configuration file - this needs to be specified manually'
            )
            exit()
        log(model)
