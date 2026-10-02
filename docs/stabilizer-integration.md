# Stabilizer integration

The current fallback is one purple test part near the lobby spawn, at `(20, 1, 145)`. It is created during Play only when no authored station is present.

Your friend's machine should be a Model named `Stabilizer`, containing an anchored BasePart named `CoreMount`. Alternatively set the Model attribute `IsStabilizer` to true. The placed core appears 1.5 studs above the mount's center. Keep the mount directly inside that model and leave the core reachable and visible from the front. The service adds a ProximityPrompt automatically.

When islands are scripted, assign their `OwnerUserId` attribute on the server. The service checks that attribute on the mount and all its ancestors before allowing interaction. Public test stations show each player's own job locally; production island ownership still requires the island system.

There is one saved stabilizer slot per player. Hold an Unknown Core, press E at the station, and choose Place Held Core. Equip an electrical weapon and channel it into the placed core to start. Cracked takes 30 seconds; Charged takes 120. An unstarted core can be returned to the hotbar if there is storage room. Active jobs cannot be cancelled. FinishAt is an absolute Unix timestamp, so leaving does not pause the timer. The existing player data save path stores the job and its rolled result.

Press E and Reveal Core when ready. The server awards exactly one result, clears the job, and creates the hotbar Tool before sending the animation event. Closing or disconnecting during the visual cannot consume the reward. The client spins decorative black silhouettes, slows to the authoritative winner, and reveals its color and rarity. Exact grade odds are accessible through View Odds.

Eight starter outcomes and provisional weights/timers are in `src/shared/StabilizerDefinitions.luau`. Add custom Models under `ReplicatedStorage.CoreModels`, named `Spark`, `Copper`, `Static`, `Quartz`, `Lightning`, `Storm`, `Ion`, and `Reactor`. These replace the temporary parts in both the reveal and the held Tool. Models should contain welded visual parts and no behavior scripts. The reveal strips textures/effects when rendering a silhouette.

The GUI is authored in StarterGui through `studio/build_stabilizer_gui.lua`; its card template, buttons, and layout remain editable. Rojo owns behavior and shared builders, not the authored GUI.

Validation: Rojo build; Studio transaction checks for distance, ownership, placement, cancellation, charge, 30-second timer calculation, early/duplicate claim rejection, stored winner matching the awarded Tool; visible spinning silhouettes and colored result; actual station prompt, GUI placement, exact Charged odds, and weapon input starting the two-minute timer. Timer completion was accelerated in the transaction test only. Production DataStore round-trip and multi-player island integration remain untested. Studio DataStore saving is currently disabled in Config.

Selling stabilized cores, reactor installation/income, mutations, island assignment, and teleport menu are separate next steps.

Core base reactor rates are configured with `IncomePerSecond` in `StabilizerDefinitions`: Spark $2/sec, Copper $4/sec, Static $10/sec, Quartz $25/sec, Lightning $45/sec, Storm $100/sec, Ion $300/sec, Reactor $1,000/sec. These provisional rates are displayed on revealed cores and equipped Tools; they do not award cash while held. Reactor installation and collection are still pending.

Paste `studio/build_core_labels_and_signs.lua` in Edit mode to add earnings labels and convert existing lobby signs without rebuilding the map. Edit `ReplicatedStorage.UITemplates.CoreBillboard` (NameLabel, RarityLabel, IncomeLabel) and `StabilizerStatusBillboard` for world labels. The reveal uses `StarterGui.StabilizerGui.Shade.Panel.EarningsLabel`. Templates are cloned at runtime; controllers only set the text/rarity color and visibility. To preview a template, duplicate it onto a Part in Workspace and discard the preview copy afterward.

Billboard `Size` uses Scale measured in studs, with zero pixel offsets. Labels use TextScaled and scale-based bounds. Existing MineGateBeam/SellStand/WeaponStore/UpgradeStore signs remain under `Workspace.Lobby`. The roll's CardTemplate.Size uses scale; Reel.CardGapScale controls spacing, and the reel stays centered automatically during viewport resizing. Re-running the authoring script preserves template edits and signs already converted.
