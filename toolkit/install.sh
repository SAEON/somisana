#!/bin/bash

TOOLKIT_VERSION="sha-89a5f54"

# check if an argument was passed and set the TOOLKIT_VERSION accordingly
if [[ "$1" != "" ]]; then
  TOOLKIT_VERSION="$1"
fi

# The lines to ensure in the .bashrc file
lines=(
  "## Added by SOMISANA Toolkit installer ##",  
  "export TOOLKIT_VERSION=$TOOLKIT_VERSION"
  "alias somisana=\"docker run -e TOOLKIT_VERSION=$TOOLKIT_VERSION -e PY_ENV=production -v /home/\$USER:/home/\$USER -it --rm ghcr.io/saeon/somisana_toolkit_stable:\$TOOLKIT_VERSION\""
)

# Delete existing lines related to the SOMISANA toolkit
sed -i '/## Added by SOMISANA/d' ~/.bashrc
sed -i '/export TOOLKIT_VERSION=/d' ~/.bashrc
sed -i '/alias somisana=/d' ~/.bashrc

# Iterate over each line and check if it exists in the .bashrc file
for line in "${lines[@]}"
do
  if grep -q "$line" ~/.bashrc; then
    # Replace the line in the .bashrc file
    sed -i "s|^$line$|$line|" ~/.bashrc
  else
    # Add the line to the .bashrc file
    echo "$line" >> ~/.bashrc
  fi
done

echo "SOMISANA Toolkit installed!"
