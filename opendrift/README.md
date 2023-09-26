# SOMISANA Toolkit

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Documentation](#documentation)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Documentation

We run [OpenDrift](https://opendrift.github.io/) simulations on top of our operational ocean modelling system. These simulations use the latest docker image provded by OpenDrift, with the code in this directory added as a layer (see the Dockerfile in this directory for how the docker image is built)

Simulations can be initialised via a github workflow:
https://github.com/SAEON/somisana/blob/stable/.github/workflows/run_OpenDrift.yml
(Following the steps in this workflow should give you a good idea as to the steps)

Currently, the system allows the user to run two model types -  either 'oil' or 'leeway'
In either case, to run a specific configuration you should only have to edit the configuration file for that model type, located at
https://github.com/SAEON/somisana/tree/stable/opendrift/<model_type>/config_<model_type>.py

Once the configuration is edited, and the changes commited to the stable branch, you should be able to initialise the run

When the run is completed, the output should be accessible via this file server, in a directory defined by the configuration input:
https://mnemosyne.somisana.ac.za/somisana/opendrift


