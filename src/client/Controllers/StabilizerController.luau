local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Definitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Unknown = require(ReplicatedStorage.Shared.CoreDefinitions)
local Visuals = require(ReplicatedStorage.Shared.CoreVisuals)
local Builder = require(ReplicatedStorage.Shared.StabilizerUIBuilder)
local WorldUI = require(ReplicatedStorage.Shared.WorldUIBuilder)
local templates = WorldUI.BuildTemplates()
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local gui = player.PlayerGui:FindFirstChild("StabilizerGui")
if not gui then
	local authored = game.StarterGui:FindFirstChild("StabilizerGui")
	gui = authored and authored:Clone() or Builder.Build(player.PlayerGui)
	gui.Parent = player.PlayerGui
end
local shade = gui:WaitForChild("Shade")
local panel = shade:WaitForChild("Panel")
local earningsLabel = Builder.EnsureEarnings(panel)
local reel = panel.Reel
local track = reel.Track
local spinning = false
local revealed = false
local stationId
local oddsVisible = false
local rng = Random.new()
local mounts = {}
local displays = {}
local folder = Instance.new("Folder")
folder.Name = "PersonalStabilizerDisplays"
folder.Parent = workspace
local function watch(item)
	if item:IsA("BasePart") and item.Name == "CoreMount" then mounts[item] = true end
end
for _, item in workspace:GetDescendants() do watch(item) end
workspace.DescendantAdded:Connect(watch)
local function accessible(mount)
	local node = mount
	while node and node ~= workspace do
		local owner = node:GetAttribute("OwnerUserId")
		if owner and owner ~= player.UserId then return false end
		node = node.Parent
	end
	return true
end
local function state()
	local kind = player:GetAttribute("StabilizerState") or "Empty"
	local finish = player:GetAttribute("StabilizerFinishAt") or 0
	if finish > 0 and finish <= workspace:GetServerTimeNow() then kind = "Ready" end
	return kind, math.max(0, math.ceil(finish - workspace:GetServerTimeNow()))
end
local function refresh()
	if spinning or revealed then return end
	local kind, remaining = state()
	local grade = player:GetAttribute("StabilizerGrade")
	if grade == nil or grade == "" then grade = "Cracked" end
	panel.Header.TitleLabel.Text = "CORE STABILIZER"
	panel.StatusLabel.TextColor3 = Color3.new(1, 1, 1)
	panel.StatusLabel.Text = kind == "Empty" and "Hold an Unknown Core to place it" or grade .. " Unknown Core"
	panel.TimerLabel.Text = kind == "Empty" and "Place → zap → stabilize → reveal" or kind == "Waiting" and "Equip your weapon and zap the core on the machine!" or kind == "Ready" and "READY TO REVEAL!" or string.format("STABILIZING  %d:%02d", math.floor(remaining / 60), remaining % 60)
	panel.TimerLabel.Visible = not oddsVisible
	panel.OddsLabel.Visible = oddsVisible
	local held = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
	if kind == "Empty" and held and held:GetAttribute("CoreGrade") then grade = held:GetAttribute("CoreGrade") end
	panel.OddsLabel.Text = grade .. " outcomes\n" .. Definitions.OddsText(grade)
	panel.ActionButton.Text = kind == "Ready" and "REVEAL CORE" or kind == "Empty" and "PLACE HELD CORE" or kind == "Waiting" and "ZAP CORE TO START" or "STABILIZING..."
	panel.ActionButton.Active = kind == "Ready" or kind == "Empty"
	panel.ActionButton.BackgroundColor3 = panel.ActionButton.Active and Color3.fromRGB(55, 213, 76) or Color3.fromRGB(93, 80, 120)
	panel.CancelButton.Visible = kind == "Waiting"
	panel.ResultLabel.Text = ""
	earningsLabel.Visible = false
end
local function close()
	if spinning then return end
	shade.Visible = false
	revealed = false
	reel.Visible = false
	panel.OddsButton.Visible = true
	panel.CloseButton.Visible = true
	refresh()
