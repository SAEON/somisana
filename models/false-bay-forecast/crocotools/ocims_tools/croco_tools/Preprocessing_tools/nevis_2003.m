function n2o=nevis_2003(zw,o2);
%==========================================================================
% O2 to N20 transfer function 
% Ref :  Nevison, C. D., T. J. Lueker, and R. F. Weiss (2004),           
%        Quantifying the nitrous oxide source from coastal upwelling,     
%        Global Biogeochem. Cycles, 18, GB1018, doi:10.1029/2003GB002110.
%==========================================================================
if ( zw <= -50)
    cff=16./170.*0.26/o2-0.0004*exp(zw./3000.);    %mmolN2O/mmolO2
    n2o=cff*o2;
else
    n2o=0.0076;
end
return