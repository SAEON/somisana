function test_nc_vargetr(mode)

if nargin < 1
    mode = 'netcdf-3';
end

fprintf('\t\tTesting NC_VARGETR ...  ' );

testroot = fileparts(mfilename('fullpath'));
switch(mode)
    case 'hdf4';
        ncfile = fullfile(testroot,'testdata/fillvalue_scaling.hdf');
        run_local_tests(ncfile);

    case 'netcdf-3'
        ncfile = fullfile(testroot,'testdata/fillvalue_scaling.classic.nc');
        run_local_tests(ncfile);

    case 'netcdf4-classic'
        ncfile = fullfile(testroot,'testdata/fillvalue_scaling.classic.nc4');
        run_local_tests(ncfile);

end

fprintf('OK\n');


%--------------------------------------------------------------------------
function run_local_tests(ncfile)

test_double(ncfile);
test_single(ncfile);
test_int(ncfile);
test_short(ncfile);
test_byte(ncfile);

%--------------------------------------------------------------------------
function test_double(ncfile)

varname = 'test_double';
data = nc_vargetr(ncfile,varname);

info = nc_getvarinfo(ncfile,varname);
sz = info.Size;

exp_data = 1:24;

pvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
if pvd
    exp_data = reshape(exp_data,sz);
else
    exp_data = reshape(exp_data,fliplr(sz));
    exp_data = exp_data';
end
exp_data(1) = -1;  % This would be NaN via NC_VARGET

if ~isequal(data,exp_data)
    error('failed');
end



%--------------------------------------------------------------------------
function test_single(ncfile)

varname = 'test_float';
data = nc_vargetr(ncfile,varname);

info = nc_getvarinfo(ncfile,varname);
sz = info.Size;

exp_data = single(1:24);

pvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
if pvd
    exp_data = reshape(exp_data,sz);
else
    exp_data = reshape(exp_data,fliplr(sz));
    exp_data = exp_data';
end
exp_data(1) = -1;  % This would be NaN via NC_VARGET

if ~isequal(data,exp_data)
    error('failed');
end



%--------------------------------------------------------------------------
function test_int(ncfile)

varname = 'test_int';
data = nc_vargetr(ncfile,varname);

info = nc_getvarinfo(ncfile,varname);
sz = info.Size;

exp_data = int32(1:24);

pvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
if pvd
    exp_data = reshape(exp_data,sz);
else
    exp_data = reshape(exp_data,fliplr(sz));
    exp_data = exp_data';
end
exp_data(1) = -1;  % This would be NaN via NC_VARGET

if ~isequal(data,exp_data)
    error('failed');
end




%--------------------------------------------------------------------------
function test_short(ncfile)

varname = 'test_short';
data = nc_vargetr(ncfile,varname);

info = nc_getvarinfo(ncfile,varname);
sz = info.Size;

exp_data = int16(1:24);

pvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
if pvd
    exp_data = reshape(exp_data,sz);
else
    exp_data = reshape(exp_data,fliplr(sz));
    exp_data = exp_data';
end
exp_data(1) = -1;  % This would be NaN via NC_VARGET

if ~isequal(data,exp_data)
    error('failed');
end







%--------------------------------------------------------------------------
function test_byte(ncfile)

varname = 'test_byte';
data = nc_vargetr(ncfile,varname);

info = nc_getvarinfo(ncfile,varname);
sz = info.Size;

exp_data = int8(1:24);

pvd = getpref('SNCTOOLS','PRESERVE_FVD',false);
if pvd
    exp_data = reshape(exp_data,sz);
else
    exp_data = reshape(exp_data,fliplr(sz));
    exp_data = exp_data';
end
exp_data(1) = -1;  % This would be NaN via NC_VARGET

if ~isequal(data,exp_data)
    error('failed');
end







