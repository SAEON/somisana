%
% ROMS Land/Sea Mask Utility
% ==========================
%
% This utility is a graphical User interface enabling the User to easily
% create and modify a land mask for ROMS. To accelerate the proccessing,
% the Land/Sea mask is edited in (I,J) grid coordinates. This requires a
% convertion of coastline data (used in SeaGRid) to (I,J) indices.  This
% utility calls the MEXCDF interface for reading and writing to NetCDF
% files.
%
%
% Drivers:
%
%   editmask     - Interactive ROMS Land/Sea mask editing driver.
%   landsea      - Authomatic ROMS Land/Sea processing.
%
% Input/Output:
%
%   read_mask    - Reads in Land/Sea mask data from GRID NetCDF file.
%   write_mask   - Writes out Land/Sea mask data into GRID NetCDF file.
%
% Land/Sea mask:
%
%   uvp_masks    - Computes the Land/Sea mask data on U-, V-, and PSI-points.
%
% Menu Interface:
%
%   axisscroll   - Draws horizontal or vertical scroll bars.
%   button       - Creates a menu button.
%   pointer      - Sets custon pointer.
%   radiobox     - Creates a group of radio bottons.
%   textbox      - Creates a textbox in a frame.
%
% Orthogonal Grid Coordinate Manipulation:
%
%   ijcoast      - Converts coastline (lon,lat) coordinates to (I,J) indices.
%
% Miscellaneous:
%
%   pltmask      - Plots Land/Sea mask.
%
