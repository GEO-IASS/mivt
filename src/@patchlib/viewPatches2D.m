function varargout = viewPatches2D(patches, patchSize, caxisrange)
% VIEWPATCHES show 2D patches in a subplot grid
%   viewPatches(patches, patchSize) show 2D patches in a subplot grid. patchSize is a [1 x 2] vector
%   indicating the size of the patches. Given nPixels = prod(patchSize); patches is a 
%   [nPatches x nPixels]. 
%
%   viewPatches(patches) or viewPatches(patches, []): viewPatches will attempt to guess the patch
%   size based on factorization. see guessPatchSize
%
%   viewPatches(patches, patchSize, caxisrange) allows the specification of color axis (e.g. [0, 1])
%   for the patches.
%
%   h = viewPatches(...) returns the hangle of the figure
%
%   [h, nElems] = viewPatches(...) also returns the number of rows/columns of subplots.
%
% See Also: guessPatchSize
%
% Contact: adalca@csail.mit.edu

    narginchk(1, 3);
    
    % guess ptchSize if it's not provided
    if nargin == 1 || isempty(patchSize)
        patchSize = patchlib.guessPatchSize(size(patches, 2), 2);
    end

    % default caxisrange is [0, 1];
    if nargin == 2
        caxisrange = [0, 1];
    end

    % get the grid size
    nPatches = size(patches, 1);
    nElems = ceil(sqrt(nPatches));
    
    % show patches in subplots.
    h = patchlib.figview();
    for i = 1:nPatches
        subplot(nElems, nElems, i);
        patch = reshape(patches(i, :), patchSize);
        imshow(patch);
        caxis(caxisrange);
        title(sprintf('%d', i));
    end
    
    if nargout > 0
        varargout{1} = h;
    end
    
    if nargout == 2
        varargout{2} = nElems;
    end