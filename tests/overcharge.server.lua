-- Execute as a temporary server Script in Studio Play mode with persistence disabled.
-- Command Bar require uses a separate cache, so run this Source inside a Script.
local Shared = game.ReplicatedStorage.Shared
local Services = game.ServerScriptService.Server.Services
local Data = require(Services.PlayerDataService)
local Definitions = require(Shared.OverchargeDefinitions)
local Tools = require(Services.CoreToolService)
local Training = require(Services.TrainingService)
local p = game.Players:GetPlayers()[1]
assert(p and not require(Shared.Config).Persistence.EnableInStudio, "Use temporary Studio profiles")
local d = Data.Get(p)
assert(d.Overcharges == 0, "Start a fresh test session")
assert(not Data.Overcharge(p, 0), "Unqualified run must fail")
for _, key in {"Level", "Power", "Cash"} do
	d.Level, d.Power, d.Cash = 25, 10000, 10000
	d[key] -= 1
	assert(not Data.Overcharge(p, 0), "Each requirement must be checked")
end
d.Level, d.Power, d.Cash = 25, 10000, 10000
d.EquippedWeapon = "Plasma Cannon"
d.Weapons["Plasma Cannon"] = true
d.Upgrades.Storage, d.Upgrades.ChainTargets, d.Upgrades.Magnet = 3, 2, 1
d.BackpackCapacity = 125
d.Materials = {["Copper Ore"] = 8}
d.UnknownCores = {{Id = "test-unknown", Grade = "Cracked"}}
d.StabilizedCores = {{Id = "test-spark", Type = "Spark"}, {Id = "test-storm", Type = "Storm"}}
d.Stabilizer = {State = "Running", FinishAt = os.time() + 1000, Result = "Spark"}
d.Reactor = {Slots = {{Id = "installed", Type = "Copper"}}}
Data.DiscoverCore(p, "Spark")
local unknown, stabilized, job, reactor, index = d.UnknownCores, d.StabilizedCores, d.Stabilizer, d.Reactor, d.DiscoveredCores
assert(not Data.Overcharge(p, 1) and not Data.Overcharge(p, "0"), "Forged counts must fail")
assert(Data.Overcharge(p, 0))
assert(d.Overcharges == 1 and d.Power == 0 and d.XP == 0 and d.Level == 1 and d.Cash == 0)
assert(d.EquippedWeapon == "Scrap Zapper" and not d.Weapons["Plasma Cannon"] and d.Weapons["Scrap Zapper"])
assert(d.BackpackCapacity == 50 and next(d.Materials) == nil)
for _, level in d.Upgrades do assert(level == 0) end
assert(d.UnknownCores == unknown and d.StabilizedCores == stabilized and d.Stabilizer == job and d.Reactor == reactor and d.DiscoveredCores == index)
assert(p:GetAttribute("PowerMultiplier") == 1.5 and p:GetAttribute("CashMultiplier") == 1.2)
assert(not Data.Overcharge(p, 0), "Replay must fail")
Data.Train(p, 1)
assert(d.Power == 1.5 and d.XP == 1.5, "Fractional starter gains must survive")
Training.Handle(p, {Sequence = 2, Epoch = 0})
assert(d.Power == 1.5 and Data.GetTrainingSequence(p) == 1, "Old training inputs must fail after reset")
d.Materials = {["Copper Ore"] = 5}
local payout, count = Data.SellAllMaterials(p)
assert(payout == 18 and count == 5 and d.Cash == 18, "Ore bonus must apply")
Tools.Sync(p)
local coreTool
for _, tool in p.Backpack:GetChildren() do if tool:GetAttribute("CoreId") == "test-spark" then coreTool = tool end end
assert(coreTool)
p.Character.Humanoid:EquipTool(coreTool)
local sold, price = Data.SellHeldCore(p, "test-spark")
assert(sold and price == 144, "Held core bonus must apply")
d.StabilizedCores = {{Id = "bulk-storm", Type = "Storm"}, {Id = "bulk-copper", Type = "Copper"}}
local summary = Data.GetCoreSaleSummary(p)
assert(summary.SellValue == 7488)
local all, total = Data.SellAllCores(p, summary.Cores)
assert(all and total == 7488, "Bulk core bonus must apply once")
local needed = Definitions.Requirements(1)
assert(needed.Level == 30 and needed.Power == 16000 and needed.Cash == 16000)
d.Level, d.Power, d.Cash = needed.Level, needed.Power, needed.Cash
assert(Data.Overcharge(p, 1))
assert(p:GetAttribute("PowerMultiplier") == 2 and p:GetAttribute("CashMultiplier") == 1.4)
print("PASS: requirements, replay rejection, reset/retention, fractional power+XP, old training rejection, ore/held/bulk cash bonuses and second Overcharge")
-- Fresh fixture for a real GUI confirmation and server reset test.
Data.Load(p)
d = Data.Get(p)
d.Level, d.Power, d.Cash = 25, 10000, 10000
d.Materials = {["Copper Ore"] = 5}
d.Upgrades.Storage, d.Upgrades.ChainTargets, d.Upgrades.Magnet = 2, 2, 2
d.BackpackCapacity = 100
d.EquippedWeapon = "Plasma Cannon"
d.Weapons["Plasma Cannon"] = true
d.UnknownCores = {{Id = "ui-unknown", Grade = "Cracked"}}
d.StabilizedCores = {{Id = "ui-storm", Type = "Storm"}}
d.Stabilizer = {State = "Running", FinishAt = os.time() + 1000, Result = "Spark"}
Data.DiscoverCore(p, "Storm")
for key, value in {Level = 25, Power = 10000, Cash = 10000, BackpackUsed = 5, BackpackCapacity = 100, EquippedWeapon = "Plasma Cannon", OwnsWeapon_PlasmaCannon = true, UnknownCoreCount = 1, StabilizedCoreCount = 1, StorageLevel = 2, ChainLevel = 2, MagnetLevel = 2, BlastCount = 3, MagnetRange = 30} do p:SetAttribute(key, value) end
Data.PublishProgress(p)
Tools.Sync(p)
require(Services.WorldService).GiveEquippedTool(p, p.Character, "Plasma Cannon", true)
require(Services.MineService).Damage(p, 1, 10000)
print("READY: qualified run with cores, ores, upgrades and Plasma Cannon for GUI test")
