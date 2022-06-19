function rem_avg_zeta(clmname,grdname,oaname)
%
% Pierrick 2003
%
% remove the domaine average of zeta
%
%
%  grid parameters
%
nc=netcdf(grdname,'r');
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
rmask=nc{'mask_rho'}(:);
[M,L]=size(rmask);
close(nc)
%
%  Model grid vertical levels
%
noa=netcdf(oaname,'r');
nc=netcdf(clmname,'write');
tlen = length(nc('zeta_time'));
%
%  Time loop
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  ssh=squeeze(noa{'zeta'}(l,:,:));
  avgssh=sum(sum(rmask.*ssh./(pm.*pn)))/sum(sum(rmask./(pm.*pn)));
  ssh=ssh-avgssh;
  nc{'zeta'}(l,:,:)=ssh;
  nc{'SSH'}(l,:,:)=ssh;
end
close(nc)
close(noa)
