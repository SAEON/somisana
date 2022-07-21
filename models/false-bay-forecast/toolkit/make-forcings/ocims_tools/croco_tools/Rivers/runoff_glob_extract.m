function [my_latriv,my_lonriv,my_flow,my_rivername,number_river]=runoff_glob_extract(grdfile,global_clim_river);
%
%  [my_latriv,my_lonriv,my_flow,my_rivername,number_river]=runoff_glob_extract(grdfile,global_clim_river);
%  Read all the rivers from the netcdf global climatology file
%  Select the ones located into the model grid
%
disp(' ')
disp(['Reading the global monthly climatological run-off dataset... '])
disp(' ')
%
%  Read the grid
%
[latr,lonr,maskr]=read_latlonmask(grdfile,'r');
dl=0.0;
minlat=min(min(latr))-dl;
maxlat=max(max(latr))+dl;
minlon=min(min(lonr))-dl;
maxlon=max(max(lonr))+dl;
%
%  Read the global rivers
%
ncriv=netcdf(global_clim_river,'r');
time=ncriv{'time'}(:);
lonriv_mou=ncriv{'lon_mou'}(:);
latriv_mou=ncriv{'lat_mou'}(:);
ct_name=ncriv{'ct_name'}(:);
cn_name=ncriv{'cn_name'}(:);
warning off
riv_name=ncriv{'riv_name'}(:);
ocn_name=ncriv{'ocn_name'}(:);
stn_name=ncriv{'stn_name'}(:);
warning on
FLOW_clm=ncriv{'FLOW_clm'}(:);
close(ncriv)
%
% Select the rivers in the domain grid
%-------------------------------------
%
my_riv=find(latriv_mou>=minlat & latriv_mou<=maxlat & lonriv_mou >= minlon & lonriv_mou <= maxlon);
%
disp(['There are ',num2str(length(my_riv)),' rivers in the domain : '])
disp(['Domain contains rivers :'])
for k=1:length(my_riv)
   disp([num2str(k),' - ',riv_name(my_riv(k),:),' flowing in ocean ',ocn_name(my_riv(k),1:4)])
end
my_flow=FLOW_clm(:,my_riv);
my_rivername=riv_name(my_riv,:);
number_river=length(my_riv);
my_latriv=latriv_mou(my_riv);
my_lonriv=lonriv_mou(my_riv);
%
% make a figure
%
if ~isempty(my_flow)
    figure
    plot([1:12],my_flow)
    legend(my_rivername)
    box on, grid on
    title(['\bf Monthly clim of the domain run off'])
    xlabel(['\bf Month']);ylabel(['\bf Discharge in m3/s'])
    set(gca,'Xtick',[0.5:11.5],'XtickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D']);
end
%
return
