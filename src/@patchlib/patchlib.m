classdef patchlib < handle
    %PATCHLIB A library for working with patches
    %   Currently still in development. 
    %
    %   See readme.md for updates and function list.
    %
    %   ToAdd:
    %   - quilting
    %   - viewKNNSearch, using functions from viewPatchesInImage
    %   - view kNN patches (maybe with image?) with scores on top.
    %
    %   requires several functions from mgt (https://github.com/adalca/mgt)
    
    properties (Constant)
        default2DpatchSize = [5, 5];
        
        % group view functions
        view = struct('patchesInImage', @patchlib.viewPatchesInImage, ...
            'patchMatches2D', @patchlib.viewPatchMatches2D, ...
            'patches2D', @patchlib.viewPatches2D, ...
            'layers2D', @patchlib.viewLayers2D);
        
        % group test functions
        test = struct('viewPatchesInImage', @patchlib.testViewPatchesInImage, ...
            'viewPatchMatches2D', @patchlib.testViewPatchMatches2D, ...
            'grid', @patchlib.testGrid, ...
            'viewStackPatches', @patchlib.testStackPatches);

        figview = ifelse(exist('figuresc', 'file') == 2, @figuresc, @figure);
    end
    
    methods (Static)
        % library construction
        varargout = vol2lib(vol, patchSize, varargin);
        varargout = volStruct2lib(volStruct, patchSize, returnEffectiveLibrary);
        
        % quilting
        vol = quilt(library, patchIdx, patchSize, nPatches, patchOverlap, varargin);
        
        % viewers
        varargout = viewPatchesInImage(im, patchLoc, patchSize, varargin)
        viewPatchMatches2D(origPatch, varargin);
        varargout = viewPatches2D(patches, patchSize, caxisrange);
        viewLayers2D(layers, mode, varargin);
        
        % testers
        testViewPatchesInImage(tid);
        testViewPatchMatches2D();
        testGrid();
        testStackPatches(varargin)
        
        % tools
        [idx, newVolSize, nPatches, overlap] = grid(volSize, patchSize, patchOverlap, varargin);
        varargout = stackPatches(patches, patchSize, nPatches, varargin);
        
        
        % mini-tools
        patchSize = guessPatchSize(n, dim);
        patches = lib2patches(lib, pIdx, varargin)
        [nPatches, newVolSize] = patchcount(volSize, patchSize, patchOverlap, varargin)
        s = patchCenterDist(patchSize);
        overlap = overlapkind(str, patchSize);
        volSize = nPatches2volSize(nPatches, patchSize, varargin)
    end
    
end
