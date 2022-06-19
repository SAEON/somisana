function outname = get_file_python_mercator(pathmotu,mercator_type,vars, ...
                                            geom,date,info,outname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Extract a subgrid from ECCO to get a CROCO forcing
%   Store that into monthly files.
%   Take care of the Greenwitch Meridian.
% 
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr
%
%  Updated   12-Feb-2016 by P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: 
%=======
% get_file_python_mercator(pathMotu,mercator_type,{'varname1' 'varname2'},
%                          [lonmin lonmax latmin latmax, depthmin depthmax],
%                          {'startdate' 'enddate'},{user password},
%                          'outname.nc');
% 
% Check http://marine.copernicus.eu/web/34-products-and-services-faq.php 
% for changes in the command line: addresses, file names, variable names ...
%
% Currently needs motu-client.py v.1.0.8 and Python 2.7.x
%=======
%
eval(['! rm ',outname])

if mercator_type==1, % Mercator data 1/12 deg

  command = {'!python '
	   sprintf('%s',pathmotu)
	   'motu-client-python/motu-client.py'
	   sprintf(' -u %s -p %s',info{1},info{2}) 
%	   ' -S' 
	   ' -m http://atoll.mercator-ocean.fr/mfcglo-mercator-gateway-servlet/Motu'
	   ' -s http://purl.org/myocean/ontology/service/database#GLOBAL_ANALYSIS_FORECAST_PHYS_001_002-TDS'
	   ' -d global-analysis-forecast-phys-001-002'
	   sprintf(' -t %s -T %s',date{1},date{2})
	   sprintf(' -x %f -X %f',geom(1),geom(2))
	   sprintf(' -y %f -Y %f',geom(3),geom(4))
	   sprintf(' -z %f -Z %f',geom(5),geom(6))
	   sprintf(' -o ./')
	   sprintf(' --out-name %s',outname)};
  for k =1:length(vars)
    command{end+1}=sprintf(' -v %s ',vars{k});
  end

else                 % UK Met Office data 1/4 deg

  command = {'!python '
	   sprintf('%s',pathmotu)
	   'motu-client-python/motu-client.py'
	   sprintf(' -u %s -p %s',info{1},info{2}) 
%	   ' -S' 
           ' -m http://data.ncof.co.uk/mis-gateway-servlet/Motu'
	   ' -s http://purl.org/myocean/ontology/service/database#GLOBAL_ANALYSIS_FORECAST_PHYS_001_015'
	   ' -d MetO-GLO-PHYS-daily'
	   sprintf(' -t %s -T %s',date{1},date{2})
	   sprintf(' -x %f -X %f',geom(1),geom(2))
	   sprintf(' -y %f -Y %f',geom(3),geom(4))
	   sprintf(' -z %f -Z %f',geom(5),geom(6))
	   sprintf(' -o ./')
	   sprintf(' --out-name %s',outname)};
  for k =1:length(vars)
    command{end+1}=sprintf(' -v %s ',vars{k});
  end

end
%===
% If you use proxy server, uncomment the following line and replace by your 
%   proxy url and port server. Beware that a SPACE is needed between 
%   "--proxy-server=" and "the proxy-server-name" !
%command{end+2}=sprintf('--proxy-server= http://your_proxy_server:your_proxy_port');
%===
disp([command{:}])
eval([command{:}])
