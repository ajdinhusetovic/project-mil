local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TrainingFeedback = require(script.Parent.TrainingFeedback)
local Config = require(ReplicatedStorage.Shared.Config)
local Overcharge = require(ReplicatedStorage.Shared.OverchargeDefinitions)
local WeaponDefinitions = require(ReplicatedStorage.Shared.WeaponDefinitions)

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:FindFirstChild("ProgressHUD") or playerGui:WaitForChild("ProgressHUD", 3)
if not gui then
	gui = Instance.new("ScreenGui")
	gui.Name = "ProgressHUD"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	local bar = Instance.new("Frame")
	bar.Name = "LevelBar"
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, 12)
	bar.Size = UDim2.fromOffset(460, 70)
	bar.BackgroundColor3 = Color3.fromRGB(18, 29, 48)
	bar.Parent = gui
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 9)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.fromRGB(255, 133, 85)
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 9)
	for _, definition in {
		{ "LevelLabel", UDim2.new(0, 12, 0, 0), UDim2.new(0.5, 0, 1, 0) },
		{ "XPLabel", UDim2.new(0.56, 0, 0, 0), UDim2.new(0.42, 0, 1, 0) },
	} do
		local label = Instance.new("TextLabel")
		label.Name = definition[1]
		label.Position = definition[2]
		label.Size = definition[3]
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.FredokaOne
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextSize = 27
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = bar
	end
	local power = Instance.new("TextLabel")
	power.Name = "PowerLabel"
	power.AnchorPoint = Vector2.new(0.5, 0)
	power.Position = UDim2.new(0.5, 0, 0, 86)
	power.Size = UDim2.fromOffset(460, 31)
	power.BackgroundTransparency = 1
	power.Font = Enum.Font.FredokaOne
	power.TextColor3 = Color3.fromRGB(255, 212, 78)
	power.TextSize = 22
	power.Parent = gui
end

local bar = gui:WaitForChild("LevelBar")
local fill = bar:WaitForChild("Fill")
local levelLabel = bar:WaitForChild("LevelLabel")
local xpLabel = bar:WaitForChild("XPLabel")
local powerLabel = gui:WaitForChild("PowerLabel")
local depthLabel = gui:FindFirstChild("DepthLabel")
if not depthLabel then
	depthLabel = powerLabel:Clone()
	depthLabel.Name = "DepthLabel"
	depthLabel.Text = "DEPTH: 0 STUDS"
	depthLabel.Visible = false
	depthLabel.Parent = gui
end
local returnButton = gui:FindFirstChild("ReturnButton")
if not returnButton then
	returnButton = Instance.new("TextButton")
	returnButton.Name = "ReturnButton"
	returnButton.AnchorPoint = Vector2.new(0.5, 0)
	returnButton.Position = UDim2.new(0.5, 0, 0, 174)
	returnButton.Size = UDim2.fromOffset(190, 44)
	returnButton.BackgroundColor3 = Color3.fromRGB(34, 184, 91)
	returnButton.TextColor3 = Color3.new(1, 1, 1)
	returnButton.Font = Enum.Font.FredokaOne
	returnButton.TextSize = 25
	returnButton.Text = "RETURN"
	returnButton.Visible = false
	returnButton.Parent = gui
	Instance.new("UICorner", returnButton).CornerRadius = UDim.new(0, 9)
end
returnButton.Activated:Connect(function()
	remote:FireServer("Surface")
end)

local lastDepth = -1
local wasInMine = false
RunService.RenderStepped:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local position = root and root.Position
	local half = Config.Width * Config.BlockSize / 2
	local inMine = position ~= nil and position.Y < 0 and math.abs(position.X) < half and math.abs(position.Z) < half
	if inMine ~= wasInMine then
		wasInMine = inMine
		powerLabel.Visible = not inMine
		depthLabel.Visible = inMine
		returnButton.Visible = inMine
	end
	if inMine then
		local depth = math.clamp(math.floor(-position.Y), 0, Config.Depth * Config.BlockSize)
		if depth ~= lastDepth then
			lastDepth = depth
			depthLabel.Text = string.format("DEPTH: %s STUDS", Format.Compact(depth))
		end
	else
		lastDepth = -1
	end
end)

local currentTween = nil
local animationToken = 0
local displayedLevel = nil
local function tweenFill(ratio, duration, token)
	local tween = TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(ratio, 1),
	})
	currentTween = tween
	tween:Play()
	tween.Completed:Wait()
	return animationToken == token
end

local function refresh(instant)
	local power, xp, level = TrainingFeedback.GetStats()
	local weaponName = player:GetAttribute("EquippedWeapon") or "Scrap Zapper"
	local definition = WeaponDefinitions[weaponName] or WeaponDefinitions["Scrap Zapper"]
	local required = math.floor(Config.LevelXPBase * level ^ Config.LevelXPExponent)
	levelLabel.Text = string.format("LEVEL %s", Format.Compact(level))
	xpLabel.Text = string.format("%s / %s XP", Format.Compact(xp), Format.Compact(required))
	powerLabel.Text = string.format("⚡ %s POWER     +%s / CLICK", Overcharge.Number(power), Overcharge.Number(definition.PowerPerClick * (player:GetAttribute("PowerMultiplier") or 1)))

	animationToken += 1
	local token = animationToken
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end
	local previousLevel = displayedLevel
	displayedLevel = level
	local ratio = math.clamp(xp / required, 0, 1)
	if instant or previousLevel == nil then
		fill.Size = UDim2.fromScale(ratio, 1)
	elseif level > previousLevel then
		task.spawn(function()
			if not tweenFill(1, 0.1, token) then return end
			fill.Size = UDim2.fromScale(0, 1)
			tweenFill(ratio, 0.12, token)
		end)
	else
		currentTween = TweenService:Create(fill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(ratio, 1),
		})
		currentTween:Play()
	end
end

local refreshQueued = false
local function queueRefresh()
	if refreshQueued then return end
	refreshQueued = true
	task.defer(function()
		refreshQueued = false
		refresh(false)
	end)
end

TrainingFeedback.Changed.Event:Connect(queueRefresh)
for _, attribute in { "EquippedWeapon", "PowerMultiplier" } do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		queueRefresh()
	end)
end
refresh(true)

return true
