# Core index

Current layout: a dark full-width card grid, purple header with an internal book
icon, centered Index title and internal close button. Rarity appears above each
core preview and its name below; undiscovered cores show a pink question mark.
The footer shows the existing +5% cash milestone per two discoveries and current
cash bonus. Four columns and two rows stay consistent on desktop and landscape phones; the whole panel scales to fit the safe screen area. The old
details sidebar and progress bar are hidden. Run `studio/style_index_gui.lua` in
the Edit Command Bar after Rojo sync to author the editable layout in StarterGui.

`StarterGui.CoreIndexGui` is the editable menu. `IndexButton` is an ImageButton using the texture `97629410614205` from the user's decal `91670004464678`; its SourceDecalId attribute records the original. Edit its position, size, image and TitleLabel in Studio. Run `studio/build_core_index.lua` in Edit mode to author the GUI; re-running preserves edits.

`Shade.Panel` contains Header/CloseButton, CountLabel, ProgressBar/Fill, Cards and HintLabel. Cards are named Spark, Copper, Static, Quartz, Lightning, Storm, Ion and Reactor, with NameLabel, Preview, RarityLabel and IncomeLabel. IndexMenuStyle fits the 800 by 473 desktop composition with one UIScale, keeping all eight cards visible. Cards, text, icons and spacing scale together. Button activation opens/closes, the X closes, and Escape closes.

Unknown cores show a black silhouette, ??? and their rarity. Discovered cores show their colored model, name, rarity and base earnings per second. Previews use CoreVisuals, so custom `ReplicatedStorage.CoreModels` automatically replace placeholders. The displayed rates describe future reactor output, not income from carrying a Tool.

PlayerDataTemplate.DiscoveredCores records permanent discoveries, independent of inventory. PlayerDataService.Load backfills existing StabilizedCores and publishes DiscoveredCore_<key> attributes. Claiming a stabilized result calls PlayerDataService.DiscoverCore on the server. Installing or removing a core later must not clear these discoveries; other server reward paths should call DiscoverCore as well. No client message can unlock an index entry on the server.

Studio persistence remains disabled by the existing Config. Production saves include DiscoveredCores; a live DataStore round-trip is still untested. UI checks passed for opening, silhouette state, a discovered Storm's name and $100/sec rate, completion count, and two-column layout in a narrow panel. Server data checks passed for discovery records, repeated discoveries and invalid keys. The resolved book icon renders correctly in Play.
