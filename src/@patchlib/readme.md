patchlib
========

A library for working with patches, currently very much in development.

Library Construction
--------------------
- [`patchlib.vol2lib`](vol2lib.m) transform a volume into a patch library
- `patchlib.volStruct2lib` transform a volStruct into a patch library
- `patchlib.grid` grid of patch starting points for n-d volume

Viewing Functions
-----------------
- `patchlib.view.patchesInImage` visualize 2D patches in an image
- `patchlib.view.patchMatches2D` display 2D patches matching an original patch
- `patchlib.view.patches2D` show 2D patches in a subplot grid

Test Functions
--------------
- `patchlib.test.viewPatchesInImage` test view.patchesInImage
- `patchlib.test.viewPatchMatches2D` test view.patchMatches2D
- `patchlib.test.grid` test grid

Helper Functions
----------------
- `patchlib.patchcount` number of patches that fit into a volume
- `patchlib.overlapkind` overlap amount to/from pre-specified overlap kind
- `patchlib.guessPatchSize` guess the size of a patch from nVoxels
- `patchlib.patchCenterDist` compute the distance to the center of a patch
- `patchlib.nPatches2volSize` volume size from number of patches
