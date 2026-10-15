# Polished ore blocks

11 original blocks matching `Config.MaterialOrder` and `BlockVisuals`:
Stone, Copper, ChargedQuartz, Quartz, Ion, Plasma, ReactorShard, Fusion,
Antimatter, Singularity, Omega.

Open **EnergyCore-PolishedOres.blend** for the editable collection. The Blender
scene that was open before this task is preserved. Assets are in the collection
`11 ORE BLOCKS - EXPORTABLE`; labels, backdrop and lights are presentation only.

Each block is one centred 6 x 6 x 6-unit mesh, 44 triangles, one material and one
1024 x 1024 colour texture. Ore facets are painted into the texture rather than
protruding, so adjacent mining cells have no large gaps or overlapping crystals.
PNG textures are packed in the Blender file and embedded in the individual FBXs.
Standalone PNGs are also provided in `textures/`.

Import the individual FBX files into Roblox Studio's 3D Importer. Use Studs as
the scale unit and confirm each body is 6 x 6 x 6. Import textures with the mesh;
if a colour texture is not resolved automatically, use its matching PNG. Keep
MeshPart.Color white so it does not tint the artwork. These are colour textures,
not vertex colours or runtime shader effects.

The runtime expects each imported Body inside a Model with the exact filename
as its name, under `ReplicatedStorage.BlockModels`. This set is now installed
in the current Studio place. The imported 600-unit meshes were normalized to
6-stud bodies. The prior set is preserved under
`ServerStorage.OLD_BlockModels_DELETE_WHEN_READY`, with `OLD_` model names.
Original import sources are under `ServerStorage.PolishedOre_ImportedSources`.
`studio/install_polished_ores.lua` records the repeatable installation procedure.
Do not carry MiningBodySize/MiningBodyOffset attributes from older, differently
scaled crystal models onto these centred cubes.

`build_polished_ores.py` is the editable authoring recipe. `manifest.json` records
the material mapping, texture paths, bounds and triangle counts.
