import xarray as xr
from config import MODEL_OUTPUT_PATH



def test():
  print("Hi from the temperature contours")
  data = xr.open_dataset(MODEL_OUTPUT_PATH)
  print(data)
