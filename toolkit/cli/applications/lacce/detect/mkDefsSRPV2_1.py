# -*- coding: utf-8 -*-
"""
Created on Tue Jun 18 11:01:29 2019

@author: cristinarusso
"""

#-----------------------------------------------------------------------
# Definition for contour extraction from U, V and SH field
# Author: Marjolaine Krug, mkrug@csir.co.za
#-----------------------------------------------------------------------
import numpy as np
import pylab as plt

def distance(a, b):
   """
   Calculates the distance between two GPS points (decimal)
   @param a: 2-tuple of point A
   @param b: 2-tuple of point B
   @return: distance in m
   """
   from math import radians, atan2, sqrt
   r = 6371000             # average earth radius in m
   dLat = radians(a[0]-b[0])
   dLon = radians(a[1]-b[1])
   x = np.sin(dLat/2) ** 2 + \
       np.cos(radians(a[0])) * np.cos(radians(b[0])) *\
       np.sin(dLon/2) ** 2
   y = 2 * atan2(sqrt(x), sqrt(1-x))
   d = r * y
   return d

def find_nearest(array, value):
    array = np.asarray(array)
    idx = np.nanargmin(np.abs(array - value))
    return array[idx]

def findNearest(ilon,ilat,lon,lat):
	"""
	loni,lati,di = findNearest(ilon,ilat,lon,lat):
	find closest point within lat and lon data
	Input:
	ilon, ilat (input longitude and latitude to match)
	lon, lat = longitude and latitude in which to look
	lon and lat must have same dimension
	return:
	loni: longitude of closest point within lon
	lati: latitude of closest point within lat
	di: distance between ilon,ilat and loni, lati
	"""
	d=[]
	for i, j in zip(lon,lat):
		d.append(distance([ilon,ilat],[i,j]))
	ind, = np.where(np.array(d)==min(d))
	ind=ind[-1]
	return lon[ind], lat[ind],np.array(d)[ind]


def getAgulhasCoreSSH(lon,lat,u,v,ssh):
	"""
	Get Agulhas Core from SSH
	
	USAGE:
	x,y = getAgulhasCoreSSH(lon,lat,u,v,ssh)
	
	INPUT:
	lon = longitude in decimal degrees east
	lat = latitude in decimal degrees north
	u = 2D eastward velocity
	v = 2D westward velocity
	ssh = 2D Sea Surface Height
	
	OUTPUT:
	x = longitude in degrees east of Agulhas core position
	y = latitude in degrees north of Agulhas core position
	"""
	speed= np.hypot(u,v)
	speed = np.ma.masked_invalid(speed)
	lonind, = np.where((lon>=26) & (lon <=30))
	latind, = np.where((lat>=-34) & (lat <=-31))
	speed_crop = speed[latind[0]:latind[-1]+1,lonind[0]:lonind[-1]+1]
	ssh_crop = ssh[latind[0]:latind[-1]+1,lonind[0]:lonind[-1]+1]
	sshMax=[]
	for i in range(len(latind)):
		if speed_crop[i,:].mask.all()==False:
			ix, = np.where(speed_crop[i,:]==np.max(speed_crop[i,:]))
			sshMax.append(ssh_crop[i,np.min(ix)])#np.min takes the minimum longitudinal position
	sshMax = np.array(sshMax)
	sshLevel = np.mean(np.ma.masked_invalid(sshMax)) 
	cs = plt.contour(lon,lat,ssh,levels=[sshLevel])
	plt.close()

	pcount=[]
	for p in cs.collections[0].get_paths():
	    pcount+=len(p.vertices[:,0]),
	ind,=np.where(np.array(pcount)==max(pcount))
	crap=cs.collections[0].get_paths()[ind[0]]
	x=crap.vertices[:,0]
	y=crap.vertices[:,1]
	return x,y,sshLevel
	
def setMap(ax,west,east,north,south):
	# Plot trajectory of SVP drifters with ids defined in svpids
	# on axis ax
	# Return map handle mmap
	from mpl_toolkits.basemap import Basemap, cm
	m = Basemap(llcrnrlon=west, \
            llcrnrlat=south, \
            urcrnrlon=east, \
            urcrnrlat = north, \
            resolution = 'h', \
            projection = 'merc', \
            lon_0 = west+(east-west)/2, \
            lat_0 = south+(north-south)/2)
            # compute the native map projection coordinates for depth contours
	parallels = np.arange(np.floor(south),np.ceil(north),2.0)#changed from 5 to 2
	meridians = np.arange(np.floor(west),np.ceil(east),2.0)
	m.drawmapboundary(color='k', linewidth=2.0)
	m.drawcoastlines(color='k')
	m.fillcontinents(color='peru')#peru
	m.drawparallels(parallels, labels=[1,0,0,0],linewidth=0,size=14,fontweight='bold',fontname = 'Times New Roman')
	m.drawmeridians(meridians,labels=[0,0,0,1],linewidth=0,size=14,fontweight='bold',fontname='Times New Roman')
	#m.drawmapscale(east-0.25,south+0.1, east-0.25, south+0.25, 50, barstyle='fancy')
	return m

