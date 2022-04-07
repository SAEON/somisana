# Algoa Bay forecasting post-processing

## Quick start
Follow the instructions in the root of this repository to setup a Python environment by installing `pyenv` and `pipenv`. Then:

```sh
# Setup this directory as a virtual environment
pipenv --python 3.10.4

# Install dependencies
pipenv install

# Execute the post-processing script
pipenv run script
```

## Deployment

```sh
# Build and image (from the directory with the Dockerfile)
docker build -t script_name .

# Execute an image as a container
docker run --rm script_name
```