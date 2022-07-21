function [j2,i2]=locate_runoff(dir,j,i,mask,masku,maskv)
% 
% j,i : first guess river position
% dir : direction and sense of the flow 
% 
if mask(j,i)==1
    disp('River positionned in sea')
    insea=1;
else
    disp('River positionned in land')
    insea=0;
end
if dir(1)==0
    if insea
        if dir(2)==-1      %est - west => TESTED
            while masku(j,i)==1
                i=i+1;
                %disp(['MASKU:',num2str(masku(j,i))])
            end
            %disp(['--'])
            %disp(['MASKU:',num2str(masku(j,i))])
        elseif dir(2)==1 % west - est => TESTED
            while masku(j,i)==1
                i=i-1;
                %disp(['MASKU:',num2str(masku(j,i))])
            end
            %disp(['--'])
            %disp(['MASKU:',num2str(masku(j,i))])
        end
    else %inland
        if dir(2)==1      %west-est  => TESTED
            while masku(j,i)~=1
                i=i+1;
                %disp(['MASKU:',num2str(masku(j,i))])
            end
            disp(['--'])
            i=i-1
            %disp(['MASK:',num2str(masku(j,i))])
        elseif dir(2)==-1 %est-west => TESTED
            while masku(j,i)~=1
                i=i-1;
                %disp(['MASKU:',num2str(masku(j,i))])
            end
            %disp(['--'])
            i=i+1;
            %disp(['MASKU:',num2str(masku(j,i))])
        end
    end
else %dir(k,1)=1
    if insea
        if dir(2)==-1     % nord - sud  => TESTED
            while maskv(j,i)==1
                j=j+1;
                %disp(['MASKV:',num2str(maskv(j,i))])
            end
            %disp(['--'])
            %disp(['MASKV:',num2str(maskv(j,i))])
        elseif dir(2)==1 % sud - nord => TESTED
            while maskv(j,i)==1
                j=j-1;
                %disp(['MASKV:',num2str(maskv(j,i))])
            end
            %disp(['--'])
            %disp(['MASKV:',num2str(maskv(j,i))])
        end
    else %inland  
        if dir(2)==1      %sud-nord  => TESTED          
            while maskv(j,i)~=1
                j=j+1;
                %disp(['MASKV:',num2str(maskv(j,i))])
            end
            %disp(['--'])
            j=j-1;
            %disp(['MASKV:',num2str(maskv(j,i))])
        elseif dir(2)==-1 %nord-sud => TESTED
            while maskv(j,i)~=1
                j=j-1;
                %disp(['MASKV:',num2str(maskv(j,i))])
            end
            %disp(['--'])
            j=j+1;
            %disp(['MASKV:',num2str(maskv(j,i))])
        end
    end
end
j2=j; i2=i;
return
