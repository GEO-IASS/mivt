patchlib
========

A library for working with patches, currently very much in development.

Library Construction
--------------------
- `patchlib.vol2lib` transform a volume into a patch library
- `patchlib.volStruct2lib` transform a volStruct into a patch library

Viewing Functions
-----------------
- `patchlib.view.patchesInImage` visualize 2D patches in an image
- `patchlib.view.patchMatches2D` display 2D patches matching an original patch
- `patchlib.view.patches2D` show 2D patches in a subplot grid

Test Functions
--------------
- `patchlib.test.viewPatchesInImage` test view.patchesInImage
- `patchlib.test.viewPatchMatches2D` test view.patchMatches2D

Helper Functions
----------------
- `patchlib.guessPatchSize` guess the size of a patch from nVoxels
- `patchlib.patchCenterDist` compute the distance to the center of a patch
