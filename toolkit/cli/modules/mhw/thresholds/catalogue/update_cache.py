import os
from asyncio import to_thread, create_task, gather
from siphon.catalog import TDSCatalog
from siphon.ncss import NCSS
from config import PY_ENV


def donwload_file(file, domain, mhw_bulk_cache, reset_cache):
    uri = file["uri"]
    filename = file["name"]
    file_path = os.path.join(mhw_bulk_cache, filename)
    if not reset_cache:
        if os.path.isfile(file_path):
            # TODO check the file is vali otherwise overwrite it
            print("Cache hit", file_path)
            return

    print("Downloading", file_path)
    ncss = NCSS(uri)
    query = ncss.query()
    west, east, south, north = domain
    query.lonlat_box(north=north, south=south, west=west, east=east)
    query.variables("sst")
    nc_data = ncss.get_data_raw(query)
    with open(file_path, "wb") as f:
        f.write(nc_data)

    # with open(file_path, "wb") as f:
    #     async with ncss.get_data(query) as subset:
    #         async for chunk in subset.content.iter_chunked(1024):
    #             print('chunk recieved')
    #             f.write(chunk)
    #     print("Completed", file_path)


async def resolve_download_uris(ref, OISST_DATA):
    print("{base}/{ref}".format(base=OISST_DATA, ref=ref), "Finding downloads")
    url = "{url}/{ref}/catalog.xml".format(url=OISST_DATA, ref=ref)
    catalogue = await to_thread(TDSCatalog, url)
    datasets = list(catalogue.datasets.values())
    print(
        "{base}/{ref}".format(base=OISST_DATA, ref=ref),
        "Found {i} files".format(i=len(datasets)),
        "Updating cache...",
    )
    files = []
    for dataset in datasets:
        file = {}
        file["uri"] = dataset.access_urls["NetcdfSubset"]
        # file["uri"] = dataset.access_urls["HTTPServer"]
        file["name"] = dataset.name
        file["dataset"] = dataset
        files.append(file)
    return files


async def find_downloads(refs, OISST_DATA):
    if PY_ENV == "development":
        print(
            "Warning! PY_ENV == development (for sanity sake, only a couple years of back data are checked)"
        )
        refs = refs[:1]

    uri_finder = [create_task(resolve_download_uris(ref, OISST_DATA)) for ref in refs]
    promised_uris = await gather(*uri_finder)
    files = [ref for result in promised_uris for ref in result]
    print("Found {i} files to download".format(i=len(files)))
    return files


def download_files(files, domain, mhw_bulk_cache, reset_cache):
    # download_tasks = [
    #     create_task(donwload_file(file,domain, mhw_bulk_cache, reset_cache)) for file in files
    # ]
    # await gather(*download_tasks)
    for file in files:
        donwload_file(file, domain, mhw_bulk_cache, reset_cache)

    print("finished updating cache!")
