from datetime import timedelta
import os
from lib.log import log
from config import COPERNICUS_PASSWORD as PWD, COPERNICUS_USERNAME as USER
import xarray as xr
import asyncio
import subprocess
import time
from lib.open_datasets import open_datasets


def is_valid_netcdf_file(file_path):
    try:
        with xr.open_dataset(file_path) as ds:
            return True
    except:
        return False


VARIABLES = [
    {
        "name": "so",
        "#": "Salinity in psu",
        "id": "cmems_mod_glo_phy-so_anfc_0.083deg_P1D-m",
        "vars": ["so"],
    },
    {
        "name": "thetao",
        "#": "Temperature in degrees C",
        "id": "cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m",
        "vars": ["thetao"],
    },
    {
        "name": "zos",
        "#": "SSH in m",
        "id": "cmems_mod_glo_phy_anfc_0.083deg_P1D-m",
        "vars": ["zos"],
    },
    {
        "name": "uo_vo",
        "#": "uo:Eastward velocity in m/s | vo:Northward velocity in m/s",
        "id": "cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m",
        "vars": ["uo", "vo"],
    },
]

DEPTH_RANGE = [0.493, 5727.918]

MAX_RETRIES = 3
RETRY_WAIT = 10


async def run_cmd(c, run_date, start_date, end_date, domain, workdir):
    dataset = c["id"]
    name = c["name"]
    vars = c["vars"]
    variables = f"--variable {' --variable '.join(vars)} "
    fname = f"mercator_{name}_{run_date.strftime('%Y%m%d')}.nc"
    c["fname"] = fname

    runcommand = f"""
        motuclient \
            --user {USER} \
            --pwd {PWD} \
            --motu http://nrt.cmems-du.eu/motu-web/Motu \
            --service-id GLOBAL_ANALYSISFORECAST_PHY_001_024-TDS \
            --product-id {dataset} \
            --longitude-min {domain[0]} \
            --longitude-max {domain[1]} \
            --latitude-min {domain[2]} \
            --latitude-max {domain[3]} \
            --date-min "{start_date.strftime("%Y-%m-%d")}" \
            --date-max "{end_date.strftime("%Y-%m-%d")}" \
            --depth-min {DEPTH_RANGE[0]} \
            --depth-max {DEPTH_RANGE[1]} \
            {variables} \
            --out-dir {os.path.normpath(workdir)} \
            --out-name {fname}"""

    log(" ".join(runcommand.split()))
    f = os.path.normpath(os.path.join(workdir, fname))
    if os.path.exists(f) == False:
        for i in range(MAX_RETRIES):
            log(
                f"downloading latest mercator ocean forecast from CMEMS. Attempt {i + 1} of {MAX_RETRIES}"
            )
            try:
                subprocess = await asyncio.create_subprocess_shell(runcommand)
                await subprocess.communicate()
                if subprocess.returncode != 0:
                    raise Exception(
                        f"Mercator download failed from cmd: {name}. Exit code: {subprocess.returncode}"
                    )
                else:
                    if is_valid_netcdf_file(f):
                        log("Completed", name)
                        return
                    else:
                        os.unlink(f)
                        raise Exception(
                            f"Mercator download failed (bad NetCDF output) for variable {name}"
                        )
            except Exception as e:
                log(f"Error: {e}, retrying in {RETRY_WAIT} seconds...")
                time.sleep(RETRY_WAIT)
        log(f"Failed to download after 3 attempts: {name}")
    else:
        log(
            os.path.normpath(os.path.join(workdir, fname)),
            "already exists - not downloading mercator data",
        )


async def batch_cmds(run_date, start_date, end_date, domain, workdir):
    await asyncio.gather(
        *(
            run_cmd(c, run_date, start_date, end_date, domain, workdir)
            for c in VARIABLES
        )
    )


def get_path(f, workdir):
    return os.path.abspath(os.path.join(workdir, f))


def download(run_date, hdays, fdays, domain, workdir):
    log(" => Copernicus Marine Environment Monitoring Service (CMEMS) download")
    hdays = hdays + 1
    fdays = fdays + 1
    start_date = run_date + timedelta(days=-hdays)
    end_date = run_date + timedelta(days=fdays)

    # Download the separate NetCDF files
    asyncio.run(batch_cmds(run_date, start_date, end_date, domain, workdir))

    # Concatenate the separate NetCDF files into the expected single file structure
    log("concatenating NetCDF files")
    output_path = os.path.abspath(
        os.path.join(workdir, f"mercator_{run_date.strftime('%Y%m%d')}.nc")
    )
    with open_datasets(
        *[get_path(el["fname"], workdir) for el in VARIABLES]
    ) as datasets:
        encoding = {
            "zos": {
                "dtype": "float32",
                "scale_factor": 0.000305185094475746,
                "add_offset": 0.0,
            },
            "so": {
                "dtype": "float32",
                "add_offset": -0.00152592547237873,
                "scale_factor": 0.00152592547237873,
            },
            "uo": {
                "dtype": "float32",
                "scale_factor": 0.000610370188951492,
                "add_offset": 0.0,
            },
            "vo": {
                "dtype": "float32",
                "scale_factor": 0.000610370188951492,
                "add_offset": 0.0,
            },
            "thetao": {
                "dtype": "float32",
                "scale_factor": 0.000732444226741791,
                "add_offset": 21.0,
            },
        }
        with xr.merge(datasets) as ds:
            ds.to_netcdf(
                output_path, mode="w", encoding=encoding, format="NETCDF3_CLASSIC"
            )

    subprocess.call(["chmod", "-R", "775", output_path])
