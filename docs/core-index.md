# Core index

`StarterGui.CoreIndexGui` is the editable menu. `IndexButton` is an ImageButton using the texture `97629410614205` from the user's decal `91670004464678`; its SourceDecalId attribute records the original. Edit its position, size, image and TitleLabel in Studio. Run `studio/build_core_index.lua` in Edit mode to author the GUI; re-running preserves edits.

`Shade.Panel` contains Header/CloseButton, CountLabel, ProgressBar/Fill, Cards and HintLabel. Cards are named Spark, Copper, Static, Quartz, Lightning, Storm, Ion and Reactor, with NameLabel, Preview, RarityLabel and IncomeLabel. CoreIndexController arranges two columns in narrow panels and four in wider panels; the card grid scrolls vertically. Positions and sizes use Scale. Button activation opens/closes, the X closes, and Escape closes.

Unknown cores show a black silhouette, ??? and their rarity. Discovered cores show their colored model, name, rarity and base earnings per second. Previews use CoreVisuals, so custom `ReplicatedStorage.CoreModels` automatically replace placeholders. The displayed rates describe future reactor output, not income from carrying a Tool.

PlayerDataTemplate.DiscoveredCores records permanent discoveries, independent of inventory. PlayerDataService.Load backfills existing StabilizedCores and publishes DiscoveredCore_<key> attributes. Claiming a stabilized result calls PlayerDataService.DiscoverCore on the server. Installing or removing a core later must not clear these discoveries; other server reward paths should call DiscoverCore as well. No client message can unlock an index entry on the server.

Studio persistence remains disabled by the existing Config. Production saves include DiscoveredCores; a live DataStore round-trip is still untested. UI checks passed for opening, silhouette state, a discovered Storm's name and $100/sec rate, completion count, and two-column layout in a narrow panel. Server data checks passed for discovery records, repeated discoveries and invalid keys. The resolved book icon renders correctly in Play.
