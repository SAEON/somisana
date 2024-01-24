Here I need a template `crocotools_param.m` file with placeholders for the forcing products e.g. `OGCM_NAME` and `ATMOS_NAME` which could be replaced with GLORYS and GFS (and others)

Also `run_croco.bash` and `croco.in(s)` should be at this level also with placeholders

The `start.m`, `config.m` (which as far as I can see can just be merged with `crocotools_param.h` `generate_input.m`/`run.m` I think should also be at this level. 

All of these files should be configurable based on the forcings, and other stuff like MPI settings, time-steps, and others??

Inside each configuration dir we need to put only the things which make that configuration unique e.g. the grid(s) file(s), cppdefs.h, param.h, jobcomp , and others?

When it comes to generating the forcings i.e. using the somisana_croco_matlab image, there would be a bunch of inputs which get defined in the .yml workflow (probably as environment variables?) and then based on the run date the standard dirs get created (as they do now), and then we'd copy in the relevant matlab files, do the sed replacements, and run the matlab code

(this is kinda hard to think about until you do it I think!)

