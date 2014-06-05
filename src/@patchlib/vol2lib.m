function varargout = vol2lib(vol, patchSize, varargin)
% VOL2LIB transform a volume into a patch library
%   library = vol2lib(vol, patchSize) transform volume vol to a patch
%   library. vol can be any dimensions (tested for 2, 3); patchSize is the size
%   of the patch (nDims x 1 vector). 
%
%   Alternatively, vol can be a cell array of volumes, in which case the library is computed for
%   each volumes. library is then a cell array with as many entries as volumes.
%
%   library = vol2lib(vol, patchSize, kind) allow specification of how the volume is split via kind
%       kind = 'sliding': (default) patches are sliding, so maximally overlapping 
%       kind = 'distinct': non-overlapping, grid-like setup. 
%
%   Note: in the sliding case, the number of patches will be roughly the number of voxels in
%   the original volume minus those patches that would have started in the last (patchSize - 1)
%   entries in each direction (since they wouldn't make complete patches). in the distinct case,
%   vol2lib will cut the volume to an integral number of patches
%
%   [library, idx] = vol2lib(...) returns the index of the starting (top-left) point of every patch
%       in the *original* image.
%
% TODO: can probably speed up with smarter indexing. 
%
% See Also: im2col, ifelse, ind2ind
%
% Contact: {adalca,klbouman}@csail.mit.edu

    narginchk(2, 3);

    % if vol is a cell, recursively compute the libraries for each cell. 
    if iscell(vol)
        varargout{1} = cell(numel(vol), 1);
        idx = cell(numel(vol), 1);
        for i = 1:numel(vol)
            [varargout{1}{i}, idx{i}] = patchlib.vol2lib(vol{i}, patchSize, varargin{:});
        end
        if nargout == 2, varargout{2} = idx; end
        return
    end


    % input check. default kind is sliding.
    assert(isnumeric(vol), 'vol should be numeric');
    if nargin == 2
        varargin{1} = 'sliding';
    end
    kind = validatestring(varargin{1}, {'sliding', 'distinct'}, mfilename, 'kind', 3);
    nDims = numel(patchSize);
    origSize = size(vol);

    % want to work with the effective reference size
    if strcmp(kind, 'sliding')
        storeVolSize = size(vol) - patchSize + 1;
        library = zeros(numel(vol), prod(patchSize));
    else
        volSize = floor(size(vol) ./ patchSize) .* patchSize;
        storeVolSize = volSize ./ patchSize;
        vol = cropVolume(vol, ones(1, nDims), volSize);
        library = zeros(numel(vol) ./ prod(patchSize), prod(patchSize));
    end

    % get the class of the volume, and then work in double
    origVolumeClass = class(vol);
    vol = double(vol);

    % keep off-setting the volume to create the library automatically by stacking
    sub = cell(nDims, 1);
    [sub{:}] = ind2sub(patchSize, 1:prod(patchSize));
    
    % if requiring index output, prepare the index volume to sub-sample.
    if nargout == 2
        idxVol = reshape(1:numel(vol), size(vol));
    end
    
    % go through the possible offsets
    for idx = 1:prod(patchSize)
        
        % copy the volume
        tempVol = vol;
        
        % shift the volume appropriately
        shiftRanges = cell(nDims, 1);
        for d1 = 1:nDims 
            
            % compute the range for which to insert nans
            nanRange = cell(nDims, 1);
            for d2 = 1:nDims
                s = sub{d2};
                if d2 == d1
                    nanRange{d2} = 1:(s(idx)-1);
                else
                    nanRange{d2} = 1:size(vol, d2);
                end
            end
            
            tempVol(nanRange{:}) = nan;
            
            % compute the range for shifting in this dimension
            s = sub{d1};
            step = ifelse(strcmp(kind, 'sliding'), 1, patchSize(d1));
            range = [s(idx):size(vol, d1), 1:(s(idx) - 1)];
            shiftRanges{d1} = range(1:step:end);
        end
        tempVol = tempVol(shiftRanges{:});
        
        % insert the shifted volume to the library
        library(:, idx) = tempVol(:);
        
        % if output is requested and using 'discrete'
        if nargout == 2 && strcmp(kind, 'distinct') && idx == 1
            idxVol = idxVol(shiftRanges{:});
        end
            
    end
    
    % take out nan patches (i.e. only return patches originating in the
    % effective library) if returnEffectiveLibrary
    nanIdx = isnan(sum(library, 2));
    library(nanIdx, :) = [];
    assert(size(library, 1) == prod(storeVolSize));   
    varargout{1} = cast(library, origVolumeClass); 
    
    % prepare the index output, if necessary
    if nargout == 2 
        if strcmp(kind, 'sliding')
            idxVol(nanIdx) = [];
        else
            idxVol = ind2ind(size(vol), origSize, idxVol(:));
        end
        assert(numel(idxVol) == size(library, 1), ...
            'Something went wrong with the library of index computation. Sizes don''t match.');
        varargout{2} = idxVol(:);
    end
end
