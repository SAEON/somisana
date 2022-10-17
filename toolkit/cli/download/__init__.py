import os
from datetime import datetime, timedelta
from pathlib import Path
from cli.download.mercator import download as mercator_download
from cli.download.gfs import download as gfs_download


def download(options, arguments):
    print("Downloading forecast model boundary data...")

    workdir = options.workdir
    matlab_env = options.matlab_env
    gfs = options.gfs
    mercator = options.mercator
    run_date = datetime.strptime(options.download_date, "%Y%m%d")
    domain = list(map(lambda i: float(i), options.domain.split(",")))

    hdays = 5
    fdays = 5
    date_start = run_date + timedelta(days=-hdays)
    date_end = run_date + timedelta(days=fdays)

    print("date", str(run_date))
    print("hindcast days", str(hdays))
    print("forecast days", str(fdays))
    print("simulation temporal coverage", str(date_start), "-", str(date_end))
    print(
        "spatial extent for download of global forcing data (west, east, south, north)",
        str(domain),
    )

    print("Downloads path", workdir)
    Path(workdir).mkdir(parents=True, exist_ok=True)

    if mercator:
        mercator_download(run_date, hdays, fdays, domain, workdir)

    if gfs:
        delta_days_gfs = gfs_download(run_date, hdays, fdays, domain, workdir)
        print("Configuring MatLab...")
        with open(matlab_env, "w+") as env:
            env.writelines(
                [
                    "RUN_DATE=" + str(datetime.strftime(run_date, '%Y-%m-%d')) + "\n",
                    "DELTA_DAYS_GFS=" + str(delta_days_gfs) + "\n",
                ]
            )
        os.chmod(matlab_env, 0o777)

    # Script complete
    print("Complete!")
