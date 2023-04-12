import asyncio
from datetime import datetime, timedelta, time
from cli.applications.ops.download.gfs.functions import (
    download_file,
    get_latest_available_dt,
    set_params,
    create_fname,
)

"""
Download GFS forecast data for running a croco model
Data is downloaded from hdays before date_now till hdays after date_now
The GFS model is initialised every 6 hours, and provides hourly forecasts
For the historical data we download the forecast for hours 1 through 6 from each initialisation 
The forecast data gets downloaded from the latest available initialisation

The latest initialisation is used at the time this is run, so that if there is an error on GFS
side then a slightly older initialization will be found
"""

# nomads.ncep.noaa.gov has strict rate limits,
# so keep this number low
MAX_CONCURRENT_NET_IO = 2


async def download_hindcast(semaphore, start, end, workdir, params):
    tasks = []
    while start < end:
        for i in range(1, 7):  # hours 1 to 6
            tasks.append(
                asyncio.create_task(
                    download_file(
                        semaphore,
                        create_fname(start, i),
                        workdir,
                        set_params(params, start, i),
                    )
                )
            )
        start = start + timedelta(hours=6)
    await asyncio.gather(*tasks)


async def download_forecast(
    semaphore, total_forecast_hours, latest_available_date, workdir, params
):
    tasks = []
    for i in range(1, total_forecast_hours + 1):
        tasks.append(
            asyncio.create_task(
                download_file(
                    semaphore,
                    create_fname(latest_available_date, i),
                    workdir,
                    set_params(params, latest_available_date, i),
                )
            )
        )
    await asyncio.gather(*tasks)


def download(run_date, hdays, fdays, domain, workdir):
    _now = datetime.now()
    hdays = hdays + 0.25
    fdays = fdays + 0.25
    run_date = datetime.combine(run_date, time())
    start_date = run_date + timedelta(days=-hdays)

    latest_available_date = get_latest_available_dt(run_date)
    delta_days = (latest_available_date - run_date).total_seconds() / 86400

    params = {
        "lev_10_m_above_ground": "on",
        "lev_2_m_above_ground": "on",
        "lev_surface": "on",
        "var_DLWRF": "on",
        "var_DSWRF": "on",
        "var_LAND": "on",
        "var_PRATE": "on",
        "var_RH": "on",
        "var_TMP": "on",
        "var_UFLX": "on",
        "var_UGRD": "on",
        "var_ULWRF": "on",
        "var_USWRF": "on",
        "var_VFLX": "on",
        "var_VGRD": "on",
        "subregion": "",
        "leftlon": str(domain[0]),
        "rightlon": str(domain[1]),
        "toplat": str(domain[3]),
        "bottomlat": str(domain[2]),
    }

    # Download forcing files up to latest available date
    print("\nDOWNLOADING HINDCAST files")
    asyncio.run(
        download_hindcast(
            asyncio.BoundedSemaphore(MAX_CONCURRENT_NET_IO),
            start_date,
            latest_available_date,
            workdir,
            params,
        )
    )

    # Download forecast forcing files
    print("\nDOWNLOADING FORECAST files")
    total_forecast_hours = int((fdays - delta_days) * 24)
    asyncio.run(
        download_forecast(
            asyncio.BoundedSemaphore(MAX_CONCURRENT_NET_IO),
            total_forecast_hours,
            latest_available_date,
            workdir,
            params,
        )
    )

    print("GFS download completed (in " + str(datetime.now() - _now) + " h:m:s)")
    return delta_days
