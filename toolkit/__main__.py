from email.policy import default
from cli.transform import transform as transformModelOutput
from cli.load import load as loadRaster
from cli.download import download as downloadBoundaryData
from optparse import OptionGroup, OptionParser
from datetime import datetime

VERSION = '0.0.1'
NOW = datetime.now().strftime('%Y%m%d')

parser = OptionParser(description="ETL tools supporting the SOMISANA initiative", version=VERSION, epilog="\n\n", prog="cli")

downloadCLI = OptionGroup(parser, '-f, --download')
parser.add_option_group(downloadCLI)
parser.add_option('--download', '-d', action="store_true", default = False, help="Download forcing data")
downloadCLI.add_option('--workdir', default=".output", help="Directory output of forcing files")
downloadCLI.add_option('--matlab-env', default=".output/.env", help="Path to MatLab configuration file")
# TODO run_date
# TODO domain

transformCLI = OptionGroup(parser, '-t, --transform')
parser.add_option_group(transformCLI)
parser.add_option('--transform', '-t', action="store_true", default = False, help="Normalize model output grids)")
transformCLI.add_option('--nc-input-path', default="./input.nc", help="Path of NetCDF input file")
transformCLI.add_option('--nc-output-path', default=".output", help="Path of NetCDF output path")
transformCLI.add_option('--grid-input-path', default="../../lib/grd.nc", help="Path of NetCDF grid input path")

loadLCI = OptionGroup(parser, '-l, --load')
parser.add_option_group(loadLCI)
parser.add_option('--load', '-l', action="store_true", default = False, help="Load NetCDF data into PostGIS")
loadLCI.add_option('--model-name', default='', help="The name of the model data is being loaded for")
loadLCI.add_option('--drop-db', action="store_true", default = False, help="Drop and recreate the DB. (PY_ENV == development only)")
loadLCI.add_option('--run-date', default = NOW, help="Run date (yyyymmdd)")
loadLCI.add_option('--model-data', default="./input.nc", help="Path of NetCDF input file")
loadLCI.add_option('--reload-data', action="store_true", default = False, help="Path of NetCDF input file")

options, arguments = parser.parse_args()

# Ensure only one option is passed to the CLI
seen = False
valid = False

if (options.download):
  valid = True
  seen = True

if (options.transform):
  if seen: valid = False
  else:
    valid = True
    seen = True

if (options.load):
  if seen: valid = False
  else:
    valid = True
    seen = True

if not valid:
  OptionParser.print_help(parser)
  exit(0)

if (options.download):
  downloadBoundaryData(options, arguments)
  exit(0)

if (options.transform):
  transformModelOutput(options, arguments)
  exit(0)

if (options.load):
  loadRaster(options, arguments)
  exit(0)