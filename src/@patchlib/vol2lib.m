function varargout = vol2lib(vol, patchSize, varargin)
% VOL2LIB transform a volume into a patch library
%   library = vol2lib(vol, patchSize) transform volume vol to a patch
%       library. vol can be any dimensions (tested for 2, 3); patchSize is the size
%       of the patch (nDims x 1 vector). 
%
%       Alternatively, vol can be a cell array of volumes, in which case the library is computed for
%       each volumes. library is then a cell array with as many entries as volumes.
%
%   library = vol2lib(vol, patchSize, overlap) allow specification of how the overlap between
%       patches: a scalar, vector (of size [1xnDims]) or a string for a pre-specified configuration,
%       like 'sliding', 'discrete', or 'mrf'. see patchlib.grid for details of the supported overlap
%       kinds. If not specified (i.e. function has only 2 inputs), default overlap is 'sliding'.
%
%   Note: vol2lib will cut the volume to fit the right number of patches.
%
%   [library, idx] = vol2lib(...) returns the index of the starting (top-left) point of every patch
%       in the *original* volume.
%
%   [library, idx, libVolSize] = vol2lib(...) returns the size of the volumes size, which is smaller
%       than or equal to the size of vol. It will be smaller than the initial volume if the volume
%       had to be 
%
%   Current Algorithm:
%       Initiate by getting a first 'grid' of the top left index of every patch
%       Iterate: shift through all the indexes in a patch (1:prod(patchSize)) 
%       - get the appropriate grid
%           e.g. the second iteration gives us the second point in every patch
%       - stack the grids [horzcat] in a library of indexes
%       use this library of indexes to index into the volume, giving the final library
%   This method was optimized over several versions. History of performance:
%       for 1000 smaller calls: ~2.7s --> down to 0.7s
%       for 10 big calls: 4.7s --> 2.5s
%
%   TODO: could speed up for the special case of 2D or 3D?
%
% See Also: grid, im2col, ifelse
%
% Contact: {adalca,klbouman}@csail.mit.edu
   
    % if vol is a cell, recursively compute the libraries for each cell. 
    if iscell(vol)
        varargout{1} = cell(numel(vol), 1);
        idx = cell(numel(vol), 1);
        sizes = cell(numel(vol), 1);
        for i = 1:numel(vol)
            [varargout{1}{i}, idx{i}, sizes{i}] = patchlib.vol2lib(vol{i}, patchSize, varargin{:});
        end
        if nargout == 2, varargout{2} = idx; end
        if nargout == 2, varargout{3} = sizes; end
        return
    end
    
    
    if nargin == 2
        varargin{1} = 'sliding';
    end
    nDims = ndims(vol);
    volSize = size(vol);
    
    % get the index and subscript of the initial grid
    [initidx, cropVolSize] = patchlib.grid(volSize, patchSize, varargin{:}); 
    initsub = cell(1, nDims);
    [initsub{:}] = ind2sub(volSize, initidx);
    vol = cropVolume(vol, cropVolSize);
    
    
    % get all of the shifts in a [prod(patchSize) x nDims] subscript matrix
    shift = cell(1, nDims);
    [shift{:}] = ind2sub(patchSize, (1:prod(patchSize))');
    shift = [shift{:}];
    
    % initialize library of subscripts into the volume
    sub = cell(numel(patchSize), 1);
    for dim = 1:numel(patchSize)
        sub{dim} = zeros(numel(initidx), prod(patchSize));
    end
    
    % go through each shift
    for s = 1:prod(patchSize)
        
        % update subscript library
        for dim = 1:numel(patchSize)
            sub{dim}(:, s) = initsub{dim}(:) + shift(s, dim) - 1;
        end
    end
    
    % for each dimension, put the subscript library in a vector
    for dim = 1:numel(patchSize)
        sub{dim} = sub{dim}(:);
    end
    
    % compute the library of linear indexes into the volume
    idxvec = sub2ind(cropVolSize, sub{:});
    idx = reshape(idxvec, [numel(initidx), prod(patchSize)]);
    
    % 
    library = vol(idx(:));
    library = reshape(library, size(idx));
    
    varargout{1} = library; 
    
    % prepare the index output, if necessary
    if nargout == 2 
        assert(numel(initidx) == size(library, 1), ...
            'Something went wrong with the library of index computation. Sizes don''t match.');
        varargout{2} = initidx(:);
    end
    
    % prepare the new volume output, if necessary
    if nargout == 3
        varargout{3} = cropVolSize;
    end
end



function [vol, patchSize, olap] = parseInputs(vol, patchSize, varargin)

    narginchk(2, 4);
    
    assert(isnumeric(vol), 'Volume vol should be numeric');
    if nargin == 2
        varargin{1} = 'sliding';
    end
%     kind = validatestring(varargin{1}, {'sliding', 'distinct'}, mfilename, 'kind', 3);

    switch varargin{1}
        case 'sliding'
            olap = patchSize - 1;
        case 'olap'
            olap = varargin{2};
        case 'discrete'
            olap = 0;
        otherwise
            eror('unknown overlap kind');
    end
end
