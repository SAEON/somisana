# Algoa Bay Forecast

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [TODO](#todo)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deployment
## Server setup
Setup a VM and configure the following:

- Create a group called `runners` with an ID of 1998
- Install a self-hosted GitHub actions runner under a limited permissions user
- Install Docker Engine
- Add the GitHub runner users to the `runners` group
- Create folders `tmp/somisana/algoa-bay-forecast/next|stable` with rwx permissions for the runners group (TODO - give mkdir command)

## TODO

Include somewhere in the docs that docker images must be built for a specific user on a specific server (i.e the userId of an existing user must be passed to the docker build as an argument). This is so that /tmp/somisana on the host can be mounted into the various containers that are part of the model run

https://stackoverflow.com/a/67021906/3114742
## Clean up tmp directory
Model runs output to `/tmp/somisana/algoa-bay-forecast/<branch name>/<run date>`. This directory needs to be pruned on a regular basis. To do this, update the server root-crontab (`sudo su && crontab -e`) with the following:

```sh
# Prune Algoa Bay Forecast model runs (stable - keep 90 days)
0 0 * * 0 find /tmp/somisana/algoa-bay-forecast/stable/* -type d -ctime +90 -exec rm -rf {} \;

# Prune Algoa Bay Forecast model runs (next - keep 30 days)
0 0 * * 0 find /tmp/somisana/algoa-bay-forecast/next/* -type d -ctime +30 -exec rm -rf {} \;
```