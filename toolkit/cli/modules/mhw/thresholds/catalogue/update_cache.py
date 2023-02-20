import os
import asyncio
import aiohttp
import aiofiles
from config import PY_ENV
from cli.modules.mhw.oisst import Catalogue


async def download_file(semaphore, file, domain, mhw_bulk_cache, reset_cache):
    uri = file["uri"]
    filename = file["name"]
    file_path = os.path.join(mhw_bulk_cache, filename)
    if not reset_cache:
        if os.path.isfile(file_path):
            # TODO check the file is vali otherwise overwrite it
            print("Cache hit", file_path)
            return

    print("Downloading", file_path)
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

    print("Completed", file_path)


async def resolve_download_uris(ref, OISST_DATA, domain, mhw_bulk_cache, reset_cache):
    print("{base}/{ref}".format(base=OISST_DATA, ref=ref), "Finding downloads")
    url = "{url}/{ref}/catalog.xml".format(url=OISST_DATA, ref=ref)
    async with Catalogue(url) as catalogue:
        datasets = list(catalogue.datasets.values())
        files = [
            {"uri": dataset.access_urls["NetcdfSubset"], "name": dataset.name}
            for dataset in datasets
        ]

        # Allow for downloading one months worth of data concurrently
        semaphore = asyncio.Semaphore(31)
        tasks = []
        for file in files:     
            tasks.append(
                asyncio.create_task(
                    download_file(semaphore, file, domain, mhw_bulk_cache, reset_cache)
                )
            )
        await asyncio.gather(*tasks)


def update_cache(refs, OISST_DATA, domain, mhw_bulk_cache, reset_cache):
    if PY_ENV == "development":
        print(
            "Warning! PY_ENV == development (for sanity sake, only a couple years of back data are checked)"
        )
        refs = refs[:12]
    for ref in refs:
        asyncio.run(
            resolve_download_uris(
                ref, OISST_DATA, domain, mhw_bulk_cache, reset_cache
            )
        )