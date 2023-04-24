from lib.log import log
from postgis import pool
import os
import json


def load_pp_v1_output_to_pg(args):
    print("Load pv1 to pg")