end
panel.CloseButton.Activated:Connect(close)
panel.OddsButton.Activated:Connect(function() oddsVisible = not oddsVisible; refresh() end)
panel.CancelButton.Activated:Connect(function() if stationId then remote:FireServer("CancelStabilizer", stationId) end end)
panel.ActionButton.Activated:Connect(function()
	if spinning then return end
	if revealed then close(); return end
	if not stationId then return end
	local kind = state()
	if kind == "Empty" then remote:FireServer("PlaceCore", stationId)
	elseif kind == "Ready" then remote:FireServer("ClaimCore", stationId) end
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Escape then close() end
end)
local function reveal(result)
	if spinning then return end
	spinning = true
	revealed = false
	shade.Visible = true
	reel.Visible = true
	panel.TimerLabel.Visible = false
	panel.OddsLabel.Visible = false
	panel.OddsButton.Visible = false
	panel.CancelButton.Visible = false
	panel.CloseButton.Visible = false
	panel.ActionButton.Visible = false
	panel.Header.TitleLabel.Text = "REVEALING YOUR CORE"
	panel.StatusLabel.Text = "WHAT'S INSIDE?"
	panel.ResultLabel.Text = ""
	earningsLabel.Visible = false
	track:ClearAllChildren()
	-- Decorative cards never choose a reward. The server supplied the winner.
	RunService.RenderStepped:Wait()
	local width = panel.CardTemplate.Size.X.Scale
	local step = width + (reel:GetAttribute("CardGapScale") or 0.025)
	local winnerIndex = 32
	local winningCard
	for index = 1, 38 do
		local key = index == winnerIndex and result.Type or Definitions.Roll(result.Grade, rng)
		local definition = Definitions.Cores[key]
		local card = panel.CardTemplate:Clone()
		card.Name = "SpinCard"
		card.Size = UDim2.fromScale(width, panel.CardTemplate.Size.Y.Scale)
		card.Position = UDim2.fromScale((index - 1) * step, (1 - card.Size.Y.Scale) / 2)
		card.BackgroundColor3 = Definitions.Rarities[definition.Rarity]:Lerp(Color3.fromRGB(28, 16, 51), 0.35)
		card.RarityLabel.Text = string.upper(definition.Rarity)
		card.Visible = true
		card.Parent = track
		Visuals.Show(card.CoreViewport, key, true)
		if index == winnerIndex then winningCard = card end
	end
	track.Position = UDim2.fromScale(0.5 - step * 2, 0)
	local destination = 0.5 - ((winnerIndex - 1) * step + width / 2)
	local tween = TweenService:Create(track, TweenInfo.new(4.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(destination, 0)})
	local lastIndex
	local ticks = RunService.RenderStepped:Connect(function()
		local index = math.floor((0.5 - track.Position.X.Scale) / step)
		if index ~= lastIndex then
			lastIndex = index
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxasset://sounds/volume_slider.ogg"
			sound.Volume = 0.13
			sound.PlaybackSpeed = 1.8
			sound.Parent = gui
			sound:Play()
			game:GetService("Debris"):AddItem(sound, 1)
		end
	end)
	tween:Play()
	tween.Completed:Wait()
	ticks:Disconnect()
	track.Position = UDim2.fromScale(0.5 - ((winnerIndex - 1) * step + width / 2), 0)
	local definition = Definitions.Cores[result.Type]
	local color = Definitions.Rarities[definition.Rarity]
	Visuals.Show(winningCard.CoreViewport, result.Type, false)
	winningCard.BackgroundColor3 = color
	panel.Header.BackgroundColor3 = color
	panel.Header.TitleLabel.Text = "CORE REVEALED!"
	panel.StatusLabel.Text = string.upper(definition.Name)
	panel.StatusLabel.TextColor3 = color
	panel.ResultLabel.Text = string.upper(definition.Rarity) .. "  •  ADDED TO YOUR HOTBAR"
	panel.ResultLabel.TextColor3 = color
	earningsLabel.Text = Definitions.IncomeText(result.Type) .. " IN YOUR REACTOR"
	earningsLabel.Visible = true
	local scale = Instance.new("UIScale")
	scale.Scale = 1.15
	scale.Parent = winningCard
	TweenService:Create(scale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	panel.CloseButton.Visible = true
	panel.ActionButton.Visible = true
	panel.ActionButton.Active = true
	panel.ActionButton.Text = "CONTINUE"
	panel.ActionButton.BackgroundColor3 = Color3.fromRGB(55, 213, 76)
	spinning = false
	revealed = true
end
remote.OnClientEvent:Connect(function(action, first)
	if action == "StabilizerOpen" and not spinning then
		stationId = first
		revealed = false
		reel.Visible = false
		shade.Visible = true
		panel.OddsButton.Visible = true
		panel.ActionButton.Visible = true
		panel.CloseButton.Visible = true
		refresh()
	elseif action == "StabilizerPlaced" then close()
	elseif action == "CoreReveal" then task.spawn(reveal, first) end
end)
local elapsed = 0
RunService.RenderStepped:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.1 then return end
	elapsed = 0
	if shade.Visible then refresh() end
	local kind, remaining = state()
	local grade = player:GetAttribute("StabilizerGrade") or ""
	local held = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
	local heldKnownCore = held and held:GetAttribute("IsStabilizedCore")
	local heldBoard = heldKnownCore and held:FindFirstChild("Handle") and held.Handle:FindFirstChild("CoreBillboard")
	if heldBoard then heldBoard.Enabled = not shade.Visible end
	for mount in mounts do
		local id = mount:GetAttribute("StabilizerId")
		if not mount:IsDescendantOf(workspace) then
			if displays[mount] then displays[mount]:Destroy(); displays[mount] = nil end
			mounts[mount] = nil
		elseif id and accessible(mount) then
			if not displays[mount] then
				local part = Instance.new("Part")
				part.Name = "PlacedUnknownCore"
				part.Shape = Enum.PartType.Ball
				part.Size = Vector3.one * 1.8
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.Material = Enum.Material.Neon
				part:SetAttribute("StabilizerTargetId", id)
				part.Parent = folder
				local billboard = templates.StabilizerStatusBillboard:Clone()
				billboard.Name = "Status"
				billboard.Parent = part
				displays[mount] = part
			end
			local part = displays[mount]
			part.Status.Enabled = not shade.Visible and not (kind == "Empty" and heldKnownCore)
			part.Transparency = kind == "Empty" and 1 or 0
			part.CanQuery = kind ~= "Empty"
			part.Position = mount.Position + Vector3.new(0, 1.5 + math.sin(os.clock() * (kind == "Running" and 12 or 3)) * 0.12, 0)
			part.Color = Unknown[grade] and Unknown[grade].Color or Color3.fromRGB(174, 98, 255)
			part.Status.TextLabel.Text = "CORE STABILIZER\n" .. (kind == "Empty" and "Hold a core and press E" or kind == "Waiting" and "Zap the core to start!" or kind == "Ready" and "READY! Press E to reveal" or string.format("STABILIZING  %d:%02d", math.floor(remaining / 60), remaining % 60))
		end
	end
end)
shade.Visible = false
return true
