-- Run as a temporary ServerScriptService Script in a Studio playtest.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = game.ServerScriptService.Server.Services
local Data = require(Services.PlayerDataService)
local Training = require(Services.TrainingService)
local AFK = require(Services.AFKTrainingService)
local Definitions = require(ReplicatedStorage.Shared.AFKTrainingDefinitions)
local Weapons = require(ReplicatedStorage.Shared.WeaponDefinitions)
local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
repeat task.wait() until Data.Get(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
task.wait(1)
local profile = Data.Get(player)
local root = player.Character.HumanoidRootPart
local saved = { CFrame = root.CFrame, Anchored = root.Anchored, Power = profile.Power, XP = profile.XP, Level = profile.Level, Overcharges = profile.Overcharges, Weapon = profile.EquippedWeapon }
root.Anchored = true
local now = os.clock() + 1000
local function enter(id)
	AFK.Release(player)
	local station = workspace.AFKTrainingStations[id]
	root.CFrame = station.Zone.CFrame
	now += 10
	return station
end
local ok, err = pcall(function()
	profile.Power, profile.XP, profile.Level = 0, 0, 1
	profile.EquippedWeapon, profile.Overcharges = "Scrap Zapper", 0
	enter("Charged")
	assert(not AFK.Step(player, now), "Locked station awarded training")
	assert(player:GetAttribute("AFKStation") == nil and profile.Power == 0)
	enter("Starter")
	assert(not AFK.Step(player, now), "Entry must wait for the first pulse")
	assert(player:GetAttribute("AFKStation") == "Starter")
	assert(Definitions.Interval == 0.5)
	assert(not AFK.Step(player, now + 0.25))
	local success, gain = AFK.Step(player, now + 0.5)
	assert(success and gain == 1 and profile.Power == 1 and profile.XP == 1)
	for _ = 1, 20 do assert(not AFK.Step(player, now + 0.5)) end
	assert(profile.Power == 1, "Repeated checks must not duplicate rewards")
	local sequence = Data.GetTrainingSequence(player) + 1
	Training.Handle(player, { Epoch = Data.GetProgressEpoch(player), Sequence = sequence })
	assert(profile.Power == 1 and Data.GetTrainingSequence(player) == sequence, "Manual clicks must be rejected and acknowledged")
	profile.Overcharges, profile.EquippedWeapon = 2, "Arc Pistol"
	enter("Charged")
	AFK.Step(player, now)
	local awarded, amount = AFK.Step(player, now + 1)
	assert(awarded and amount == Weapons["Arc Pistol"].PowerPerClick * 2 * 1.5)
	assert(profile.Power == 1 + amount and profile.XP == 1 + amount)
	profile.Overcharges = 4
	enter("Supercharged")
	AFK.Step(player, now)
	local _, triple = AFK.Step(player, now + 1)
	assert(triple == Weapons["Arc Pistol"].PowerPerClick * 3 * 3)
	assert(profile.Power == 1 + amount + triple and profile.Level > 1, "AFK XP must level up normally")
	local before = profile.Power
	AFK.Step(player, now + 100)
	assert(profile.Power == before + triple, "No catch-up reward burst after a stall")
	root.CFrame = CFrame.new(0, 5, 120)
	assert(not AFK.Step(player, now + 101) and player:GetAttribute("AFKStation") == nil)
	root.CFrame = CFrame.new(0, 5, 0)
	assert(not AFK.Step(player, now + 102), "No AFK training in the mine")
	enter("Starter")
	Training.MarkCombat(player)
	assert(not AFK.Step(player, os.clock()), "Combat must stop AFK training")
	local station = workspace.AFKTrainingStations.Starter
	assert(Definitions.Contains(station.Zone, station.Zone.Position))
	assert(not Definitions.Contains(station.Zone, station.Zone.Position + Vector3.new(100, 0, 0)))
	local snapshot = game.HttpService:JSONDecode(player:GetAttribute("ProgressSnapshot"))
	assert(snapshot.Power == profile.Power and snapshot.Level == profile.Level, "AFK rewards must reconcile click prediction")
end)
AFK.Release(player)
Training.Release(player)
profile.Power, profile.XP, profile.Level = saved.Power, saved.XP, saved.Level
profile.Overcharges, profile.EquippedWeapon = saved.Overcharges, saved.Weapon
Data.PublishProgress(player)
root.CFrame, root.Anchored = saved.CFrame, saved.Anchored
assert(ok, err)
print("AFK TRAINING TESTS PASSED: locks, weapon/rebirth rewards, XP, cadence, no stacking/catch-up, exit, mine and combat.")
