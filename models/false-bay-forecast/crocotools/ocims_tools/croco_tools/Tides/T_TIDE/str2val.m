function [val,str,form,msg] = str2val(val,form,vnan,acc)

% STR2VAL  Converts between Valus and Formated Strings
%
% [ Value , String , Format , Msg ] = STR2VAL( Argument , Format )
%
% For permuted Outputs use VAL2STR !!!
%
% Argument can be a Value or a String, Format gives the Conversion 
%   between them:   Value <--- Format ---> String
%
% To Replace MissingValues or Dummies by NaN use a 3. and 4. Input:
%
%    STR2VAL( Argument , Format , Dummy , Accuracy )
% 
% All Values which are in Range of Accuracy around the Dummies
%  will be replaced by NaN. Dummy can be a Vector or Matrice.
%  Example:   STR2VAL( ... , [ -9999  1e32 ] , 1e-10 )
% 
% Valid Formats are:
%
%  'char'    Value == String
%
%  '%#.#*'   for using by SPRINTF
%
%  'glon#'   for Geographic Coordinates Longitude    **°**.**' <E|W>
%  'glat#'   for Geographic Coordinates  Latitude    **°**.**' <N|S>
%  'gpos#'   for Geographic Coordinates  Lat & Lon: [ "glat#"  "glon#" ] 
%
%            # gives the Number of decimal Minutes
%
%            use the first upper Character "G" in Positionsformat
%              to return a short Form:  ***<E|W>**.**  or  ***<N|S>**.**
%
%  'dgms#'   for Sexagesimal Conversion: [ Degree Minute Second ]
%                # == '-'   Degree = ( -180 .. 180 ]   ±DDD° MM' SS"
%                # == '+'   Degree = [    0 .. 360 )    DDD° MM' SS"
%
%  'time#'   for TimeConversation, first Value  Day: # == 1    DD HH:MM
%                                              Hour: # == 2       HH:MM
%                                              Hour: # == 3       HH:MM:SS
%                                            Minute: # == 4          MM:SS
%
%            increase the Value by 4, to use Duplicate TimeValues:
%
%                # == 5    DD HH:MM - DD HH:MM
%                # == 6       HH:MM - HH:MM
%                # == 7       HH:MM:SS - HH:MM:SS
%                # == 8          MM:SS - MM:SS
%
%              use 'time#<seperator>' to define the Seperator between the Values
%               default: ' - '
%
%  'date#*'  for DateConversion, # == 0       Month as Number
%                                     1       Month as Short String (3 Characters)
%                                     2       Month as long String
%                                * == e | g   english / german Date only
%                                     E | G   english / german Date and HH:MM
%
%                                     d | D   YYYY-MM-DD Notation
%
%            Note:  Year < 100  will expand with 2000 !!!
%
%            Example:
%
%            'date0E'   MM/DD/YYYY HH:MM       12/01/1995 15:45
%            'date0G'   DD/MM/YYYY hh:mm       01.12.1995 15:45
%
%            'date1E'   DD-MMM-YYYY hh:mm      01-Dec-1995 15:45
%            'date1G'   DD.MMM.YYYY hh:mm      01.Dez.1995 15:45
%
%            'date2E'   DD. Month YYYY hh:mm   01. December 1995 15:45
%            'date2G'   DD. Monat YYYY HH:MM   01. Dezember 1995 15:45
%
%            'date0D'   YYYY/MM/DD hh:mm       1995/12/01 15:45
%            'date1D'   YYYY-MM-DD hh:mm       1995-12-01 15:45
%            'date2D'   YYYY MM DD hh mm       1995 12 01 15 45
%
%
% { Seperator }      Converts between String and CellArray of Strings,
%                     splitted by the single SeperatorCharacter
%
% { Value  Format }  a 2-Column CellArray gives allowed Values 
%                      and the corresponding Format
%
%
%  '@'            String returns the Size and Class of Argument
%
%  '@ClassName'   Specify the Class of Value
%
% Special ClassNames are:
%
% 'numeric'   True if ISNUMERIC
% 'string'    True for ONE-Row CharacterArray or ONE-Element CellArray of it
% 'cellstr'   True for CellArray or CharacterArray of Strings
% 'object'    True if ISOBJECT
%
% Special additional Handlings for Matlab-defined Class's:
%
% 'double'    True if ISNUMERIC
% 'single'    True if ISNUMERIC
% 'sparse'    True if ISNUMERIC
% 'logical'   True if ISNUMERIC  with Values [ 0 | 1 ]
% 'int<B>'    True if ISNUMERIC  with Values [ -2^(B-1) .. 2^(B-1)-1 ]
% 'uint<B>'   True if ISNUMERIC  with Values [  0       .. 2^(B)-1   ]
% 'char'      True if ISCELLSTR
% 'cell'      True if CharacterArray
% 'struct'    True if Object
% ClassName   True if Object is of given Class
% @ClassName  True if Object inherits of given Class, using ISA, returns Object
% @ClassName@ True if Object inherits of given Class, using ISA, returns Parent
%
%
%-------------------------------------------------------------------------------
%
% See also: VAL2STR, STR2VEC, SPRINTF, VAR2MSTR, STRHCAT, SEPNAME, CLASSCHK
%
% requires: VAR2MSTR, STR2VEC
%

str  = '';

Nin = nargin;

if Nin < 2 
   msg  = 'Input "Format" is missing.';
   form = '';
   return
end

if Nin < 3, vnan = []; end
if Nin < 4,  acc = []; end

[msg,val,str,ff,mode] = checkin(val,form);

nl = char(10);

if ~isempty(vnan)
    if isnumeric(vnan)
       vnan = double(vnan(:))';
    else
       msg = cat(2,msg,nl(1:(end*(~isempty(msg)))), ...
                  'Dummy must be numerics.');
    end
end

if isempty(acc)
   acc = 1e-10;
elseif ~( isnumeric(acc) & ( prod(size(acc)) == 1 ) )
   msg = cat(2,msg,nl(1:(end*(~isempty(msg)))), ...
               'Accuracy must be a single numeric.');
end
   
if ~isempty(msg)
    return
end


switch lower(ff)

     %----------------------------------------
     case 'none'

          form = '';

          return

     %----------------------------------------
     case 'empty'

          return

     %----------------------------------------
     case '@'

         [msg,val,str] = obj_str(val,mode);

     %----------------------------------------
     case 'cell'

         [msg,val,str,form] = cell_str(val,form,vnan,acc);

     %----------------------------------------
     case 'sep'

         [msg,val,str] = sep_str(val,form);

     %----------------------------------------
     case 'char'

         [msg,val,str] = char_str(val);

     %----------------------------------------
     case 'dgms'

         [msg,val,str] = dgms_str(val,mode,vnan,acc);

     %----------------------------------------
     case 'time'

         [msg,val,str] = time_str(val,mode,vnan,acc);

     %----------------------------------------
     case 'date'

         [msg,val,str] = date_str(val,mode,vnan,acc);
  
     %----------------------------------------
     case 'gpos'

         [msg,val,str] = pos_str(val,ff,mode,vnan,acc);

     %----------------------------------------
     case { 'glon'  'glat' }

         [msg,val,str] = geo_str(val,ff,mode,vnan,acc);

     %----------------------------------------
     otherwise

         [msg,val,str] = form_str(val,form,vnan,acc);

end 

   
%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str,form,mode] = checkin(val,form);

msg   = '';
str   = '';
mode  = '';

% First Check of Inputs

%-------------------------------------------
% Check for Empty Format

if isempty(form)

  if ischar(val)
     str = val;
     if ~iscell(form)
         val = [];
     end
  end

  form = 'none';

  return

