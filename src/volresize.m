function vol = volresize(vol, sizeDstVol, interpMethod)
% interpMethod - anything taken by interpn, e.g. linear or nearest
%   as well as 'decimate', which decimates every second element starting with [2, 2, 2..]

    % check inputs
    narginchk(2, 3);
    if nargin == 2
        interpMethod = 'linear';
    end
    sizeDstVol = checkInputSizes(size(vol), sizeDstVol);

    % check that the method requires upsampling or downsampling
    % TODO - can you do both at the same time???
    sizeVol = ones(1,length(sizeDstVol));
    sizeVol(1:ndims(vol)) = size(vol); 
    isUpSampling = all(sizeVol <= sizeDstVol);
    isDownSampling = all(sizeVol >= sizeDstVol);
    assert(isUpSampling || isDownSampling);
    if (isUpSampling && isDownSampling) 
        return;
    end


    % if down-sampling, do smoothing
    if isDownSampling && ~isUpSampling && ~(strcmp(interpMethod, 'nearest'))
        
        % blur the image. note the sigma factor is kind of arbritrary
%         s = pi^2 / 8 * sizeDstVol./sizeVol;
        s = 1/4 * sizeVol ./ sizeDstVol;
        window = ceil(6 * s) + mod(ceil(6 * s), 2) + 1;
        % nn for the edge padding
        vol = imBlurSep(vol, window, s, ones(1, ndims(vol)), 'nn');     
        
%         fftVol = fftn(double(vol));
%         startVal = (floor(size(vol)/2) + 1) - ceil((sizeDstVol - 1)/2);
%         endVal = startVal + sizeDstVol - 1; 
%         fftVolCut = actionSubArray('extract', fftshift(fftVol), startVal, endVal);       
% %         fftVolCutZeros = zeros(size(fftVol));
% %         fftVolCutZeros = actionSubArray('insert', fftVolCutZeros, startVal, endVal, fftVolCut);
% %         vol = ifftn(ifftshift(fftVolCutZeros), 'symmetric');
%         ratio = prod(sizeDstVol./size(vol));
%         vol = ifftn(ifftshift(fftVolCut), 'symmetric') .* ratio;
%         return;
    end
    
    % get the interpolation points in each dimensions
    x = cell(1, ndims(vol));
    for i = 1:ndims(vol)
        if sizeDstVol(i) > 1
            x{i} = linspace(1, size(vol,i), sizeDstVol(i));
        else
            x{i} = (size(vol, i)+1)/2;
        end
    end

    % obtain a ndgrid (not meshgrid) for each dimension
    xi = cell(1, ndims(vol));
    [xi{:}] = ndgrid(x{:});

    % interpolate
    vol = interpn(vol, xi{:}, interpMethod);
    
end



function sizeDst = checkInputSizes(sizeInput, sizeDst)
    nDimsDst = numel(sizeDst);
    nDimsInput = numel(sizeInput);
    
    if nDimsDst > nDimsInput
        assert(all(sizeDst(nDimsInput + 1:end) == 1));

        msg = ['resizeNd: Destination size has more dimensions (%d) than the input vector (%d).', ...
            '\n\tSince the size in all the extra dimensions is 1, we are cropping the destination', ...
            'dimension to %d.'];
        warning('VEC:LENMATCH', msg, nDimsDst, nDimsInput, nDimsInput);
        sizeDst = sizeDst(1:nDimsInput);
    end
    
    assert(nDimsInput == numel(sizeDst));
    
    
end