# Spawn Crossroads layout

Open `EnergyCore-SpawnCrossroads.blend` to edit, or import `EnergyCore-SpawnCrossroads.fbx` into Roblox Studio with the 3D Importer.

Facing the mine from spawn:
- Left: 10 AFK foundations in two stepped rows of five, facing inward.
- Right: four leaderboard foundations in a single row, facing inward.
- Around spawn: three shop foundations and a core stabilizer foundation.
- Ahead: a separate mine court enclosed by the same terraced orange walls as the lobby.

Smooth surfaces, no studs. The lobby courtyard is 360 × 260 units. The mine opening is 72 × 72 with a 720-unit shaft. Geometry uses one Blender unit per Roblox stud; inspect the importer scale before applying an additional scale multiplier.

Only environmental geometry and reserved paving pads are exported. Actual machines, shops, leaderboard panels, stabilizer equipment, and gameplay blocks are not included. Planning labels and arrows live in a separate Blender collection and are excluded from FBX. The full shaft is exported but hidden in preview renders; enable its collection's render visibility for deep shaft renders.

`layout-manifest.json` records placement sizes and facing directions in Blender coordinates. Front is +Y in Blender, corresponding to -Z in the exported Roblox orientation. The existing Roblox Studio map has not been replaced by this revision.
