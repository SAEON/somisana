import os
from datetime import datetime, timedelta
from pathlib import Path
from lib.log import log
from cli.applications.download.mercator import download as mercator_download
from cli.applications.download.gfs import download as gfs_download


def download(args):
    workdir = args.workdir
    matlab_env = args.matlab_env
    gfs = args.provider == "gfs"
    mercator = args.provider == "mercator"
    run_date = datetime.strptime(args.download_date, "%Y%m%d")
    domain = list(map(lambda i: float(i), args.domain.split(",")))

    hdays = args.hdays
    fdays = args.fdays
    date_start = run_date + timedelta(days=-hdays)
    date_end = run_date + timedelta(days=fdays)

    log("CONFIG::date", str(run_date))
    log("CONFIG::hdays", str(hdays))
    log("CONFIG::fdays", str(fdays))
    log("CONFIG::simulation temporal coverage", str(date_start), "-", str(date_end))
    log(
        "CONFIG::domain (west, east, south, north)",
        str(domain),
    )

    log("CONFIG::workdir", os.path.abspath(workdir))
    Path(workdir).mkdir(parents=True, exist_ok=True)

    if mercator:
        mercator_download(run_date, hdays, fdays, domain, workdir)

    if gfs:
        delta_days_gfs = gfs_download(run_date, hdays, fdays, domain, workdir)
        log("Configuring MatLab...")
        with open(matlab_env, "w+") as env:
            env.writelines(
                [
                    "RUN_DATE=" + str(datetime.strftime(run_date, "%Y-%m-%d")) + "\n",
                    "DELTA_DAYS_GFS=" + str(delta_days_gfs) + "\n",
                ]
            )
        try:
            os.chmod(matlab_env, 0o777)
        except:
            log(
                "Unable to run os.chmod on the .env file - you may have to do this manually"
            )

    # Script complete
    log("Completed! If you don't see this there was an error")
