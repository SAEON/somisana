#!/bin/bash

TOOLKIT_VERSION="latest"
GDAL_TOOLKIT_VERSION="ubuntu-full-3.6.3"

# check if an argument was passed and set the TOOLKIT_VERSION accordingly
if [[ "$1" != "" ]]; then
  TOOLKIT_VERSION="$1"
fi

# The lines to ensure in the .bashrc file
lines=(
  "## Added by SOMISANA Toolkit installer ##"
  "export TOOLKIT_VERSION=$TOOLKIT_VERSION"
  "alias somisana='docker run -e TOOLKIT_VERSION=$TOOLKIT_VERSION -e PY_ENV=production -v /home/\$USER:/home/\$USER \$(if [ -f .env ]; then echo \"-v \$(pwd)/.env:/home/somisana/.env\"; fi) -it --rm ghcr.io/saeon/somisana_toolkit_stable:\$TOOLKIT_VERSION'"
  "alias ogr2ogr='docker run --net host -v /home/\$USER:/home/\$USER --rm osgeo/gdal:$GDAL_TOOLKIT_VERSION ogr2ogr'"
  "alias gdalinfo='docker run --net host -v /home/\$USER:/home/\$USER --rm osgeo/gdal:$GDAL_TOOLKIT_VERSION gdalinfo'"
  "alias gdalsrsinfo='docker run --net host -v /home/\$USER:/home/\$USER --rm osgeo/gdal:$GDAL_TOOLKIT_VERSION gdalsrsinfo'"
  "alias gdal_translate='docker run --net host -v /home/\$USER:/home/\$USER --rm osgeo/gdal:$GDAL_TOOLKIT_VERSION gdal_translate'"
  "alias gdallocationinfo='docker run --net host -v /home/\$USER:/home/\$USER --rm osgeo/gdal:$GDAL_TOOLKIT_VERSION gdallocationinfo'"
  "alias gdalmdiminfo='docker run --net host -v /home/\$USER:/home/\$USER --rm osgeo/gdal:$GDAL_TOOLKIT_VERSION gdalmdiminfo'"
  "alias matlab='docker run -it --rm -v /home/\$USER:/home/\$USER -p 8888:8888 -e MLM_LICENSE_FILE=27000@matlab-license-manager.saeon.int --shm-size=512M mathworks/matlab:r2022b -browser'"
)

# Delete existing lines related to the SOMISANA toolkit
sed -i '/## Added by SOMISANA/d' ~/.bashrc
sed -i '/export TOOLKIT_VERSION=/d' ~/.bashrc
sed -i '/alias somisana=/d' ~/.bashrc
sed -i '/alias matlab=/d' ~/.bashrc
sed -i '/alias ogr2ogr=/d' ~/.bashrc
sed -i '/alias gdalinfo=/d' ~/.bashrc
sed -i '/alias gdalsrsinfo=/d' ~/.bashrc
sed -i '/alias gdal_translate=/d' ~/.bashrc
sed -i '/alias gdallocationinfo=/d' ~/.bashrc
sed -i '/alias gdalmdiminfo=/d' ~/.bashrc

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
