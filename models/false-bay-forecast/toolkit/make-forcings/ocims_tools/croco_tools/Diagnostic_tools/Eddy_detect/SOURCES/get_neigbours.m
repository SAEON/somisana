function [match1,ismatch1,match2,ismatch2]=...
            get_neigbours(elon1,elat1,R1,X1,MeanSSH1,Ampl1,...
	                  elon2,elat2,R2,X2,MeanSSH2,Ampl2,do_plots,...
                          L0,R0,X0,Z0,A0);
%
% Test which eddy is the closest to each other
%
%
%
match1=NaN*elon1;
ismatch1=0*elon1;
match2=NaN*elon2;
ismatch2=0*elon2;
n1=length(elon1);
n2=length(elon2);
%
% construct a distances matrix (n1 eddies in frame #1 X n2 eddies in frame #2)
%
D=zeros(n1,n2);
for i1=1:n1
%  D(i1,:)=spheric_dist(elat1(i1),elat2,elon1(i1),elon2);
  D(i1,:)=general_dist(elon1(i1),elat1(i1),R1(i1),X1(i1),MeanSSH1(i1),Ampl1(i1),...
	               elon2,elat2,R2,X2,MeanSSH2,Ampl2,...
                       L0,R0,X0,Z0,A0);
end
while sum(isfinite(D(:)))~=0
%
% get the closest eddies
%
  [i1,i2]=find(D==min(D(:)));
%
% plot the link between the 2
%
  if do_plots==1
    hold on
    h1=m_plot([elon1(i1) elon2(i2)],[elat1(i1) elat2(i2)],'k');
    set(h1,'LineWidth',2)
  end
%
% Store the value
%  
  ismatch1(i1)=1;
  match1(i1)=i2;
  ismatch2(i2)=1;
  match2(i2)=i1;
%
% remove the line and column associated with these 2 eddies
%
  D(:,i2)=NaN;
  D(i1,:)=NaN;
end


return
