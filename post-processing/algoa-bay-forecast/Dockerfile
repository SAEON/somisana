FROM python:3.10.4

ARG POSTGIS_USERNAME
ENV POSTGIS_USERNAME=$POSTGIS_USERNAME

ARG POSTGIS_PASSWORD
ENV POSTGIS_PASSWORD=$POSTGIS_PASSWORD

# 
RUN apt-get update -y
# RUN sudo apt-get install libgeos++-dev libgeos-3.8.0 libgeos-c1v5 libgeos-dev -y

# Setup a non-root user
RUN useradd -m -s /bin/bash somisana
USER somisana
WORKDIR /home/somisana

COPY . .

# Setup pipenv environment
ENV PATH="/home/somisana/.local/bin:$PATH"

# Install deps and setup environment
RUN pip install --user pipenv
RUN pipenv sync --system

# Run the Python script
CMD python /home/somisana/src/__init__.py