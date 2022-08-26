from optparse import OptionParser

def ensure_valid_group(options, parser):
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