end

%-------------------------------------------
% Check Format-String

is_sep   = 0;
is_class = 0;

is_cell  = iscell(form);

if is_cell

   %------------------------------------------------------
   % Seperator

   is_sep = ( prod(size(form)) == 1 );

   if is_sep

      sep = form{1};

      is_sep = ( ischar(sep) & ( prod(size(sep)) == 1 ) );

      if ~is_sep
          msg = 'Single-Element Format-CellArray must contain a single Character (Seperator).';
          return
      end

      form = 'sep';

   %------------------------------------------------------
   % { Value Format }

   elseif ~( ( size(form,2) == 2 ) | isempty(form) )

      msg = 'Format-CellArray must have 2 Columns.';
      return

   else

      form = 'cell';

   end

   is_cell = ~is_sep;

elseif ~chkstr(form,1)

   msg = 'Format must be a String.';

   return

else

   is_class = strcmp(form(1),'@');

   nm = 4 - 3 * is_class;

   mode = form( nm+1 : end );
   form = form( 1 : min(size(form,2),nm) );

end

%-------------------------------------------
% Check String-Input

if iscellstr(val)  &  ~( is_class | is_cell | is_sep )
   val = char(val);
end

if ischar(val) & ~( is_cell | is_class )

   val = rmblank(val,2);

   %---------------------------------------
   % Seperator: CharacterArray --> CellStringArray

   if is_sep & ( size(val,1) > 1 )
      if isempty(val)
         val    = cell(1,size(val,1));
         val(:) = { '' };
      else
         val = cellstr(val);
         val = val(:)';
      end
      return
   end

end

%-------------------------------------------
% Check for Empty Value

if isempty(val) & ~( is_class | is_cell )

   if is_sep
      val = cell(1,0);
   else
      val = [];
   end

   str = '';

   form = 'empty';

   return

end

%-------------------------------------------

is_char = ~( is_cell | is_sep );

if is_char
   is_char = strcmp( lower(form) , 'char' );
end

%-------------------------------------------
% Check String

%-------------------------------------------
if ischar(val) 

  if ~( ( prod(size(val)) == size(val,2) )  ...
        | is_char | is_cell | is_sep )
 
      msg = 'Character-Input must be a String.';

  end

%-------------------------------------------
elseif is_class

  if isempty(mode)

     mode = class(val);

  else

     is_end = strcmp(mode(end),'@');

     md = mode( 1 : ( end - is_end ) );

     if is_end
        [ok,v] = classchk( val , md );
     else
         ok    = classchk( val , md );
     end

     if  ~ok
         msg = cat( 2 , 'Input must be a String or of Class "' , md , '".' );
     elseif is_end
         val = v;
     end

  end

%-------------------------------------------
elseif is_sep

  if ~chkcstr(val,0)
     msg = 'Input must be a String or CellArray of Strings.';
  else
     val = val(:)';
  end

%-------------------------------------------
elseif isnumeric(val) & ~is_cell

  if ~is_char

      val = val(:)';

  end

%-------------------------------------------
elseif ~( is_char | is_cell )

  msg = 'Input must be a String or Numeric.';

end


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,vv,str,ff] = cell_str(val,form,vnan,acc);

% CELL_STR   Compares Values with { Value Format } - Cell
%

msg = '';
vv  = [];
str = '';
ff  = '';


%-----------------------------------------------
% Check for String-Value

char_val = ischar(val);

if char_val
   vs  = rmblank(val,2);
   if size(vs,1) == 1
      vs = lower(vs);
   end
end


%-----------------------------------------------
% Check for Value in Format


nf        = size(form,1);
last_free = isempty(form{nf,1});

for ii = 1 : nf-last_free

    vv = form{ii,1};
    ff = form{ii,2};

    %---------------------------------------------------------
    % Compare Direct

    ok = isequal(val,vv);

    if ~ok

       %---------------------------------------------------------
       % Try to Convert Strings to lower

       if char_val  &  ischar(vv) 

         vc = rmblank(vv,2);

         if size(vc,1) == 1
            vc = lower(vc);
         end

         ok = isequal(vs,vc);

       end

       %---------------------------------------------------------
       % Try to Convert Value with Format

       if ~ok

          try

            [v1,str,ff,msg1] = str2val(val,ff,vnan,acc);

             ok = ( isequal(v1,vv) & isempty(msg1) );

             if ok
                return
             end

          end

       end

    end
    % ~ok = isequal(val,vv)

    %---------------------------------------------------------
    if ok

       try

          [vv,str,ff,msg1] = str2val(vv,ff,vnan,acc);

          if isempty(msg1)
             return
          end

      end
 
    end

end           


ok = last_free;

if ok

    [vv,str,ff,msg] = str2val(val,form{nf,2},vnan,acc);

    ok = isempty(msg);

end


if ~ok

    msg = 'Invalid Value.';

     vv = val;
    str = '';
     ff = '';

end

   
%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = sep_str(val,form);

% SEP_STR   Convert String or CellArray of Strings with Seperator
%

msg = '';

sep = form{1};

if iscell(val)
   val = strhcat(val,sep);
end

str = val;
val = { '' };

%---------------------------------------------

n = size(str,2);

%---------------------------------------------
% Find Seperator in Name

is = ( double(str) == double(sep) );

if all(is)
   val = val(ones(1,n-1));
   return
end

%---------------------------------------------

i0 = ~is(1);
i1 = ~is(n);

is = cat( 2 , ones(1,i0) , is , ones(1,i1) );

is = find( is );

is = is(:);

ni = size(is,1) - 1;

if ni == 0 
   return
end
     
%---------------------------------------------
% [ Start  End ]

ind = ( 1 : ni ) ;

is  = cat( 2 , is(ind)+1 , is(ind+1)-1 ) - i0;

%---------------------------------------------
% Take care for duplicate Blank Seperators

if ( double(sep) == char(32) )

   is( find( is(:,1) > is(:,2) ) , : ) = [];

end

%---------------------------------------------

ni = size(is,1);

if ni == 0
   return
end

%---------------------------------------------
   
   ind = ( 1 : ni );

   is = is(ind,:);

   val = cell(1,ni);
  
   for ii = 1 : ni

       val{ii} = str( is(ii,1) : is(ii,2) );

   end



%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = char_str(val);

msg = '';

if ischar(val)

     str = val;

else

     try
        str = var2mstr(val);
     catch
        msg = sprintf('Error call VAR2MSTR.%s%s',char(10),lasterr);
     end

end

%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = obj_str(val,mode);

msg = '';

%----------------------------------------
% Check for Parent

is_end = ~isempty(mode);

if is_end

   is_end = strcmp(mode(end),'@');

   mode = mode( 1 : ( end - is_end ) );

end

%----------------------------------------
% Check for Matlab-Expression

if ischar(val) 
   if           strcmp( mode ,   'cellstr' )
            val = cellstr(val);
   elseif ~any( strcmp( mode , { 'char'  'string' } ) )
          try
            val = eval(val);
          end
   end
end

%----------------------------------------

if isempty(mode)
   mode = class(val);
end

%---------------------------------------------
% Check for Object

if is_end
   [ok,v] = classchk( val , mode );
else
    ok    = classchk( val , mode );
end

if ok

   if is_end
      val = v;
   end

   str = sprintf('%.0fx',size(val));

   str = str(1:(end-1));

   str = cat( 2 , str , ' ' , class(val) );

   return

end

%---------------------------------------------
% Check for String

str = val;
val = [];

ok = 1;

try
   val = eval(str);
catch
   ok  = 0;
end

if ok 
   if  is_end
       [ok,v] = classchk( val , mode );
   else
        ok    = classchk( val , mode );
   end