def secondMax(list1):
    # Code to find second max
    # sorting the list 
    list1.sort()
    secondmaximum = list1[-2]
    return secondmaximum


def intermediates(p1, p2, nb_points=8):
    """"Return a list of nb_points equally spaced points
    between p1 and p2"""
    # If we have 8 intermediate points, we have 8+1=9 spaces
    # between p1 and p2
    x_spacing = (p2[0] - p1[0]) / (nb_points + 1)
    y_spacing = (p2[1] - p1[1]) / (nb_points + 1)

    return [[p1[0] + i * x_spacing, p1[1] +  i * y_spacing] 
            for i in range(1, nb_points+1)]

#print(intermediates([1, 2], [10, 6.5], nb_points=8))

def speed_intermediates(sst_1, sst_2,p1,p2, nb_points=25):
    """"Return a list of nb_points equally spaced points
    between p1 and p2, nb_points = 25 so that the speed data is interpolated to 1 km resolution""" 
    # If we have 8 intermediate points, we have 8+1=9 spaces
    # between p1 and p2
    
    x_spacing = (p2[0] - p1[0]) / (nb_points + 1)
    y_spacing = (p2[1] - p1[1]) / (nb_points + 1)
    sst_spacing = float(sst_2 - sst_1) / float(nb_points + 1)
    interp_speed = []
    for i in range(1, nb_points+1):
        interp_speed.append(sst_1 + i * sst_spacing)
    interp_coords_lon = []
    interp_coords_lat = []
    for i in range(1, nb_points+1):
        interp_coords_lon.append(p1[0] + i * x_spacing)
        interp_coords_lat.append(p1[1] +  i * y_spacing)
    return np.array(interp_speed), np.array(interp_coords_lon), np.array(interp_coords_lat)

def x_round(x):
    import math
    x = math.ceil(x*40)/40
    return x


def regrid_contour_for_OSTIA(g):
    import decimal

    gg = []
    for i in g:
        d = decimal.Decimal(str(i))
        num_decimals = d.as_tuple().exponent
        if num_decimals == -3:
            gg.append(i)
        elif num_decimals == -2:
            dd = round(i,1) + 0.025
            gg.append(round(dd,3))
        elif num_decimals == -1:
            dd = i + 0.025
            gg.append(round(dd,3))
    return np.array(gg)

def calculate_initial_compass_bearing(pointA, pointB):
    """
    https://gist.github.com/jeromer/2005586
    Calculates the bearing between two points.
    The formulae used is the following:
        θ = atan2(sin(Δlong).cos(lat2),
                  cos(lat1).sin(lat2) − sin(lat1).cos(lat2).cos(Δlong))
    :Parameters:
      - `pointA: The tuple representing the latitude/longitude for the
        first point. Latitude and longitude must be in decimal degrees
      - `pointB: The tuple representing the latitude/longitude for the
        second point. Latitude and longitude must be in decimal degrees
    :Returns:
      The bearing in degrees
    :Returns Type:
      float
    """
    import math
    if (type(pointA) != tuple) or (type(pointB) != tuple):
        raise TypeError("Only tuples are supported as arguments")

    lat1 = math.radians(pointA[0])
    lat2 = math.radians(pointB[0])

    diffLong = math.radians(pointB[1] - pointA[1])

    x = math.sin(diffLong) * math.cos(lat2)
    y = math.cos(lat1) * math.sin(lat2) - (math.sin(lat1)
            * math.cos(lat2) * math.cos(diffLong))

    initial_bearing = math.atan2(x, y)

    # Now we have the initial bearing but math.atan2 return values
    # from -180° to + 180° which is not what we want for a compass bearing
    # The solution is to normalize the initial bearing as shown below
    initial_bearing = math.degrees(initial_bearing)
    compass_bearing = (initial_bearing + 360) % 360

    return compass_bearing

def fill(self, *args, **kwargs):
        """
 Draw lines and/or markers on the map (see pylab.plot documentation).
 extra keyword 'ax' can be used to override the default axis instance.
        """
        if not kwargs.has_key('ax') and self.ax is None:
            try:
                ax = pylab.gca()
            except:
                import pylab
                ax = pylab.gca()
        elif not kwargs.has_key('ax') and self.ax is not None:
            ax = self.ax
        else:
            ax = popd(kwargs,'ax')
        # allow callers to override the hold state by passing hold=True|False
        b = ax.ishold()
        h = popd(kwargs, 'hold', None)
        if h is not None:
            ax.hold(h)
        try:
            ret =  ax.fill(*args, **kwargs)
            try:
                pylab.draw_if_interactive()
            except:
                pass
        except:
            ax.hold(b)
            raise
        ax.hold(b)
        # set axes limits to fit map region.
        self.set_axes_limits(ax=ax)
        # make sure axis ticks are turned off.
        if self.noticks:
            ax.set_xticks([])
            ax.set_yticks([])
        return ret
