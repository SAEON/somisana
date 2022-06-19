function y = fli_end(fid,fli_file)

%function y = fli_end(fid,fli_file)

fclose(fid);
ppm2fli('.ppm.list',fli_file)
