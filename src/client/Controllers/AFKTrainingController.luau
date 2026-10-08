local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Definitions = require(ReplicatedStorage.Shared.AFKTrainingDefinitions)
local Feedback = require(script.Parent.FeedbackEffects)
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local folder = workspace:WaitForChild("AFKTrainingStations")
local entries = {}

local function register(model)
	local definition = Definitions.Get(model:GetAttribute("StationId"))
	local block = model:FindFirstChild("ChargeBlock")
	if definition and block and block:IsA("BasePart") then
		entries[model] = { Definition = definition, Block = block, Origin = block.CFrame }
	end
end

local function refresh()
	local rebirths = player:GetAttribute("Overcharges") or 0
	for model, entry in entries do
		if model.Parent then
			local definition = entry.Definition
			local sign = entry.Block:FindFirstChild("StationSign")
			local unlocked = rebirths >= definition.Rebirths
			local requirement = sign and sign:FindFirstChild("Requirement")
			if requirement then
				requirement.Text = unlocked and (player:GetAttribute("AFKStation") == definition.Id and "⚡ TRAINING ⚡" or "UNLOCKED • STAND HERE")
					or tostring(definition.Rebirths) .. " REBIRTHS TO UNLOCK"
				requirement.TextColor3 = unlocked and Color3.fromRGB(116, 255, 87) or Color3.fromRGB(255, 107, 107)
			end
		end
	end
end

for _, model in folder:GetChildren() do register(model) end
folder.ChildAdded:Connect(function(model) register(model); refresh() end)
folder.ChildRemoved:Connect(function(model) entries[model] = nil end)
for _, attribute in { "Overcharges", "AFKStation" } do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
refresh()

RunService.RenderStepped:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local time = os.clock()
	for model, entry in entries do
		if model.Parent and (root.Position - entry.Origin.Position).Magnitude < 140 then
			-- Derive position from the movable pedestal, preserving Studio placement.
			local pedestal = model:FindFirstChild("Pedestal")
			local position = pedestal and (pedestal.Position + Vector3.new(0, 2.35, 0)) or entry.Origin.Position
			entry.Block.CFrame = CFrame.new(position + Vector3.new(0, math.sin(time * 2) * 0.22, 0))
				* CFrame.Angles(0, time * 0.45, math.rad(12))
		end
	end
end)

remote.OnClientEvent:Connect(function(action, id, gain)
	if action == "MiningTraining" then Feedback.ShowPower(id); return end
	if action ~= "AFKTraining" then return end
	Feedback.ShowPower(gain)
	local model = folder:FindFirstChild(id)
	local block = model and model:FindFirstChild("ChargeBlock")
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local target = block and block:FindFirstChild("ChargeTarget")
	if not head or not target then return end
	local tool = character:FindFirstChildWhichIsA("Tool")
	local muzzle = tool and tool:FindFirstChild("Muzzle", true)
	local source = muzzle and muzzle:IsA("Attachment") and muzzle or nil
	local temporary
	if not source then
		temporary = Instance.new("Attachment")
		temporary.Parent = head
		source = temporary
		Debris:AddItem(temporary, 0.35)
	end
	local beam = Instance.new("Beam")
	beam.Attachment0, beam.Attachment1 = source, target
	beam.FaceCamera, beam.Segments = true, 8
	beam.Width0, beam.Width1 = 0.3, 0.12
	beam.CurveSize0, beam.CurveSize1 = 1.5, -1.5
	beam.Color = ColorSequence.new(block.Color, Color3.new(1, 1, 1))
	beam.LightEmission = 1
	beam.Parent = source
	TweenService:Create(beam, TweenInfo.new(0.25), { Width0 = 0, Width1 = 0 }):Play()
	Debris:AddItem(beam, 0.3)
	local highlight = Instance.new("Highlight")
	highlight.Adornee = block
	highlight.FillColor, highlight.OutlineColor = Color3.new(1, 1, 1), block.Color
	highlight.FillTransparency, highlight.OutlineTransparency = 0.15, 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = block
	TweenService:Create(highlight, TweenInfo.new(0.3), { FillTransparency = 1, OutlineTransparency = 1 }):Play()
	Debris:AddItem(highlight, 0.35)
end)

return {}
