function [idx, newVolSize, nPatches, overlap] = grid(volSize, patchSize, patchOverlap, varargin)
% GRID grid of patch starting points for n-d volume
%   idx = grid(volSize, patchSize, patchOverlap) computed the grid of patches that fit into volSize
%       given a particular patchSize and patchOverlap, and return the indexes of the top-left voxel
%       of each patch. The volume will be cropped to the maximum size that fits the patch grid. For
%       example, a [6x6] volume with a patchsize of [3x3] and overlap of 1 will be cropped to [5x5]
%       volume. Overlap should be < patchSize. patchSize should be the same length as volSize.
%       patchOverlap should be a scalar (applied to all dim) or the same length as patchSize.
%
%       The index is in the given volume. If the volume gets cropped as part of the function and you
%       want a linear indexing into the new volume size, use 
%       >> newidx = ind2ind(newVolSize, volSize, idx); 
%       newVolSize can be passed by the current function, see below.
%
%       To get spacing between non-overlapping patches, enter negative overlaps.
%
%   idx = grid(volSize, patchSize, kind) allows for pre-specified kind of overlaps:
%       'sliding' refers to a sliding window, giving an overlap of patchSize - 1 'discrete' refers
%       to discrete patches, so the overlap is 0 'mrf' assumes an overlap of floor((patchSize -
%       1)/2) (e.g. 2 on [5x5] patch)
%
%   idx = grid(..., startSub) - start the indexing at a particular location [1 x nDims]. This
%       essentially means that the volume will be cropped starting at that location. e.g. if
%       startSub is [2, 2], then only vol(2:end, 2:end) will be included.
%
%   sub = grid(..., 'sub') return n-D subscripts instead of linear index. sub will be a 1 x nDim
%       cell. This is equivalent to [sub{:}] = sub2ind(volSize, idx), but is done faster inside this
%       function.
%
%   [..., newVolSize, nPatches, overlap] = grid(...) returns the size of the cropped volume, the
%       number of patches in each direction, and the size of the overlap. The latter is useful is
%       the 'kind' input was used.
%
% Contact: {adalca,klbouman}@csail.mit.edu



    % check inputs
    [overlap, startDel, returnsub] = parseinputs(volSize, patchSize, patchOverlap, varargin{:});
    
    nMiddleVoxels = patchSize - 2 * overlap;
    nDims = numel(patchSize);
    mVolSize = volSize - startDel + 1;
    
    % compute the number of patches
    repvox = mVolSize - overlap;    % nVoxels in [middle, 1-border] repetitions.
    nPatchesComp = repvox ./ (overlap + nMiddleVoxels);
    nPatches = floor(nPatchesComp);
        
    % new volume size
    newVolSize = nPatches .* (overlap + nMiddleVoxels) + overlap;

    % compute grid idx
    % prepare the sample grid in each dimension
    step = patchSize - overlap;
    xvec = cell(nDims, 1);
    for i = 1:nDims
        xvec{i} = startDel(i):step(i):(newVolSize(i) + startDel(i) - 1 - (patchSize(i) - 1));
        assert(xvec{i}(end) + patchSize(i) - 1 == ((newVolSize(i) + startDel(i) - 1)));
    end
    
    % get the ndgrid
    % if want subs, this is the faster way to compute (rather than ind -> ind2sub)
    if returnsub
        idx = cell(nDims, 1);
        [idx{:}] = ndgrid(xvec{:});
    else
    
        % if want index, this is the faster way to compute (rather than sub -> sub2ind
        v = reshape(1:prod(volSize), volSize);
        idx = v(xvec{:});
    end
    
end

function [patchOverlap, startDel, retsub] = parseinputs(volSize, patchSize, patchOverlap, varargin)

    % check input count, and sizes of elements.
    narginchk(3, 5);
    if isscalar(patchSize)
        patchSize = repmat(patchSize, [1, numel(volSize)]);
    
    else
        assert(numel(volSize) == numel(patchSize), ...
            'volume and patch have different dimensions: %d, %d', numel(volSize), numel(patchSize));
    end

    % if patchOverlap is a string, use pre-specified numbers
    if ischar(patchOverlap)
        switch patchOverlap
            case 'mrf'
                patchOverlap = floor((patchSize - 1)/2);
            case 'sliding'
                patchOverlap = patchSize - 1;
            case 'discrete'
                patchOverlap = 0;
            otherwise
                error('Unknown overlap method: %s', patchOverlap);
        end
    end
    assert(all(patchSize > patchOverlap));
    
    retsub = false;
    if nargin == 3 || ischar(varargin{1})
        startDel = ones(size(patchSize));
    elseif nargin == 4 && ~ischar(varargin{1})
        startDel = varargin{1};
    end
    
    if (nargin == 4 && ischar(varargin{1})) || (nargin == 5)
        if nargin == 4 && ischar(startDel)
            assert(strcmp(startDel, 'sub'), 'Char last character must be ''sub''');
        else
            assert(strcmp(varargin{1}, 'sub'), 'Char last character must be ''sub''');
        end
        retsub = true; 
    end
end
