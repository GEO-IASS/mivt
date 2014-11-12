function stats = volstats(vol, verbose)

    if nargin == 1
        verbose = false;
    end
    
    stats.class = class(vol);
    vol = double(vol);
    stats.size = size(vol);
    stats.min = min(vol(:));
    stats.max = max(vol(:));
    
    nBins = numel(vol) ./ 1000;
    nBins = max(nBins, 10);
    nBins = min(nBins, numel(vol));
    [stats.histcounts, stats.histbins] = hist(vol(:), nBins);
    
    if verbose
        figure();
        hist(vol(:), nBins);
    end
        