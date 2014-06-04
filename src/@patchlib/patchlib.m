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
        % library construction
        varargout = vol2lib(vol, patchSize, varargin);
        varargout = volStruct2lib(volStruct, patchSize, returnEffectiveLibrary);
        
        % mrf-related
%         library = mrfVolStruct2lib(volStruct, patchSize, varargin);
        
        % viewers
        varargout = viewPatchesInImage(im, patchCenter, patchSize, interactive);
        viewPatchMatches2D(origPatch, varargin);
        viewPatches2D(patches, patchSize, caxisrange);
        
        % testers
        testViewPatchesInImage();
        testViewPatchMatches2D();
        
        % tools
        patchSize = guessPatchSize(n, dim);
        s = patchCenterDist(patchSize);
    end
    
end
