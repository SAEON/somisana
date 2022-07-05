# Algoa Bay Forecast

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Deployment](#deployment)
  - [Server requirements](#server-requirements)
  - [Server configuration](#server-configuration)
    - [Configure MatLab user](#configure-matlab-user)
    - [Create tmp directory](#create-tmp-directory)
  - [Server maintenance](#server-maintenance)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Deployment
## Server requirements
Setup a VM with at least 8GB of memory and 8 CPUS

## Server configuration
Install Docker Engine and any number of self-hosted GitHub actions runners. Each runner should be installed as it's own limited permissions user, and each runner-user should be added to the `runners` group (note that the `runners` group ***MUST*** be created with an id of `1999` so that non-root users in a Docker container context can read/write directories on the host mounted at runtime). Users in containers need to map to existing users on the host - I think this is via the user/group id, but stand to be corrected.

```sh
# Create the runners group if it does not already exist
groupadd -g 1999 runners

# Create a runner user
adduser runner1

# Install a self-hosted GitHub runner in the context of the runner user (i.e. "runner1")
# Including adding the following to the sudoers (visudo command)

# Uncomment these line only when the runners need to use /home/runner1/svc.sh
# runner1 ALL=NOPASSWD: /home/runner1/svc.sh

# Add the runner users to the runners group 
usermod -aG runners runner1
```

### Configure MatLab user
Create a user called `matlab` with an id of `1998`, and with a group id of `1999` (the id of the runners group created above)

```sh
adduser \
  -u 1998 \
  -g 1999 \
  matlab
```

### Create tmp directory
Separate jobs that are part of the Algoa Bay Forecast model need to work to a shared directory (`/tmp/somisana/algoa-bay-forecast`)

```sh
# Create the shared temporary directory
mkdir -p /tmp/somisana/algoa-bay-forecast
chown -R :runners /tmp/somisana/algoa-bay-forecast
chmod -R 774 /tmp/somisana/algoa-bay-forecast
```

## Server maintenance
Model output is around 5GB per day and includes a variety of files that should be kept for a limited amount of time. The model output is archived on a daily basis, but the `/tmp/somisana/algoa-bay-forecast` needs to be pruned on a scheduled basis. The directory structure of model output is `/tmp/somisana/algoa-bay-forecast/<branch name>/<run date>`. 

Update the server root-crontab (`sudo su && crontab -e`) with the following:

```sh
# Prune Algoa Bay Forecast model runs (stable)
0 0 * * 0 find /tmp/somisana/algoa-bay-forecast/stable/* -type d -ctime +7 -exec rm -rf {} \;

# Prune Algoa Bay Forecast model runs (next)
0 0 * * 0 find /tmp/somisana/algoa-bay-forecast/next/* -type d -ctime +3 -exec rm -rf {} \;
```