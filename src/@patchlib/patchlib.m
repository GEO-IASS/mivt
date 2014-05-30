classdef patchlib < handle
    %PATCHLIB A library for working with patches
    %   Currently still in development. 
    %
    %
    %   5/30/2014
    %   - added viewing functions: 
    %       patchlib.view.patchesInImage
    %       patchlib.view.patchMatches
    %   - adding test functions:
    %       patchlib.test.viewPatchesInImage
    %       patchlib.test.viewPatchMatches2D
    
    properties (Constant)
        default2DpatchSize = [5, 5];
        
        % group view functions
        view = struct('patchesInImage', @patchlib.viewPatchesInImage, ...
            'patchMatches', @patchlib.viewPatchMatches);
        
        % group test functions
        test = struct('viewPatchesInImage', @patchlib.testViewPatchesInImage, ...
            'viewPatchMatches2D', @patchlib.testViewPatchMatches2D);

        figview = ifelse(exist('figuresc', 'file') == 2, @figuresc, @figure);
    end
    
    methods (Static)
        
        varargout = vol2lib(vol, patchSize, varargin);
        varargout = vols2lib(vols, patchSize, returnEffectiveLibrary);
        varargout = volStruct2lib(volStruct, patchSize, returnEffectiveLibrary);
        library = mrfVolStruct2lib(volStruct, patchSize, varargin);
        s = patchCenterDist(patchSize);
        
        % viewers
        varargout = viewPatchesInImage(im, patchCenter, patchSize, interactive);
        viewPatchMatches2D(patchSize, origPatch, varargin);
        
        % testers
        testViewPatchesInImage();
        testViewPatchMatches2D();
    end
    
end

