# Underground progression

The personal mine is 12×12×60 cells, six studs per cell, 360 studs deep. Shared shell walls and bedrock are extended to match; run `studio/expand_mine_layers.lua` in Edit mode after Rojo sync for persistent authoring. Layer discovery popups are removed.

| Layer | Depth (studs) | Block health | Core drop per broken block | Charged grade given a core |
|---|---:|---:|---:|---:|
| Stone Circuit | 0–36 | 150 | 1.5% | 0% |
| Charged Cavern | 36–96 | 750 | 2.5% | 35% |
| Crystal Grid | 96–168 | 3,500 | 3.5% | 60% |
| Plasma Veins | 168–252 | 15,000 | 4.5% | 80% |
| Reactor Depths | 252–360 | 60,000 | 5.5% | 95% |

Bounds describe cell extents; a block center belongs to the containing row. `Config.Layers.EndDepth` uses row numbers. These explicit boundaries drive rendering, authoritative health, ore rewards, core discoveries. Tune health and odds there. The existing first-core guarantee and pending-core limit still apply.

Plasma Ore sells for $40; Reactor Shards sell for $75. Existing material values are unchanged. New materials use the existing inventory, pickups and sell system. This is provisional balancing; weapons increase power per training click and chain upgrades damage extra nearby blocks after the target breaks.

Only surface and exposed neighbor blocks are instantiated locally. Startup uses 144 ore parts rather than 8,640. Destroying any cell reveals its surviving six neighbors; the server still keeps the full logical mine and validates accessibility. Reset clears the removed-cell ledger and renders the surface again. Large excavations can still create many exposed parts; device performance needs profiling.

Validation: Rojo build and whitespace checks pass. Studio client checks exercise all 8,640 coordinate round trips, layer boundaries and material definitions, a full-depth shaft, health updates, destroyed-cell handling, reset and bedrock alignment. A live client-to-server mining test destroyed a starter cell and exposed the next row. An invisible legacy SpawnLocation was blocking center shots; WorldService now disables its CanQuery when retiring it. Run `tests/deep_mine.client.lua` in the client Command Bar in Play; stop afterward to clear test changes. Mobile performance and long-session economy balancing remain untested.

Mining balance: damage equals trained power exactly: 36 power deals 36 damage, 100 power deals 100 damage. Zero power deals no damage; train before mining. Layer health is fixed at 150 / 750 / 3,500 / 15,000 / 60,000, so 36 power takes five hits to break starter stone; 1,000 power takes four hits to break crystal blocks. Damage pulses are limited to one every 0.4 seconds on both client and server, while the electrical beam continues animating smoothly. Breaking a primary block chains 75% of current damage to up to five neighbors, respecting their remaining health and layer toughness. Only destroyed blocks create drops, discovery attempts and mined credit; secondary breaks do not trigger another chain. Buried partial damage is remembered locally until the cell becomes exposed. Tune `Config.Mining` for interval and chain multiplier; edit `Config.Layers` for fixed block health.

Validation: Studio checks previously passed for five-neighbor chain limits across the stone/cavern boundary, weakened-neighbor breaks, mine reset, rapid multi-target RemoteEvent spam limiting, and mining resuming after the cooldown. Client checks passed for buried partial-health persistence without premature exposure and reset cleanup. Balance still needs playtesting for feel.

Direct-power balance validation: Studio server checks passed for exact power-to-damage equality, all five fixed layer health values, five-hit starter stone at 36 power, four-hit crystal at 1,000 power, health-respecting chain damage, and mine reset. Client starter blocks show 150 current/max health.
