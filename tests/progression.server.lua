-- Temporary Studio server test. Restores all player stats afterwards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = game.ServerScriptService.Server.Services
local Data = require(Services.PlayerDataService)
local Progression = require(ReplicatedStorage.Shared.Progression)
local Weapons = require(ReplicatedStorage.Shared.WeaponDefinitions)
local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
repeat task.wait() until Data.Get(player)
task.wait(2)
local profile = Data.Get(player)
local saved = { Power = profile.Power, XP = profile.XP, Level = profile.Level, Overcharges = profile.Overcharges, Weapon = profile.EquippedWeapon }
local ok, err = pcall(function()
	assert(Progression.XPRequired(1) == 25)
	assert(Progression.XPRequired(2) == 40)
	assert(Progression.XPRequired(5) == 120)
	assert(Progression.XPRequired(20) == 1050)
	assert(Progression.XPRequired(25) == 1550)
	for level = 1, 100 do
		assert(Data.GetXPToNextLevel(level) == Progression.XPRequired(level))
		assert(Progression.XPRequired(level + 1) > Progression.XPRequired(level))
	end
	assert(Progression.MiningMultiplier(6) == 3)
	assert(Progression.MiningMultiplier(7) == 6)
	assert(Progression.MiningMultiplier(17) == 12)
	assert(Progression.MiningMultiplier(29) == 24)
	assert(Progression.MiningMultiplier(43) == 48)
	profile.Power, profile.XP, profile.Level = 0, 0, 1
	profile.Overcharges, profile.EquippedWeapon = 2, "Arc Pistol"
	local success, gain = Data.AwardTraining(player, Progression.MiningMultiplier(7))
	assert(success and gain == Weapons["Arc Pistol"].PowerPerClick * 2 * 6)
	assert(profile.Power == gain, "Mining rewards must also increase damage")
	local level, xp = 1, gain
	while xp >= Progression.XPRequired(level) do xp -= Progression.XPRequired(level); level += 1 end
	assert(profile.Level == level and profile.XP == xp, "Mining XP must respect the new curve")
	local miningPower = profile.Power
	Data.Train(player)
	assert(profile.Power == miningPower + Weapons["Arc Pistol"].PowerPerClick * 2, "Manual training must use weapon and rebirth stats")
	local snapshot = game.HttpService:JSONDecode(player:GetAttribute("ProgressSnapshot"))
	assert(snapshot.Power == profile.Power and snapshot.XP == profile.XP and snapshot.Level == profile.Level)
end)
profile.Power, profile.XP, profile.Level = saved.Power, saved.XP, saved.Level
profile.Overcharges, profile.EquippedWeapon = saved.Overcharges, saved.Weapon
for _, key in { "Power", "XP", "Level" } do player:SetAttribute(key, profile[key]) end
Data.PublishProgress(player)
assert(ok, err)
print("PROGRESSION TESTS PASSED: curve, all depth reward bands, power+XP, weapon/rebirth scaling and snapshots.")
