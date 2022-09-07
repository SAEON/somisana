function fname=get_filename_ECCO2(vname,Y,M,D)

stryear=num2str(Y);
if M<10
    strmonth=['0',num2str(M)];
else
    strmonth=[num2str(M)];
end

if D<10
    strday=['0',num2str(D)];
else
    strday=[num2str(D)];
end

if strcmp(vname,'SSH')
    fname=[vname,'.1440x720.',stryear,strmonth,strday,'.nc'] ;
else
    fname=[vname,'.1440x720x50.',stryear,strmonth,strday,'.nc'] ;
end
return
