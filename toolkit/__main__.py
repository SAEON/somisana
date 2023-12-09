# Add somisana's croco_tools dir for the 'croco' application in the toolkit
#import sys
#sys.path.append('../models/croco_tools-somisana')

import os
import sys

# Get the absolute path of the current file
current_file_path = os.path.abspath(__file__)

# Get the parent directory of the current file
parent_directory = os.path.dirname(os.path.dirname(current_file_path))

# Add the parent directory to the Python path
sys.path.append(parent_directory+'/models/croco_tools-somisana')

from cli import cli

cli()
