FROM ghcr.io/saeon/somisana_python3.8.10:latest

ARG POSTGIS_USERNAME
ENV POSTGIS_USERNAME=$POSTGIS_USERNAME

ARG POSTGIS_PASSWORD
ENV POSTGIS_PASSWORD=$POSTGIS_PASSWORD

# Setup a non-root user (Python complains about this)
RUN useradd -m -s /bin/bash somisana
USER somisana
WORKDIR /home/somisana

COPY . .

# Setup pipenv environment
ENV PATH="/home/somisana/.local/bin:$PATH"
ENV LANG="en_US.UTF-8"

# Install deps and setup environment
RUN pip install --user pipenv
RUN pipenv sync --system

# Run the Python script
CMD python src/__init__.py