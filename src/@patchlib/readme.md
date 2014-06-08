patchlib
========

A library for working with patches, currently very much in development.
Please let us know of any questions/suggestions at adalca@csail.mit.edu

Library Construction
--------------------
- [`patchlib.vol2lib`](vol2lib.m) transform a volume into a patch library
- [`patchlib.volStruct2lib`](volStruct2lib.m) transform a volStruct into a patch library
- [`patchlib.grid`](grid.m) grid of patch starting points for n-d volume

Viewing Functions
-----------------
- [`patchlib.view.patchesInImage`](viewPatchesInImage.m) visualize 2D patches in an image
- [`patchlib.view.patchMatches2D`](viewPatchMatches2D.m) display 2D patches matching an original patch
- [`patchlib.view.patches2D`](viewPatches2D.m) show 2D patches in a subplot grid

Test Functions
--------------
- [`patchlib.test.viewPatchesInImage`](testViewPatchesInImage.m) test view.patchesInImage
- [`patchlib.test.viewPatchMatches2D`](testViewPatchMatches2D.m) test view.patchMatches2D
- [`patchlib.test.grid`](testGrid.m) test grid

Helper Functions
----------------
- [`patchlib.patchcount`](patchcount.m) number of patches that fit into a volume
- [`patchlib.overlapkind`](overlapkind.m) overlap amount to/from pre-specified overlap kind
- [`patchlib.guessPatchSize`](guessPatchSize.m) guess the size of a patch from nVoxels
- [`patchlib.patchCenterDist`](patchCenterDist.m) compute the distance to the center of a patch
- [`patchlib.nPatches2volSize](nPatches2volSize.m)` volume size from number of patches
