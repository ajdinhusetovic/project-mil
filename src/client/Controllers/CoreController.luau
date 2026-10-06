local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage.Shared.Config)
local Definitions = require(ReplicatedStorage.Shared.CoreDefinitions)
local Visuals = require(ReplicatedStorage.Shared.CoreVisuals)
local Feedback = require(script.Parent.FeedbackEffects)
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local playerGui = player:WaitForChild("PlayerGui")
-- Retire the old authored HUD; collected cores now appear as server-created Tools.
local function hideOldHUD(child)
	if child.Name == "CoreHUD" and child:IsA("ScreenGui") then child.Enabled = false end
end
for _, child in playerGui:GetChildren() do hideOldHUD(child) end
playerGui.ChildAdded:Connect(hideOldHUD)

local folder = Instance.new("Folder")
folder.Name = "PersonalCoreDiscoveries"
folder.Parent = workspace
local drops = {}
local function remove(id)
	local drop = drops[id]
	if not drop then return end
	drop.Part:Destroy()
	drop.Beam:Destroy()
	drops[id] = nil
end
local function create(id, position, grade)
	remove(id)
	local color = Definitions[grade].Color
	-- Invisible prompt/effect anchor; imported meshes supply the visible core.
	local part = Instance.new("Part")
	part.Name = grade .. " Unknown Core"
	part:SetAttribute("CoreId", id)
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.one * 1.7
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Position = position
	part.Transparency = 1
	part.Parent = folder
	local visual = Visuals.BuildUnknown(grade)
	visual.Parent = part
	visual:PivotTo(part.CFrame)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = part
	local top = Instance.new("Attachment")
	top.Position = Vector3.new(0, 5, 0)
	top.Parent = part
	local bottom = Instance.new("Attachment")
	bottom.Position = Vector3.new(0, -0.8, 0)
	bottom.Parent = part
	local beam = Instance.new("Beam")
	beam.Attachment0 = bottom
	beam.Attachment1 = top
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(color)
	beam.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
	beam.Width0 = 1.4
	beam.Width1 = 0.3
	beam.Parent = folder
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Pick Up"
	prompt.ObjectText = grade .. " Unknown Core"
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = Config.Cores.PickupRange
	prompt.RequiresLineOfSight = true
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = part
	local drop = {Part = part, Visual = visual, Beam = beam, Position = position, Prompt = prompt, PendingUntil = 0}
	drops[id] = drop
	prompt.Triggered:Connect(function()
		if os.clock() < drop.PendingUntil then return end
		drop.PendingUntil = os.clock() + 0.5
		remote:FireServer("CollectCore", id)
	end)
	Feedback.ShowCore("UNKNOWN CORE FOUND!", color)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/volume_slider.ogg"
	sound.Volume = 0.45
	sound.PlaybackSpeed = 0.8
	sound.RollOffMaxDistance = 80
	sound.Parent = part
	sound:Play()
end
remote.OnClientEvent:Connect(function(action, first, second, third)
	if action == "CoreDiscovered" then
		create(first, second, third)
	elseif action == "CoreRemoved" then
		remove(first)
	elseif action == "ClearCoreDrops" then
		local ids = {}
		for id in drops do table.insert(ids, id) end
		for _, id in ids do remove(id) end
	elseif action == "CoreCollected" then
		Feedback.ShowCore("+1 " .. string.upper(first) .. " UNKNOWN CORE", Definitions[first].Color)
	elseif action == "CoreNotice" then
		Feedback.ShowCore(first, Color3.fromRGB(255, 154, 106))
	end
end)
RunService.RenderStepped:Connect(function()
	local now = os.clock()
	for _, drop in drops do
		drop.Part.CFrame = CFrame.new(drop.Position + Vector3.new(0, math.sin(now * 3) * 0.25, 0))
		drop.Visual:PivotTo(drop.Part.CFrame * CFrame.Angles(0, now * 0.5, 0))
	end
end)
if player:GetAttribute("Level") then
	remote:FireServer("GetCoreInventory")
else
	player:GetAttributeChangedSignal("Level"):Once(function() remote:FireServer("GetCoreInventory") end)
end
return true
