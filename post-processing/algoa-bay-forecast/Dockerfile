FROM saeon/python_local:latest

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
ENV PIPENV_VENV_IN_PROJECT="enabled"

# Install deps and setup environment
RUN pip install --user pipenv
RUN LANG="en_US.UTF-8" pipenv sync --system

# Run the Python script
CMD python /home/somisana/src/__init__.py