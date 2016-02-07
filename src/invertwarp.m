function iwarp = invertwarp(warp, volwarpfn)
% invertwarp
%
% new comment: given a warp A -> B, we want to make it B -> A
%
%   one solution (might be others, faster)
%   - get ndgrid
%   - move ndgrid forward according to warp (this is slow)
%   - inversewarp: compute difference of "target" nd grid (same nd grid, really) and moved one

    narginchk(1, 2);
    if nargin == 1
        volwarpfn = @volwarp; % culd try volwarpForwardApprox
    end

    % get an nd grid based on the size of the warp
    grd = size2ndgrid(size(warp{1}));

    % warp the grid, this takes it to "target" space
    grdw = cellfunc(@(x) volwarpfn(x, warp, 'forward'), grd);

    % now compute the difference.
    iwarp = cellfunc(@(ws, t) ws - t, grdw, grd);
end