end

if ok

   if is_end
      val = v;
   else
      mode = class(val);
   end

else

  %-------------------------------------------
  % Get Size from String

  [msg,si] = str2vec(str,'0123456789');

  if isempty(si) 
     si = [ 0  0 ];
  elseif prod( size(si) == 1 )
     si = cat( 2 , si , 1 );
  end

  ii     = find( ~isfinite(si) | ( si < 0 ) );
  si(ii) = 0;

  %-------------------------------------------
  % Create Object

  [val,msg] = defval(mode,si);

  if ~isempty(msg)
      return
  end

  if ~isequal( size(val) , si )

    %-------------------------------------------
    % IndexVectors

    ns = prod(size(si));

    ind = cell(ns,1);

    for ii = 1 : ns
        ind{ii} = ones(1,si(ii));
    end

    val = val(ind{:});

  end

end

%-------------------------------------------
% Get String

[msg,val,str] = obj_str(val,mode);
 

%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = pos_str(val,form,mode,vnan,acc)

msg = '';
str = '';

[msg,v1,v2] = split(val);

if ~isempty(msg)
    if ischar(val);
       str = val;
    end
    return
end

val = NaN * ones(1,2);

[msg1,val(1),str1] = geo_str(v1,[form(1) 'lat'],mode,vnan,acc);

[msg2,val(2),str2] = geo_str(v2,[form(1) 'lon'],mode,vnan,acc);


nl = char( 10 * ones( 1 , ~( isempty(msg1) | isempty(msg2) ) ) );

msg = cat( 2 , msg1 , nl , msg2 );

str = cat( 2 , str1 , ',' , str2 );

%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = geo_str(val,form,mode,vnan,acc)

msg = '';
str = '';


is_lat = strcmp(lower(form),'glat');

[msg,val] = geo_val(val,is_lat,vnan,acc);

if ~isempty(msg)
   return
end

short = ( form(1) == upper(form(1)) );

%--------------------------------------------------------
% Get Format

[msgM,mode] = str2vec(mode,'0123456789');

if isempty(mode)
   mode = 2;
else
   mode = mode(1);
end

%--------------------------------------------------------

ws = ( val < 0 );

wsc = 'EWNS';

wsc = wsc( (1+ws) + 2*is_lat );

%--------------------------------------------------------

mpre = 2 + ( mode > 0 ) + mode;

mfrm = sprintf('%%%.0f.%.0ff',[mpre mode]);  % Format for Minutes

gpre = 4;

gfrm = sprintf('%%%.0f.0f',gpre);  % Format for Degree

%--------------------------------------------------------

short = ( form(1) == upper(form(1)) );

if short
   frm = sprintf('%s%s%s',gfrm,wsc,mfrm);
   rep = gpre + 1;
else
   frm = sprintf('%s%s %s''%s',gfrm,char(176),mfrm,wsc);
   rep = gpre + 1;
end

