function M=m_shaperead(fname,UBR);
% M_SHAPEREAD reads an ESRI-format shapefile
%
%   M=M_SHAPEREAD(FNAME) reads the 3 files
%   that have name FNAME with added .dbf, .shp,
%   and .shx extensions. Data is returned in a
%   structure M, whose format includes several
%   fixed fields that contain the data, as well
%   as an arbitrary number of fields that
%   contain the database information for this
%   particular file.
%
%   Since the shapefile is a self-describing
%   format you have to look at M to discover
%   what is there. The data itself is usually
%   in the .ncst subfield.
% 
% Format info as per:
%
%   Shapefile (.shx,.shp):  Wikipedia and www.esri.com
%   dbf file:  http://www.clicketyclick.dk/databases/xbase/format/index.html
%
%   M_SHAPEREAD(FNAME,UBR) returns only those
%   elements with a minimum bounding rectangle (MBR)
%   that intersects with the User-specified minimum
%   bounding rectangle (UBR), in the format
%      [minX  minY  maxX maxY]
%

% R. Pawlowicz rpawlowicz@eos.ubc.ca 24/Jan/2011


if nargin<2,
 UBR=[-Inf -Inf Inf Inf];
end;
 
%
% Read the .shx file

fidb=fopen([fname '.shx'],'r','b');  % big-endian open
fidl=fopen([fname '.shx'],'r','l');  % little-endian open

if fidb==-1,
 error(['Cannot file filename: ' fname '.shx']);
end;
 
% Read header

head1=fread(fidb,7,'int32');

status=fseek(fidl,28,'bof');
head2=fread(fidl,2,'int32');
head3=fread(fidl,8,'double');

% Read index data
status=fseek(fidb,100,'bof');
recn16=fread(fidb,[2 Inf],'int32')';
lrec=size(recn16,1);

fprintf('%d Records in file, by 500:\n',lrec);

fclose(fidb);
fclose(fidl);


% Read the dbf file. If it isn't there
% we should stil try to read the shp file.
 
fidl=fopen([fname '.dbf'],'r','l');

if fidl==-1,
 disp(['Cannot file filename: ' fname '.dbf']);
 dbf={};
 fnam={};
 nfield=0;
 mdat=[NaN NaN NaN];
