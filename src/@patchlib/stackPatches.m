function varargout = stackPatches(patches, patchSize, nPatches, varargin)
% draft.
% STACKPATCHES stack patches in layer structure
%   layers = stackPatches(patches, patchSize, nPatches) stack given patches in a layer structure.
%       - patchSize is a vector indicating the size of the patch. Let V = prod(patchSize);
%       - nPatches is a vector with the number of patches in each direction in the volume. 
%       Let N = prod(nPatches). Together, patchSize, nPatches and the patch overlap (see below),
%       indicate how the patches will be layed out. 
%       - patches is then [N x V x K], with patches(i, :, K) indicates K patch candidates at 
%           location i (e.g. the result of a 3-nearest neightbours search).
%       - patches are assumed to have a 'sliding' overlap (i.e. patchSize - 1) -- see below for
%       specifying overlap amounts. patches can also be [N x prod(patchSize) x K], representing K
%       patches for a particular index/location
%       - layers is a [nLayers x targetSize x K] array, with nLayers that are the size of the
%       desired target (i.e. once the patches are positioned to fit the grid). The first layer,
%       essentially stacks the first patch, then the next non-overlapping patch, and so on. The
%       second layer takes the first non-stacked patch, and then the next non-overlapping patch, and
%       so on until we run out of patches. To position the patches correctly, the layers will 
%
%       For more information about the interplay between patchSize, nPatches and patchOverlap, see
%       patchlib.grid.
%
%   layers = stackPatches(patches, patchSize, targetSize) allows for the specification of the target
%       image size instead of the number of patches.
%
%   layers = stackPatches(..., patchOverlap) allows for the specification of patch overlap amount or
%       kind. Default is 'sliding'. see patchlib.overlapkind for more information
%
%   [layers, idxmat, pLayerIdx] = stackPatches(...) also returns idxmat, a matrix the same size as
%       'layers' containing linear indexes into the inputted patches matrix. This is useful if the
%       user wants to, say, create a layer structure of patch weights to match the patches layer
%       structure. pLayerIdx is a [V x 1] vector indicating the layer index of each input patch.
%
% TODO: Need to compute more efficient layer structure based on maximum connectivity/overlap
%   
% Contact: {adalca,klbouman}@csail.mit.edu
    
    % input checking
    narginchk(3, 4);
    nLayers = prod(patchSize);
    K = size(patches, 3);    
    
    % compute the targetsize and target
    if prod(nPatches) == size(patches, 1)
        intargetSize = patchlib.nPatches2volSize(nPatches, patchSize, varargin{:});
    else
        intargetSize = nPatches;
    end  
    
    % compute the targetsize and target
    [grididx, targetSize] = patchlib.grid(intargetSize, patchSize, varargin{:});
    assert(all(intargetSize == targetSize), 'The grid does not match the provided target size');
    
    % prepare subscript and index vectors
    allSub = ind2subvec(targetSize, grididx(:));
    allIdx = 1:numel(grididx);

    % get index of layer location so that patches don't overlap
    modIdx = num2cell(modBase(allSub, repmat(patchSize, [size(allSub, 1), 1])), 1);
    pLayerIdx = sub2ind(patchSize, modIdx{:})';
    
    % initiate the votes layer structure
    layers = nan([nLayers, targetSize, K]);
    if nargout == 2
        idxmat = nan([nLayers, targetSize, K]);
    end
    
    % go over each layer index
    for layerIdx = 1:nLayers % parfor
        pLayer = find(pLayerIdx == layerIdx);

        layerVotes = nan([targetSize, K]);
        if nargout == 2
            layerIdxMat = nan([targetSize, K]);
        end
        for pidx = 1:length(pLayer)
            p = pLayer(pidx);
            idx = allIdx(p);
            
            localpatches = squeeze(patches(p, :, :));
            
            % extract the patch and insert into the layers
            patch = reshape(localpatches, [patchSize, K]);
            sub = [allSub(p, :), 1];
            endSub = sub + [patchSize, K] - 1;
            layerVotes = actionSubArray('insert', layerVotes, sub, endSub, patch);
            
            if nargout == 2
                locidx = repmat(idx, [patchSize, K]);
                endSub = sub + [patchSize, K] - 1;
                layerIdxMat = actionSubArray('insert', layerIdxMat, sub, endSub, locidx);
            end
        end
        layers(layerIdx, :) = layerVotes(:);
        if nargout == 2
            idxmat(layerIdx, :) = layerIdxMat(:);
        end
    end
    
    % setup outputs
    varargout{1} = layers;
    
    if nargout == 2
        varargout{2} = idxmat;
    end
    
    if nargout == 3
        varargout{3} = pLayerIdx;
    end
end
