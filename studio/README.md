# Studio Command Bar UI builders

UI is authored in Edit mode and saved in StarterGui. Runtime controllers wait
for these screens; they never build fallback HUDs or manually clone StarterGui.
After syncing the current code, paste [prepare_authored_ui.lua](prepare_authored_ui.lua)
into the Edit Command Bar once before publishing. It preserves existing screens,
adds controls that previously existed only during Play, and hides old launchers.
Changing item slots and popups clone authored templates at runtime.

The colorful lobby has already been created in the current place as editable `Workspace.Lobby`. For a new place, [build_lobby.lua](build_lobby.lua) recreates its grass plaza, paths, blocky trees, orange walls, mine gate, shop stands, sell stand, and spawn. It preserves an existing Lobby. Only the diggable ore blocks are generated during Play because they are personal to each player.

The mine shell has also been saved as editable `Workspace.MineArea`. [build_mine_area.lua](build_mine_area.lua) recreates it in a fresh place and moves the mine gate into it. Edit the deck, cyan rim, walls, bedrock, and entrance here. Keep the 12×12 opening centered at `(0, 0, 0)` and the wall dimensions aligned with `Config.BlockSize` and `Config.Width`; the personal ore grid is still calculated from those values during Play.

Paste [build_surface_hud.lua](build_surface_hud.lua) into Roblox Studio's **Command Bar while not playing**. It creates `StarterGui.SurfaceLoopHUD` with editable cash, bag, and sale feedback. The UI follows the supplied bright simulator reference: thick black outlines, white Fredoka text, vivid gradients, and large readable counters.

Paste [build_progress_hud.lua](build_progress_hud.lua) the same way to create the editable Level, XP, and Power display.

Paste [build_mining_ui.lua](build_mining_ui.lua) in Edit mode to create the editable Materials panel and add `DepthLabel` plus `ReturnButton` to the existing `ProgressHUD`. In the lobby the Power label shows your current power and click gain. Inside the shaft it switches to depth and the Return button; the old top-right Depth/Blocks/Bag test panel is gone. The script preserves an existing MaterialsHUD and existing Depth/Return controls, so you can edit them in Explorer and run it again safely.

Paste [build_feedback_hud.lua](build_feedback_hud.lua) in Edit mode to create `StarterGui.FeedbackHUD`. Its hidden Power, Ore, and Sale TextLabels are editable templates for the animated text effects. Power gains scatter across the screen, ore pickups appear around the center, and sale cash flies toward the money counter. These popups have no background panel; the cash and bag rows pulse when their values increase.

Paste [build_shop_gui.lua](build_shop_gui.lua) in Edit mode to create `StarterGui.ShopGui`. The purple upgrade page and orange weapon page open from their storefront ProximityPrompts. Buying happens only after pressing the green button. The GUI is fully editable in Explorer; the Rojo client controller updates its prices, stats, cash, and owned/equipped state.

Paste [expand_shop_gui.lua](expand_shop_gui.lua) in Edit mode after the shop builder. It preserves the existing ShopGui, adds scrolling catalogs, Chain Targets and Magnet Range upgrades, and six weapon tiers. Each Card remains editable in Explorer. The starter weapon breaks one block; five Chain purchases increase that to six. Weapons share the same temporary tool shape until you add your own Tool models. Later, put a Tool named after a weapon in `ServerStorage.WeaponTools` with a `Handle` BasePart; the server will clone it instead of the placeholder and add a `Muzzle` attachment if needed.

For your lobby map, name the shop Models `UpgradeStore` and `WeaponStore`. Put an anchored BasePart (ideally named `Counter`) inside each model. On Play, the server attaches an **Open shop** ProximityPrompt if you have not placed one, or configures the existing prompt. The temporary part-built storefronts appear only when a named model is missing. Keep the NPC model named `showcase npc` for selling.

Run [setup_sell_npc.lua](setup_sell_npc.lua) once to place `Workspace.showcase npc` at the lobby sell stand and disable its sample conversation. Its model, `ReplicatedStorage.DialogModule`, and `StarterGui.dialog` stay editable in Studio; the source-controlled `NPCSellController` supplies the real sell conversation.

The matching client controller will bind to those names but will not rebuild or restyle the hierarchy. This lets you edit positions, colors, strokes, gradients, and constraints directly in Studio without fighting Rojo.

The builder preserves an existing `SurfaceLoopHUD`, so running it again will not erase your Studio edits. The client waits for the saved screen.

Power also appears above the money counter, with a lightning icon and the same
row styling. It follows the same predicted and server-confirmed stats as the top
Power display. Author the row before Play.
Run [add_surface_power_hud.lua](add_surface_power_hud.lua) in Edit mode to save an
editable `Counters.PowerBar` in StarterGui.

