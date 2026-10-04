# Stabilizer integration

Your friend's machine should be a Model named `Stabilizer` containing an anchored BasePart named `CoreMount`, or a Model with `IsStabilizer = true`. The service adds the interaction prompt. Set `OwnerUserId` on the island or machine on the server; both interaction validation and local displays check ownership. A purple test station at `(20, 1, 145)` appears only if no authored station exists.

Hold an Unknown Core and use the machine's prompt to place it directly. Placement immediately starts stabilization: Cracked takes 30 seconds, Charged 120 seconds. Placed cores cannot be returned or canceled. Saved unstarted jobs begin automatically when loaded; running jobs keep their existing result and finish time. The machine has one interaction prompt; old Odds and Return Core prompts are disabled. FinishAt is a saved absolute Unix timestamp, so leaving does not pause the timer. There is one job per player.

When ready, use Reveal Core at the machine. The server awards one result to the hotbar and clears the job before sending the presentation event with the station ID. The local animation cycles black 3D core silhouettes above that station, slows down, and reveals the authoritative winner with name, rarity, and base reactor earnings per second. The result stays above the machine for three seconds. There is no rolling ScreenGui. Walking away does not cancel or consume the awarded core; removing the station cleans up the presentation. Results are queued if multiple reveal events arrive.

A View Core Odds button appears only within 13 studs of an accessible machine. It opens an editable panel with exact weighted percentages for Cracked and Charged and closes when leaving proximity. These are calculated from the same tables as the server roll. The panel is informational and does not trigger or choose rewards.

Paste `studio/build_stabilizer_world_roll.lua` in Edit mode. Edit `StarterGui.StabilizerOddsGui.NearbyOddsButton` and `Shade.Panel` for the odds UI. Rows are named after the core keys, with NameLabel and ChanceLabel children. Sizes and positions use Scale. The previous `StabilizerGui` remains disabled as a reference and is no longer used by the controller. Edit `ReplicatedStorage.UITemplates.CoreBillboard` for world reveal and held-core labels, or StabilizerStatusBillboard for machine instructions.

Eight provisional outcomes, grade weights, timers and `IncomePerSecond` values live in `Shared.StabilizerDefinitions`: Spark $2/sec, Copper $4/sec, Static $10/sec, Quartz $25/sec, Lightning $45/sec, Storm $100/sec, Ion $300/sec, Reactor $1,000/sec. Rates represent future installed reactor output; hotbar Tools do not earn cash. Stabilized cores can be sold through the Ore Buyer with a price confirmation; see `docs/core-selling.md`. Reactor installation, income collection, mutations, islands and teleports remain separate steps.

Add custom Models under `ReplicatedStorage.CoreModels` named Spark, Copper, Static, Quartz, Lightning, Storm, Ion and Reactor. These replace temporary parts in both the world roll and held Tool. Silhouettes strip textures and effects. Models should contain visual parts and no behavior scripts.

Studio persistence is disabled in Config. Production DataStore round-trip and multi-player island integration remain untested.

The world reveal adds a short suspense windup, spring pop, rarity-colored light and expanding rings, white flash, sparkle burst, and bouncing result labels. Effects clean up after the result fades.

Validation: Studio client presentation tests passed for Storm and Reactor, winner and earnings labels, burst effects, and animation cleanup. Clicking View Core Odds opened the correct Cracked percentages. Full server prompt-to-reward flow and mobile odds-panel testing remain pending.

Automatic stabilization validation: Studio server checks passed for matching power/XP on all six weapons, level rollover, legacy waiting-job migration, immediate placement consumption and timers, rejected return/zap actions, blocked early claims, and exactly one completed reward. Client checks passed for immediate +3 XP prediction and removal of the Return Core GUI. The reveal test accelerated the finish timestamp; production persistence remains untested.

Core mutations are rolled once at stabilization start and retained in the saved job/inventory. Use `StabilizerDefinitions.Income(coreRecord)` for future reactor income so mutation bonuses are included. Existing odds UI remains unchanged. See `docs/core-mutations.md` for variants and integration helpers.
