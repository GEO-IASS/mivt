function testViewPatchesInImage()
% test patch viewing methods    
    
    im = imresize(im2double(imread('peppers.png')), [75, 75]);
    pv = patchlib.view;
    patchCenters = [7, 7; 25, 23; 17, 29; 37, 13; 10, 10];
    patchSize = [7, 7];
    
    
    % take a look at patches in the image
    pv.patchesInImage(im, patchCenters, patchSize);
    
    % take a look at patches in the image, interactively
    patches = pv.patchesInImage(im, patchCenters, patchSize, true);
    fprintf('Returned %d patches\n', numel(patches));
    
