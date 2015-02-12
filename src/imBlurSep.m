function [filtVol, filt]  = imBlurSep(vol, window, sigma, voxDims, padType)
% IMBLURSEP blur the given volume with separable gaussian filter
%     vol the volume (nDims)
%     window should be (nDims x 1)
%     sigma is a scalar in mm
%     voxDims [optional] the dimensions of the voxels in mm (nDims x 1)
%    padType [optional] - 'nn' for nearest neighbour padding, any other string for no padding.
%       default: nn
%
% Contact: adalca@mit.edu

    % input parsing
    narginchk(3, 5);
    if isscalar(sigma)
        sigma = ones(1, ndims(vol)) * sigma;
    end

    if nargin <= 3
        voxDims = ones(size(window));
    end
    
    if nargin <= 4
        padType = 'nn';
    end
    assert(all(mod(window, 2) == 1));
    
    % create filters
    filt = cell(1, ndims(vol));
    onesVec = ones(1, ndims(vol));
    for i = 1:ndims(vol)
        filter = gaussianfilter([1, window(i)], sigma(i) ./ voxDims(i));
        % filterchk = fspecial('gaussian', [1, window(i)], sigma(i) ./ voxDims(i));
        % assert(all(filter == filterchk));        
        reshapeVec = onesVec;
        reshapeVec(i) = window(i);
        filt{i} = reshape(filter, reshapeVec);
    end

    % filter volume.
    switch padType
        
        case 'nn' 
            % if using nearest neighbour padding
            % pad via replicates and crop back after doing the filtering.
            inputVol = padarray(vol, (window - 1)/2, 'replicate', 'both');
            filtVol = imfilterSep(inputVol, filt{:}, 'valid');
                
        otherwise
            filtVol = imfilterSep(vol, filt{:});
    end
    
    assert(all(size(filtVol) == size(vol)));
end

function h = gaussianfilter(window, sigma)
% fast implementation of gaussian filter
% TODO: check: this works in 3D?

    siz = (window-1)/2;
    std = sigma;

    [x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));
    arg = -(x.*x + y.*y)/(2*std*std);

    h     = exp(arg);
    h(h<eps*max(h(:))) = 0;

    sumh = sum(h(:));
    if sumh ~= 0,
        h  = h/sumh;
    end;
end
