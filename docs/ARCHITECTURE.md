# Energy Core architecture

The current milestone is the saved mining vertical slice. Every gameplay reward is decided on the server. Clients handle input, rendering, animation, and UI.

## Source layout

```text
src/
  shared/
    Config.luau                  feel-test and temporary balance values
    MaterialDefinitions.luau     material colors and sell values
    PlayerDataTemplate.luau      versioned saved-data shape
  server/
    init.server.luau             networking and mining request routing
    Services/
      PlayerDataService.luau     load, reconcile, mutate, publish, save
      MineService.luau           per-player block health and shot validation
      WorldService.luau          surface shell, spawn, starter tool
  client/
    init.client.luau             small client bootstrap
    Controllers/
      MiningController.luau      current mining input, effects, and temporary HUD
      MineRenderer.luau          locally rendered personal block grid
      SurfaceUIController.luau    cash, bag, upgrade feedback
studio/
  README.md                      editable-UI Command Bar workflow
```

`MiningController` will be split further into `EffectsController` and `UIController` when the production HUD replaces the temporary feel-test HUD. Doing that at the same time prevents us from maintaining two UI APIs.

## Saved profile

`PlayerDataTemplate` already reserves the fields needed by the GDD. Studio DataStore access is disabled by default in `Config.Persistence`, so local sessions use safe temporary profiles. Published games use `EnergyCore_PlayerData_v1`.

All changes to cash, materials, weapons, upgrades, cores, and reactor state must go through `PlayerDataService`. Client requests never send reward amounts.

## Model contract

Models can replace placeholders without changing gameplay code. Keep these names and attachments:

- Weapon `Tool`: its definition ID as the Tool name for now.
- Weapon main part: `Handle`.
- Electricity origin attachment: `Handle/Muzzle`.
- Mine block models: require a targetable primary `BasePart`; visuals may be replaced client-side later.
- Surface stations should use `CollectionService` tags instead of scripts embedded in models.

## Next implementation slice

1. Add Power/XP training and one weapon upgrade.
2. Replace the remaining temporary mining HUD with editable production UI.
3. Verify leave/rejoin persistence in a published test place.
