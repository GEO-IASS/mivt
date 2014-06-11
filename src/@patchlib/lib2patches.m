function patches = lib2patches(lib, pIdx, varargin)
% draft
%   lib2patches(lib, pIdx)
%   lib2patches(lib, pIdx, patchSize)
%   lib2patches(lib, pIdx, 'cell')
%   lib2patches(lib, pIdx, patchSize, 'cell')
%
%
%   lib - N x V
%   pIdx - M x K
%   patches - M x V x K or cell of {M x K} patchSize patches.
%

    if nargin == 2
        patchSize = patchlib.guessPatchSize(size(lib, 2));
    end
    docell = '';
    
    if nargin >= 3
        if isnumeric(varargin{1})
            patchSize = varargin{1};
        else
            docell = varargin{1};
            patchSize = patchlib.guessPatchSize(size(lib, 2));
        end
    end
       
    if nargin == 4
        docell = varargin{2};
    end    
    K = size(pIdx, 2);
    
    tmppatches = lib(pIdx(:), :);
    
    % reshape to [M x K x V]
    tmppatches = reshape(tmppatches, [size(pIdx), prod(patchSize)]);

    if strcmp(docell, 'cell')
        tmppatches = reshape(tmppatches, [size(pIdx), patchSize]);
        tmppatches = permute(tmppatches, [3:numel(patchSize) + 2, 1, 2]);
        p = num2cell(patchSize);
        if K == 1
            s = {ones(1, size(pIdx, 1))};
        else
            s = {ones(1, size(pIdx, 1)), ones(1, K)};
        end
        patches = squeeze(mat2cell(tmppatches, p{:}, s{:}));
    else
        % reshape to [M x V x K]
        patches = permute(tmppatches, [1, 3, 2]);    
    end
    