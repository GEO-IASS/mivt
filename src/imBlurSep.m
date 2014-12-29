function [filtVol, filt]  = imBlurSep(vol, window, sigma, voxDims, padType)
% IMBLURSEP blur the given volume with separable gaussian filter
% 	vol the volume (nDims)
% 	window should be (nDims x 1)
% 	sigma is a scalar in mm
% 	voxDims [optional] the dimensions of the voxels in mm (nDims x 1)
%	padType [optional] - 'nn' for nearest neighbour padding, any other string for no padding.
%       default: nn
%
% Contact: adalca@mit.edu

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
    
    volSize = size(vol);
    filt = cell(1, ndims(vol));
    onesVec = ones(1, ndims(vol));
    
    for i = 1:ndims(vol)
%         filterchk = fspecial('gaussian', [1, window(i)], sigma(i) ./ voxDims(i));
        filter = gaussianfilter([1, window(i)], sigma(i) ./ voxDims(i));
%         assert(all(filter == filterchk));        
        reshapeVec = onesVec;
        reshapeVec(i) = window(i);
        filt{i} = reshape(filter, reshapeVec);
    end

    switch padType
        
		case 'nn' 
            % if using nearest neighbour padding
            % pad via replicates and crop back after doing the filtering.
			inputVol = padarray(vol, (window - 1)/2, 'replicate', 'both');
			filtVol = imfilterSep(inputVol, filt{:}, 'valid');
				
		otherwise
			filtVol = imfilterSep(vol, filt{:});
    end

    assert(all(size(filtVol) == volSize));

end

function h = gaussianfilter(p2, p3)

    siz   = (p2-1)/2;
     std   = p3;
     
     [x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));
     arg   = -(x.*x + y.*y)/(2*std*std);

     h     = exp(arg);
     h(h<eps*max(h(:))) = 0;

     sumh = sum(h(:));
     if sumh ~= 0,
       h  = h/sumh;
     end;
end
