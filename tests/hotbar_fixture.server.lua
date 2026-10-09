-- Studio-only fixture: run after economy_v2.server.lua, stop to discard it.
local player = game.Players:GetPlayers()[1]
local Services = game.ServerScriptService.Server.Services
local Data = require(Services.PlayerDataService)
assert(not require(game.ReplicatedStorage.Shared.Config).Persistence.EnableInStudio)
local data = assert(Data.Get(player), "Player loading must complete")
assert(data.Reactor.Slots == nil, "Fresh migrated profiles have no reactor slots")
assert(player.Character:FindFirstChild("Scrap Zapper") or player.Backpack:FindFirstChild("Scrap Zapper"), "Starter gun must spawn")
data.UnknownCores = {{Id = "hotbar-unknown", Grade = "Cracked", Depth = 6}}
data.StabilizedCores = {}
for index, key in require(game.ReplicatedStorage.Shared.StabilizerDefinitions).Order do
	table.insert(data.StabilizedCores, {Id = "hotbar-" .. index, Type = key, Depth = 42})
end
require(Services.CoreToolService).Sync(player)
print("HOTBAR FIXTURE: starter gun, one unknown and eight stabilized cores; test equip, scroll, menus and respawn")
