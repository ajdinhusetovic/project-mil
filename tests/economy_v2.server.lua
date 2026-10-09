-- Temporary Studio server Script; persistence must be disabled. Stop after running.
local Shared = game.ReplicatedStorage.Shared
local Services = game.ServerScriptService.Server.Services
local Config = require(Shared.Config)
assert(not Config.Persistence.EnableInStudio, "Use temporary Studio profiles")
local Data = require(Services.PlayerDataService)
local Rebirth = require(Shared.OverchargeDefinitions)
local Cores = require(Shared.StabilizerDefinitions)
local Migration = require(Shared.EconomyMigration)
local Progression = require(Shared.Progression)
local Weapons = require(Shared.WeaponDefinitions)
local Grid = require(Shared.MineGrid)
local Mine = require(Services.MineService)
local player = game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait()
repeat task.wait() until Data.Get(player)
task.wait(2)
local legacy = {StabilizedCores = {{Id = "a", Type = "Spark"}},
	Reactor = {Slots = {{Id = "b", Type = "Reactor"}, {Id = "a", Type = "Spark"}}, Stored = 1000000}}
Migration.Apply(legacy)
assert(#legacy.StabilizedCores == 2 and next(legacy.Reactor) == nil)
Migration.Apply(legacy)
assert(#legacy.StabilizedCores == 2, "Migration must not duplicate cores")
assert(#Config.WeaponOrder == 15 and #Config.Layers == 9 and Config.Depth == 120)
local previousPrice, previousGain, previousLevel = -1, 0, 0
for _, name in Config.WeaponOrder do
	local weapon = Weapons[name]
	assert(weapon.Price > previousPrice and weapon.PowerPerClick > previousGain and weapon.Level > previousLevel)
	previousPrice, previousGain, previousLevel = weapon.Price, weapon.PowerPerClick, weapon.Level
end
local previousEnd, previousHealth = 0, 0
for _, layer in Config.Layers do
	assert(layer.EndDepth > previousEnd and layer.Health > previousHealth)
	assert(Grid.Layer(previousEnd + 1) == layer and Grid.Layer(layer.EndDepth) == layer)
	previousEnd, previousHealth = layer.EndDepth, layer.Health
end
assert(previousEnd == Config.Depth)
local oldPower, oldCash, oldLevel = 0, 0, 0
for count = 0, 100 do
	local power, cash = Rebirth.Multipliers(count)
	local level = Rebirth.Requirements(count).Level
	assert(power > oldPower and cash > oldCash and level > oldLevel)
	oldPower, oldCash, oldLevel = power, cash, level
end
assert(require(Shared.AFKTrainingDefinitions).Interval == 0.5)
assert(Progression.MiningMultiplier(120) == 8)
assert(Progression.MiningMultiplier(120) * Config.Mining.ChainTrainingMultiplier == 1.2)
assert(Cores.SaleValue({Type = "Spark", Depth = 6}) == 150)
assert(Cores.SaleValue({Type = "Spark", Depth = 720, Mutation = "Overloaded"}) == 300000)
assert(require(Shared.ReactorRules).Rate({Slots = {{Type = "Reactor"}}}) == 0)
local data = Data.Get(player)
assert(not Data.CollectReactor(player) and not Data.ChangeReactor(player, "ReactorEquipBest"))
local cores, job, discoveries = data.StabilizedCores, data.Stabilizer, data.DiscoveredCores
for count = 0, 2 do
	assert(data.Overcharges == count)
	data.Level, data.Cash, data.Power = Rebirth.Requirements(count).Level - 1, 0, 0
	assert(not Data.Overcharge(player, count), "Below-level rebirth must fail")
	data.Level += 1
	data.EquippedWeapon = "Omega Core"
	data.Weapons["Omega Core"] = true
	data.Upgrades.Storage, data.Upgrades.ChainTargets, data.Upgrades.Magnet = 16, 8, 10
	data.BackpackCapacity = 850
	data.Materials = {["Omega Ore"] = 50}
	assert(not Data.Overcharge(player, count + 1), "Forged run must fail")
	assert(Data.Overcharge(player, count), "Zero cash and power must allow qualified level")
	assert(data.Power == 0 and data.XP == 0 and data.Cash == 0 and data.Level == 1)
	assert(data.EquippedWeapon == "Scrap Zapper" and not data.Weapons["Omega Core"])
	assert(data.BackpackCapacity == 50 and next(data.Materials) == nil)
	for _, value in data.Upgrades do assert(value == 0) end
	assert(data.StabilizedCores == cores and data.Stabilizer == job and data.DiscoveredCores == discoveries)
	assert(not Data.Overcharge(player, count), "Rebirth replay must fail")
	local expectedPower, expectedCash = Rebirth.Multipliers(count + 1)
	local _, gain = Data.Train(player)
	assert(gain == expectedPower and data.Power == expectedPower)
	assert(player:GetAttribute("CashMultiplier") == expectedCash)
end
data.StabilizedCores = {{Id = "sale-a", Type = "Spark", Depth = 6}, {Id = "sale-b", Type = "Copper", Depth = 42}}
local summary = Data.GetCoreSaleSummary(player)
assert(summary.SellValue == 1500, "Third rebirth doubles surface + cavern core sales")
local sold, payout = Data.SellAllCores(player, summary.Cores)
assert(sold and payout == 1500 and #data.StabilizedCores == 0)
assert(not Data.SellAllCores(player, summary.Cores), "Core sales must not replay")
Mine.Create(player)
local id = Grid.Id(1, 120, 1)
assert(Mine.GetHealth(player, id) == Config.Layers[9].Health)
assert(Mine.Damage(player, id, Config.Layers[9].Health) == 0)
print("ECONOMY V2 PASS: migration, 15 weapons, nine layers, three rebirths, reset/retention, sales and no passive income")
-- Return to a fresh profile for manual UI checks.
Data.Load(player)
require(Services.CoreToolService).Sync(player)
require(Services.WorldService).GiveEquippedTool(player, player.Character, "Scrap Zapper", true)
