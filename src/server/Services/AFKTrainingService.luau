local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(ReplicatedStorage.Shared.AFKTrainingDefinitions)
local Builder = require(ReplicatedStorage.Shared.AFKStationBuilder)
local Rules = require(ReplicatedStorage.Shared.TrainingRules)
local Data = require(script.Parent.PlayerDataService)
local Training = require(script.Parent.TrainingService)
local Service = {}
local states = {}
local remote

local function publish(player, definition)
	local id = definition and definition.Id or nil
	if player:GetAttribute("AFKStation") ~= id then
		player:SetAttribute("AFKStation", id)
		player:SetAttribute("AFKMultiplier", definition and definition.Multiplier or nil)
	end
end

function Service.Step(player, now)
	local profile = Data.Get(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local definition
	if profile and root and humanoid and humanoid.Health > 0
		and not Rules.InMine(root.Position) and Training.CanTrain(player, now) then
		definition = Definitions.At(root.Position, profile.Overcharges)
	end
	if not definition then
		states[player] = nil
		publish(player, nil)
		return false
	end
	publish(player, definition)
	local entry = states[player]
	if not entry or entry.Id ~= definition.Id or entry.Character ~= character then
		states[player] = { Id = definition.Id, Character = character, Next = now + Definitions.Interval }
		return false
	end
	if now < entry.Next then return false end
	-- Never bank time offline, or burst rewards after a server stall.
	entry.Next = now + Definitions.Interval
	local success, gain = Data.AwardTraining(player, definition.Multiplier)
	if success and remote then remote:FireClient(player, "AFKTraining", definition.Id, gain) end
	return success, gain
end

function Service.Initialize(event)
	remote = event
	Builder.Build(workspace)
	task.spawn(function()
		while true do
			task.wait(0.1)
			local now = os.clock()
			for _, player in Players:GetPlayers() do Service.Step(player, now) end
		end
	end)
end

function Service.Release(player)
	states[player] = nil
	publish(player, nil)
end

return Service
