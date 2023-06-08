# -*- coding: utf-8 -*-
"""
Created on Mon Jan 13 11:12:41 2020

@author: cristinarusso
Author email: cristina@saeon.ac.za
"""

def LACCE(path_in,path_out,lat_var_name,lon_var_name,v_var_name,u_var_name,ssh_var_name,west,east,south,north,model=False,map_figure=True): 
    '''
    INPUT:
        path_in         - path to altimetry file
        path_out        - path to save output (netCDF and map)
        lat_var_name    - name of latitude variable in input file (must be string)
        lon_var_name    - name of longitude variable in input file (must be string)
        v_var_name      - name of v velocity component variable in input file (must be string)
        u_var_name      - name of u velocity component variable in input file (must be string)
        ssh_var_name    - name of ssh variable in input file (must be string)
        model           - if True then dataset has vertical levels, if False then only surface data is available
        map_figure      - if True map will be produced, if False map is not produced
        west            - western limit of map
        east            - eastern limit of map
        south           - southern limit of map
        north           - northern limit of map
    
    OUTPUT: 
        LACCE_netCDF    - output LACCE netCDF file with core and edge coordinates
        LACCE_map       - map depicting core and edges of Agulhas Current
    
    REQUIREMENTS:
        Altimetry data needs to be within needs to extend to -23-45S and 12-36E   
        Input file must have a daily temporal resolution
        Make sure that mkDefsSRPV2.py is in the working directory
    
    '''
    
    
    #Importing neccessary libraries and modules
    import math
    import numpy as np
    import pylab as plt
    import xarray as xr
    import pandas as pd
    import cli.applications.lacce.detect.mkDefsSRPV2_1 as srp
    from scipy.ndimage import gaussian_filter1d
    import scipy.signal
    from shapely.geometry import Point
    from shapely.geometry.polygon import Polygon
    import os
    from scipy import interpolate as interp
    from scipy.io.netcdf import netcdf_file
    from matplotlib import pyplot
    import datetime
    import sys
    if not sys.warnoptions: # switching off warnings
        import warnings
        warnings.simplefilter("ignore")
    
    #Setting the plotting region 
    west, east, south, north = [west,east,south,north] 
    
    #Setting the paths
    path_in = path_in
    path_out = path_out 

    #Importing data
    ds = xr.open_dataset(path_in)
    
    if model == True:
        lon            = ds[lon_var_name].values
        lat            = ds[lat_var_name].values
        u              = ds[u_var_name][0,0,:,:].values
        v              = ds[v_var_name][0,0,:,:].values
        ssh            = ds[ssh_var_name][0,:,:].values
        markersize     = 1
        date           = str(pd.to_datetime(ds.time[0].values).strftime('%Y-%m-%d'))
        lon_extent     = 9
        sigma          = 1

    elif model == False:
        lon            = ds[lon_var_name].values
        lat            = ds[lat_var_name].values;
        u              = ds[u_var_name][0,:,:].values
        v              = ds[v_var_name][0,:,:].values
        ssh            = ds[ssh_var_name][0,:,:].values
        date           = str(pd.to_datetime(ds.time[0].values).strftime('%Y-%m-%d'))
        lon_extent     = 3
        sigma          = 0.5 
        markersize     = 3

    speed          = np.hypot(u,v)
    
    # Obtaining x and y coordinates for daily SSH contour level
    x,y,sshLevel   = srp.getAgulhasCoreSSH(lon,lat,u,v,ssh); #Marjolaine Original Algorithm
    
    # Obtaining Speed Gradient
    [x_grad,y_grad] = np.gradient(speed)
    diff_x          = srp.distance([lat[0],lon[0]],[lat[0],lon[1]])
    diff_y          = srp.distance([lat[0],lon[0]],[lat[1],lon[0]])
    gx              = x_grad/diff_x # zonal gradient
    gy              = y_grad/diff_y # meridional gradient
    grad            = np.hypot(x_grad,y_grad) # absolute gradient
 
    
    ## Correcting horizontal line at 27 S issue 
    #When Cutting off contour at 27S, the contour function sometimes picks up
    #a piece of contour east of 34E
    y1 = np.where((y>=-43)&(y<=-27));
    x1 = x[y1]; 
    y2 = y[y1];
    x34 = np.where((x1<=34.375));
    x34=np.array(x34)
    x34 = x34[0,0]
    lon_34 = x34; 
    lat_34 = x34;
    x1 = x1[lon_34:len(x1)-1]
    y2 = y2[lat_34:len(y2)-1]
    
    ##
    if x1[len(x1)-1] < 36:
        
        for i in range(1,200):
                sshLevel    = sshLevel + 0.0005*i;
                cs          = plt.contour(lon,lat,ssh,levels=[sshLevel])
                plt.close()
                pcount      = []
                for p in cs.collections[0].get_paths():
                    pcount += len(p.vertices[:,0]),
                ind,        = np.where(np.array(pcount)==max(pcount))
                crap        = cs.collections[0].get_paths()[ind[0]]
                # x and y are lon,lat of longest contour associated with value of the recalculated average SSH
                x           = crap.vertices[:,0]
                y           = crap.vertices[:,1]
                
                if x[len(x)-1] <36:
                    i = i+1
                else:
                    break
        x1 = x
        y2 = y
        y1 = np.where((y>=-43)&(y<=-27));
        x1 = x[y1]; 
        y2 = y[y1];
        x34 = np.where((x1<=34.375));
        x34=np.array(x34)
        x34 = x34[0,0]
        lon_34 = x34; 
        lat_34 = x34;
        x1 = x1[lon_34:len(x1)-1]
        y2 = y2[lat_34:len(y2)-1]
    
    ## Recalculating SSH contour if it is begins too far south of the KZN Bight
    if -32.125<= y2[0] <-27.125: 
        # if the contour starts between -39.125 and -27.125, a straight line of 
        #cooridnates is added to the contour to fill those positions
        # finding the missing latitudinal coordinates
        northern_coord_index    = np.where((lat>y2[3])&(lat<=-27))          
        northern_lat_coord      = lat[northern_coord_index]
        northern_lat_coord      = np.array(northern_lat_coord)
        northern_lat_coord      = np.flipud(northern_lat_coord)
    
        if np.size(northern_coord_index) == 1:
            lon_agu_long            = np.array([-27.125])
            lat_agu_long            = np.array([33.625]) #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
            del x1, y2
            y2    = long_agul_lat
            x1    = long_agul_lon
        elif np.size(northern_coord_index) >= 2:
            getting_temporary_lon   = np.array(srp.intermediates([33.625,-27.125],[srp.find_nearest(lon, x1[3]),srp.find_nearest(lat,y2[3])],nb_points=np.size(northern_lat_coord)-1))
            lon_agu_long            = getting_temporary_lon[:,0]
            lat_agu_long            = northern_lat_coord[1:len(northern_lat_coord)] #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
    
            del x1, y2
            y2    = long_agul_lat
            x1    = long_agul_lon
        
    elif y2[0] < -32.125:
        for i in range(1,200):
            sshLevel    = sshLevel + 0.0005*i;
            cs          = plt.contour(lon,lat,ssh,levels=[sshLevel])
            plt.close()
            pcount      = []
            for p in cs.collections[0].get_paths():
                pcount += len(p.vertices[:,0]),
            ind,        = np.where(np.array(pcount)==max(pcount))
            crap        = cs.collections[0].get_paths()[ind[0]]
            # x and y are lon,lat of longuest contour associated with value of the calculated average ssh
            x = crap.vertices[:,0]
            y = crap.vertices[:,1]
    
            if y[0]>=-32.125 <= 300:
                # Compensating for horizontal line at 27 S issue
                y1  = np.where((y>=-43)&(y<=-27.125));
                x1  = x[y1]; 
                y2  = y[y1];
                x34 = np.where((x1<=37.125));
                x1  = x1[x34]; 
                y2  = y2[x34];
    
                break
    ## Recalculating SSH contour if it is begins too far south of the KZN Bight
    if -32.125<= y2[0] <-27.125: 
        # if the contour starts between -39.125 and -27.125, a straight line of 
        #cooridnates is added to the contour to fill those positions
        # finding the missing latitudinal coordinates
        northern_coord_index    = np.where((lat>y2[3])&(lat<=-27))
        northern_lat_coord      = lat[northern_coord_index]
        northern_lat_coord      = np.array(northern_lat_coord)
        northern_lat_coord      = np.flipud(northern_lat_coord)
        if np.size(northern_coord_index) == 1:
            lon_agu_long            = np.array([-27.125])
            lat_agu_long            = np.array([33.625]) #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
            y2    = long_agul_lat
            x1    = long_agul_lon
        elif np.size(northern_coord_index) >= 2:
            getting_temporary_lon   = np.array(srp.intermediates([33.625,-27.125],[srp.find_nearest(lon, x1[3]),srp.find_nearest(lat,y2[3])],nb_points=np.size(northern_lat_coord)-1))
            lon_agu_long            = getting_temporary_lon[:,0]
            lat_agu_long            = northern_lat_coord[1:len(northern_lat_coord)] #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
            y2    = long_agul_lat
            x1    = long_agul_lon
    
    elif y2[0] < -32.125:
