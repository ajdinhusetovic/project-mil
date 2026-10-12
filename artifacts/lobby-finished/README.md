# Stud simulator lobby

Open EnergyCoreMining-StudSimulator.blend. This is the detailed art pass requested after the Stage 1 correction. It retains the three booth footprints, the right-facing left-side boards, ten AFK locations in two rows, the core station reservation, and the 72 x 72 mine opening at world origin.

The art adds physical square studs to grass, orange walls, roof strips, booth surfaces and training blocks; bordered tile paths; a small circular paving inlay; striped vendor roofs; square tree tiers; flowers, grass tufts, small rocks and two human-scale edge benches. The mine contains no floor, shaft or mining blocks.

Named collections and parent groups remain separate. Shop counters retain Counter in their RobloxName property and mesh names. Stabilizer has CoreMount. Each AFK has StandingArea and TrainingBlock. Decorative stud patches remain separate by surface. Do not export the hidden ReviewGuides collection or Presentation collection. Signs and leaderboard rows remain blank for Roblox-authored editable displays; there is no baked mesh text, no screen UI and no NPC character geometry.

colors-rgb.json gives the flat sRGB palette. Vertex color data is stored on the art meshes. Blender Z is Roblox Y; one Blender unit is one stud. Local mesh scales are applied; hierarchy transformations need to be baked or preserved correctly at final export.

The full FBX is intentionally not exported yet. The prior requested Roblox size test for ScaleTest-12x1x4.fbx has not been completed in Studio. Verify that test piece is 12 x 1 x 4 studs before full export. Large stud patches should be split as needed for the importer mesh triangle limit during that export step. Studio collisions, prompts, shop logic, AFK logic and live leaderboard data remain separate game integration work.

Preview files: simulator-overview.png, simulator-player-height.png and simulator-plaza-view.png. Relationship lines, extra objects and the grid are hidden in the saved viewport for a clean art view.

Latest update: the shop and leaderboard walkways now match the pale stone paving. A red studded carpet with a gold edge fills the leaderboard forecourt. The AFK platform has ten independently editable stations, two rows of five, a four-stud middle aisle and gold borders. Added groups duplicate the original five as AFK_1x_02, AFK_1_5x_02, AFK_3x_02, AFK_5x_02 and AFK_8x_02. These names are visual duplicates, not new progression tuning.

Path correction: all tile/checkerboard slabs, shop aprons, shop approaches and extra side paths have been removed. Three continuous studded pale-stone branches meet the circular plaza: forward to mine, left to leaderboards, right to AFK. The shops sit directly on grass beside the plaza. Ten AFK stations remain in place. simple-paths-overhead.png shows this update.

Polish update: 174 individually editable grass tiles, on a 12-stud grid, alternate dark/light green with a small number of middle-green patches. Each tile has its own matching stud mesh. Tile top is exactly Blender Z=0; underlying support slab tops are Z=-0.04. Grass stud patches are now split by tile rather than large combined fields. Tree crowns use two shades, four low flower beds decorate the edges, and narrow yellow/dark hazard markings finish the mine rim. No shop sidewalks were reintroduced. All mine, ground-height, AFK-count and three-path checks passed.