Unknown Cores now appear as server-created Tools in the Roblox hotbar. [build_core_hud.lua](build_core_hud.lua) disables the old CoreHUD if it exists; it no longer builds a HUD.

Paste [build_stabilizer_gui.lua](build_stabilizer_gui.lua) in Edit mode to create editable `StarterGui.StabilizerGui`. `Shade.Panel` contains the station controls, exact odds, `Reel.Track`, and hidden `CardTemplate` with its `CoreViewport` and `RarityLabel`. The client clones the card template for the silhouette spin and colors the winning core at the end. An existing GUI is preserved.

Paste [build_core_labels_and_signs.lua](build_core_labels_and_signs.lua) in Edit mode for core earnings labels and scale-based lobby signs. Edit world templates in `ReplicatedStorage.UITemplates`, reveal earnings in `StarterGui.StabilizerGui.Shade.Panel.EarningsLabel`, and the actual mine/shop/sell signs under `Workspace.Lobby`. Income rates are in `Shared.StabilizerDefinitions`; they represent reactor income after installation, not cash generated by a hotbar Tool.

[build_mobile_mining_hud.lua](build_mobile_mining_hud.lua) creates the editable `StarterGui.MobileMiningHUD` with a centered Crosshair. Phones mine by tapping/holding a visible nearby block directly; the extra zap button has been removed. Mining follows the attacking finger only; camera swipes cancel direct mining, and movement/jump releases do not stop the attack. Outside the mine, a world tap trains on release, while camera swipes do not train.

The current stabilizer uses [build_stabilizer_world_roll.lua](build_stabilizer_world_roll.lua): direct prompt placement/reveal and a 3D silhouette animation above CoreMount. The old StabilizerGui is disabled. The nearby View Core Odds button and odds panel are editable in `StarterGui.StabilizerOddsGui`; world labels still use `ReplicatedStorage.UITemplates.CoreBillboard`. See `docs/stabilizer-integration.md` for model integration.

Run `expand_mine_layers.lua` in Edit mode after Rojo sync to deepen the existing shell. Colors/materials on the existing shaft stay editable.

Run `build_core_index.lua` in Edit mode to create the editable `StarterGui.CoreIndexGui`, including the image button, progress bar and core cards.

Overcharge: paste `studio/build_overcharge_gui.lua` in Edit mode. Edit `StarterGui.OverchargeGui` for the button, rewards, requirements, reset confirmation and celebration text. Balance requirements and permanent multipliers in `Shared.OverchargeDefinitions`.

### AFK charging stations

`build_afk_training.lua` creates `Workspace.AFKTrainingStations` in Edit mode.
Move a whole station Model to move its invisible `Zone` trigger along with it.
Signs are editable under `ChargeBlock.StationSign` (scale-based BillboardGui).
`Title` is authored; `Requirement` updates per player at runtime.
Rewards pulse every 0.5 seconds. The old Power + XP rate label is removed,
including from existing stations when the builder runs.
Tune unlocks/multipliers in `src/shared/AFKTrainingDefinitions.luau`.
Tune the level curve and block-break rewards in `src/shared/Config.luau`.
Players gain both power and XP; manual clicks cannot stack with unlocked AFK stations.

### Responsive menu buttons

Run `build_mobile_menu_hud.lua` in the Edit Command Bar after Rojo sync. Editable
Shop, Rebirth, Index and Teleport buttons live in
`StarterGui.HUDMenuGui.SafeArea.Buttons`. A two-column grid uses safe screen bounds
and adapts to landscape phone screens. Runtime changes grid spacing and placement;
card colors, icons and labels stay authored. Currency counters keep their authored
positions. The HUD Shop button is a placeholder for future gamepasses/products.
Upgrades and Weapons open separately from their respective storefront prompts.
Design responsive UI for landscape play only; do not add portrait-specific layouts.
Rebirth progress averages the three capped requirement ratios, starts at 0%, and
only displays 100% when Level, Power and Cash all qualify.

### Imported ore sizing

`calibrate_block_bodies.lua` measures the connected rock body in the three current
crystal meshes and saves `MiningBodySize`/`MiningBodyOffset` on their Models.
Run it in Edit mode after replacing those assets. Block rendering fits this body
into the cell; pickups still fit the entire mesh. Crystals may extend past the rock.
Buried cells use compact opaque columns so the mine stays solid behind exposed ore.
# Custom hotbar

Run `studio/build_hotbar_gui.lua` in the Edit-mode Command Bar after Rojo syncs.
The editable GUI is `StarterGui.HotbarGui`; change `Bar`, `SlotTemplate`, and the
navigation buttons there. Runtime clones the template for real Backpack/Character
Tools, supports 1–9, click/tap, swipe, wheel and arrow navigation, and hides the bar
for menus and buyer dialogue. Weapons and cores stay server-owned Tools.
