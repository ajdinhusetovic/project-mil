local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TrainingFeedback = require(script.Parent.TrainingFeedback)
local Config = require(ReplicatedStorage.Shared.Config)
local Overcharge = require(ReplicatedStorage.Shared.OverchargeDefinitions)
local WeaponDefinitions = require(ReplicatedStorage.Shared.WeaponDefinitions)
local Progression = require(ReplicatedStorage.Shared.Progression)
local AFKDefinitions = require(ReplicatedStorage.Shared.AFKTrainingDefinitions)

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("ProgressHUD")

local bar = gui:WaitForChild("LevelBar")
local fill = bar:WaitForChild("Fill")
local levelLabel = bar:WaitForChild("LevelLabel")
local xpLabel = bar:WaitForChild("XPLabel")
local powerLabel = gui:WaitForChild("PowerLabel")
local depthLabel = gui:WaitForChild("DepthLabel")
local returnButton = gui:WaitForChild("ReturnButton")
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
	local required = Progression.XPRequired(level)
	levelLabel.Text = string.format("LEVEL %s", Format.Compact(level))
	xpLabel.Text = string.format("%s / %s XP", Format.Compact(xp), Format.Compact(required))
	powerLabel.Text = string.format("⚡ %s POWER     +%s / CLICK", Overcharge.Number(power), Overcharge.Number(definition.PowerPerClick * (player:GetAttribute("PowerMultiplier") or 1)))
	local afkMultiplier = player:GetAttribute("AFKMultiplier")
	if player:GetAttribute("AFKStation") and afkMultiplier then
		local interval = AFKDefinitions.Interval
		powerLabel.Text = string.format("⚡ %s POWER     AFK +%s / SEC", Overcharge.Number(power), Overcharge.Number(definition.PowerPerClick * (player:GetAttribute("PowerMultiplier") or 1) * afkMultiplier / interval))
	end

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
for _, attribute in { "EquippedWeapon", "PowerMultiplier", "AFKStation", "AFKMultiplier" } do
	player:GetAttributeChangedSignal(attribute):Connect(function()
		queueRefresh()
	end)
end
refresh(true)

return true
