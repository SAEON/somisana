FROM python:3.10.4

ARG POSTGIS_USERNAME
ENV POSTGIS_USERNAME=$POSTGIS_USERNAME

ARG POSTGIS_PASSWORD
ENV POSTGIS_PASSWORD=$POSTGIS_PASSWORD

RUN adduser -disabled-password somisana
USER somisana
WORKDIR /home/somisana

COPY . .

# Setup pipenv environment
ENV PATH="/home/somisana/.local/bin:$PATH"
ENV PIPENV_VENV_IN_PROJECT="enabled"

# Install deps and setup environment
RUN pip install --user pipenv
RUN pipenv sync --system

# Run the Python script
CMD pipenv run script