# Courtyard lobby layout

Structural layout inspired by the supplied simulator courtyard references:
a wide grey central avenue, green side lawns, orange terraced cliffs, and
grass-capped perimeter shelves. All surfaces now use smooth flat colours;
the stud patterns have been removed. No future gameplay objects are built.

The **72 x 72-stud mine is in the front forecourt**, outside the courtyard,
at Blender `(0, -212, 0)` / Roblox `(0, 0, 212)`. The center of the lobby stays
open. A 72-stud-wide passage through the front wall connects the two areas.
The opening has walkways around all four sides, four shaft walls down to
720 studs, and bottom bedrock. No floor crosses the mine opening. Roblox's
gameplay will supply the mineable blocks when this layout is integrated.
The mine forecourt is surrounded on its three outer sides by the same orange
terraced cliffs, green shelves and grass crowns as the main courtyard. These
walls rise 34–40 studs. The 72-stud lobby connection remains open.

Reserved foundations:

| Area | Count | Footprint per object |
| --- | --- | --- |
| AFK stations | 10, two rows of five at the far end | 28 x 20 studs |
| Weapon buying shop | 1, left side | 42 x 30 studs |
| Weapon upgrade shop | 1, right side | 42 x 30 studs |
| Selling shop | 1, right side | 42 x 30 studs |
| Core stabilizer | 1, left side | 42 x 30 studs |
| Leaderboards | 4, two on each side near the front | 38 x 12 studs |
| Mine | 1, in the front forecourt | 72 x 72 studs |

The interior is 224 x 288 studs. The main avenue has 72 studs of clear paving,
and side access paths have 18.8 studs of clear paving. AFK foundations have
12-stud gaps between columns and between rows. All 18 reserved footprints
plus the mine are checked for overlaps. Their exact coordinates are in `layout-manifest.json`.

Open `EnergyCore-CourtyardLayout.blend`. Collections are separated into:

- **LAYOUT - Export This**: editable floor plates, reserved paving foundations,
  path trim, orange cliffs and grass shelves.
- **PLANNING GUIDES - Do Not Export**: temporary labels and placement markers.
  Hide this collection for a clean environment view.
- **CAMERAS AND LIGHTS - Do Not Export**: overview, top-down plan and eye-level
  review cameras.

The separate FBX exports the layout collection only. It excludes guide text,
markers, lights, cameras, archived pre-mine floor geometry, and the assets from
earlier Blender scenes. Smooth colours are stored in materials and vertex
colours. Import with vertex colours enabled. Old stud PNGs remain in `textures/`
as unused earlier assets; they are not referenced by the active layout or FBX.
Confirm a 72-stud opening after import; importer unit settings can change scale.

No shops, AFK machines, stabilizer machinery, leaderboard panels, NPCs, mine
blocks, trees, decorations or functional scripts are included. The current
Studio map is now installed as `Workspace.Lobby` plus `Workspace.MineArea`.
Its mine opening is aligned to the existing gameplay grid at world origin;
the rest of the courtyard is translated with it. A hidden spawn is on the main
path. Previous map objects and 15 obsolete world-sign GUIs are preserved in
`ServerStorage.OLD_Lobby_BEFORE_COURTYARD_DELETE_WHEN_READY`.
`LayoutOnly = true` on Lobby suppresses automatic placeholder shops and the
fallback stabilizer until the real objects are authored. An empty authored
AFKTrainingStations folder prevents the old AFK machines from respawning.

Studio Play checks passed for spawning, all 18 reserved foundations, floor
collision on the access routes, the open 72-stud shaft, all 144 top mining
cells, walking onto the mine, and a server-accepted mining hit after training.
Previous Blender scenes remain preserved.

Authoring sequence: `build_lobby_layout.py`, `add_mine_and_smooth.py`, then
`move_mine_to_front.py`, then `surround_mine.py`. The final `.blend` and FBX
already contain all changes.
