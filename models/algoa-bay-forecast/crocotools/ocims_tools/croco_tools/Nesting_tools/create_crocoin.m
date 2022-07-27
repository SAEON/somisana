function create_crocoin(parent_name,child_name,rfac,lev)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Create a croco.in.# child input file from a parent input file
%
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['  Create : ',child_name])
fid1=fopen(parent_name,'r');
eval(['!rm -f ',child_name])
fid2=fopen(child_name,'w');
maxlen=0;
blankline=' ';
blankline=repmat(blankline,1,200);
lblank=length(blankline);
while 1==1
  tline=fgetl(fid1);
  ltline=length(tline);
  myline=blankline;
  if ltline>1
    myline(1:min([ltline,lblank]))=tline(1:min([ltline,lblank]));
  end
  if ltline>=maxlen
    maxlen=ltline;
  end
  if ~ischar(tline)
    break
  end
  fprintf(fid2,'%s\n',tline);
  
  %%
  
  if strcmp(myline(1:6),'title:');
    tline=fgetl(fid1);
    if isempty(lev)
      fprintf(fid2,'%s\n',[tline,' ZOOM LEVEL #1']);
    else
      warning off
      if str2num(tline(end))==lev
	tline(end)=num2str(lev+1);
      end
      fprintf(fid2,'%s\n',tline);
      warning on
    end
  end
  
  %%
  
  if strcmp(myline(1:11),'start_date:');
      tline=fgetl(fid1);
      fprintf(fid2,'%s\n',tline);
  end
  
  %%
  
  if strcmp(myline(1:14),'time_stepping:');
    tline=fgetl(fid1);
    A=sscanf(tline,'%f');
    ntimes=A(1);
    dt=A(2);
    ndtfast=A(3);
    ninfo=A(4);
    if rem(dt,rfac)~=0
      disp('Warning: child time step is not an integer...')
    end
    dt=dt/rfac;
    ntimes=1;
    fprintf(fid2,'%s\n',['            ',num2str(ntimes),...
		    '        ',num2str(dt),...
		    '        ',num2str(ndtfast),...
		    '        ',num2str(ninfo)]);
    
  end
  
  %%
  
  if strcmp(myline(1:5),'grid:') | ...
	strcmp(myline(1:8),'forcing:') | ...
	strcmp(myline(1:13),'bulk_forcing:')
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:12),'climatology:') | ...
	strcmp(myline(1:9),'boundary:')
    tline=fgetl(fid1);
    fprintf(fid2,'%s\n','  XXXXXXXXX');
  end
  
  %%
  
  if strcmp(myline(1:8),'initial:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%f');
    nrrec=A(1);
    fprintf(fid2,'%s\n',['          ',num2str(nrrec)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:8),'restart:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%f');
    nrst=A(1);
    nrst=rfac*nrst;
    nrpfrst=A(2);
    fprintf(fid2,'%s\n',['                 ',num2str(nrst),...
		    '   ',num2str(nrpfrst)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:8),'history:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%s %f %f');
    ldefhis=char(A(1));
    nwrt=A(2);
    nwrt=rfac*nwrt;
    nrpfhis=A(3);
    fprintf(fid2,'%s\n',['            ',ldefhis,...
		    '     ',num2str(nwrt),...
		    '     ',num2str(nrpfhis)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  if strcmp(myline(1:9),'averages:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%f');
    ntsavg=A(1);
    navg=A(2);
    navg=rfac*navg;
    nrpfavg=A(3);
    fprintf(fid2,'%s\n',['            ',num2str(ntsavg),...
		    '     ',num2str(navg),...
		    '     ',num2str(nrpfavg)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:12),'diagnostics:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%s %f %f');
    ldefdia=char(A(1));
    nwrtdia=A(2);
    nwrtdia=rfac*nwrtdia;
    nrpfdia=A(3);
    fprintf(fid2,'%s\n',['            ',ldefdia,...
		    '     ',num2str(nwrtdia),...
		    '     ',num2str(nrpfdia)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:9),'diag_avg:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%s %f %f %f %f');
    ldefdia_avg=char(A(1));
    ntsdia_avg=A(2);
    nwrtdia_avg=A(3);
    nwrtdia_avg=rfac*nwrtdia_avg;
    nrpfdia_avg=A(4);
    fprintf(fid2,'%s\n',['    ',ldefdia_avg,...
		    '     ',num2str(ntsdia_avg),...
		    '     ',num2str(nwrtdia_avg),...
		    '     ',num2str(nrpfdia_avg)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:13),'diagnosticsM:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%s %f %f');
    ldefdiaM=char(A(1));
    nwrtdiaM=A(2);
    nwrtdiaM=rfac*nwrtdiaM;
    nrpfdiaM=A(3);
    fprintf(fid2,'%s\n',['    ',ldefdiaM,...
		    '    ',num2str(nwrtdiaM),...
		    '    ',num2str(nrpfdiaM)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:10),'diagM_avg:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%s %f %f %f');
    ldefdiaM_avg=char(A(1));
    ntsdiaM_avg=A(2);
    nwrtdiaM_avg=A(3);
    nwrtdiaM_avg=rfac*nwrtdiaM_avg;
    nrpfdiaM_avg=A(4);
    fprintf(fid2,'%s\n',['     ',ldefdiaM_avg,...
		    '     ',num2str(ntsdiaM_avg),...
		    '     ',num2str(nwrtdiaM_avg),...
		    '     ',num2str(nrpfdiaM_avg)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:16),'diagnostics_bio:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%s %f %f');
    ldefdiabio=char(A(1));
    nwrtdiabio=A(2);
    nwrtdiabio=rfac*nwrtdiabio;
    nrpfdiabio=A(3);
    fprintf(fid2,'%s\n',['    ',ldefdiabio,...
		    '    ',num2str(nwrtdiabio),...
		    '    ',num2str(nrpfdiabio)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:12),'diagbio_avg:')
    tline=fgetl(fid1);
    A=sscanf(tline,'%s %f %f %f');
    ldefdiabio_avg=char(A(1));
    ntsdiabio_avg=A(2);
    nwrtdiabio_avg=A(3);
    nwrtdiabio_avg=rfac*nwrtdiabio_avg;
    nrpfdiabio_avg=A(4);
    fprintf(fid2,'%s\n',['     ',ldefdiabio_avg,...
		    '     ',num2str(ntsdiabio_avg),...
		    '     ',num2str(nwrtdiabio_avg),...
		    '     ',num2str(nrpfdiabio_avg)]);
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:8),'biology:')
    tline=fgetl(fid1);
    fname=rem_blanks(tline);
    if isempty(lev)
      fprintf(fid2,'%s\n',['  ',fname,'.1']);
    else
      fname(end)=num2str(lev+1);
      fprintf(fid2,'%s\n',['  ',fname]);
    end
  end
  
  %%
  
  if strcmp(myline(1:7),'sponge:')
    tline=fgetl(fid1);
     fprintf(fid2,'%s\n','                   XXX              XXX');
%     A=sscanf(tline,'%f');
%     xsponge=A(1);
%     xsponge=round(xsponge/rfac);
%     vsponge=A(2);
%     vsponge=round(vsponge/(rfac^2));
%     fprintf(fid2,'%s\n',['                   ',num2str(xsponge,3),...
% 		    '           ',num2str(vsponge,3)]);
  end
end
fclose(fid1);
fclose(fid2);
return
%
function lineout=rem_blanks(line)
len=length(line);
n=0;
for i=1:len
  if line(i)~=' '
    n=n+1;
    lineout(n)=line(i);
  end
end
return
