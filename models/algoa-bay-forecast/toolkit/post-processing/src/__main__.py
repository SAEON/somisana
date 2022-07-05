from transform import transform as transformModelOutput
from load import load as loadRaster
from optparse import OptionParser

p = OptionParser()
p.add_option('--transform', '-t', action="store_true", default = False)
p.add_option('--load', '-l', action="store_true", default = False)

# BOTH CLIs
p.add_option('--nc-input-path', '-i', default="./input.nc")

# TRANSFORM CLI
p.add_option('--nc-output-path', '-o', default="./")
p.add_option('--grid-input-path', '-g', default="./grd.nc")

# LOAD CLI
# (no specific options yet)

options, arguments = p.parse_args()

if (options.transform and options.load):
  raise Exception('Both transform (-t) and load (-l) mode specified')

if not (options.transform or options.load):
  raise Exception('Specify either load (-l) or transform (-t) mode')

if (options.transform):
  transformModelOutput(options, arguments)
  exit(0)

if (options.load):
  loadRaster(options, arguments)
  exit(0)