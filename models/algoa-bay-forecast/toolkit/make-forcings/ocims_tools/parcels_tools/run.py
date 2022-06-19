#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts for running parcels, once input is already prepared

"""

from argparse import ArgumentParser
from datetime import timedelta
from datetime import datetime
from glob import glob
from os import path
from netCDF4 import Dataset,num2date,date2num

import numpy as np
import pytest

from parcels import AdvectionRK4
from parcels import Field
from parcels import FieldSet
from parcels import JITParticle
from parcels import ParticleFile
from parcels import ParticleSet
from parcels import ScipyParticle
from parcels import ErrorCode
from parcels import DiffusionUniformKh
from parcels import AdvectionDiffusionM1
from parcels import Grid

ptype = {'scipy': ScipyParticle, 'jit': JITParticle}

def DeleteParticle(particle, fieldset, time):
    # used for when particles exit the model domain
    particle.delete()
    
def c_grid_sum(mode, infile_1, infile_2, lon_part, lat_part, time_part, dt_part, dt_out, dur_run, Kh, outfile):
    
    # running parcels on a c-grid by summing the effect of two field sets
    
    # Define the first fieldset
    filenames_1 = {'U': {'lon': infile_1,
                       'lat': infile_1,
                       'data': infile_1},
                 'V': {'lon': infile_1,
                       'lat': infile_1,
                       'data': infile_1}}
    variables = {'U': 'u', 'V': 'v'}
    dimensions = {'lon': 'lon', 'lat': 'lat', 'time': 'time'}
    field_set= FieldSet.from_c_grid_dataset(filenames_1, variables, dimensions)
    grd =  field_set.U.grid # used to add diffusion below
    
    # add the second fieldset (e.g. wind / stokes drift)
    filenames_2 = {'U': {'lon': infile_2,
                        'lat': infile_2,
                        'data': infile_2},
                  'V': {'lon': infile_2,
                        'lat': infile_2,
                        'data': infile_2}}
    field_set_2 = FieldSet.from_c_grid_dataset(filenames_2, variables, dimensions)
    
    # combine the fieldsets
    field_set = FieldSet(U=field_set_2.U+field_set.U, V=field_set_2.V+field_set.V)
    
    # add the constant diffusion to the fieldset
    # I get the following error just trying to use 'grd' when adding the diffusion fields:
    # "Cannot combine Grid from defer_loaded Field with np.ndarray data. please specify lon, lat, depth and time dimensions separately"
    # So I am manually creating a new grid as suggested, just using all the input from 'grd'
    grid = Grid.create_grid(grd.lon, grd.lat, grd.depth, grd.time, grd.time_origin, mesh=grd.mesh)
    field_set.add_field(Field('Kh_zonal', Kh, grid=grid,interp_method='cgrid_tracer'))
    field_set.add_field(Field('Kh_meridional', Kh, grid=grid,interp_method='cgrid_tracer'))
    # note I am using the 'cgrid_tracer' interpolation method as our land mask used to make Kh is on the croco rho grid
    # which is where tracers are defined according to the parcels c-grid index definitions (my understanding of it anyway)
    #
    field_set.add_constant("dres", 0.01) # hmmm, I don't think this matters as our Kh field is actually uniform anyway
    
    pset = ParticleSet.from_list(field_set, ptype[mode], lon=lon_part, lat=lat_part, time=time_part)
    pfile = ParticleFile(outfile, pset, outputdt=dt_out)
    #kernels = pset.Kernel(AdvectionRK4) + pset.Kernel(DiffusionUniformKh) # alternative to AdvectionDiffusionM1 below
    pset.execute(AdvectionDiffusionM1, runtime=dur_run, dt=dt_part,
                 output_file=pfile, recovery={ErrorCode.ErrorOutOfBounds: DeleteParticle})
    pfile.export()

#if __name__ == "__main__":

#    p = ArgumentParser(description="""Chose the mode using mode option""")
#    p.add_argument('--mode', choices=('scipy', 'jit'), nargs='?', default='jit',
#                   help='Execution mode for performing computation')
#    args = p.parse_args()
#    
#    # time origin (not written to the croco output file)
#    #date_ref=datetime(2000,1,1,0,0,0)
#    
#    infile_1 = 'parcels_input_curr.nc'
#    infile_2 = 'parcels_input_wind.nc'
#    
#    # time settings
#    date_start=datetime(2021,1,10,0,0,0) # time of first particle release
#    dur_run=timedelta(days=5)
#    
#    # particle settings
#    dur_spill=timedelta(hours=6)
#    date_end=date_start + dur_spill #datetime(2021,1,11,0,0,0) # time of last particle release
#    dt_part=600 # time interval in seconds between particle release
#    npart_dt=50 # number of particles to be released at each dt_part
#    lon_part = 25.75143 
#    lat_part = -33.82751
#    lon_part,lat_part,time_part=define_particles(infile_1,date_start,date_end,dt_part,npart_dt,lon_part,lat_part)
#    print('releasing a total of '+str(len(time_part))+' particles')
#    
#    # Set diffusion (assumed constant in zonal and meridional directions).
#    Kh = 5 # in m^2/s (should really depend on grid resolution but 5 m^2/s in the right ballpark)
#    Kh=make_Kh(infile_1,Kh)
#    
#    outfile_sum = "parcels_output_sum"
#    run_c_grid_sum(args.mode, infile_1, infile_2, lon_part,lat_part,time_part, Kh, dur_run, outfile_sum)
    
    
