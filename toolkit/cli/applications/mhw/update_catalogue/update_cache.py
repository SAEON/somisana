import os
import xarray as xr
from lib.log import log
from glob import glob
import asyncio
import aiohttp
import aiofiles
from config import PY_ENV
from oisst import Catalogue
import subprocess

# Throttle to 31 concurrent HTTP requests ( +/- 1 months data)
MAX_CONCURRENT_NET_IO = 31


def validate_nc_file(file):
    log(f"Validating {file}")
    try:
        with xr.open_dataset(file) as ds:
            
            dimensions = {
                "time": len(ds["time"]),
                "lon": len(ds["lon"]),
                "lat": len(ds["lat"]),
            }
            for dim, size in dimensions.items():
                if size < 1:
                    log(f"0-length dimension found. {dim}: {size}")
                    raise Exception("Empty NetCDF file found")
    except Exception as e:
        print(f"NetCDF file invalid {file}. Deleted", e)
        try:
            os.unlink(file)
        except Exception as e2:
            log(f"Failed to delete {file}")
            raise e2


async def download_file(semaphore, file, domain, oisst_cache, reset_cache, chown):
    uri = file["uri"]
    filename = file["name"].replace(
        ".nc", "_{domain}.nc".format(domain="".join(str(v) for v in domain))
    )
    file_path = os.path.join(oisst_cache, filename)
    if not reset_cache:
        if os.path.isfile(file_path):
            # TODO check the file is valid otherwise overwrite it
            print("Cache hit", file_path)
            return

    west, east, south, north = domain
    async with semaphore:
        async with aiohttp.ClientSession(
            connector=aiohttp.TCPConnector(ssl=False)
        ) as session:
            async with session.get(
                uri,
                params={
                    "var": "sst",
                    "west": west,
                    "east": east,
                    "south": south,
                    "north": north,
                },
            ) as response:
                async with aiofiles.open(file_path, mode="wb") as f:
                    while True:
                        chunk = await response.content.read(1024)
                        if not chunk:
                            break
                        await f.write(chunk)
                # Check the NetCDF file is valid, otherwise delete
                validate_nc_file(file_path)
    if chown:
        subprocess.call(["chown", chown, file_path])
    subprocess.call(["chmod", "775", file_path])
    log("Downloaded", file_path)


async def resolve_download_uris(
    semaphore, refs, OISST_DATA, domain, oisst_cache, reset_cache, chown
):
    tasks = []
    async with semaphore:
        for ref in refs:
            async with Catalogue(
                "{url}/{ref}/catalog.xml".format(url=OISST_DATA, ref=ref)
            ) as catalogue:
                datasets = list(catalogue.datasets.values())
                files = [
                    {"uri": dataset.access_urls["NetcdfSubset"], "name": dataset.name}
                    for dataset in datasets
                ]

                for file in files:
                    tasks.append(
                        asyncio.create_task(
                            download_file(
                                semaphore,
                                file,
                                domain,
                                oisst_cache,
                                reset_cache,
                                chown,
                            )
                        )
                    )
    await asyncio.gather(*tasks)


def delete_cached_preliminary_files(oisst_cache):
    search = "_preliminary_"
    files = glob(os.path.join(oisst_cache, f"*{search}*"))
    for p in files:
        os.remove(p)


def update_cache(refs, OISST_DATA, domain, oisst_cache, reset_cache, chown):
    if PY_ENV == "development":
        print(
            "Warning! PY_ENV == development (for sanity sake, only a couple years of back data are checked)"
        )
        refs = refs[-48:]

    # First delete any cached preliminary files
    delete_cached_preliminary_files(oisst_cache)

    semaphore = asyncio.BoundedSemaphore(MAX_CONCURRENT_NET_IO)
    asyncio.run(
        resolve_download_uris(
            semaphore, refs, OISST_DATA, domain, oisst_cache, reset_cache, chown
        )
    )
