function y = ppm2fli(list_file,fli_file)

%function y = ppm2fli(list_file,fli_file)

eval(['!rm -f ',fli_file]) 
eval(['!ppm2fli -b 250 -N ',list_file,' ',fli_file]) 
eval (['!echo ''foreach F (`cat ',list_file,'`)'' > .csh.cmd'])
eval (['!echo ''rm -f $F'' >> .csh.cmd'])
eval (['!echo ''end''  >> .csh.cmd'])
!csh .csh.cmd
!rm .csh.cmd
eval(['!rm -f ',list_file])
