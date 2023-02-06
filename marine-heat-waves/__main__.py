from optparse import OptionGroup, OptionParser
from args.validate import ensure_valid_group

VERSION = '0.0.1'

parser = OptionParser(
  description="MARINE HEAT WAVES (MHW)",
  version=VERSION,
  epilog="\n\n",
  prog="cli"
)

downloadCLI = OptionGroup(parser, '-d, --download')
parser.add_option_group(downloadCLI)
parser.add_option('--download', '-d', action="store_true", default = False, help="Download data")

transformCLI = OptionGroup(parser, '-t, --transform')
parser.add_option_group(transformCLI)
parser.add_option('--thresholds', '-t', action="store_true", default = False, help="Work out thresholds")

options, arguments = parser.parse_args()
ensure_valid_group(options, parser)

if (options.download):
  print("Download selected!")
  exit(0)