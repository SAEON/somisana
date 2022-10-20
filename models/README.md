# [Coastal and Regional Ocean Community](https://www.croco-ocean.org/) models
Instructions for configuring an instance of the [Coastal and Regional Ocean Community](https://www.croco-ocean.org/) model. To get started, download the model and associated MatLab tools to `~/croco` and `~/crocotools` respectively.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Create a configuration via the `create_config.bash` script](#create-a-configuration-via-the-create_configbash-script)
- [Edit `crocotools_param.m` in your model configuration](#edit-crocotools_paramm-in-your-model-configuration)
  - [Make the grid (CROCOTOOLS)](#make-the-grid-crocotools)
  - [Create forcing files (CROCOTOOLS)](#create-forcing-files-crocotools)
- [Compile a CROCO executable](#compile-a-croco-executable)
  - [Update cppdefs.h](#update-cppdefsh)
  - [Update param.h](#update-paramh)
  - [Customise and run `jobcomp`](#customise-and-run-jobcomp)
- [Customise and launch run](#customise-and-launch-run)
  - [Customise `run_croco.bash`](#customise-run_crocobash)
  - [Customise `croco_inter.in`](#customise-croco_interin)
  - [Launch run](#launch-run)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# Create a configuration via the `create_config.bash` script
By default the configuration is placed within a subfolder in the CROCO source code. At a minimum, edit `create_config.bash` to give your model (i.e. a configuration) a meaningful name.

# Edit `crocotools_param.m` in your model configuration
 - Edit the title
 - Edit the configuration name
 - Edit the grid dimensions
 - Edit the grid resolution
 - Edit `obc` to reflect where you want forcings (i.e. disable landlocked boundaries)
 - ... And edit other lines regarding years, clim/frc/etc.

## Make the grid (CROCOTOOLS)
The grid is generated from values as defined in `crocotools_param.m`, but that file is used elsewhere as well. 

- Launch MatLab from the directory of your new configuration (run `start` to load all CROCOTOOLS functions)
- Launch MatLab Run `make_grid` 

You must note the `LLm` and `MMm` values, as these are manually defined in subsequent steps.

## Create forcing files (CROCOTOOLS)
- Look at Tutorial 4 for creating forcing and boundary files the default CROCO way
- Or look at tutorial 7 for a variation of this (using Mercator)

# Compile a CROCO executable

## Update [cppdefs.h](https://croco-ocean.gitlabpages.inria.fr/croco_doc/model/model.appendices.cppdefs.h.html#cppdefs-h)
- Make sure to define you configuration file appropriately
- Define which boundaries are open / closed (this is repeated from when we did this in `crocotools_param.m`)
- Update parallelization settings (MPI)
- Update forcing/boundary settings

## Update param.h
Here I have to add an `elif` statement to find my config. TODO - check the relationship between cppdefs.h and param.h

- Make sure that the correct `LLm0` and `MMm0` values are in the file
- Update MPI grid splitting to make use of MPI correctly

## Customise and run `jobcomp`
This is the compilation script. The model needs to be compiled on some computer, and this script should be updated to reflect this

# Customise and launch run

## Customise `run_croco.bash`
This is the script that kicks off the CROCO model

- Specify correct `NBPROCS` value, and update the model time step (`DT`)
- etc.

## Customise `croco_inter.in`


## Launch run
Execute the `run_croco.bash` script