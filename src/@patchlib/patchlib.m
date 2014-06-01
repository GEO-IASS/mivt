classdef patchlib < handle
    %PATCHLIB A library for working with patches
    %   Currently still in development. 
    %
    %   See readme.md for updates and function list.
    %
    %   requires several functions from mgt (https://github.com/adalca/mgt)
    
    properties (Constant)
        default2DpatchSize = [5, 5];
        
        % group view functions
        view = struct('patchesInImage', @patchlib.viewPatchesInImage, ...
            'patchMatches2D', @patchlib.viewPatchMatches2D, ...
            'patches2D', @patchlib.viewPatches2D);
        
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
        viewPatches2D(patches, patchSize, caxisrange);
        
        % testers
        testViewPatchesInImage();
        testViewPatchMatches2D();
        
        % tools
        patchSize = guessPatchSize(n, dim);
    end
    
end

