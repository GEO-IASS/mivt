function viewPatchMatches2D(patchSize, origPatch, varargin)
% VIEWPATCHMATCHES display 2D patches matching an original patch
%   viewPatchMatches(patchSize, origPatch, matchPatches) display an original 2D patch and several 
%       other ('matching') patches. patchSize is a [1x2] vector indicating the size of the patches.
%       origPatch is a [1 x nPixels] vector of the original patch, with nPixels = prod(patchSize)
%       is the number of pixes in a patch. MatchPatches is a [nMatches x nPixels] matrix with 
%       nMatches matching pixels. The visualization will then show the original patch on the left 
%       subplot, and the matching patches in the right of that.
%   
%       Alternatively, origPatch can be [nOrigPatches x nPixels], i.e. several original patches. In 
%       that case, matchPatches should be a cell array of nOrigPatches [nMatches x nPixels] matrices
%       indicating the appropriate matching patches for each origPatch. (E.g. origPatch(3, :) has
%       corresponding matching patches matchPatches{e}). Each one of the 
%
%   viewPatchMatches(patchSize, origPatch, matchPatches, corrPatches1, ...) allows the specification
%        of more corresponding patches (e.g. corrPatches1 could be the equivalent labeled patches).
%        corrPatchesX should be the same form as matchPatches. 
%
%   % TODO: plot/compute distances
%
% Contact: adalca@csail.mit.edu

    % parse param/value inputs
    f = find(cellfun(@ischar, varargin), 1, 'first');
    inputs = parseinputs(varargin{f:end});
    
    % determine the number of matching groups
    if ~isempty(f)
        matchgroups = varargin(1:(f-1));
    else
        matchgroups = varargin;
    end
    nPatches = size(origPatch, 1);
    if numel(inputs.caxis) == 1
        inputs.caxis(2:(2+numel(matchgroups))) = {inputs.caxis{1}};
    end
    
    % collect primary matching match groups
    nMatches = 0;
    if nargin >= 3
        knnPatches = matchgroups{1};
        if ~iscell(knnPatches);
            knnPatches = {knnPatches};
        end    
        nMatches = size(knnPatches{1}, 1);
        assert(numel(knnPatches) == nPatches, ...
            'need the same number of nPatches as knnPatches cell entries');
    end
    
    % collect even more matching match groups
    if nargin >= 4
        corrPatches = matchgroups(2:end);
        nCorrTypes = numel(corrPatches);
        for i = 1:nCorrTypes
            if ~iscell(corrPatches{i})
                corrPatches{i} = {corrPatches{i}};
            end
        end
    else
        nCorrTypes = 0;
    end
    
    
    % create the main figure
    patchlib.figview();
    
    % compute the number of rows and columns in the plot
    nRows = nPatches * (nCorrTypes + 1);
    nCols = nMatches + 1;
    
    % go through all the patches
    for i = 1:nPatches
        
        % display original patch
        subplot(nRows, nCols, nCols * ((i - 1) * (nCorrTypes + 1)) + 1);
        imshow(reshape(origPatch(i, :), patchSize));
        caxis(inputs.caxis{1});
        
        % compute vertical subplot delay
        groupsDelay = nCols * ((i - 1) * (nCorrTypes + 1)) + 1;
        
        % display knn Patches
        kp = knnPatches{i};
        for j = 1:nMatches
            subplot(nRows, nCols, groupsDelay + j);
            imshow(reshape(kp(j, :), patchSize));
            caxis(inputs.caxis{2});
        end
        
        
        % display knn Patches from the extra groups.
        for t = 1:nCorrTypes
            kp = corrPatches{t}{i};
            for j = 1:nMatches
                idx = groupsDelay + nCols * t + j;
                subplot(nRows, nCols, idx);
                imshow(reshape(kp(j, :), patchSize));
                caxis(inputs.caxis{2 + t});
            end
        end
    end

end

function inputs = parseinputs(varargin)
% process input parser

    p = inputParser();
    p.addParamValue('caxis', {[0, 1]});
    p.parse(varargin{:});
    
    inputs = p.Results;
    if ~iscell(inputs.caxis)
        inputs.caxis = {inputs.caxis};
    end
end   
