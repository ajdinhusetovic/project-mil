# Compact lobby V2

Import EnergyCoreLobby-V2-Colored.fbx through Studio File > Import. Enable Anchored, Add to Workspace, Insert Using Scene Position, Set Pivot to Scene Origin. Keep Merge Meshes and Ignore Vertex Colors off. Select Scale Unit: Studs. FBX uses FBX Unit Scale rather than baking a 100x conversion into the geometry.

Check the WeaponStore_Counter mesh width: it should be 8.3 studs. The mine opening should be 72 x 72 studs at world origin. Roblox Studio import has not been tested directly; the exported FBX was reimported in Blender and verified for colors and dimensions.

The layout has two small kiosks flanking the direct path to the mine, a sell kiosk southwest of the central plaza, a stabilizer southeast, four leaderboard boards on the west stage, and six AFK pads in two short tiers on the east. Kiosks have an 11 x 9 footprint with an 8.5-stud canopy height. AFK pads are 8.4 x 8 studs. The 5.5-stud scale mannequin and preview cameras are excluded from FBX.

The Blender file retains editable meshes, text, colors and separate groups. The previous version remains in its original saved file and in a separate Blender scene.

This is art. Leaderboard rows are blank placeholders; the game must provide live player rankings. Most Levels, Most Money, Most Damage and Most Rebirths each have a named DisplaySurface. AFK multipliers and rebirth requirements are visual placeholders, not game-balance changes. No runtime scripts, datastore rankings, prompts or purchases are added by this FBX.

Shop groups are WeaponStore, UpgradeStore and SellStore. Rename WeaponStore_Counter and UpgradeStore_Counter to Counter after importing, keeping each inside its corresponding Model. Stabilizer contains CoreMount. Reuse the existing ore buyer NPC rather than the decorative booth vendor. Runtime ore blocks and the full-depth shaft remain owned by your existing game; the exported 24-stud shaft is an illustrative shell only.

The ground uses separate slabs so the mine opening has no collision cap. Review Studio mesh collision and disable collisions on small scenery, lettering and displays as appropriate. Test with a player before replacing the existing lobby.

Files: compact-overview.png, spawn-view.png, player-view.png, EnergyCoreLobby-V2.blend, EnergyCoreLobby-V2-Colored.fbx. build_compact_lobby.py rebuilds the art; export_compact_lobby.py exports and checks the FBX.
