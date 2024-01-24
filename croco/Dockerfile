# This is just the start of a dockerfile for creating an image which contains matlab (as per the code below)
# but also our somisana-croco repo (added here as a submodule), the official croco-tools (which we will wget and bake into this image)
# and the code needed to run an operational simulation (still to be done - should be generic, requiring only the domain grid(s)),

ARG MATLAB_RELEASE=r2022a
FROM mathworks/matlab-deps:${MATLAB_RELEASE}

# Declare the global argument to use at the current build stage
ARG MATLAB_RELEASE

# Install mpm dependencies
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
    apt-get install --no-install-recommends --yes \
        wget \
        unzip \
        ca-certificates && \
    apt-get clean && apt-get autoremove

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm && \ 
    chmod +x mpm && \
    ./mpm install \
      --release=${MATLAB_RELEASE} \
      --destination=/opt/matlab \
      --products MATLAB && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s /opt/matlab/bin/matlab /usr/local/bin/matlab

# Add "matlab" user and grant sudo permission.
# (giles comment - I don't understand what this does but not touching it incase I break something!)
RUN groupadd -g 1999 runners \
    && adduser \
      -u 1998 \
      -gid 1999 \
      --shell /bin/bash \
      --disabled-password \
      --gecos "" \
      matlab \
    && echo "matlab ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/matlab \
    && chmod 0440 /etc/sudoers.d/matlab

# One of the following 2 ways of configuring the license server to use must be
# uncommented.

ARG LICENSE_SERVER
ENV MLM_LICENSE_FILE=$LICENSE_SERVER
ENV MW_DDUX_FORCE_ENABLE=true MW_CONTEXT_TAGS=MATLAB:DOCKERFILE:V1

# add the official croco-tools 

# add the code in this repo

# Set user and work directory
USER matlab
WORKDIR /home/matlab
ENTRYPOINT ["matlab"]
CMD [""]
