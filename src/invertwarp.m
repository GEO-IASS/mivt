function iwarp = invertwarp(warp, dirn)
% invertwarp
%
% if warp is 'forward' A->B: output: a 'forward' warp from B->A
%   one solution (might be others, faster)
%   - get ndgrid
%   - move ndgrid forward according to warp (this is slow)
%   - inversewarp: compute difference of "target" nd grid (same nd grid, really) and moved one
%   Solution two: can probably get exact same result if we do backward and compute the "difference"
%   in the opposite direction?! No, this doesn't seem to work :(
%
% if warp is 'backward' --- same method as above, really!

    % get an nd grid based on the size of the warp
    grd = size2ndgrid(size(warp{1}));

    % warp the grid, this takes it to "target" space
    grdw = cellfunc(@(x) volwarp(x, warp, dirn), grd);

    % now compute the difference.
    iwarp = cellfunc(@(ws, t) ws - t, grdw, grd);
end
