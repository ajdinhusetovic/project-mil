local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Rules = require(ReplicatedStorage.Shared.TrainingRules)
local Weapons = require(ReplicatedStorage.Shared.WeaponDefinitions)
local Data = require(script.Parent.PlayerDataService)
local Service = {}
local states = {}
local function state(player)
	if not states[player] then states[player] = {Tokens = Config.Training.Burst, Updated = os.clock(), CombatUntil = 0} end
	return states[player]
end
function Service.MarkCombat(player)
	state(player).CombatUntil = os.clock() + Config.Training.CombatCooldown
end
function Service.Handle(player, sequence)
	if typeof(sequence) == "table" then
		if sequence.Epoch ~= Data.GetProgressEpoch(player) then return end
		sequence = sequence.Sequence
	end
	if typeof(sequence) ~= "number" or sequence ~= sequence or sequence % 1 ~= 0 or sequence < 1 or sequence > 1000000000 then return end
	if sequence <= Data.GetTrainingSequence(player) then return end
	local entry = state(player)
	local now = os.clock()
	entry.Tokens = math.min(Config.Training.Burst, entry.Tokens + (now - entry.Updated) * Config.Training.ClicksPerSecond)
	entry.Updated = now
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local tool = character and character:FindFirstChildWhichIsA("Tool")
	local profile = Data.Get(player)
	local allowed = root and humanoid and humanoid.Health > 0 and profile and tool
		and Weapons[tool.Name] and tool.Name == profile.EquippedWeapon
		and not Rules.InMine(root.Position) and now >= entry.CombatUntil and entry.Tokens >= 1
	if allowed then
		entry.Tokens -= 1
		Data.Train(player, sequence)
	else
		-- Always acknowledge legitimate input IDs, so client prediction can reconcile rejections.
		Data.AcknowledgeTraining(player, sequence)
	end
end
function Service.Release(player) states[player] = nil end
return Service
