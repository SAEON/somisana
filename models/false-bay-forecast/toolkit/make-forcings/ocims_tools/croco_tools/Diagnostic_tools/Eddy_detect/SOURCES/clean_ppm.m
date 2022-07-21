function clean_ppm(list_file)
%
%function clean_ppm(list_file)
%
% Remove the .ppm files form the list
%
eval (['!echo ''foreach F (`cat ',list_file,'`)'' > .csh.cmd'])
eval (['!echo ''rm -f $F'' >> .csh.cmd'])
eval (['!echo ''end''  >> .csh.cmd'])
!csh .csh.cmd
!rm .csh.cmd
eval(['!rm -f ',list_file])
