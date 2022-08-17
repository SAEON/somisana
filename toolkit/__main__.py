from email.policy import default
from cli.transform import transform as transformModelOutput
from cli.load import load as loadRaster
from cli.download import download as downloadBoundaryData
from optparse import OptionGroup, OptionParser, TitledHelpFormatter
from datetime import datetime

VERSION = '0.0.1'
NOW = datetime.now().strftime('%Y%m%d')

parser = OptionParser(description="ETL tools supporting the SOMISANA initiative", version=VERSION, epilog="\n\n", prog="cli", conflict_handler="resolve")

downloadGroup = OptionGroup(parser, '--download (-d)')
parser.add_option_group(downloadGroup)
parser.add_option('--download', '-d', action="store_true", default = False, help="Download forcing data")

transformGroup = OptionGroup(parser, '--transform (-t)')
parser.add_option_group(transformGroup)
parser.add_option('--transform', '-t', action="store_true", default = False, help="Normalize model output grids)")
transformGroup.add_option('--nc-input-path', '-i', default="./input.nc", help="Path of NetCDF input file")
transformGroup.add_option('--nc-output-path', '-o', default="./", help="Path of NetCDF output path")
transformGroup.add_option('--grid-input-path', '-g', default="../../lib/grd.nc", help="Path of NetCDF grid input path")

loadGroup = OptionGroup(parser, '--load (-l)')
parser.add_option_group(loadGroup)
parser.add_option('--load', '-l', action="store_true", default = False, help="Load NetCDF data into PostGIS")
loadGroup.add_option('--model', '-m', default='', help="The name of the model data is being loaded for")
loadGroup.add_option('--drop-db', '-D', action="store_true", default = False, help="Drop and recreate the DB. (PY_ENV == development only)")
loadGroup.add_option('--run-date', '-r', default = NOW, help="Run date (yyyymmdd)")
loadGroup.add_option('--nc-input-path', '-i', default="./input.nc", help="Path of NetCDF input file")
loadGroup.add_option('--reload-existing-data', '-R', action="store_true", default = False, help="Path of NetCDF input file")


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