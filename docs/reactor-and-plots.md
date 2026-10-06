# Personal plots and reactor

The teleport menu offers This World (the existing surface lobby) and Your Plot.
Each player receives a separate island clone in Workspace.PlayerPlots. Plots are
released when their owner leaves; their installed cores and bank live in the
existing saved player profile.

## Editable assets

Run `studio/build_island_and_reactor.lua` in the Studio Command Bar in Edit mode
after Rojo connects. It creates only missing assets, preserving your edits:

- StarterGui.TeleportGui: open button and destination menu.
- StarterGui.ReactorGui: reactor menu and hidden CoreCardTemplate.
- ServerStorage.PlotTemplate: editable island with a regular Reactor part.

Replace the Reactor part with your future model named Reactor. Give the model
an anchored BasePart named Interact, or set its PrimaryPart. Keep PlotSpawn as a
BasePart at the arrival location. Keep the template pivot fixed while editing;
the server moves each clone by that pivot. Anchor the island and reactor models.
Keep GUI instance names; controllers bind to those names. All main layout sizes
use scale. Card grids switch to two columns on narrow screens.

## Reactor behavior

Interact with your own reactor to open the menu. Five slots are available.
Equip Best sorts all installed and stored stabilized cores by mutated income,
keeps installed cores first on ties, and installs the top five. Click installed
cores to remove them into your hotbar; click stored cores to install them.
Unknown cores and stabilization jobs cannot be installed.

Installed cores accrue cash while the menu is closed and while mining. Collect
pays the bank with the player's current Overcharge cash multiplier and retains
fractional earnings. Removing or replacing cores first accrues their old rate.
Offline earnings cap at four hours. Slots and bank survive Overcharge. Installed
cores are excluded from hotbar and NPC sales until removed.

Reactor mutations/transfers/collection are server-owned. Requests require a live
character within 14 studs of that player's reactor; other players' plots cannot
be managed. Opening range is 11 studs; walking away closes the menu.

Persistence uses the existing DataStore configuration. Studio profiles remain
temporary with EnableInStudio=false; stopping Play removes test fixtures.

## Validation

`tests/reactor.server.lua` runs as a temporary server Script in Studio Play.
It checks mutation-aware best selection, conservation of core IDs, full/replayed
transfers, hotbar synchronization, accrual before swaps, fractional collection,
cash bonuses, offline cap, teleport/ownership/proximity and Overcharge retention.
The script leaves test cores for interactive menu testing; stop Play afterward.
