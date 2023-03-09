import os
import asyncio
import aiohttp
import aiofiles
from config import PY_ENV
from oisst import Catalogue
import subprocess

# Throttle to 31 concurrent HTTP requests ( +/- 1 months data)
MAX_CONCURRENT_NET_IO = 31


async def download_file(semaphore, file, domain, mhw_bulk_cache, reset_cache, chown):
    uri = file["uri"]
    filename = file["name"]
    file_path = os.path.join(mhw_bulk_cache, filename)
    if not reset_cache:
        if os.path.isfile(file_path):
            # TODO check the file is valid otherwise overwrite it
            print("Cache hit", file_path)
            return

    west, east, south, north = domain
    async with semaphore:
        async with aiohttp.ClientSession() as session:
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
    if chown:
        subprocess.call(["chown", chown, file_path])
    subprocess.call(["chmod", "775", file_path])
    print("Downloaded", file_path)


async def resolve_download_uris(
    semaphore, refs, OISST_DATA, domain, mhw_bulk_cache, reset_cache, chown
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
                                mhw_bulk_cache,
                                reset_cache,
                                chown,
                            )
                        )
                    )
    await asyncio.gather(*tasks)


def update_cache(refs, OISST_DATA, domain, mhw_bulk_cache, reset_cache, chown):
    if PY_ENV == "development":
        print(
            "Warning! PY_ENV == development (for sanity sake, only a couple years of back data are checked)"
        )
        refs = refs[:44]

    semaphore = asyncio.BoundedSemaphore(MAX_CONCURRENT_NET_IO)
    asyncio.run(
        resolve_download_uris(
            semaphore, refs, OISST_DATA, domain, mhw_bulk_cache, reset_cache, chown
        )
    )
