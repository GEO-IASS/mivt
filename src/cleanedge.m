function rvol = cleanedge(vol, edgecount, edgefill)
% clean the edge of a volume (n-dimensional) by edgecount on all sides using edgefill

    if nargin == 1
        edgecount = 1;
    end
    
    if nargin <= 2
        edgefill = 0;
    end
    
    r = num2cell(1:ndims(vol));
    range = cellfun(@(x) (1+edgecount):(size(vol, x)-edgecount), r, 'UniformOutput', false);
    rvol = ones(size(vol)) * edgefill;
    rvol(range{:}) = vol(range{:});
end
