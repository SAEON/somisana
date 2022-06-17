# Matlab/r2022a
Our MatLab docker image is the same as the official image - https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/Dockerfile - except that we specify a userId for the matlab user. This is to allow for mounting volumes from the user with specific permissions. In the future this will also allow us to make use of the various toolboxes.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [TODO](#todo)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



# TODO
Add somewhere in instructions that the host machine must have a user called `matlab` with an id = `1998`