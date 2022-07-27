
%%%% hindcast iterations %%%
start
crocotools_param

time=(floor(now)-datenum(Yorig,1,1)-(hdays-1)-timezone/24)*86400;

% shift back restart time after first iteration
eval(['!cp ','croco_rst.nc',' ','croco_ini.nc'])
nc=netcdf('croco_ini.nc','write');
nc{'scrum_time'}(1)=time;
close(nc)

for i=1:3
  disp(['I=',num2str(i+1)])
  eval(['!export OMP_NUM_THREADS=4 ; ./croco ','croco_hindcast.in ',' > ','croco_hindcast_',num2str(date),'.out']);

  % shift back restart time for next iteration
  eval(['!cp ','croco_rst.nc',' ','croco_ini.nc'])
  nc=netcdf('croco_ini.nc','write');
  nc{'scrum_time'}(1)=time;
  close(nc)

end

return