else

  ver=fread(fidl,1,'int8');
  mdat=fread(fidl,3,'int8')';
  nrec=fread(fidl,1,'int32');
  hlen=fread(fidl,1,'int16');
  rlen=fread(fidl,1,'int16');

  nfield=(hlen-32-1)/32;
  for k=1:nfield,    % 
    status=fseek(fidl,32*k,'bof');
    fnam{k}=char(fread(fidl,11,'uchar')');
    fnam{k}=fnam{k}(fnam{k}>0);
    ftype(k)=char(fread(fidl,1,'uchar'));
    faddr(k)=fread(fidl,1,'int32');
    flen(k)=fread(fidl,1,'uchar');
  end;

  dbf=cell(nrec,nfield);
  for k=1:nrec,
    if rem(k,500)==0, fprintf('-'); end;
    
    status=fseek(fidl,hlen+1+(k-1)*rlen,'bof');
    for l=1:nfield,
      switch ftype(l),
	case 'N',
          str=char([fread(fidl,flen(l),'uchar')']);
          dbf{k,l}=sscanf(str,'%d');
	case 'F',
          str=char([fread(fidl,flen(l),'uchar')']);
          dbf{k,l}=sscanf(str,'%f');
	case 'I',
          dbf{k,l}=fread(fidl,4,'int32');
	case 'C',
          str=char(fread(fidl,flen(l),'uchar')');
	  str(str==13)=' ';  % CR added in some strings, change to space
          dbf{k,l}= deblank(str);
	case 'D',
       	  str=char(fread(fidl,8,'uchar')');
          dbf{k,l}=datenum(str,'yyyymmdd');
	otherwise
          disp(['Unknown field type: ' ftype(l)]);
       end; 
    end;
  end;  
  fprintf('\n');
  fclose(fidl);
end;

% Set up the data structure so far

M=struct('versiondate',mdat+[1900 0 0],'fieldnames',cell(1,1),...
         'dbfdata',cell(1,1),'type',NaN,'ctype',' ',...
	 'ncst',cell(1,1),'mbr',NaN(lrec,4));

M.fieldnames=fnam;
M.dbfdata=dbf;
for k=1:nfield,
  M=setfield(M,fnam{k},dbf(:,k));
end;


% Read the .shp file

fidl=fopen([fname '.shp'],'r','l');

if fidl==-1,
 error(['Cannot file filename: ' fname '.shp']);
end;

ikp=ones(lrec,1);

for k=1:lrec,
  if rem(k,500)==0, fprintf('.'); end;
  
  fseek(fidl,recn16(k,1)*2+8,'bof');
  stype=fread(fidl,1,'int32');
  M.type=stype;
  switch stype,
    case 0, % null
    
    case 1, % point
      M.ctype='point';
      pt=fread(fidl,2,'double')';
      M.ncst{k,1}=pt;
  
    case 3, % polyline
      M.ctype='polyline';
      mbr=fread(fidl,4,'double');

      if mbr(1)<UBR(3) & mbr(3)>UBR(1) & mbr(2)<UBR(4) & mbr(4)>UBR(2),
	nparts=fread(fidl,1,'int32');
	npts=fread(fidl,1,'int32');
	parts=fread(fidl,nparts,'int32');
	pts=fread(fidl,[2 npts],'double')';
	% Separate in Nan-separated list.
	% Add 'last' offset
	parts=[parts;length(pts)];

	ncst=NaN(length(pts)+length(parts)-2,2);
	for k2=1:length(parts)-1,
          ncst([parts(k2)+1:parts(k2+1)]+(k2-1),:)=pts([parts(k2)+1:parts(k2+1)],:);
	end;
	M.mbr(k,:)=mbr;	
	M.ncst{k,1}=ncst;
      else
	M.ncst{k,1}=[];
        ikp(k)=0;
      end;	  
      
    case 5, % polygon
      M.ctype='polygon';
      mbr=fread(fidl,4,'double');
      if mbr(1)<UBR(3) & mbr(3)>UBR(1) & mbr(2)<UBR(4) & mbr(4)>UBR(2),
	 nparts=fread(fidl,1,'int32');
	 npts=fread(fidl,1,'int32');
	 parts=fread(fidl,nparts,'int32');
	 pts=fread(fidl,[2 npts],'double')';

	 % Separate in Nan-separated list.
	 % Add 'last' offset
	 parts=[parts;length(pts)];

	 ncst=NaN(length(pts)+length(parts)-2,2);
	 for k2=1:length(parts)-1,
           ncst([parts(k2)+1:parts(k2+1)]+(k2-1),:)=pts([parts(k2)+1:parts(k2+1)],:);
	 end;	
	 M.mbr(k,:)=mbr;	
	 M.ncst{k,1}=ncst;
      else
	M.ncst{k,1}=[];
        ikp(k)=0;
      end;	  
      
    case 8, % multipoint
      M.ctype='multipoint';
      mbr=fread(fidl,4,'double');
      if mbr(1)<UBR(3) & mbr(3)>UBR(1) & mbr(2)<UBR(4) & mbr(4)>UBR(2),
	 npts=fread(fidl,1,'int32');
	 pts=fread(fidl,[2 npts],'double')';
	 M.mbr(k,:)=mbr;	
	 M.ncst{k,1}=pts;
      else
	M.ncst{k,1}=[];
        ikp(k)=0;
      end;	  
      
    case 11, % pointZ
      M.ctype='pointZ';
      pt=fread(fidl,3,'double')';
      M.ncst{k,1}=pt;

    case 13, % polylineZ
      M.ctype='polylineZ';
      mbr=fread(fidl,4,'double')';
      if mbr(1)<UBR(3) & mbr(3)>UBR(1) & mbr(2)<UBR(4) & mbr(4)>UBR(2),
	 nparts=fread(fidl,1,'int32');
	 npts=fread(fidl,1,'int32');
	 parts=fread(fidl,nparts,'int32');
	 pts=fread(fidl,[2 npts],'double')';
	 mbrZ=fread(fidl,2,'double')';
	 ptsZ=fread(fidl,[npts],'double')';

	 % Separate in Nan-separated list.
	 % Add 'last' offset
	 parts=[parts;length(pts)];

	 ncst=NaN(length(pts)+length(parts)-2,2);
	 for k2=1:length(parts)-1,
           ncst([parts(k2)+1:parts(k2+1)]+(k2-1),1:2)=pts([parts(k2)+1:parts(k2+1)],:);
           ncst([parts(k2)+1:parts(k2+1)]+(k2-1),3)=ptsZ([parts(k2)+1:parts(k2+1)] );
	 end;
	 if size(M.mbr,2)==4, M.mbr=NaN(size(M.mbr,1),6); end;	
	 M.mbr(k,:)=[mbr mbrZ];	
	 M.ncst{k,1}=ncst;
      else
	M.ncst{k,1}=[];
        ikp(k)=0;
      end;	  

    case 15, % polygonZ
      M.ctype='polygonZ';
      mbr=fread(fidl,4,'double')';
      if mbr(1)<UBR(3) & mbr(3)>UBR(1) & mbr(2)<UBR(4) & mbr(4)>UBR(2),
	 nparts=fread(fidl,1,'int32');
	 npts=fread(fidl,1,'int32');
	 parts=fread(fidl,nparts,'int32');
	 pts=fread(fidl,[2 npts],'double')';
	 mbrZ=fread(fidl,2,'double')';
	 ptsZ=fread(fidl,[npts],'double')';

	 % Separate in Nan-separated list.
	 % Add 'last' offset
	 parts=[parts;length(pts)];

	 ncst=NaN(length(pts)+length(parts)-2,2);
	 for k2=1:length(parts)-1,
           ncst([parts(k2)+1:parts(k2+1)]+(k2-1),1:2)=pts([parts(k2)+1:parts(k2+1)],:);
           ncst([parts(k2)+1:parts(k2+1)]+(k2-1),3)=ptsZ([parts(k2)+1:parts(k2+1)] );
	 end;
	 if size(M.mbr,2)==4, M.mbr=NaN(size(M.mbr,1),6); end;	
	 M.mbr(k,:)=[mbr mbrZ];	
	 M.ncst{k,1}=ncst;
      else
	M.ncst{k,1}=[];
        ikp(k)=0;
      end;	  

    case 18, % multipointZ
      M.ctype='multipointZ';
      mbr=fread(fidl,4,'double');
      if mbr(1)<UBR(3) & mbr(3)>UBR(1) & mbr(2)<UBR(4) & mbr(4)>UBR(2),
	 npts=fread(fidl,1,'int32');
	 pts=fread(fidl,[2 npts],'double')';
	 mbrZ=fread(fidl,2,'double')';
	 ptsZ=fread(fidl,[npts],'double')';
	 if size(M.mbr,2)==4, M.mbr=NaN(size(M.mbr,1),6); end;	
	 M.mbr(k,:)=[mbr mbrZ];	
	 M.ncst{k,1}=[pts ptsZ];
      else
	M.ncst{k,1}=[];
        ikp(k)=0;
      end;	  

       
    otherwise
      disp(['Unknown record type: ' int2str(stype)])
  end;
end;
fclose(fidl);

irem=find(~ikp);
M.dbfdata(irem,:)=[];
M.ncst(irem,:)=[];
M.mbr(irem,:)=[];
for k=1:nfield,
  M.(fnam{k})(irem,:)=[];
end;

  
  
