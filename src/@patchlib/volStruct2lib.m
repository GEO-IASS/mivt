function varargout = volStruct2lib(volStruct, patchSize, varargin)
% similar to vol2lib, but takes in a volStruct, not volume. 
% Returns horizontally concatenanted features.
%   volStruct is a struct with two fields:
%   volStruct.features = nVoxels x nFeatures
%   volStruct.volSize = size of the volume. 
%
%   should have: prod(volStruct.volSize) == size(volStruct.features, 1);
%
% See Also: vol2lib
%
% Contact: {adalca,klbouman}@csail.mit.edu

    % some input checks
    narginchk(2, 3);
   
    % compute cell of feature-volumes
    vols = volStruct2featVols(volStruct);
    
    % compute libraries
    [libraries, idx] = vols2lib(vols, patchSize, varargin{:});
    
    % add horizontally
    varargout{1} = libraries;
    
    if nargout == 2
        % should actually be consistent!
        varargout{2} = idx;
    end 
end
