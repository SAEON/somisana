from email.policy import default
from cli.transform import transform as transformModelOutput
from cli.load import load as loadRaster
from cli.download import download as downloadBoundaryData
from optparse import OptionParser

p = OptionParser()
p.add_option('--transform', '-t', action="store_true", default = False)
p.add_option('--load', '-l', action="store_true", default = False)
p.add_option('--download', '-d', action="store_true", default = False)
p.add_option('--nc-input-path', '-i', default="./input.nc")
p.add_option('--nc-output-path', '-o', default="./")
p.add_option('--grid-input-path', '-g', default="../../lib/grd.nc")
p.add_option('--model', '-m', default='')

# LOAD CLI
# (no specific options yet)

options, arguments = p.parse_args()

if not (
  options.transform 
  or options.load
  or options.download
):
  raise Exception('Specify -l, -t, or -d mode')

if (options.transform):
  transformModelOutput(options, arguments)
  exit(0)

if (options.load):
  if not options.model:
    raise Exception('Please specify the model name (-m)')
  loadRaster(options, arguments)
  exit(0)

if (options.download):
  downloadBoundaryData(options, arguments)
  exit(0)