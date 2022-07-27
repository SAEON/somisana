%----------------------------------------------------------------------
% Read and store in a netcdf file the Self-attraction/Loading "tide" 
% amplitude and phase from the tide model GOT99.2b of R Ray/GSFC                          %                     
%  for principal constituents:
%         M2 S2 N2 K2 K1 O1 P1 Q1
% itide=  1  2  3  4  5  6  7  8 
%
% P. Marchesiello 2015
%----------------------------------------------------------------------
%
clear all
close all
%
SALname='GOT99_SAL.nc';
Ntides=8;
components = 'M2 S2 N2 K2 K1 O1 P1 Q1' ;
prefix=['m2'; 's2'; 'n2'; 'k2'; 'k1'; 'o1'; 'p1'; 'q1'];
%
%  Tidal loading grid:
%    size:  361  720
%   lat: -90.0000   90.0000
%   lon:   0.0000  359.5000
%   spval:  999.00
%
x=[0:0.5:359.5];
y=[-90:0.5:90];
L=length(x);
M=length(y);
%
% Create netcdf file ---------------------------------
%
nw = netcdf(SALname, 'clobber');
%
%  define dimensions
%
nw('tide_period')=Ntides;
nw('x') = L;
nw('y') = M;
%
%  define variables and attributes
%
nw{'lon'} = ncdouble('x');
nw{'lon'}.long_name = ncchar('longitude');
nw{'lon'}.long_name = 'longitude';
nw{'lon'}.units = ncchar('degree_east');
nw{'lon'}.units = 'degree_east';

nw{'lat'} = ncdouble('y');
nw{'lat'}.long_name = ncchar('latitude');
nw{'lat'}.long_name = 'latitude';
nw{'lat'}.units = ncchar('degree_north');
nw{'lat'}.units = 'degree_north';

nw{'tide_period'} = ncdouble('tide_period');
nw{'tide_period'}.long_name = ncchar('Tide angular period');
nw{'tide_period'}.long_name = 'Tide angular period';
nw{'tide_period'}.units = ncchar('Hours');
nw{'tide_period'}.units = 'Hours';

nw{'tide_SALamp'} = ncdouble('tide_period', 'y', 'x');
nw{'tide_SALamp'}.long_name = ncchar('Amplitude of Self-attraction/Loading tide');
nw{'tide_SALamp'}.long_name = 'Amplitude of Self-attraction/Loading tide';
nw{'tide_SALamp'}.units = ncchar('Meter');
nw{'tide_SALamp'}.units = 'Meter';

nw{'tide_SALpha'} = ncdouble('tide_period', 'y', 'x');
nw{'tide_SALpha'}.long_name = ncchar('Phase of Self-attraction/Loading tide');
nw{'tide_SALpha'}.long_name = 'Phase of Self-attraction/Loading tide';
nw{'tide_SALpha'}.units = ncchar('Degrees');
nw{'tide_SALpha'}.units = 'Degrees';
%
% Create global attributes
%
nw.type = ncchar('GOT99.2 tides loading file');
nw.type = 'GOT99.2 tides loading file';
nw.components = ncchar(components);
nw.components = components;
nw.date = ncchar(date);
nw.date = date;
%
% Write grid
%
nw{'lon'}(:)=x;
nw{'lat'}(:)=y;
% ----------------------------------------------------
%
%  Amplitude and Phase
%
for itide=1:Ntides

  fname=[prefix(itide,:),'sal.txt'];
  disp(['... Processing ',fname,' ...'])
  M=importdata(fname);

  for j=1:361
    for i=1:720
      j0=(j-1)*66+ceil(i/11);
      i0=mod(i,11);
      if i0==0, i0=11; end
      joff=floor(361*726/11);
      SALamp(j,i)=M(j0,i0)*0.001; % mm --> m
      SALpha(j,i)=M(j0+joff,i0);
    end
  end
  %
  % Perform extrapolation
  %
  SALamp(SALamp==999)=NaN;
  SALpha(SALpha==999)=NaN;
  SALamp=get_missing_val(x,y,SALamp);
  SALpha=get_missing_val(x,y,SALpha);
  %
  % Write data
  %
  nw{'tide_SALamp'}(itide,:,:)=SALamp;
  nw{'tide_SALpha'}(itide,:,:)=SALpha;

end
close(nw)

%
%  Make a few plot
%
nc=netcdf(SALname);
for itide=[1 5];
 SALamp=squeeze(nc{'tide_SALamp'}(itide,:,:));
 SALpha=squeeze(nc{'tide_SALpha'}(itide,:,:));
% AMP
 figure
 domaxis=[0 359 -80 80];
 m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
 m_pcolor(x,y,SALamp);
 shading flat;
 colorbar
 m_gshhs_c('color','r');
 m_gshhs_c('patch','k');
 m_grid('box','fancy',...
         'xtick',5,'ytick',5,...
         'fontsize',7);
 fname=[prefix(itide,:),'sal.txt'];
 title([fname(1:5),' AMPLITUDE'],'fontsize',16)
% PHASE
 figure
 domaxis=[0 359 -80 80];
 m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
 m_pcolor(x,y,SALpha);
 shading flat;
 colorbar
 m_gshhs_c('color','r');
 m_gshhs_c('patch','k');
 m_grid('box','fancy',...
         'xtick',5,'ytick',5,...
         'fontsize',7);
 fname=[prefix(itide,:),'sal.txt'];
 title([fname(1:5),' PHASE'],'fontsize',16)
end
close(nc)

