# Stage 1 — layout review

Open EnergyCoreMining-Stage1.blend. The scene contains placeholder architecture only: 3 booths, 5 AFK spots on one raised platform, a core station reservation, a circular plaza and the connecting paths. Four boards reserve the leaderboard space requested earlier. Studs, striped roofs, flowers and final booth/station decoration wait for layout approval.

The 72 x 72 opening is centered at origin, ground at Blender Z=0 / Roblox Y=0. Mesh bounding-box audit found no intrusion into the opening. There are no ore blocks, shaft walls, pit floor or underground art.

Required groups are separate collections with named parent empties. Child names have a group prefix to keep Blender names unique, for example WeaponStore__Counter; RobloxName custom properties specify Counter, CoreMount and StandingArea. Each AFK group has a separate TrainingBlock. ReviewGuides contains editable font labels used only to identify placeholders in renders; do not export these or bake them into geometry. Final Roblox signs will be authored in Studio. Presentation includes lights and cameras, with no character geometry.

RGB palette: colors-rgb.json. Object layout: layout-manifest.json. Player eye-height renders use 5.5 studs; overhead-layout.png shows the entire layout.

Only ScaleTest-12x1x4.fbx has been exported. Import it in Roblox Studio with Scale Unit Studs, Merge Meshes off and Ignore Vertex Colors off. Inspect its MeshPart Size: expected X=12, Y=1, Z=4. This has NOT yet been verified in Roblox. The full lobby export must wait for both layout approval and a successful Roblox scale test.

No runtime or authored Roblox UI was changed. Stage 2 must retain the approved layout and produce separate editable pieces.
