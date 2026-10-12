# Energy Core lobby art

Open EnergyCoreLobby.blend to edit. EnergyCoreLobby.fbx contains the colored geometry and mesh lettering for Roblox Studio 3D Importer. Original Blender scene objects are preserved in a hidden collection and excluded from export.

The mine opening is 72 by 72 Blender units at origin. Z is up in Blender; FBX exports Y up. Check imported scale against a 72-stud opening before placing the model. The modeled pit is 30 studs deep for presentation; the existing game owns the full-depth shaft and generated mining blocks.

This is a visual model, not a scripted Roblox lobby. It does not replace the project source or add AFK, shop, RNG, collision or prompt behavior. Import and review collision settings in Studio. Runtime-generated ore should remain separate.

Collections separate each shop, each AFK station, Stabilizer, MineArea, terrain and decorations. Mesh export flattens collection structure; group the imported components into the game Models. Keep WeaponStore and UpgradeStore with a Counter BasePart, and Stabilizer with a CoreMount BasePart. Exported counter meshes have shop-prefixed names; rename them Counter when integrating. Reuse the existing Ore Buyer NPC.

AFK multiplier and rebirth lettering are editable art placeholders. Adjust them to the configured game balance. Preview: lobby-preview.png. Rebuild script: build_lobby.py.