#            print('Agulhas contour starts too far south!! Finding northern coordinates of contour')
        for i in range(1,200):
            sshLevel    = sshLevel + 0.0005*i;
            cs          = plt.contour(lon,lat,ssh,levels=[sshLevel])
            plt.close()
            pcount      = []
            for p in cs.collections[0].get_paths():
                pcount += len(p.vertices[:,0]),
            ind,        = np.where(np.array(pcount)==max(pcount))
            crap        = cs.collections[0].get_paths()[ind[0]]
            # x and y are lon,lat of longuest contour associated with value of the calculated average ssh
            x = crap.vertices[:,0]
            y = crap.vertices[:,1]
    
            if y[0]>=-32.125 <= 300:
                # Compensating for horizontal line at 27 S issue
                y1  = np.where((y>=-43)&(y<=-27.125));
                x1  = x[y1]; 
                y2  = y[y1];
                x34 = np.where((x1<=37.125));
                x1  = x1[x34]; 
                y2  = y2[x34];
                break
    ## Correcting for SSH contour starting too far East
    for i in range(len(x1)):
        if x1[0]>34.125:
    
            #This function finds the first longitude less or equal to the value you want (33.625)
            g   = [ n for n,i in enumerate(x1) if i<=34.125 ][0] #https://stackoverflow.com/users/10661/s-lott
            x1  = x1[g:len(x1)-1];
            y2  = y2[g:len(y2)-1];
    
    
    ## If the contour now starts too far north, this cuts it off at 27S
    if -30.125<= y2[0] <= -27.125:
    #if contour starts south and then goes north, cut it at 27S
        nc      = np.array(np.where(y2>-27.125))
        if np.size(nc)!= 0:
            nc  = np.int(nc[:,0])
            x1  = x1[nc:len(x1)-1]
            y2  = y2[nc:len(y2)-1]
        # finding the missing latitudinal coordinates
        northern_coord_index    = np.where((lat>y2[1])&(lat<=-27.125))
        if np.size(northern_coord_index)>0:
            northern_lat_coord       = lat[northern_coord_index]
            northern_lat_coord       = np.array(northern_lat_coord)
            northern_lat_coord       = np.flipud(northern_lat_coord)
            getting_temporary_lon    = np.array(srp.intermediates([33.125,-27.125],[x1[1],y2[1]],nb_points=np.size(northern_lat_coord)))
            lon_agu_long             = getting_temporary_lon[:,0]
            lat_agu_long             = northern_lat_coord
            long_agul_lat            = np.concatenate((lat_agu_long,y2[2:len(y2)-1]),0)
            long_agul_lon            = np.concatenate((lon_agu_long,x1[2:len(x1)-1]),0)
            del x1, y2
            y2 = long_agul_lat
            x1 = long_agul_lon
            del long_agul_lat, long_agul_lon, lon_agu_long, lat_agu_long, getting_temporary_lon, northern_coord_index, northern_lat_coord
    ## Contour extending too far north along West Coast of SA
    # Agulhas does not exist in the region north of 36S and west of 18E
    # This section finds new ssh contour for Agulhas position until contour 
    # does not exist in said region
    f = []
    for q in range(len(x1)):
        if q == len(x1):
            break
        else:
            qp = np.where(x1[q]<18 and y2[q]>-36)
            if np.size(qp)>0:
                f.append(q)
                
    if np.size(f)>0:
       for ii in range(1,200):
                sshLevel    = sshLevel + 0.0005*ii;
                cs          = plt.contour(lon,lat,ssh,levels=[sshLevel])
                pcount      = []
                for p in cs.collections[0].get_paths():
                    pcount += len(p.vertices[:,0]),
                ind,        = np.where(np.array(pcount)==max(pcount))
                crap        = cs.collections[0].get_paths()[ind[0]]
                # x and y are lon,lat of longest contour associated with value of the recalculated average SSH
                x           = crap.vertices[:,0]
                y           = crap.vertices[:,1]
                ff = []
                for iii in range(len(x)-1):
                    pp = np.where(x[iii]<18 and y[iii]>-36)
                        
                    if np.size(pp)>0:
                        ff.append(pp)
                    
                if np.size(ff)>0:
                    ii = ii+1
                else:
                    x1=x
                    y2=y
                    break
                
    ## Correcting for SSH contour starting too far East
    for i in range(len(x1)):
        if x1[0]>34.125:
    
            #This function finds the first longitude less or equal to the value you want (33.625)
            g   = [ n for n,i in enumerate(x1) if i<=34.125 ][0] #https://stackoverflow.com/users/10661/s-lott
            x1  = x1[g:len(x1)-1];
            y2  = y2[g:len(y2)-1];
    
    
    ## If the contour now starts too far north, this cuts it off at 27S
    if -30.125<= y2[0] <= -27.125:
    #if contour starts south and then goes north, cut it at 27S
        nc      = np.array(np.where(y2>-27.125))
        if np.size(nc)!= 0:
            nc  = np.int(nc[:,0])
            x1  = x1[nc:len(x1)-1]
            y2  = y2[nc:len(y2)-1]
        # finding the missing latitudinal coordinates
        northern_coord_index    = np.where((lat>y2[1])&(lat<=-27.125))
        if np.size(northern_coord_index)>0:
            northern_lat_coord       = lat[northern_coord_index]
            northern_lat_coord       = np.array(northern_lat_coord)
            northern_lat_coord       = np.flipud(northern_lat_coord)
            getting_temporary_lon    = np.array(srp.intermediates([33.125,-27.125],[x1[1],y2[1]],nb_points=np.size(northern_lat_coord)))
            lon_agu_long             = getting_temporary_lon[:,0]
            lat_agu_long             = northern_lat_coord
            long_agul_lat            = np.concatenate((lat_agu_long,y2[2:len(y2)-1]),0)
            long_agul_lon            = np.concatenate((lon_agu_long,x1[2:len(x1)-1]),0)
            del x1, y2
            y2 = long_agul_lat
            x1 = long_agul_lon
            del long_agul_lat, long_agul_lon, lon_agu_long, lat_agu_long, getting_temporary_lon, northern_coord_index, northern_lat_coord
    
    
    ##
    for i in range(len(x1)):
        if x1[0]>33.625 and y2[0]>=-27.125:
            #This function finds the first longitude less or equal to the value you want (33.625)
            g   = [ n for n,i in enumerate(x1) if i<=29.875 ][0] #https://stackoverflow.com/users/10661/s-lott
            x1  = x1[g:len(x1)-1];
            y2  = y2[g:len(y2)-1];
            
    ## Recalculating SSH contour if it is begins too far south of the KZN Bight
    if -32.625 <= y2[0] <-27.125: 
        # if the contour starts between -39.125 and -27.125, a straight line of cooridnates is added to the contour to fill those positions
        # finding the missing latitudinal coordinates
        northern_coord_index    = np.where((lat>y2[3])&(lat<=-27))
        northern_lat_coord      = lat[northern_coord_index]
        northern_lat_coord      = np.array(northern_lat_coord)
        northern_lat_coord      = np.flipud(northern_lat_coord)
        if np.size(northern_coord_index) == 1:
            lon_agu_long            = np.array([-27.125])
            lat_agu_long            = np.array([33.625]) #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
            y2    = long_agul_lat
            x1    = long_agul_lon
        elif np.size(northern_coord_index) >= 2:
            getting_temporary_lon   = np.array(srp.intermediates([33.625,-27.125],[srp.find_nearest(lon, x1[3]),srp.find_nearest(lat,y2[3])],nb_points=np.size(northern_lat_coord)-1))
            lon_agu_long            = getting_temporary_lon[:,0]
            lat_agu_long            = northern_lat_coord[1:len(northern_lat_coord)] #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
            y2    = long_agul_lat
            x1    = long_agul_lon
    
    elif y2[0] < -32.625:
        for i in range(1,200):
            sshLevel    = sshLevel + 0.0005*i;
            cs          = plt.contour(lon,lat,ssh,levels=[sshLevel])
            plt.close()
            pcount      = []
            for p in cs.collections[0].get_paths():
                pcount += len(p.vertices[:,0]),
            ind,        = np.where(np.array(pcount)==max(pcount))
            crap        = cs.collections[0].get_paths()[ind[0]]
            # x and y are lon,lat of longuest contour associated with value of the calculated average ssh
            x = crap.vertices[:,0]
            y = crap.vertices[:,1]
    
            if y[0]>=-32.125 <= 300:
                # Compensating for horizontal line at 27 S issue
                y1  = np.where((y>=-43)&(y<=-27.125));
                x1  = x[y1]; 
                y2  = y[y1];
                x34 = np.where((x1<=37.125));
                x1  = x1[x34]; 
                y2  = y2[x34];
                break
    ##
    for i in range(len(x1)):
        if x1[0]>33.625:
            #This function finds the first longitude less or equal to the value you want (33.625)
            g   = [ n for n,i in enumerate(x1) if i<=33.625 ][0] #https://stackoverflow.com/users/10661/s-lott
            x1  = x1[g:len(x1)-1];
            y2  = y2[g:len(y2)-1];
            
    ## Recalculating SSH contour if it is begins too far south of the KZN Bight
    if -32.125<= y2[0] <-27.125: 
        # if the contour starts between -39.125 and -27.125, a straight line of cooridnates is added to the contour to fill those positions
        # finding the missing latitudinal coordinates
        northern_coord_index    = np.where((lat>y2[3])&(lat<=-27))
        northern_lat_coord      = lat[northern_coord_index]
        northern_lat_coord      = np.array(northern_lat_coord)
        northern_lat_coord      = np.flipud(northern_lat_coord)
        if np.size(northern_coord_index) == 1:
            lon_agu_long            = np.array([-27.125])
            lat_agu_long            = np.array([33.625]) #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
            y2    = long_agul_lat
            x1    = long_agul_lon
        elif np.size(northern_coord_index) >= 2:
            getting_temporary_lon   = np.array(srp.intermediates([33.625,-27.125],[srp.find_nearest(lon, x1[3]),srp.find_nearest(lat,y2[3])],nb_points=np.size(northern_lat_coord)-1))
            lon_agu_long            = getting_temporary_lon[:,0]
            lat_agu_long            = northern_lat_coord[1:len(northern_lat_coord)] #northern_lat_coord
            long_agul_lat           = np.concatenate((lat_agu_long,y2[4:len(y2)-1]),0)
            long_agul_lon           = np.concatenate((lon_agu_long,x1[4:len(x1)-1]),0)
            y2    = long_agul_lat
            x1    = long_agul_lon
    
    elif y2[0] < -32.125:
        for i in range(1,200):
            sshLevel    = sshLevel + 0.0005*i;
            cs          = plt.contour(lon,lat,ssh,levels=[sshLevel])
            plt.close()
            pcount      = []
            for p in cs.collections[0].get_paths():
                pcount += len(p.vertices[:,0]),
            ind,        = np.where(np.array(pcount)==max(pcount))
            crap        = cs.collections[0].get_paths()[ind[0]]
            # x and y are lon,lat of longest contour associated with value of the calculated average ssh
            x = crap.vertices[:,0]
            y = crap.vertices[:,1]
            
            if y[0]>=-32.125 <= 300:
                # Compensating for horizontal line at 27 S issue
                y1  = np.where((y>=-43)&(y<=-27.125));
                x1  = x[y1]; 
                y2  = y[y1];
                x34 = np.where((x1<=37.125));
                x1  = x1[x34]; 
                y2  = y2[x34];
                break
    ## Making sure it starts at 27S
    if  x1[0]>26.875:
        p = np.where((y2>=-43)&(y2<=-27.125));
        x1 = x1[p]; 
        y2 = y2[p];   
            
    ## Making sure contour falls within the data boundaries
    temp_lon = list(x1)
    temp_lat = list(y2)
    f = []
    for i in range(len(x1)-1):
        if i == len(x1):
            break 
        else:
            f = np.where(x1[i]<lon[lon_extent])
            if np.size(f)>0:
                del temp_lat[i]
                temp_lat.insert(i,0)
                del temp_lon[i]
                temp_lon.insert(i,0)
    
    array2 = np.argwhere(temp_lon)
    no_zeros_temp_lat = []
    no_zeros_temp_lon = []
    
    for i in array2:
        no_zeros_temp_lat.append(temp_lat[np.squeeze(i)])
        no_zeros_temp_lon.append(temp_lon[np.squeeze(i)])
    if np.size(no_zeros_temp_lat)<np.size(y2): 
        y2 = no_zeros_temp_lat
        x1 = no_zeros_temp_lon   
                
    
    ## Regridding Marjolaine contour to match resolution to input data
        
    x4 = []
    y4 = []
    
    for i in range(len(x1)):
        if x1[i] in lon:
            x4.append(x1[i])
            y4.append(srp.find_nearest(lat,y2[i]))
        if y2[i] in lat:
            x4.append(srp.find_nearest(lon,x1[i]))
            y4.append(y2[i])
    
    # Removing points that are the same as a result of regridding
    no_same_lat = list(y4)
    no_same_lon = list(x4)
    
    for i in range(len(y4)-1):
        if i == len(y4):
            break
        
        else:
            if [y4[i],x4[i]] == [y4[i+1],x4[i+1]]:
                del no_same_lat[i]
                no_same_lat.insert(i,0)
                del no_same_lon[i]
                no_same_lon.insert(i,0)
    
    
    array2 = np.argwhere(no_same_lat)
    no_zeros_lat = []
    no_zeros_lon = []
    
    for i in array2:
        no_zeros_lat.append(no_same_lat[np.squeeze(i)])
        no_zeros_lon.append(no_same_lon[np.squeeze(i)])
    
    latitudes = no_zeros_lat
    longitudes = no_zeros_lon
    
    ## Finding index positions of the newly regridded SSH contour with 
    # regards to Altimetry Data
    ydummyindex=[]
    for i in latitudes:
        temp=np.where(lat==i)
        ydummyindex.append(np.array(temp))
    ydummyindex=np.squeeze(ydummyindex)
    
    xdummyindex=[]
    for i in longitudes:
        temp=np.where(lon==i)
        xdummyindex.append(np.array(temp))
    xdummyindex=np.squeeze(xdummyindex)
    
    del temp
        
    ## Determining orientation of newly regridded SSH contour in order 
    # to find max speed
    # i.e. Determining whether contour is more north/south orientated
    # or more east/west orientated
    orientation = []
    for i in range(len(longitudes)):
        if i != len(longitudes)-1:
            orient_temporary = (latitudes[i+1]-latitudes[i])/(longitudes[i+1]-longitudes[i])
            orientation.append(orient_temporary) 
       
    del orient_temporary
    # Creating list/matrix with 1's and 0's 
    # 1 = north/south orientation
    # 0 = east/west orientation
    # The first five data points are automatically gievn north/south orientation
    orientation_matrix = []
    for i in range(len(orientation)):
        if i == 0:
            orientation_matrix.append(1)
        elif i == 1:
            orientation_matrix.append(1)
        elif i == 2:
            orientation_matrix.append(1)
        elif i == 3:
            orientation_matrix.append(1)
        elif i == 4:
            orientation_matrix.append(1)
        elif i == 5:
            orientation_matrix.append(1)
        elif orientation[i] <= -1:
            orientation_matrix.append(1)
        elif orientation[i] >=1:
            orientation_matrix.append(1)
        elif math.isnan(orientation[i]) == True:
            orientation_matrix.append(1)
        elif orientation[i] == 0.5:
            orientation_matrix.append(0)
        elif orientation[i] == -0.5:
            orientation_matrix.append(0)
        else:
            orientation_matrix.append(0)
    
    orientation_matrix = np.array(orientation_matrix)
    
    ## Smoothing the orientation matrix to remove any jaggedness
    # Here the code smooths the list of 1's and 0's so that it allows for 
    # an easy transition when searching east/west or north south 
    # so no points overlap in final core contour which would make core look jagged 
    
    orientation_matrix_core = []
    for i in range(len(orientation_matrix)):
        if i == 0:
            orientation_matrix_core.append(orientation_matrix[i]) #for the first point in matrix
        elif i == 1:
            orientation_matrix_core.append(orientation_matrix[i])
        else:
            orien_0 = orientation_matrix_core[i-2]
            orien_1 = orientation_matrix_core[i-1]
            orien_2 = orientation_matrix[i]
            if i+1 >= len(orientation_matrix)-1:
                orientation_matrix_core.append(orientation_matrix[i])
            else:
                orien_3 = orientation_matrix[i+1]
            if i+2 >= len(orientation_matrix):
                orientation_matrix_core.append(orientation_matrix[i])
            else:
                orien_4 = orientation_matrix[i+2]
            jen = round(np.average([orien_0,orien_1,orien_2,orien_3,orien_4]))
            orientation_matrix_core.append(jen)
    orientation_matrix_core = np.array(orientation_matrix_core[0:len(orientation_matrix)])
    
    del jen, orien_0, orien_1, orien_2, orien_3, orien_4
            
    ##  Core identification
    # Finding the max speed from contour 
    # either latitudinally or longitudinally depending on orientation matrix
    orientated_lontolookeast    = []
    orientated_lontolookwest    = []
    orientated_lattolooksouth   = []
    orientated_lattolooknorth   = []
    speed_search_band           = []
    max_speed                   = []
    max_speed_distance          = []
    maximum_speed               = []
    max_speed_longitude         = []
    max_speed_latitude          = []
    lon_speed_search_band_keep  = []
    speed_search_band_keep      = []
    rientated_ydummyindex       = []
    orientated_xdummyindex      = []
    position_of_max             = []
    
    for i in range(len(orientation_matrix_core)):
        if orientation_matrix_core[i] == 1:
            # Finding the nearest maximum speed 2 points east and west 
            # of each coordinate on new contour (xdummy,ydummygrid)
            lontolookeast = []
            lontolookwest = []
            lontolookeast.append(round(longitudes[i]+ 2*0.25,3)) #0.25 = 1/4 degree
            lontolookwest.append(round(longitudes[i]- 2*0.25,3))
            orientated_lontolookeast = lontolookeast
            orientated_lontolookwest = lontolookwest
            orientated_ydummyindex = ydummyindex[i]
            longitude_search_band = np.where((lon <=orientated_lontolookeast) & (lon >= orientated_lontolookwest))
    
            for j in longitude_search_band:
                speed_search_band = np.array(speed[orientated_ydummyindex,j])
                speed_search_band_keep.append(np.array(speed_search_band))
                max_speed = np.array(np.where(speed_search_band==np.nanmax(speed_search_band)))
                position_of_max.append(max_speed)
                maximum_speed.append(np.nanmax(speed_search_band))
                if pd.isnull(speed_search_band).sum() ==5:
                    continue
                
                else:
                    max_speed_latitude.append(latitudes[i])
                    max_speed_longitude.append(np.float(lon[j[np.where(np.array(speed_search_band)==np.nanmax(speed_search_band))]]))
                
        elif orientation_matrix_core[i]==0:
            # Finding the nearest maximum speed 2 points east and west of each 
            # coordinate on new contour (xdummy,ydummygrid)
            
            lattolooknorth = []
            lattolooksouth = []
            lattolooknorth.append(round(latitudes[i]+ 2*0.25,3)) # 0.25 = 1/4 degree
            lattolooksouth.append(round(latitudes[i]- 2*0.25,3))
            orientated_lattolooknorth   = lattolooknorth
            orientated_lattolooksouth   = lattolooksouth
            orientated_xdummyindex      = xdummyindex[i]
            latitude_search_band = np.where((lat <=lattolooknorth) & (lat >= lattolooksouth))
    
            for j in latitude_search_band:
                speed_search_band = np.array(speed[j,orientated_xdummyindex])
                speed_search_band_keep.append(np.array(speed_search_band))
                max_speed = np.array(np.where(speed_search_band==np.nanmax(speed_search_band)))
                position_of_max.append(max_speed)
                maximum_speed.append(np.nanmax(speed_search_band))
                if pd.isnull(speed_search_band).sum() ==5:
                    continue
                else:
                    max_speed_longitude.append(longitudes[i])
                    max_speed_latitude.append(np.float(lat[j[np.where(np.array(speed_search_band)==np.nanmax(speed_search_band))]]))
    
    ## Determining orientation of core coordinates in order to find max speed
    orientation = []
    for i in range(len(max_speed_longitude)):
        if i != len(max_speed_longitude)-1:
            orient_temporary = (max_speed_latitude[i+1]-max_speed_latitude[i])/(max_speed_longitude[i+1]-max_speed_longitude[i])
            orientation.append(orient_temporary) 
       
    del orient_temporary
    
    orientation_matrix = []
    for i in range(len(orientation)):
        if i == 0:
            orientation_matrix.append(1)
        elif i == 1:
            orientation_matrix.append(1)
        elif i == 2:
            orientation_matrix.append(1)
        elif i == 3:
            orientation_matrix.append(1)
        elif i == 4:
            orientation_matrix.append(1)
        elif i == 5:
            orientation_matrix.append(1)
        elif orientation[i] <= -1:
            orientation_matrix.append(1)
        elif orientation[i] >=1:
            orientation_matrix.append(1)
        elif math.isnan(orientation[i]) == True:
            orientation_matrix.append(1)
        elif orientation[i] == 0.5:
            orientation_matrix.append(0)
        elif orientation[i] == -0.5:
            orientation_matrix.append(0)
        else:
            orientation_matrix.append(0)
    
    orientation_matrix = np.array(orientation_matrix)
    
        
    ## Smoothing of orientation matrix for edges
    
    orientation_matrix_edges = []
    for i in range(len(orientation_matrix)):
        if i == 0:
            orientation_matrix_edges.append(orientation_matrix[i]) #for the first point in matrix
        else:
            orien_1 = orientation_matrix_edges[i-1]
            orien_2 = orientation_matrix[i]
            if i+1 >= len(orientation_matrix)-1:
                orientation_matrix_edges.append(orientation_matrix[i])
            else:
                orien_3 = orientation_matrix[i+1]
            if i+2 >= len(orientation_matrix):
                orientation_matrix_edges.append(orientation_matrix[i])
    
            jen = round(np.average([orien_1,orien_2,orien_3]))
            orientation_matrix_edges.append(jen)
    orientation_matrix_edges = np.array(orientation_matrix_edges[0:len(orientation_matrix)])
    
    del jen, orien_1, orien_2, orien_3
    
    ## Naning points where orientation changes to allow for 
    # a better transition for the edges
    orientation_matrix_2 = []
    for i in range(len(orientation_matrix_edges)):
        if i == 0:
            orientation_matrix_2.append(orientation_matrix_edges[i])
        elif orientation_matrix_edges[i]-orientation_matrix_edges[i-1] == 0:
            orientation_matrix_2.append(orientation_matrix_edges[i])
        else:
            orientation_matrix_2.append(np.nan)
    orientation_matrix_2 = np.array(orientation_matrix_2)
    
    ## Finding the first edge (unsorted)
    orientated_lontolookeast        = []
    orientated_lontolookwest        = []
    orientated_lattolooksouth       = []
    orientated_lattolooknorth       = []
    speed_search_band               = []
    max_speed_distance              = []
    edges1_latitude                 = []
    edges1_longitude                = []
    lon_speed_search_band_keepeast  = []
    lat_speed_search_band_keepnorth = []
    orientated_ydummyindex          = []
    orientated_xdummyindex          = []
    half_speed_keep                 = []
    change_east_keep = []
    change_north_keep = []
    peaks_east_keep = []
    peaks_north_keep = []
    for i in range(len(orientation_matrix_2)-1):
        ## Finding the nearest maximum speed gradient 3 points East of the core
        if orientation_matrix_2[i] == 1:
            edges1_latitude.append(max_speed_latitude[i])
            lontolookeast            = []
            lontolookeast.append(round(max_speed_longitude[i]+ 3*0.25,3)) #used 0.25 = 1/4 degree
            orientated_lontolookeast = lontolookeast
            orientated_ydummyindex   = ydummyindex[i]
            longitude_search_band    = np.where((lon <=orientated_lontolookeast) & (lon > max_speed_longitude[i]))
            if np.size(longitude_search_band)==0:
                break
            if np.size(longitude_search_band)==1:
                break
            if np.size(longitude_search_band)==2:
                break
            for j in longitude_search_band:
                speed_search_band = np.array(grad[orientated_ydummyindex,j])
                lon_speed_search_band_keepeast.append(np.array(speed_search_band))
                peaks_east,dump = scipy.signal.find_peaks(speed_search_band) 
                peaks_east_keep.append(peaks_east)
                if np.size(peaks_east) == 1:
                    edges1_longitude.append(np.float(lon[j[peaks_east]]))
                elif np.size(peaks_east)>=2:
                    peaks_east = peaks_east[0]
                    edges1_longitude.append(np.float(lon[j[peaks_east]]))
                elif np.size(peaks_east) == 0:
                    peaks_east = np.where(speed_search_band == np.nanmax(speed_search_band))
                    if np.size(peaks_east)== 0:
                        edges1_longitude.append(np.nan)
                    else:
                        edges1_longitude.append(np.float(lon[j[peaks_east]]))
            
    
        elif orientation_matrix_2[i]==0:
            edges1_longitude.append(max_speed_longitude[i])
            lattolooknorth              = []
            lattolooknorth.append(round(max_speed_latitude[i]+ 3*0.25,3)) #0.25 = 1/4 degree
            orientated_lattolooknorth   = lattolooknorth
            orientated_xdummyindex      = xdummyindex[i]
            latitude_search_band = np.where((lat <=lattolooknorth) & (lat > max_speed_latitude[i]))
            if np.size(latitude_search_band)==0:
                break    
            if np.size(latitude_search_band)==1:
                break
            if np.size(latitude_search_band)==2:
                break
            for j in latitude_search_band:
                speed_search_band = np.array(grad[j,orientated_xdummyindex])
                lat_speed_search_band_keepnorth.append(np.array(speed_search_band))
                peaks_north,dump = scipy.signal.find_peaks(speed_search_band) 
                peaks_north_keep.append(peaks_north)
                
                if np.size(peaks_north) == 1:
                    edges1_latitude.append(np.float(lat[j[peaks_north]]))
                elif np.size(peaks_north)>=2:
                    peaks_north = peaks_north[0]
                    edges1_latitude.append(np.float(lat[j[peaks_north]]))
                elif np.size(peaks_north) == 0:
                    peaks_north = np.where(speed_search_band == np.nanmax(speed_search_band))
                    if np.size(peaks_north)== 0:
                        edges1_latitude.append(np.float(lat[j[0]]))
                    else:
                        edges1_latitude.append(np.float(lat[j[peaks_north]]))
                
    
        
    ## Finding the second edge (unsorted)
    orientated_lontolookeast          = []
    orientated_lontolookwest          = []
    orientated_lattolooksouth         = []
    orientated_lattolooknorth         = []
    speed_search_band                 = []
    max_speed_distance                = []
    edges2_latitude                   = []
    edges2_longitude                  = []
    lon_speed_search_band_keepwest    = []
    lat_speed_search_band_keepsouth   = []
    orientated_ydummyindex            = []
    orientated_xdummyindex            = []
    change_west_keep = []#01/13
    change_south_keep = [] 
    
    peaks_west_keep = []
    peaks_south_keep = []
    for i in range(len(orientation_matrix_2)-1):
        # Finding the nearest maximum speed gradient 3 points west of the core
        if orientation_matrix_2[i] == 1:
            edges2_latitude.append(max_speed_latitude[i])
            lontolookwest               = []
            lontolookwest.append(round(max_speed_longitude[i]- 3*0.25,3)) #used 0.25 because the resolution of the Altimetry data is 1/4 degree
            orientated_lontolookwest    = lontolookwest
            orientated_ydummyindex      = ydummyindex[i]
            longitude_search_band       = np.where((lon >=orientated_lontolookwest) & (lon < max_speed_longitude[i]))
            if np.size(longitude_search_band)==0:
                break
            if np.size(longitude_search_band)==1:
                break
            if np.size(longitude_search_band)==2:
                break
            for j in longitude_search_band:
                speed_search_band = np.array(grad[orientated_ydummyindex,j])
                lon_speed_search_band_keepwest.append(np.array(speed_search_band))
                peaks_west,dump = scipy.signal.find_peaks(speed_search_band) 
                peaks_west_keep.append(peaks_west)
                if np.size(peaks_west) == 1:
                    edges2_longitude.append(np.float(lon[j[peaks_west]]))
                elif np.size(peaks_west)>=2:
                    peaks_west = peaks_west[len(peaks_west)-1]
                    edges2_longitude.append(np.float(lon[j[peaks_west]]))
                elif np.size(peaks_west) == 0:
                    peaks_west = np.where(speed_search_band == np.nanmax(speed_search_band))
                    if np.size(peaks_west)== 0:
                        edges2_longitude.append(np.float(lon[j[len(j)-1]]))
                    else:
                        edges2_longitude.append(np.float(lon[j[peaks_west]]))    
        # Finding the nearest maximum speed gradient 3 points south of the core
        elif orientation_matrix_2[i]==0:
            edges2_longitude.append(max_speed_longitude[i])
            lattolooksouth              = []
            lattolooksouth.append(round(max_speed_latitude[i]- 3*0.25,3)) 
            orientated_lattolooksouth   = lattolooksouth
            orientated_xdummyindex      = xdummyindex[i]
            latitude_search_band        = np.where((lat >=lattolooksouth) & (lat < max_speed_latitude[i]))
            if np.size(latitude_search_band)==0:
                break
            if np.size(latitude_search_band)==1:
                break
            if np.size(latitude_search_band)==2:
                break
            for j in latitude_search_band:
                speed_search_band       = np.array(grad[j,orientated_xdummyindex])
                lat_speed_search_band_keepsouth.append(np.array(speed_search_band))
                peaks_south,dump = scipy.signal.find_peaks(speed_search_band) 
                peaks_south_keep.append(peaks_south)
                
                if np.size(peaks_south) == 1:
                    edges2_latitude.append(np.float(lat[j[peaks_south]]))
                elif np.size(peaks_south)>=2:
                    peaks_south = peaks_south[len(peaks_south)-1]
                    edges2_latitude.append(np.float(lat[j[peaks_south]]))
                elif np.size(peaks_south) == 0:
                    peaks_south = np.where(speed_search_band == np.nanmax(speed_search_band))
                    if np.size(peaks_south)== 0:
                        edges2_latitude.append(np.nan)
                    else:
                        edges2_latitude.append(np.float(lat[j[peaks_south]]))
                 
      
    ## Smoothing the Core Contour for better plotting
    a=np.array([max_speed_longitude,max_speed_latitude])
    a=np.transpose(a)
    
    x, y = a.T
    t = np.linspace(0, 1, len(x))
    t2 = np.linspace(0, 1, 100)
    sigma = sigma
    x2 = np.interp(t2, t, x)
    y22 = np.interp(t2, t, y)
    x3 = gaussian_filter1d(x2, sigma)
    y3 = gaussian_filter1d(y22, sigma)
    
    smoothed_max_speed_lon = np.interp(t, t2, x3)
    smoothed_max_speed_lat = np.interp(t, t2, y3)
    
    del y3, x3, x2, y22, t, t2, x, y, a
    
    ## Removing any dodgy points in the core (if core begins too far offshore on the east coast)
    check_delete = []
    for p in range(len(smoothed_max_speed_lat[0:10])):
        check = smoothed_max_speed_lat[p+1]-smoothed_max_speed_lat[p]
        if check > 0:
            check_delete.append(p+1)
    
    smoothed_max_speed_lat1 = list(smoothed_max_speed_lat)
    smoothed_max_speed_lon1 = list(smoothed_max_speed_lon)
    
    for pp in range(len(check_delete)):
        for p in check_delete:
            smoothed_max_speed_lat1.pop(p)
            smoothed_max_speed_lon1.pop(p)
    
    smoothed_max_speed_lat1 = np.array(smoothed_max_speed_lat1)
    smoothed_max_speed_lon1 = np.array(smoothed_max_speed_lon1)
    
    del check_delete, p
        
    ## Resizing the edges so that the number of longitudes and latitudes are equal
    if np.size(edges1_latitude)!= np.size(edges1_longitude):
        if np.size(edges1_latitude)>np.size(edges1_longitude):
            edges1_latitude=edges1_latitude[0:len(edges1_longitude)]
        if np.size(edges1_latitude)<np.size(edges1_longitude):
            edges1_longitude=edges1_longitude[0:len(edges1_latitude)]
    
    if np.size(edges2_latitude)!= np.size(edges2_longitude):
        if np.size(edges2_latitude)>np.size(edges2_longitude):
            edges2_latitude=edges2_latitude[0:len(edges2_longitude)]
        if np.size(edges2_latitude)<np.size(edges2_longitude):
            edges2_longitude=edges2_longitude[0:len(edges2_latitude)]
    
    if np.size(edges2_latitude)!= np.size(edges1_latitude):
        if np.size(edges2_latitude)>np.size(edges1_latitude):
            edges2_latitude=edges2_latitude[0:len(edges1_latitude)]
            edges2_longitude = edges2_longitude[0:len(edges1_latitude)]
        if np.size(edges2_latitude)<np.size(edges1_longitude):
            edges1_longitude=edges1_longitude[0:len(edges2_latitude)]
            edges1_latitude = edges1_latitude[0:len(edges2_latitude)]
        
    ## Interpolating core for better definition of polygon 
    # used to separate edges
                
    smoothed_interp_max_speed_lat=[]
    for i in range(len(smoothed_max_speed_lat1)):
        if i == len(smoothed_max_speed_lat1)-1:
            break
        p = srp.intermediates([smoothed_max_speed_lat1[i],smoothed_max_speed_lat1[i]],[smoothed_max_speed_lat1[i+1],smoothed_max_speed_lat1[i+1]],nb_points=5)
        for ii in p:
            smoothed_interp_max_speed_lat.append(ii)
    smoothed_interp_max_speed_lat=np.array(smoothed_interp_max_speed_lat)
    
    smoothed_interp_max_speed_lon=[]
    for i in range(len(smoothed_max_speed_lon1)):
        if i == len(smoothed_max_speed_lon1)-1:
            break
        p = srp.intermediates([smoothed_max_speed_lon1[i],smoothed_max_speed_lon1[i]],[smoothed_max_speed_lon1[i+1],smoothed_max_speed_lon1[i+1]],nb_points=5)
        for ii in p:
            smoothed_interp_max_speed_lon.append(ii)
    smoothed_interp_max_speed_lon=np.array(smoothed_interp_max_speed_lon)
    
    smoothed_interp_max_speed_lat = smoothed_interp_max_speed_lat[:,0]
    smoothed_interp_max_speed_lon = smoothed_interp_max_speed_lon[:,0]
        
    ## Finding whether points are inside or outside of core polygon in
    # order to sort edges into inner and outer: inner = inside polygon and 
    # outer = outside of polygon
    xs = list(smoothed_interp_max_speed_lon)
    ys = list(smoothed_interp_max_speed_lat)
    
    xs.insert(0,xs[0])
    ys.insert(0,ys[0]+0.25)
    xs.append(xs[len(xs)-1])
    
    ys.append(ys[0]+0.25)
    xs.append(xs[0])
    ys.append(ys[0]+0.25)
    
    ys = np.array(ys)
    xs = np.array(xs)
    
    matrix          = np.zeros([len(xs),2])
    for i in range(len(xs)):
        matrix[i,1] = xs[i]
    for i in range(len(ys)):
        matrix[i,0] = ys[i]
    matrix          = tuple(matrix)
    
    lBoundary = matrix
    inner_edge_latitude     = np.zeros([len(edges1_latitude),1])
    inner_edge_longitude    = np.zeros([len(edges1_latitude),1])
    outer_edge_latitude     = np.zeros([len(edges1_latitude),1])
    outer_edge_longitude    = np.zeros([len(edges1_latitude),1])
    
    for i in range(len(edges1_latitude)):
        coordPoint                      = Point(edges1_latitude[i],edges1_longitude[i])
        coordPolygon                    = Polygon(lBoundary)
        if coordPolygon.contains(coordPoint) is True:
            inner_edge_latitude[i,0]    = edges1_latitude[i]
            inner_edge_longitude[i,0]   = edges1_longitude[i]
        else:
            outer_edge_latitude[i,0]    = edges1_latitude[i]
            outer_edge_longitude[i,0]   = edges1_longitude[i]
    
    for i in range(len(edges2_latitude)):
        coordPoint                      = Point(edges2_latitude[i],edges2_longitude[i])
        coordPolygon                    = Polygon(lBoundary)
        if coordPolygon.contains(coordPoint) is True:
            inner_edge_latitude[i,0]    = edges2_latitude[i]
            inner_edge_longitude[i,0]   = edges2_longitude[i]
        else:
            outer_edge_latitude[i,0]    = edges2_latitude[i]
            outer_edge_longitude[i,0]   = edges2_longitude[i]
    
    # Removing zeros from outer edge arrays
    outer_edge_latitude1    = outer_edge_latitude[outer_edge_latitude!=0]
    outer_edge_longitude1   = outer_edge_longitude[outer_edge_longitude!=0]
    
    # Removing zeros from inner edge arrays
    inner_edge_latitude1    = inner_edge_latitude[inner_edge_latitude!=0]
    inner_edge_longitude1   = inner_edge_longitude[inner_edge_longitude!=0]
        
    ## Removing nan values from outer edge coordinates to allow for better plotting
    out_lon         = np.isfinite(outer_edge_longitude1)
    out_lon_index   = np.where(out_lon == True)
    out_lon         = []
    out_lat         = []
    
    for i in out_lon_index:
        out_lon.append(outer_edge_longitude1[i])
        out_lat.append(outer_edge_latitude1[i])
    
    out_lon         = np.squeeze(np.transpose(np.array(out_lon)))
    out_lat         = np.squeeze(np.transpose(np.array(out_lat)))
    out_lat1        = np.isfinite(out_lat)
    out_lat_index   = np.where(out_lat1 == True)
    
    outer_lon = []
    outer_lat = []
    
    for i in out_lat_index:
        outer_lon.append(out_lon[i])
        outer_lat.append(out_lat[i])
    
    out_lon = np.squeeze(np.transpose(np.array(outer_lon)))
    out_lat = np.squeeze(np.transpose(np.array(outer_lat)))
        
    ## Removing nan values from inner edge coordinates to allow for better plotting
    in_lon          = np.isfinite(inner_edge_longitude1)
    in_lon_index    = np.where(in_lon == True)
    in_lon          = []
    in_lat          = []
    
    for i in in_lon_index:
        in_lon.append(inner_edge_longitude1[i])
        in_lat.append(inner_edge_latitude1[i])
    
    in_lon          = np.squeeze(np.transpose(np.array(in_lon)))
    in_lat          = np.squeeze(np.transpose(np.array(in_lat)))
    
    in_lat1         = np.isfinite(in_lat)
    in_lat_index    = np.where(in_lat1 == True)
    
    inner_lon       = []
    inner_lat       = []
    
    for i in in_lat_index:
        inner_lon.append(in_lon[i])
        inner_lat.append(in_lat[i])
    
    in_lon = np.squeeze(np.transpose(np.array(inner_lon)))
    in_lat = np.squeeze(np.transpose(np.array(inner_lat)))
    
    ## Smoothing the Inner edge to remove jaggedness for better plotting
    a       = np.array([in_lon,in_lat])
    a       = np.transpose(a)
    x, y    = a.T
    t       = np.linspace(0, 1, len(x))
    t2      = np.linspace(0, 1, 200)
    x2      = np.interp(t2, t, x)
    y22     = np.interp(t2, t, y)
    sigma   = sigma
    x3      = gaussian_filter1d(x2, sigma)
    y3      = gaussian_filter1d(y22, sigma)
    
    inner_edge_longitude    = np.interp(t, t2, x3)
    inner_edge_latitude     = np.interp(t, t2, y3)
    
    del y3, x3, x2, y22, t, t2, x, y, a
        
    ## Smoothing the Outer Edge to remove jaggedness for better plotting
    a       = np.array([out_lon, out_lat])
    a       = np.transpose(a)
    x, y    = a.T
    t       = np.linspace(0, 1, len(x))
    t2      = np.linspace(0, 1, 200)
    x2      = np.interp(t2, t, x)
    y22     = np.interp(t2, t, y)
    sigma   = sigma
    x3      = gaussian_filter1d(x2, sigma)
    y3      = gaussian_filter1d(y22, sigma)
    
    outer_edge_longitude = np.interp(t, t2, x3)
    outer_edge_latitude = np.interp(t, t2, y3)
    
    del y3, x3, sigma, x2, y22, t, t2, x, y, a

    
    ##Plotting LACCE Figure
    if map_figure == True:
        fig                                         = plt.figure(figsize =(8., 8.),facecolor='white', edgecolor='black')
        ax                                          = fig.add_axes([0.1, 0.135, 0.8, 0.8])
        mmap                                        = srp.setMap(ax,west,east,north,south)
        inner_edge_lon,inner_edge_lat               = mmap(*(inner_edge_longitude,inner_edge_latitude))
        outer_edge_lon,outer_edge_lat               = mmap(*(outer_edge_longitude,outer_edge_latitude))
        lonm,latm                                   = mmap(*np.meshgrid(lon,lat))
        maxspeedlon_lat_gaus,maxspeedlat_lat_gaus   = mmap(*(smoothed_max_speed_lon1,smoothed_max_speed_lat1))
            
        h                                           = mmap.pcolormesh(lonm,latm,ssh,cmap='jet')
        
        mmap.plot(maxspeedlon_lat_gaus,maxspeedlat_lat_gaus,'k',lw=3,label = 'Agulhas Current Core',markersize=2)
        
        
        mmap.plot(outer_edge_lon,outer_edge_lat,'k.',lw=2,markersize=markersize)
        mmap.plot(inner_edge_lon,inner_edge_lat,'k.',lw=2,markersize=markersize)
        
        plt.title('Date: '+date, fontsize=14,fontweight='bold')
        plt.savefig(path_out+'LACCE_'+date+'.png')
        plt.show()
#        plt.close(fig)
        print('figure saved to desired directory')
    
    ##Creating daily LACCE netcdf file 
    filename_out = path_out+'LACCE-'+date+'.nc'
    
    LACCE_ds = {
            'core_lat': smoothed_max_speed_lat1,
            'core_lon': smoothed_max_speed_lon1,
            'outer_edge_lat': outer_edge_latitude,
            'outer_edge_lon': outer_edge_longitude,
            'inner_edge_lat': inner_edge_latitude,
            'inner_edge_lon': inner_edge_longitude,
            'time': ds.time
            }
    LACCE_ds_data = xr.Dataset(LACCE_ds)
    LACCE_ds_data.to_netcdf(filename_out,unlimited_dims={'time':True},format='NETCDF4_CLASSIC')
    print('netDCF saved to desired directory')
