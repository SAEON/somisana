function h=hanning(h);
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;

h(2:Mm,2:Lm)=0.125*(h(1:Mmm,2:Lm)+h(3:M,2:Lm)+...
                       h(2:Mm,1:Lmm)+h(2:Mm,3:L)+...
                       4*h(2:Mm,2:Lm));
h(1,:)=h(2,:);
h(M,:)=h(Mm,:);
h(:,1)=h(:,2);
h(:,L)=h(:,Lm);
return


