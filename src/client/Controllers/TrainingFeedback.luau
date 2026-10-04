local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Config = require(ReplicatedStorage.Shared.Config)
local Rules = require(ReplicatedStorage.Shared.TrainingRules)
local Feedback = require(script.Parent.FeedbackEffects)
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local Training = {}
Training.Changed = Instance.new("BindableEvent")
local pending = {}
local sequence = 0
local base
local tokens = Config.Training.Burst
local updated = os.clock()
local combatUntil = 0
local function reconcile()
	local encoded = player:GetAttribute("ProgressSnapshot")
	if not encoded then return end
	local ok, snapshot = pcall(HttpService.JSONDecode, HttpService, encoded)
	if not ok or type(snapshot) ~= "table" then return end
	if base and base.Epoch ~= snapshot.Epoch then table.clear(pending) end
	base = snapshot
	sequence = math.max(sequence, snapshot.Sequence)
	for id in pending do if id <= snapshot.Sequence then pending[id] = nil end end
	Training.Changed:Fire()
end
player:GetAttributeChangedSignal("ProgressSnapshot"):Connect(reconcile)
reconcile()
function Training.GetStats()
	local stats = base or { Power = player:GetAttribute("Power") or 0, XP = player:GetAttribute("XP") or 0, Level = player:GetAttribute("Level") or 1 }
	local power, xp, level = stats.Power, stats.XP, stats.Level
	for _, click in pending do power += click.Power; xp += click.Power end
	local required = math.floor(Config.LevelXPBase * level ^ Config.LevelXPExponent)
	while xp >= required do
		xp -= required
		level += 1
		required = math.floor(Config.LevelXPBase * level ^ Config.LevelXPExponent)
	end
	return power, xp, level
end
function Training.MarkCombat()
	combatUntil = os.clock() + Config.Training.CombatCooldown
end
function Training.Click(definition)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not base or not root or Rules.InMine(root.Position) then return end
	local now = os.clock()
	tokens = math.min(Config.Training.Burst, tokens + (now - updated) * Config.Training.ClicksPerSecond)
	updated = now
	if now < combatUntil or tokens < 1 then return end
	tokens -= 1
	sequence += 1
	local gain = definition.PowerPerClick * (base.PowerMultiplier or 1)
	pending[sequence] = {Power = gain}
	Feedback.ShowPower(gain)
	Training.Changed:Fire()
	remote:FireServer("Train", {Sequence = sequence, Epoch = base.Epoch or 0})
end
return Training