% form = cat( 2 , '%4.0f' , char(176) , form , '''' , wsc );
 
[val,vec] = fixvec(abs(val),[1 60],-mode);

str = sprintf(frm,vec);

rep = rep + 1;

if short & ( str(rep) == ' ' ) & ~isnan(vec(2))
   str(rep) = '0';
end
 
[msg,val] = geo_val(str,is_lat,vnan,acc);


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val] = geo_val(val,is_lat,vnan,acc)

msg = '';

if ischar(val)
%*******************************************************
% STRING --> VALUE
%-------------------------------------------------------

   ws =  ( ( any(lower(val)=='w')  &  ~is_lat ) | ...
           ( any(lower(val)=='s')  &   is_lat )       );

   [msg,val] = str2vec(val,'0123456789+-*/.');

   if ~isempty(msg)
      return
   end

   if isempty(val)

      val = NaN * ones(1,3);

   end

else

  ws = 0;

  val(2:end) = val(2:end) * sign(val(1));

end


%-------------------------------------------------

val = val( 1 : min(size(val,2),3) );

if ~isempty(vnan)
    isn = zeros(size(val));
    for v = vnan
        isn = ( isn | ( abs(val - v) < acc ) );
    end
    if any(isn)
           isn  = find(isn);
       val(isn) = NaN;
    end
end

val = cat( 2 , val , zeros(1,3-size(val,2)) );

val = sum( val .* [ 1  1/60  1/3600 ] ) * ( 1 - 2*ws );

val = val - 360 * floor(val/360);  % [ 0 .. 360 )

val = val - 360 * ( val > 180 );   % ( 180 .. 180 ]


% Special for Latitude

if is_lat
   while abs(val) > 90
         val = val + ( sign(val) * 180 - 2*val ) * ( abs(val) > 90 );
   end
end


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = dgms_str(val,mode,vnan,acc)

msg = '';
str = '';

%--------------------------------------------------------
% Get Format

if isempty(mode)
   mode = '-';
else
   mode = mode(1);
end

mode = ( mode == '-' );

%--------------------------------------------------------
% Get Format

if mode 
   form = [ '%4.0f' char(176) ' %2.2d'' %2.2d"' ];
else
   form = [ '%3.0f' char(176) ' %2.2d'' %2.2d"' ];
end

%--------------------------------------------------------

[msg,val,vec] = time_val(val,[1 2 3],[1 60 60],vnan,acc);

if ~isempty(msg)
    return
end

val = val - 360 * floor(val/360);

if mode
   val = val - 360 * ( val > 180 );
end

[msg,val,vec] = time_val(val,[1 2 3],[1 60 60],vnan,acc);

if ~isempty(msg)
    return
end

str = sprintf(form,vec);


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = time_str(val,mode,vnan,acc)

msg = '';
str = '';

%--------------------------------------------------------
% Get Format

% 1: DD hh:mm
% 2:    hh:mm
% 3:    hh:mm:ss
% 4:       mm:ss

sep = '';
if ischar(mode)
   sep = mode(2:end);
   [msg,mode] = str2vec(mode,'0123456789');
end

if isempty(mode)
   mode = NaN;
else
   mode = mode(1);
end

if isnan(mode)
   mode = 3;
end

dbl  = ( mode > 4 );
mode = mode - 4 * floor(mode/4);  % 0 .. 3 
mode = mode + 4 * ( mode == 0 );

%******************************************************
if dbl
%******************************************************

   if isempty(sep)
      sep = ' - ';
   end

   [msg,v1,v2] = split(val);

   if ~isempty(msg)
       if ischar(val);
          str = val;
       end
       return
   end

   val = NaN * ones(1,2);

   [msg1,val(1),str1] = time_str(v1,mode,vnan,acc);

   [msg2,val(2),str2] = time_str(v2,mode,vnan,acc);


    nl = char( 10 * ones( 1 , ~( isempty(msg1) | isempty(msg2) ) ) );

    msg = cat( 2 , msg1 , nl , msg2 );

    str = cat( 2 , str1 , sep , str2 );

    return

%******************************************************
end
%******************************************************

%--------------------------------------------------------
% Get Format

   form = { '%.0f'  ' '
            '%2.0f' ':'
            '%2.2d' ':'
            '%2.2d' ''    };

i0 = 1 + ( mode > 1 ) + ( mode > 3 );
i1 = 3 + ( mode > 2 );

ind = ( i0 : i1 );

form = permute( form(ind,:) , [ 2  1 ] );
form = form(:);
form = cat( 2 , form{ 1 : (end-1) } );

%--------------------------------------------------------

[msg,val,vec] = time_val(val,ind,[1 24 60 60],vnan,acc);

if ~isempty(msg)
   return
end

str = sprintf(form,vec);


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,vec] = time_val(val,ind,quot,vnan,acc)

msg = '';

n = max(ind);

[msg,vec] = get_vec(val,ind,n,'0123456789*+-./()[]',vnan,acc);

if ~isempty(msg)
    return
end

quot = quot(ind);
vec  =  vec(ind);

quot(1) = 1;

vec(2:end) = vec(2:end) * ( sign(vec(1)) + ( sign(vec(1)) == 0 ) );

[val,vec] = fixvec(vec,quot,0);

vec(2:end) = abs(vec(2:end));


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = date_str(val,mode,vnan,acc)

msg = '';
str = '';

%------------------------------------------------------------------

if nargin < 2
   mode = char(zeros(1,0));
elseif isempty(mode)
   mode = char(zeros(1,0));
end

form = '1E';

nm = size(mode,2);
nf = size(form,2);

mode = cat( 2 , mode( 1 : min(nm,nf) ) , form( nm+1 : nf ) );


is_time = isequal( mode(2) , upper(mode(2)) );

mode = lower(mode);

%------------------------------------------------------------------
% replace MonthString with MonthNumber

is_char = ischar(val);

if is_char

   val = mon_str(val,mode);

end

%------------------------------------------------------------------
% Get Vector

n = 3 + 2*is_time;

[msg,val] = get_vec(val,(1:n),n,'0123456789*+()[]',vnan,acc);

if ~isempty(msg)
    return
end

%------------------------------------------------------------------
% String ==> Switch DD MM YY

if is_char

   if strcmp( mode([1 2]) , '0e' )

      val([1 2 3]) = val([3 1 2]);

   elseif ~strcmp(mode(2),'d')

      val([1 2 3]) = val([3 2 1]);

   end

end

%------------------------------------------------------------------

val(1) = val(1) + 2000 * ( val(1) < 100 );  % !!! Y2K !!!

if ~any(isnan(val))

  if is_time

    val = datevec( datenum(val(1),val(2),val(3),val(4),val(5),1) );

  else

    val = datevec( datenum(val(1),val(2),val(3)) );

  end

end

val = val(1:n);

%------------------------------------------------------------------
% Build Date-String

if strcmp(mode(2),'d')

   ind  = [ 1  2  3 ];
   form = '%4.0f#%2.2d#%2.2d';

   sp = '/- ';

   ok    = ( mode(1) == '012' );
   ok(1) = ok(1) + ( sum(ok) == 0 );
   ok    = find(ok);

   form = strrep(form,'#',sp(ok));

    str = sprintf(form,val(ind));

else

  switch mode(1)

   case { '1'  '2' }

     if strcmp(mode(1),'1')
        if strcmp(mode(2),'g')
           form = '%2.2d.###.%.0f';
        else
           form = '%2.2d-###-%.0f';
        end
     else
           form = '%2.2d. ### %.0f';
     end

     str = strrep( sprintf(form,val([3 1])) , '###' , mon_str(val(2),mode) ) ;

   otherwise

     if strcmp( mode(2) , 'g' )

        ind  = [ 3  2  1 ];
        form = '%2.2d.%2.2d.%.0f';

     else

        ind  = [ 2  3  1 ];
        form = '%2.2d/%2.2d/%.0f';

     end

     str = sprintf(form,val(ind));
      
  end

end

%------------------------------------------------------------------
% Append Time

if is_time

  [t_val,t_vec] = fixvec(val([4 5]),[1 60],0);

  [t_val,t_str,ff,msg] = str2val(t_vec,'time2',vnan,acc);

  if strcmp( mode([1 2]) , '2d' )
     t_str = strrep(t_str,':',' ');
  end
 
  str = cat( 2 , str , ' ' , t_str );

  val([4 5]) = t_vec;

else

  val([4 5]) = 0;

end


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str] = form_str(val,form,vnan,acc)

msg = '';
str = '';

is_str = ~isempty(findstr(form,'%s'));

if ischar(val)
%*******************************************************
% STRING --> VALUE
%-------------------------------------------------------

   if is_str
      str = sprintf(form,val);
      return
   end

   cl = { 'double'  'char' };
   
   cl = cl{ 1 + is_str };

   [msg,val] = str2vec(val,['@' cl]);

   if ~isempty(msg)
       return
   end

end

cl = class(val);

if ~strcmp(cl,'double')
    val = double(val);
end

if ~isempty(vnan) & ~isempty(val)
    isn = zeros(size(val));
    for v = vnan
        isn = ( isn | ( abs(val - v) < acc ) );
    end
    if any(isn)
           isn  = find(isn);
       val(isn) = NaN;
    end
end

%--------------------------------------------
% Check out with different formats  EXP !!!

good = { '0123456789.ije+-*/^()[]:,;~=' 
         '0123456789.ije+-*/^()[]:,;' 
         '0123456789.ije+-*/^()[]:' 
         '0123456789.ije+-*/^' 
         '0123456789.ije-+' 
         '0123456789.-' 
         '0123456789.' 
         '0123456789'            };

nv = prod(size(val));

for gd = good'

    for ff = { form  strrep(form,'%',' %') }

        str = sprintf(ff{1},val);

        [msg,v,s] = str2vec(str,gd{1});

        if isempty(msg) & ~( nv == prod(size(v)) )
           msg = 'Invalid Size of expression.';
        end

        if isempty(msg)
           val = v;
        %%%str = s;
           break
        end

    end

    if isempty(msg)
       break
    end

end

if ~isempty(msg)
    val = [];
end

%--------------------------------------------

if ~strcmp(cl,'double')
    try
       val = feval(cl,val);
    end
end

%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,vec] = get_vec(val,ind,n,good,vnan,acc)

msg = '';

if ischar(val)
%*******************************************************
% STRING --> VALUE
%-------------------------------------------------------

   [msg,val] = str2vec(val,good);

   if ~isempty(msg)
      return
   end

   if isempty(val)

      val = zeros(1,1);

   end

end

%-------------------------------------------------

ni = size(ind,2);
nv = size(val,2);

val = val( 1 : min(nv,ni) );

if ~isempty(vnan) & ~isempty(val)
    isn = zeros(size(val));
    for v = vnan
        isn = ( isn | ( abs(val - v) < acc ) );
    end
    if any(isn)
           isn  = find(isn);
       val(isn) = NaN;
    end
end

val = cat( 2 , val , zeros(1,ni-size(val,2)) );

vec = zeros(1,n);

vec(ind) = val;


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [val,vec] = fixvec(val,quot,acc)


if nargin < 3
   acc = 0;
end

acc = 10^acc;

quot = quot(:)';

n = size(quot,2);

if size(val,2) == n

    m = size(val,1);

  val = sum( val ./ (ones(m,1)*cumprod(quot)) );

else

  val = val(:);

    m = size(val,1);

end

vec = zeros( m , n );

%---------------------------------------------------

for ii = 1 : n-1

    vec(:,ii) = fix( quot(ii) * val );

    val = quot(ii)*val - vec(:,ii);

end

vec(:,n) = acc * round( ( quot(n) * val ) / acc );

   
%---------------------------------------------------

for ii = n : -1 : 2

    p = fix( vec(:,ii) / quot(ii) );

 vec(:,ii-0) = vec(:,ii-0) - p * quot(ii);
 vec(:,ii-1) = vec(:,ii-1) + p;
  
end
 
val = sum( vec ./ cumprod(quot) );


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [ff,ind] = modeform(mode,form)

mode = strrep(mode,'%','%%');
mode = strrep(mode,'\','\\');

ff  = char( 32 * ones(1,0) );
ind = zeros(1,0);

nf = prod(size(form));
cc = cell(nf,1);

for ii = 1 : nf

    cc{ii} = sprintf('%.0f',ii);

end

for ii = 1 : size(mode,2)

    jj = find( strcmp( mode(ii) , cc ) );

    if isempty(jj)
 
       ff = cat(2,ff,mode(ii));

     else

       ff = cat(2,ff,form{jj});

       ind = cat(2,ind,jj);

     end

end


%******************************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function val = mon_str(val,form)


if nargin < 2
   form = char(zeros(1,0));
elseif isempty(form)
   form = char(zeros(1,0));
end

f0 = '1e';

n1 = size(form,2);
n0 = size(f0,2);

form = cat( 2 , form( 1 : min(n1,n0) ) , f0( n1+1 : n0 ) );

 
mon = cell(12,2,2);

mon(:,:,1) = { ...

           'Jan'   'January'
           'Feb'   'February'
           'Mar'   'March'
           'Apr'   'April'
           'May'   'May'
           'Jun'   'June'
           'Jul'   'July'
           'Aug'   'August'
           'Sep'   'September'
           'Oct'   'October'
           'Nov'   'November'
           'Dec'   'December'   };

mon(:,:,2) = { ...

           'Jan'   'Januar'
           'Feb'   'Februar'
           'Mar'   'März'
           'Apr'   'April'
           'Mai'   'Mai'
           'Jun'   'Juni'
           'Jul'   'Juli'
           'Aug'   'August'
           'Sep'   'September'
           'Okt'   'Oktober'
           'Nov'   'November'
           'Dez'   'Dezember'    };



long = strcmp(       form(1)  , '2' );
germ = strcmp( lower(form(2)) , 'g' );



i3 = [ 1  2 ] + [ 1  -1 ] * germ;   % Language
i2 = [ 1  2 ] + [ 1  -1 ] * long;   % Long Format
 
s1 = size(mon,1);

if isnumeric(val)

   if isnan(val)

      val = 'NaN';

   else

     val = val - s1 * floor( val / s1 );

     val = val + s1 * ( val == 0 );

     val = mon{val,i2(1),i3(1)};

   end

elseif ischar(val)

   ok = 0;

   for ii3 = i3

       for ii2 = i2

           for ii1 = ( 1 : s1 )

               jj = findstr( lower(val) , lower(mon{ii1,ii2,ii3}) );

               ok = ~isempty(jj);

               if ok

                 jj = jj(1);

                 s2 = size( mon{ii1,ii2,ii3} , 2 );

                 val = cat( 2 , val(1:jj-1) , sprintf(' %.0f ',ii1) , val(jj+s2:end) );
 
                 break

               end

           end
           % ii1

           if ok
              break
           end

       end
       % ii2
 
       if ok
          break
       end

   end
   % ii3

end

%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,v1,v2] = split(val)


msg = '';
v1  = [];
v2  = [];

%*******************************************************
if ischar(val)
%*******************************************************
% Split String
%-------------------------------------------------------

   val = rmblank(val,2);

   nv  = size(val,2);

   [msg,v,str] = str2vec(val);

   if ~isempty(msg)
       return
   end

   if isempty(v)

      n2 = floor( (nv+1) / 2 );

      v1 = rmblank( val(    1 : n2 ) );
      v2 = rmblank( val( n2+1 : nv ) );

   else

      sep = char(32);

      str = cat( 2 , sep , str , sep );
      val = cat( 2 , sep , val , sep );

      nv = nv + 2;

      %-------------------------------------------------
      % Split Value

      n = prod(size(v));

      n2 = floor( (n+1) / 2 );

      v1 = v(    1 : n2 );
      v2 = v( n2+1 : n  );

      v1(find(isnan(v1))) = 0;
      v2(find(isnan(v2))) = 0;

      %-------------------------------------------------
      % Groups of SeperatorCharacters

      [i0,l] = ind2grp( find( str == sep ) );

       i0 = i0 + l;  % End of Space == Begin of Number

      %-------------------------------------------------
      % Compare Groups with Splitted Values

       ok = 0;

       for ii = 2 : prod(size(i0))

           i1 = ( 1      : i0(ii)-1 ); 
           i2 = ( i0(ii) : nv       );

           [m1,w1] = str2vec(str(i1));
           [m2,w2] = str2vec(str(i2));

           w1(find(isnan(w1))) = 0;
           w2(find(isnan(w2))) = 0;

           ok = ( isempty(m1) & isequal(v1,w1) & ...
                  isempty(m2) & isequal(v2,w2)       );

           if ok
              break
           end

       end

       if ok
          v1 = rmblank(val(i1));
          v2 = rmblank(val(i2));
       else
          v1 = v(    1 : n2 );
          v2 = v( n2+1 : n  );
       end

   end

%*******************************************************
else
%*******************************************************
% Split Value
%-------------------------------------------------------

   nv = prod(size(val));

   n2 = floor( (nv+1) / 2 );

   v1 = val(    1 : n2 );
   v2 = val( n2+1 : nv );

end
%*******************************************************

if isempty(v1)
   v1 = NaN;
end

if isempty(v2)
   v2 = NaN;
end


%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val,str,gd] = str2vec(str,varargin)   

% STR2VEC  Converts String into Numeric
%
%  [Msg,V] = STR2VEC( String )
%
%  [Msg,V] = STR2VEC( String , [@Class] , AllowedCharacters , NotAllowedCharacters )
%
%  Empty Value for AllowedCharacters: Allowed Characters will get automaticly
%                                         
%  Empty Value for NotAllowedCharacters: no Character is notallowed
%
%  If the Input '@ClassName' is given, the Values will check with this.
%
%--------------------------------------------------------------
%
%  [Msg,V] = STR2VEC( ['@' FileName '@'] , ... )
%  
%   Reads the String from a File, specified by FileName.
%
%--------------------------------------------------------------
% 
%  [Msg,V,String,AllowedCharacters] = STR2VEC( String , ... );
%


msg = '';
val = [];


Nin = nargin;

%*******************************************************

if Nin == 0
   msg = 'Input String is missing.';
   return
end

%------------------------------------------------------
% Check String

if isempty(str)
   str = '';
end

if ~chkstr(str,0)
   msg = 'Input must be a String.';
   return
end

if isempty(str)
   return
end

%-------------------------------------------------------
% Check GOOD, BAD, Class

cc    = cell(3,1);
cc(:) = { char(zeros(1,0)) };

nv = prod(size(varargin));
ok = zeros(nv,1);

cok = zeros(size(cc,1),1);

for ii = 1 : nv

    v = varargin{ii};

    ok(ii) = chkstr(v,0);

    if ok(ii)
       if isempty(v)
           for jj = [ 1  2 ]
               if ~cok(jj)
                   cok(jj) = 1;
                    cc{jj} = v;
               end
               if cok(jj)
                  break
               end
           end
       else
           for jj = [ 3  1  2 ]
               if ~cok(jj)
                   if strcmp(v(1),'@') | ~( jj == 3 )
                      cok(jj) = 1;
                       cc{jj} = v( (1+(jj==3)) : end );
                   end
                  if cok(jj)
                     break
                  end
              end
           end
       end
   end

end

if ~all(ok)
   msg = 'Following Inputs must be Strings';
   return
end

gd = cc{1};
bd = cc{2};
cl = cc{3};


%*******************************************************
% Check for FileName

n2 = size(str,2);

if ( n2 > 2 ) & strcmp(str([1 n2]),'@@') & ...
    ~any( ( str == 10 ) | ( str == 13 ) |  ...
          ( str ==  9 ) | ( str == 32 )         )

    try
        [msg,str] = loadfile(str(2:n2-1),5*2^20,'char');
    catch
         msg = sprintf('Error using LOADFILE.\n%s\n',lasterr);
    end

    if ~isempty(msg)
        if isempty(str)
           return
        end
        warning(msg);
    end

end

%*******************************************************

if isempty(str)
   return
end

n2 = size(str,2);

%*******************************************************
% Remove NotAllowedCharacters

if ~isempty(cc{2})
    ok = zeros(1,n2);
    for c = cc{2}
        ok = ( ok  |  ( str == c ) );
    end
    if any(ok)
           ok  = find(ok);
       str(ok) = char(32);
    else
           ok  = [];
    end
end

%*******************************************************
% Return if Class CHAR, 
%  remove following NotAllowedCharacters

if strcmp(cl,'char')
   if ~isempty(cc{2})
       if prod(size(ok)) > 1
              ok  = ok(find(diff(ok)==1)+1);
          str(ok) = [];
       end
   end
   val = str;
   return
end

%*******************************************************
% Save NewLineCharacters

is_nl = find( double(str) == 10 );  % NewLineCharacters

   nl = [ 10  32 ];                 % Order to Set NewLineCharacters

%*******************************************************
% Extract AllowedCharacters

is_nan = cat( 2 , findstr(str,'NaN') , findstr(str,'nan') );

low = lower(str);

if ~isempty(cc{1})

   %----------------------------------------------
   % Remove following IMAG and EXP

   if any( ( cc{1} == 'i' ) | ( cc{1} == 'j' ) | ( cc{1} == 'e' ) )
      ii = ( ( low == 'i' ) | ( low == 'j' ) | ( low == 'e' ) );
      if any(ii)
         ii = find(ii);
         jj = find( diff(ii) == 1 );
         str(ii([jj jj+1])) = char(32);
      end
   end

   %----------------------------------------------
   % Check for NaN, Remove following

   is_nan = cat( 2 , findstr(str,'NaN') , findstr(str,'nan') );

   is_nan = sort(is_nan,2);

   if ~isempty(is_nan)
      jj = find( diff(is_nan,1,2) == 3 );
      is_nan([jj jj+1]) = [];
   end

   %----------------------------------------------
   % Ok for allowed Characters

   ok = ( str == char(32) );

   for c = cc{1}
       ok = ( ok  |  ( str == c ) );
   end

   if ~all(ok)
       str(find(~ok)) = char(32);
   end

   %----------------------------------------------
   % Reset NaN

   if ~isempty(is_nan)

      n = size(is_nan,2);

      nn = 'NaN';
      nn = nn(ones(n,1),:);
      nn = permute(nn,[2 1]);
      nn = permute(nn(:),[2 1]);

      in = grp2ind(is_nan,3*ones(1,n));

      str(in) = nn;
       
       ok(in) = 1;

   end

   %----------------------------------------------
   % Special Handling for IMAG: Left AND Right must be Ok

   ii = ( ( low == 'i' ) | ( low == 'j' ) );
   ii = ( ii & ok );

   if any(ii)
      ii = find(ii);
      jj = find( ~( ok(ii-(ii>1)) & ok(ii+(ii<n2)) ) );
      str(ii(jj)) = char(32);
   end

   %----------------------------------------------
   % Special Handling for EXP: Left AND Right must be Ok
   % #. before EXP, +-# behind EXP, # = 0 .. 9 

   ii = ( ( low == 'e' ) & ok );

   if any(ii)

      ii = find(ii);

      jj = ii - ( ii > 1 ); % previous
      kk = ( ( '0' <= str(jj) ) & ( str(jj) <= '9' ) );
      kk = ~( ok(jj) & ( kk  | ( str(jj) == '.' ) ) );
      if any(kk)
         kk = find(kk);
         str(ii(kk)) = char(32);
      end

      jj = ii + ( ii < n2 ); % next
      kk = ( ( '0' <= str(jj) ) & ( str(jj) <= '9' ) );
      kk = ~( ok(jj) & ( kk  | ( str(jj) == '+' ) | ( str(jj) == '-' ) ) );
      if any(kk)
         kk = find(kk);
         str(ii(kk)) = char(32);
      end

   end

   %----------------------------------------------

   nl = nl( 1 : 1+(~any(double(cc{2})==10)) );

end

%*******************************************************
% Try EVAL(str)

for c = nl

    str(is_nl) = char(c);

    [msg,val] = evalstr(str);

    if isempty(msg)
       ok = chksize(val,str);
       if ~ok
           msg = 'Invalid Size of expression.';
       end
    end

    if isempty(msg) & ~isempty(cl)
       ok = strcmp( class(val) , cl );
       if ~ok
           [ok,val] = classchk(val,cl);
       end
       if ~ok
           msg = sprintf('Class "%s" is requested.',cl);
       end
    end
 
    if isempty(msg)
       return
    end

end

if ~isempty(cc{1})
    return
end

%*******************************************************
% Set GOOD Automaticly

good = { '0123456789.ije+-*/^()[]:,;~=' 
         '0123456789.ije+-*/^()[]:,;' 
         '0123456789.ije+-*/^()[]:' 
         '0123456789.ije+-*/^' 
         '0123456789.ije-+' 
         '0123456789.-' 
         '0123456789.' 
         '0123456789'            };
              
str(is_nl) = char(10);

for ii = 1 : size(good,1)

    [msg,val,str,gd] = str2vec(str,['@' cl],good{ii});

    if isempty(msg)
       return
    end

end


%***********************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [msg,val] = evalstr(str)

msg = '';
val = [];

ww = warnstat;
     warning('off')

lastwarn('')

try
   val = eval(cat(2,'[',str,']'));
   msg = lastwarn;
catch
   msg = lasterr;
end

warning(ww)


%*********************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ww = warnstat

% WARNSTAT  Returns global WarningStatus
%
%  WARNSTAT returns the Status of WARNING
%
% Matlab R<13   WARNING
% Matlab R>12   WARNING for Identifier ALL
%

ww = warning;

if isstruct(ww)   % New Matlab R>12 Syntax
   try
      id = strcmp({ww.identifier},'all');
      if any(id)
         id = find(id);
         ww = ww(id(1)).state;
      else
         ww = '';
      end
   catch
      ww = '';
   end
elseif ~chkstr(ww)
   ww = '';
end


%***********************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function  ok = chksize(val,str);

ok = ( isempty(val) & isempty(str) );
if ok
   return
end

val = prod(size(val));

bl = ( ( str == char(32) ) | ( str == char(10) ) );

if ~any(bl) | all(bl)
    ok = ( ( ( val == 1 ) & ~any(bl) ) | ...
           ( ( val == 0 ) &  all(bl) )       );
    return
end

n2 = size(str,2);

%----------------------------------------------------
% Group of Blanks

[i0,lg] = ind2grp(find(bl));

n = size(i0,1);

i1 = i0(n) + lg(n) - 1;

i01 = ( [ i0(1)  i0(n)+lg(n)-1 ] == [ 1  n2 ] );

n = n - sum(i01);

ok = ( val == n+1 );

if ok
   return
end

%----------------------------------------------------
% Check for Sign +/- if Dot or Number follows
%  and no blank before

ii = ( ( str == '+' ) | ( str == '-' ) );

if any(ii)

   ii = find(ii);

   % Number follows
   jj = ii + ( ii < n2 ); % next
   kk = ( ( '0' <= str(jj) ) & ( str(jj) <= '9' ) );
   kk = ( kk  | ( str(jj) == '.' ) );
 
   % Blank before
   jj = ii - ( ii > 1 ); % previous
   kk = ( kk & bl(jj) );

   if any(kk)         % SignCharacter +/-
      kk = find(kk);
      str(ii(kk)) = char(32);
   end

end

%----------------------------------------------------
% Check for OperatorCharacters between Numbers

op = zeros(size(bl));

for c = '+-*/^'
    op = ( op | ( str == c ) );
end

if ~any(op)
    return
end

bl = bl + 2*op;  % Two if Operator

[i0,lg] = ind2grp(find(bl));

n = size(i0,1);

% Check Sum of Groups with Length 

sg = cumsum(bl,2);
ii = ( 1 : n-1 );
sg = sg(i0+lg-1) - cat( 2 , 0 , sg(i0(ii)+lg(ii)-1) );

op = ~( sg == lg(:)' );  % True if Operator in Group

i01 = ( [ i0(1)  i0(n)+lg(n)-1 ] == [ 1  n2 ] );

op([1 n]) = ( op([1 n]) & ~i01 );
 
n = n - sum(i01) - sum(op);

ok = ( val == n+1 );


%***********************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [ii,nn] = grp2ind(i0,l,s);

% GRP2IND  Built IndexVector from StartIndex and Length
%
% [Index,GroupNumber] = GRP2IND( StartIndex , GroupLength )
%
% where LENGTH(GroupNumber) == MAX(Index)
%
% GRP2IND( ... , LowSampleStep  ) LowSamples in Groups
%
% See also: IND2GRP, GRPMEAN, CUMSUM, CUMPROD
%

ii = [];
nn = [];

if isempty(i0);
   return
end

if nargin < 3
   s = 1;
end

si = size(i0);

if ( sum( si > 1 ) > 1 )
   error('StartIndex must be a Vector.');
end

i0 = i0(:);
l  =  l(:);

if ~isequal(size(i0,1),size(l,1))
   error('Size of StartIndex and GroupLenght must be the same.');
end

jj = ( l == 0 );
if all(jj)
   return
end

if any(jj)
      jj  = find(jj);
   i0(jj) = [];
    l(jj) = [];
end

n = size(l,1);

l = ceil( l / s );

ii = s * ones(sum(l),1);
jj = cumsum( cat(1,1,l) , 1 );

ii(jj(1:n)) = i0;

if n > 1
   ii(jj(2:n)) = ii(jj(2:n))-(i0(1:n-1,1)+s*(l(1:n-1)-1));
end

ii = cumsum(ii,1);

if ( nargout == 2 ) & ~isempty(ii)
   nn = zeros(max(ii),1);
   kk = zeros(size(ii));
   kk(jj(1:n)) = 1;
   kk = cumsum(kk);
   nn(ii) = kk;
end

if n == 1
   return
end

jj = find( si > 1 );

if jj == 1
   return
end
  
perm = cat( 2 , (1:jj-1)+1 , 1 , (jj+1:size(si,2)) );

ii = permute(ii,perm);

if ( nargout == 2 )
   nn = permute(nn,perm);
end

%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [i0,l] = ind2grp(ii);

% IND2GRP  Built StartIndex and Length from IndexVector
%
% [ StartIndex , GroupLength ] = IND2GRP( Index )
%

i0 = zeros(0,1);
l  = zeros(0,1);

if isempty(ii);
   return
end

ii = ii(:);
n  = size(ii,1);

i0 = cat( 1 , 1 , find( diff(ii,1,1) > 1 )+1 , n+1 );

l  = diff(i0,1,1);

i0 = ii(i0(1:end-1));


%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [val,msg] = defval(typ,si,val);

% DEFVAL   Returns DefaultValue for Type and Size
%
% [val,msg] = DEFVAL(typ,si,val);
%
% The 3. Input "val" is used, if the "typ" 'struct' is requested,
%   to create a Structure with new Size from existing Structure "val".
%
% typ: 'numeric'
%      'cellstr'
%      'string'
%      'object'
%      <class>
%      ''
%

Nin = nargin;

if Nin < 1
   typ = '';
end

if Nin < 2
   si = [ 0  0 ];
end

if Nin < 3
   val = [];
end


msg = '';


si(find(isnan(si))) = 0;
 

switch typ

  case { 'char'  'string' }
 
          val = char( 32 * ones(si) );

  case { 'double'  'single'  'numeric'  '' }

          val = NaN * ones(si);

  case {  'int8'     'int16'    'int32' ...
         'uint8'    'uint16'   'uint32' ...
         'logical'  'sparse'        }

          val = feval( typ ,  zeros(si) );

  case 'cell'

          val = cell(si);

  case 'cellstr'

          val = cell(si);

          if ~any( si == 0 )
              val(:) = { '' };
          end

  case 'struct'

       if ~strcmp(class(val),'struct');

           val = struct( 'NaN' , { [] } );

       end

       ns = prod(size(si));

      ind = cell(ns,1);

      for ii = 1 : ns
          ind{ii} = ones(1,si(ii));
      end
 
      val = val(ind{:});

  otherwise

     try

        val = feval(typ,si);

     catch

        msg = lasterr;

     end

end

%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [ok,v] = classchk(v,cl);

% CLASSCHK  Check if Input is of given Class
%
% [ Ok , V ] = CLASSCHK( V , Class )
%
% Returns ONE, if V is of given Class or Class is empty.
%
% Special Class's are:
%
% 'numeric'   True if ISNUMERIC
% 'string'    True for ONE-Row CharacterArray or ONE-Element CellArray of it
% 'cellstr'   True of CellArray or CharacterArray of Strings
% 'object'    True if ISOBJECT
%
% Special Handlings for Matlab-defined Class's:
%
% 'double'    True for ISNUMERIC
% 'single'    True for ISNUMERIC
% 'sparse'    True for ISNUMERIC
% 'logical'   True for ISNUMERIC  with Values [ 0 | 1 ]
% 'int<B>'    True for ISNUMERIC  with Values [ -2^(B-1) .. 2^(B-1)-1 ]
% 'uint<B>'   True for ISNUMERIC  with Values [  0       .. 2^(B)-1   ]
% 'char'      True for ISCELLSTR
% 'cell'      True for CharacterArray
% 'struct'    True for Object
% ClassName   True if  Object is of given Class
% @ClassName  True if  Object inherits of given Class, using ISA
%



Nin  = nargin;
Nout = nargout;

if Nin < 1
   ok = 0;
   v  = ones(0,0);
   return
end

ok = 1;

if Nin < 2
   cl = '';
elseif  ~chkstr(cl,0)
   error('Class must be a String.')
end

%****************************************************

if isempty(cl)
   return
end

cv = class(v);

ok = isequal(cl,cv);

if ok
   return
end

%****************************************************

out = ( Nout > 1 );

switch cl

%----------------------------------------------------
case 'numeric'

      ok = isnumeric(v);

      cl = '';

%----------------------------------------------------
case 'string'

      ok = chkstr(v,0);

      if ~ok & strcmp(cv,'cell') & ( prod(size(v)) == 1 )
          ok = chkstr(v{1},0);
          if ok
             v = v{1};
          end
      end

      cl = '';

%----------------------------------------------------
case 'cellstr'

      [ok,v] = chkcstr(v,0);

      cl = '';

%----------------------------------------------------
case 'object'

      ok = isobject(v);

      cl = '';

%----------------------------------------------------
case { 'int8' 'int16' 'int32' 'uint8' 'uint16' 'uint32' }

      ok = isnumeric(v);

      if ok & ( ~strcmp(cv,'logical') | out )

         if strcmp(cv,'double')
            w = round(v);
         else
            w = double(v);
         end

         if ~strcmp(cv,'logical')

            s  = ~( cl(1) == 'u' );               % TRUE for Signed Integer

            b = eval( cl( (5-s) : end ) ) - s;    % Bytes

            l = 2^b * [ (0-s)  1 ] + [ 0  -1 ];   % Intervall

            ok = all( ( l(1) <= w(:) ) & ( w(:) <= l(2) ) );

         end

         if ok & out
            v = w;
         end

      end

%----------------------------------------------------
case { 'double'  'single'  'logical'  'sparse' }

      ok = ( isnumeric(v) | strcmp(cv,'logical') );

      if ok & ( strcmp(cl,'logical') | out )

         if strcmp(cv,'double')
            w = v;
         else
            w = double(v);
         end

         if strcmp(cl,'logical')
            ok = ( all( w(:) == 0 ) | all( w(:) == 1 ) );
         end

         if ok & out
            v = w;
         end

      end

%----------------------------------------------------
case 'char'

      ok = iscellstr(v);

%----------------------------------------------------
case 'cell'

      ok = strcmp(cv,'char');

      cl = 'cellstr';

%----------------------------------------------------
case 'struct'

      ok = isobject(v);
  
%----------------------------------------------------
otherwise

      ok = strcmp(cl(1),'@');

      if ok
         cl  = cl(2:end);
         ok  = isa(v,cl);
      end

end

%----------------------------------------------------

if ~( ok & out ) | isempty(cl)
   return
end

%----------------------------------------------------
% Convert Value

try
  v = feval(cl,v);
end


%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function  str = strhcat(str,del,n,nl)

% STRHCAT  Concatenates Strings into ONE
%
% STRHCAT( StringArray , Delimiter )
%   Forms one long String from the Strings in the
%   StringArray, delimited with the delimiter.
%   The EndDelimiter will be removed.
%
% STRHCAT( StringArray , Delimiter , N , NewLine )
%   Build a  NewLine after each N-th String.
%   default: N = 10;  NewLine = char(10);
%
% Example:  
%         >> strhcat({'apples' 'pies' 'prunes'},', ')
%    
%         ans =
%
%         apples, pies, prunes
%
%         >> strhcat({'apples';'pies';'prunes'},', ',2)
%    
%         ans =
%
%         apples, pies
%         prunes
%



Nin = nargin;

if Nin < 4
 nl = char(10);
end
if Nin < 3
 n = [];
end
if Nin < 2
 del = char((32*ones(1,3)));
end


if isempty(str)
 str = '';
 return
end


if ischar(str)
  str = cellstr(str);
end

str = str(:);

if isempty(n)
   n = size(str,1) + 1;
end

str( : , 2 ) = { del };

str(n:n:size(str,1),2) = { nl };

str(    size(str,1),2) = { '' };


str = permute( str , [ 2  1 ] );

str = cat(2,str{:});


%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function str = rmblank(str,dim,cc)

% RMBLANK  Remove Blanks, NewLines at Begin and End of CharacterArrays
%
% String = RMBLANK( CharArray )
%
% CharArray  2-dimensional CharacterArray
%
% further Options:
%
% String = RMBLANK( CharArray , DIM , CHAR )
%
%  
%  DIM  specifies Dimension to work, 
%       default: 2
%
%    A positive complex Part of DIM, to removes Blanks only from Start,
%    A negative complex Part of DIM, to removes Blanks only from End.
%       
%  CHAR specifies BlankCharacters to remove
%       default:  [ 160  32  13  10  9  0 ];  % [ NBSP Space CR LF TAB ZERO ]
%

  
msg = '';
 nl = char(10);

Nin = nargin;

if Nin < 1
  error('Not enough Input Arguments.')
else
  if ischar(str)
    str = double(str);
  end
  ok = isnumeric(str);
  if ok
    ok = all( ( mod(str(:),1) == 0 )  & ...
              ( str(:) >= 0 ) & isfinite(str(:))  );
  end
  if ~ok
      msg = [ msg nl(1:(end*(~isempty(msg)))) ...
              'Input CharArray must be a String or ASCII-Codes.'];
  end
  if size(str,1)*size(str,2) ~= prod(size(str))
      msg = [ msg nl(1:(end*(~isempty(msg)))) ...
              'Input CharArray must be 2-dimensional.'];
  end     
end

if Nin < 2
  dim = 2;
else
  if ~isnumeric(dim)
    msg = [ msg nl(1:(end*(~isempty(msg)))) ...
            'Input DIM must be numeric.' ];
  elseif ~isempty(dim)
    dim = dim(:);
    if ~all( ( real(dim) == 1 ) |  ( real(dim) == 2 ) )
      msg = [ msg nl(1:(end*(~isempty(msg)))) ...
             'Values for Input DIM must define 1. or 2. Dimension.' ];
    end
  end 
end

if Nin < 3
  cc = [ 160  32  13  10  9  0 ];  % [ NBSP  Space CR LF TAB ZERO ]
else
  if ischar(cc)
    cc = double(cc);
  end
  ok = isnumeric(cc);
  if ok & ~isempty(cc)
    cc = cc(:)';
    ok = all( ( mod(cc,1) == 0 )  & ...
              ( cc >= 0 ) & isfinite(cc)  );
  end
  if ~ok
      msg = [ msg nl(1:(end*(~isempty(msg)))) ...
              'Input CHAR must be a String or ASCII-Codes.'];
  end
end

if ~isempty(msg)
  error(msg)
end


if isempty(str)
 str = '';
 return
end

if isempty(dim) | isempty(cc)
  str = double(str);
  return
end


  blank  = 0*str;

  for ii = cc
    blank = ( blank | ( str == ii ) );
  end

  si = size(str);

  for ii = 1 : size(dim,1)

    d = dim(ii);

    s = sign(imag(d));  % Remove from wich Side:  1  0  -1 
 
    d = real(d);

    jj = find( sum(blank,3-d) == si(3-d) );  % Columns with full Blanks

    if ~isempty(jj) 

         p  = [ 3-d  d ];
        str = permute(str,p);

         jj = jj(:)';
         nb = size(jj,2);

        %--------------------------------------------
        % Blank at Begin

        ind = ( 1 : nb );
        jj1 = find( ( ( jj == ind ) & ( s >= 0 ) ) );

        %--------------------------------------------
        % Blank at End

        ind = ind + si(d) - nb;
        jj2 = find( ( ( jj == ind ) & ( s <= 0 ) ) );

        %--------------------------------------------

        str(:,jj([jj1 jj2])) = [];

        str = permute(str,p);

    end
    
  end

  str = char(str);

%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ok = chkstr(str,opt)

% CHKSTR  Checks Input for String
%
%  ok = chkstr(str,Option)
%
%  Option ~= 0 ==> only true for nonempty Strings
%
%   default:   Option == 0  (true for empty Strings)
%

 
if nargin < 2
   opt = 0;
end

ok = ( strcmp( class(str) , 'char' )      & ...
       ( prod(size(str)) == size(str,2) ) & ...
       ( isequal(opt,0) | ~isempty(str) )         );


%****************************************************
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function [ok,str] = chkcstr(str,opt)

% CHKCSTR  Checks Input for CellString, contains Strings !
%
%  [ok,str] = chkcstr(str,Option)
%
%  Option ~= 0 ==> CharacterArrays not allowed,
%
%   default: Option == 0   ==>  CharacterArrays --> CellString
%
 
if nargin < 2
   opt = 0;
end

if strcmp(class(str),'char') & isequal(opt,0)
   str = cellstr(str);
end

ok = iscellstr(str);
if ~ok
   return
end

try
  s = cat(2,str{:});
catch
  ok = 0;
  return
end
 
ok = ( strcmp(class(s),'char')  &  ( prod(size(s)) == size(s,2) ) );

