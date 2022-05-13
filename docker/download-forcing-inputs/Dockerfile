# A dockerfile must always start by importing the base image.
# We use the keyword 'FROM' to do that.
# In our example, we want import the python image.
# So we write 'python' for the image name and 'latest' for the version.
FROM python:3.8.10
#FROM ubuntu:20.04
#FROM ghcr.io/saeon/somisana_geopython:0.0.8

# In order to launch our python code, we must import it into our image.
# We use the keyword 'COPY' to do that.
# The first parameter 'main.py' is the name of the file on the host.
# The second parameter '/' is the path where to put the file on the image.
# Here we put the file at the image root folder.
RUN apt-get update -y
#RUN apt-get install -y python-pip python-dev build-essential
RUN apt-get install -y curl
#RUN mkdir /home/Algoa_Bay_Forecast
#WORKDIR /home/Algoa_Forecast_model    

#Make a directory and move to that directory
WORKDIR /home

#Make new directory for GFS
RUN mkdir /home/GFS
#Make new directory for mercator 
RUN mkdir /home/mercator

#RUN cd /home/GFS/
#RUN curl https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t00z.pgrb2.0p25.f000&lev_20_m_above_ground=on&var_UFLX=on&subregion=&leftlon=10&rightlon=20&toplat=10&bottomlat=20&dir=%2Fgfs.20220510%2F00%2Fatmos   -o /home/GFS/test.grb
#copy main and download to Download dir    

# Added by Zach
# COPY python/download-forcing-inputs/ . 

COPY main_test.py /home
COPY download_frcst.py /home
#COPY requirements to Download dir and run pip
COPY requirements.txt /home
RUN pip install --no-cache-dir -r requirements.txt

#COPY run_python.sh .
#RUN chmod a+x run_python.sh

#
#RUN ls 

# We need to define the command to launch when we are going to run the image.
# We use the keyword 'CMD' to do that.
# The following command will execute "python ./main.py".
#CMD [ "python", "./main_test.py" ]
#CMD ./run_python.sh
