# Original voxel ore set

All 11 mining materials are remade. The art is procedurally authored with original
pixel clusters, stepped veins, palettes and rock patterns; no Minecraft assets or
textures were used. Each body fills an exact 6 x 6 x 6-stud cube. Ore is flush with
the cube faces, so no protrusions change the mining-cell fit.

Open EnergyCore-OriginalVoxelOres.blend for the full editable set. Each ore is an
independent parent and Body mesh. Presentation labels/lights/camera are excluded
from the individual FBX exports. Colour is stored in face materials and embedded
vertex colours; each model is 768 triangles.

Import individual FBX files into Roblox Studio using Scale Unit: Studs, with
Ignore Vertex Colors OFF. Use the origin pivot; do not merge different ores.
Check the imported body is 6 x 6 x 6 before installing the set. Keep each Body
inside a Model named exactly like its FBX filename (without .fbx).

ReplicatedStorage.BlockModels model names:
Stone, Copper, Quartz, ChargedQuartz, Ion, Plasma, ReactorShard, Fusion,
Antimatter, Singularity, Omega.

Replace whole Models, rather than swapping a MeshPart into an old crystal Model:
the old MiningBodySize/MiningBodyOffset attributes were calibrated for the old
200-unit meshes and must not carry onto this new cube set.

The set is installed in the live Roblox place under ReplicatedStorage.BlockModels.
The previous ores and original imports are backed up in
ServerStorage.OreModelsBeforeVoxelReplacement. studio/install_voxel_ores.lua is the
repeatable Edit-mode installation script.
