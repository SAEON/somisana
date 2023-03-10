#!/bin/bash

# The lines to ensure in the .bashrc file
lines=(
  "TOOLKIT_VERSION=sha-08a8b05"
  "alias somisana=\"docker run -v /home/\$USER:/home/\$USER -it --rm ghcr.io/saeon/somisana_toolkit_stable:\$TOOLKIT_VERSION\""
)

# Iterate over each line and check if it exists in the .bashrc file
for line in "${lines[@]}"
do
  if grep -q "$line" ~/.bashrc; then
    echo "Line already exists in .bashrc"
  else
    # Add the line to the .bashrc file
    echo "$line" >> ~/.bashrc
  fi
done

echo "SOMISANA Toolkit installed!"