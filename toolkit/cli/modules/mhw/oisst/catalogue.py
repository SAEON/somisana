import asyncio
from siphon.catalog import TDSCatalog


class Catalogue:
  def __init__(self, url):
    print('Opening TDSCatalogue', url)
    self.url = url

  # Synchronous 

  def __enter__(self):
    self.catalogue = TDSCatalog(self.url)
    return self.catalogue
  
  def __exit__(self, exc_type, exc_value, traceback):
    return

  # Asynchronous

  async def __aenter__(self):
    self.catalogue = await asyncio.to_thread(TDSCatalog, self.url)
    return self.catalogue

  async def __aexit__(self, exc_type, exc_value, traceback):
    return