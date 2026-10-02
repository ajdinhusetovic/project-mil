local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local Config = require(ReplicatedStorage.Shared.Config)
local WeaponDefinitions = require(ReplicatedStorage.Shared.WeaponDefinitions)
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local MineRenderer = require(script.Parent.MineRenderer)
local FeedbackEffects = require(script.Parent.FeedbackEffects)
local Impact = require(script.Parent.MiningImpactEffects)
local TrainingFeedback = require(script.Parent.TrainingFeedback)
local touchInput = require(script.Parent.TouchMiningInput).new()
local MobileBuilder = require(ReplicatedStorage.Shared.MobileMiningUIBuilder)
local blocks = MineRenderer.Folder()
local mouse = player:GetMouse()
local cyan = Color3.fromRGB(102, 234, 255)
local effects = Instance.new("Folder")
effects.Name = "LocalMiningEffects"
effects.Parent = workspace
mouse.TargetFilter = effects

local gui = Instance.new("ScreenGui")
gui.Name = "MiningDemoHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local function label(name, text, size, position, parent)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = position
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(229, 241, 255)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 16
	l.Parent = parent
	return l
end
local healthText = label("Target", "", UDim2.fromOffset(280, 28), UDim2.new(0.5, -140, 0.72, 0), gui)

local playerGui = player:WaitForChild("PlayerGui")
local materialsGui = playerGui:FindFirstChild("MaterialsHUD") or playerGui:WaitForChild("MaterialsHUD", 3)
if not materialsGui then
	local authored = game:GetService("StarterGui"):FindFirstChild("MaterialsHUD")
	if authored then
		materialsGui = authored:Clone()
		materialsGui.Parent = playerGui
	end
end
if not materialsGui then
	materialsGui = Instance.new("ScreenGui")
	materialsGui.Name = "MaterialsHUD"
	materialsGui.ResetOnSpawn = false
	materialsGui.Parent = playerGui
	local fallback = Instance.new("Frame")
	fallback.Name = "MaterialInventory"
	fallback.Size = UDim2.fromOffset(230, 42)
	fallback.AnchorPoint = Vector2.new(0, 1)
	fallback.Position = UDim2.new(0, 18, 1, -220)
	fallback.BackgroundColor3 = Color3.fromRGB(19, 28, 41)
	fallback.BackgroundTransparency = 0.12
	fallback.AutomaticSize = Enum.AutomaticSize.Y
	fallback.Parent = materialsGui
	Instance.new("UICorner", fallback).CornerRadius = UDim.new(0, 10)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 5)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = fallback
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = fallback
	local title = label("Title", "MATERIALS", UDim2.new(1, 0, 0, 32), UDim2.new(), fallback)
	title.TextColor3 = cyan
	title.TextXAlignment = Enum.TextXAlignment.Left
end
local inventoryPanel = materialsGui:WaitForChild("MaterialInventory")
local inventoryScale = inventoryPanel:FindFirstChild("ResponsiveScale")
if inventoryScale and inventoryScale:IsA("UIScale") then
	local function updateInventoryScale()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		inventoryScale.Scale = math.clamp(math.min(viewport.X / 720, viewport.Y / 650), 0.6, 1)
	end
	local function watchCamera()
		local camera = workspace.CurrentCamera
		if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateInventoryScale) end
		updateInventoryScale()
	end
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
	watchCamera()
end
local inventoryLabels = {}
local materialColors = {}
for _, layer in Config.Layers do
	for _, material in layer.Materials do
		materialColors[material.Name] = material.Color
	end
end
for _, materialName in Config.MaterialOrder do
	local row = inventoryPanel:FindFirstChild(materialName)
	if not row or not row:IsA("TextLabel") then
		row = label(materialName, "", UDim2.new(1, 0, 0, 25), UDim2.new(), inventoryPanel)
	end
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.LayoutOrder = table.find(Config.MaterialOrder, materialName) or 1
	row.Visible = false
	inventoryLabels[materialName] = row
end
local function updateInventory(materialName, total)
	local row = inventoryLabels[materialName]
	if not row then return end
	row.Visible = true
	row.Text = string.format("x%d  %s", total, string.upper(materialName))
end

local function clearInventory()
	for _, row in inventoryLabels do
		row.Visible = false
		row.Text = ""
	end
end

local mobileGui = playerGui:FindFirstChild("MobileMiningHUD") or MobileBuilder.Build(playerGui)
local legacyButton = mobileGui:FindFirstChild("AttackButton")
if legacyButton then legacyButton:Destroy() end
local crosshair = mobileGui:WaitForChild("Crosshair")

local selection = Instance.new("Highlight")
selection.FillColor = cyan
selection.FillTransparency = 0.8
selection.OutlineColor = cyan
selection.DepthMode = Enum.HighlightDepthMode.Occluded
selection.Parent = effects
local tool, held = nil, false
local toolConnections = {}
local touchTraining = false
local lastShot, lastArc = -math.huge, -math.huge
local function resolveTarget()
	local camera = workspace.CurrentCamera
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not camera or not root then return nil end
	local centerAim = UserInputService.TouchEnabled or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
	local ray = (touchInput.Active or centerAim) and touchInput:Ray(camera) or mouse.UnitRay
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, effects }
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 250, params)
	if hit and (hit.Instance.Parent == blocks or hit.Instance:GetAttribute("StabilizerTargetId")) and (hit.Instance.Position - root.Position).Magnitude <= Config.Range then
		return hit.Instance, hit.Position
	end
	return nil
end
local function sendShot(target)
	lastShot = os.clock()
	if target:GetAttribute("StabilizerTargetId") then
		remote:FireServer("ChargeStabilizer", target:GetAttribute("StabilizerTargetId"))
	else
		remote:FireServer("Mine", target:GetAttribute("BlockId"))
	end
end
local function beginAttack(allowTraining)
	if held or not tool or tool.Parent ~= player.Character then return end
	held = true
	local target = resolveTarget()
	if target then
		TrainingFeedback.MarkCombat()
		if os.clock() - lastShot >= Config.Tick then sendShot(target) end
	elseif allowTraining ~= false then
		TrainingFeedback.Click(WeaponDefinitions[tool.Name])
	end
end
local function clearTool()
	touchInput:Clear()
	touchTraining = false
	held = false
	tool = nil
	for _, connection in toolConnections do connection:Disconnect() end
	table.clear(toolConnections)
end
local function bindTool(item)
	if not item:IsA("Tool") or not WeaponDefinitions[item.Name] then return end
	clearTool()
	tool = item
	table.insert(toolConnections, item.Activated:Connect(function()
		if UserInputService:GetLastInputType() ~= Enum.UserInputType.Touch then beginAttack() end
	end))
	table.insert(toolConnections, item.Deactivated:Connect(function() if not touchInput.Active then held = false end end))
	table.insert(toolConnections, item.Unequipped:Connect(function() touchInput:Clear(); touchTraining = false; held = false end))
end
local characterConnections = {}
local function bindCharacter(character)
	clearTool()
	for _, connection in characterConnections do connection:Disconnect() end
	table.clear(characterConnections)
	table.insert(characterConnections, character.ChildAdded:Connect(bindTool))
	for _, child in character:GetChildren() do bindTool(child) end
end
player.CharacterAdded:Connect(bindCharacter)
if player.Character then bindCharacter(player.Character) end
local function startTouch(input, centerAim)
	if not tool or tool.Parent ~= player.Character or not touchInput:Begin(input, centerAim) then return end
	touchTraining = not centerAim and not resolveTarget()
	beginAttack(centerAim)
end
UserInputService.TouchStarted:Connect(function(input, processed)
	if not processed then startTouch(input, false) end
end)
UserInputService.TouchMoved:Connect(function(input)
	if touchInput:Move(input) then held = false; touchTraining = false end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		if input == touchInput.Active then
			if held and touchTraining and tool and tool.Parent == player.Character then
				TrainingFeedback.Click(WeaponDefinitions[tool.Name])
			end
			if touchInput:End(input) then held = false; touchTraining = false end
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2 then
		if not touchInput.Active then held = false end
	end
end)
UserInputService.WindowFocusReleased:Connect(function() touchInput:Clear(); touchTraining = false; held = false end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.R then remote:FireServer("Surface") end
end)

-- Reuse lightning segments; no per-frame instance creation.
local arcs = {}
for i = 1, 14 do
	local p = Instance.new("Part")
	p.Name = "Lightning"
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Material = Enum.Material.Neon
	p.Color = i <= 10 and cyan or Color3.fromRGB(226, 252, 255)
	p.Transparency = 1
	p.Parent = effects
	arcs[i] = p
end
local function segment(p, a, b, thickness)
	p.Size = Vector3.new(thickness, thickness, (b - a).Magnitude)
	p.CFrame = CFrame.lookAt((a + b) / 2, b)
	p.Transparency = 0
end
local rng = Random.new()
local function jitter(amount)
	return Vector3.new(rng:NextNumber(-amount, amount), rng:NextNumber(-amount, amount), rng:NextNumber(-amount, amount))
end
local function lightning(origin, finish)
	local previous = origin
	local branchOrigin
	for i = 1, 10 do
		local nextPoint = origin:Lerp(finish, i / 10) + (i == 10 and Vector3.zero or jitter(0.55))
		segment(arcs[i], previous, nextPoint, rng:NextNumber(0.065, 0.14))
		previous = nextPoint
		if i == 6 then branchOrigin = nextPoint end
	end
	local branchEnd = finish + jitter(2)
	previous = branchOrigin
	for i = 1, 4 do
		local nextPoint = branchOrigin:Lerp(branchEnd, i / 4) + jitter(0.3)
		segment(arcs[10 + i], previous, nextPoint, 0.045)
		previous = nextPoint
	end
end

-- Bounded local fragment pool. Debris never participates in gameplay physics.
local pool, fragments = {}, {}
for _ = 1, 96 do
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Size = Vector3.one * 0.45
	p.Transparency = 1
	p.Material = Enum.Material.Neon
	p.Parent = effects
	table.insert(pool, p)
end
local pulsePool = {}
for _ = 1, 6 do
	local pulse = Instance.new("Part")
	pulse.Name = "BlastPulse"
	pulse.Shape = Enum.PartType.Ball
	pulse.Anchored = true
	pulse.CanCollide = false
	pulse.CanTouch = false
	pulse.CanQuery = false
	pulse.Material = Enum.Material.Neon
	pulse.Color = cyan
	pulse.Size = Vector3.one
	pulse.Transparency = 1
	pulse.Parent = effects
	table.insert(pulsePool, pulse)
end
local materialPool, materialDrops = {}, {}
for _ = 1, 80 do
	local chunk = Instance.new("Part")
	chunk.Name = "MaterialPickup"
	chunk.Anchored = true
	chunk.CanCollide = false
	chunk.CanTouch = false
	chunk.CanQuery = false
	chunk.Material = Enum.Material.Neon
	chunk.Size = Vector3.new(0.8, 1.05, 0.8)
	chunk.Transparency = 1
	chunk.Parent = effects
	table.insert(materialPool, chunk)
end
local function recycleMaterialDrop(index)
	local drop = materialDrops[index]
	drop.Part.Transparency = 1
	table.insert(materialPool, drop.Part)
	table.remove(materialDrops, index)
end
local flash = Instance.new("ColorCorrectionEffect")
flash.Name = "MiningHitFlash"
flash.Parent = game:GetService("Lighting")
local flashTween
remote.OnClientEvent:Connect(function(action, first, second, third, fourth)
	if action == "Sold" and first > 0 then
		clearInventory()
		return
	end
	if action == "InventorySnapshot" then
		for materialName, total in first do
			if total > 0 then updateInventory(materialName, total) end
		end
		return
	end
	if action == "ResetMine" then
		for index = #materialDrops, 1, -1 do recycleMaterialDrop(index) end
		task.spawn(MineRenderer.Generate)
		return
	end
	if action == "BlockHealth" then
		MineRenderer.SetHealth(first, second)
		return
	end
	if action == "ClearDrops" then
		for index = #materialDrops, 1, -1 do
			recycleMaterialDrop(index)
		end
		return
	end
	if action == "Inventory" then
		updateInventory(first, second)
		FeedbackEffects.ShowOre(first, third or 1, materialColors[first])
		for index = #materialDrops, 1, -1 do
			if materialDrops[index].Id == fourth then
				recycleMaterialDrop(index)
				break
			end
		end
		return
	end
	if action == "BackpackFull" then
		for _, drop in materialDrops do
			if drop.Id == first then
				drop.Collecting = false
				drop.RetryAt = os.clock() + 0.5
			end
		end
		return
	end
	if action == "Drop" then
		local chunk = table.remove(materialPool)
		if not chunk then return end
		chunk.Color = third
		chunk.Transparency = 0
		chunk.Position = second
		local direction = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(0.65, 1), rng:NextNumber(-1, 1)).Unit
		table.insert(materialDrops, {
			Id = first,
			Part = chunk,
			Position = second,
			Velocity = direction * rng:NextNumber(10, 17),
			Age = 0,
			RestPosition = nil,
			Collecting = false,
			RetryAt = 0,
			Material = fourth,
		})
		return
	end
	if action ~= "Blast" and action ~= "Break" then return end
	if typeof(first) ~= "Vector3" or typeof(second) ~= "Color3" then return end
	local position, color = first, second
	if action == "Break" then MineRenderer.Break(third) end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - position).Magnitude > 75 then return end
	if action == "Blast" then
		local pulse = table.remove(pulsePool)
		if pulse then
			pulse.Position = position
			pulse.Size = Vector3.one
			pulse.Color = color:Lerp(cyan, 0.65)
			pulse.Transparency = 0.35
			local tween = TweenService:Create(
				pulse,
				TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = Vector3.one * 15, Transparency = 1 }
			)
			tween.Completed:Once(function()
				pulse.Transparency = 1
				table.insert(pulsePool, pulse)
			end)
			tween:Play()
		end
		return
	end
	if action ~= "Break" then return end
	Impact.Burst(position, color)
	for _ = 1, 12 do
		local p = table.remove(pool)
		if not p then break end
		p.Color = color:Lerp(cyan, 0.3)
		p.Transparency = 0
		p.Position = position + jitter(1.6)
		table.insert(fragments, { Part = p, Position = p.Position, Velocity = jitter(15) + Vector3.new(0, 14, 0), Age = 0 })
	end
	if flashTween then flashTween:Cancel() end
	flash.Brightness = 0.045
	flashTween = TweenService:Create(flash, TweenInfo.new(0.16), { Brightness = 0 })
	flashTween:Play()
end)

RunService.RenderStepped:Connect(function(dt)
	local camera = workspace.CurrentCamera
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local equipped = tool and tool.Parent == character
	local centerAim = UserInputService.TouchEnabled or UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
	crosshair.Visible = centerAim and equipped and not (touchInput.Active and not touchInput.CenterAim) or false
	local target, hitPosition
	if equipped then target, hitPosition = resolveTarget() end
	selection.Adornee = target
	selection.FillTransparency = held and 0.55 or 0.9
	if target and target:GetAttribute("StabilizerTargetId") then
		healthText.Text = "CORE STABILIZER  •  CHANNEL ELECTRICITY"
		selection.FillColor = cyan
	elseif target then
		local damage = 1 - target:GetAttribute("Health") / target:GetAttribute("MaxHealth")
		selection.FillColor = cyan:Lerp(Color3.new(1, 1, 1), damage)
		selection.FillTransparency = held and (0.72 - damage * 0.25 + math.sin(os.clock() * 24) * 0.09) or 0.9
		healthText.Text = string.format("%s  •  %d / %d", target:GetAttribute("Layer"), target:GetAttribute("Health"), target:GetAttribute("MaxHealth"))
	else
		healthText.Text = ""
	end
	local now = os.clock()
	if target and held and equipped then
		TrainingFeedback.MarkCombat()
		local handle = tool:FindFirstChild("Handle")
		local muzzle = handle and handle:FindFirstChild("Muzzle")
		if muzzle and now - lastArc >= 1 / 30 then
			lastArc = now
			lightning(muzzle.WorldPosition, hitPosition)
		end
		if now - lastShot >= Config.Tick then sendShot(target) end
	else
		for _, arc in arcs do arc.Transparency = 1 end
	end
	for i = #fragments, 1, -1 do
		local fragment = fragments[i]
		fragment.Age += dt
		if fragment.Age >= 0.65 then
			fragment.Part.Transparency = 1
			table.insert(pool, fragment.Part)
			table.remove(fragments, i)
		else
			fragment.Velocity += Vector3.new(0, -45 * dt, 0)
			fragment.Position += fragment.Velocity * dt
			fragment.Part.CFrame = CFrame.new(fragment.Position) * CFrame.Angles(fragment.Age * 8, fragment.Age * 11, 0)
			fragment.Part.Transparency = fragment.Age / 0.65
		end
	end
	for i = #materialDrops, 1, -1 do
		local drop = materialDrops[i]
		drop.Age += dt
		if drop.Age >= Config.DropLifetime then
			recycleMaterialDrop(i)
		elseif drop.Age < 0.5 then
			drop.Velocity += Vector3.new(0, -30 * dt, 0)
			drop.Position += drop.Velocity * dt
		else
			if not drop.RestPosition then
				drop.RestPosition = drop.Position
				drop.Velocity = Vector3.zero
			end
			local pickupTarget = root and (root.Position + Vector3.new(0, 1.2, 0))
			local backpackHasSpace = (player:GetAttribute("BackpackUsed") or 0) < (player:GetAttribute("BackpackCapacity") or 50)
			if pickupTarget and backpackHasSpace and (pickupTarget - drop.Position).Magnitude <= (player:GetAttribute("MagnetRange") or Config.CollectionRange) then
				local offset = pickupTarget - drop.Position
				local distance = offset.Magnitude
				if distance < 1.8 then
					if not drop.Collecting and os.clock() >= drop.RetryAt then
						drop.Collecting = true
						remote:FireServer("Collect", drop.Id)
					end
					continue
				end
				local speed = math.min(75, 18 + (drop.Age - 0.5) * 28)
				drop.Position += offset.Unit * math.min(distance, speed * dt)
			else
				drop.Position = drop.RestPosition + Vector3.new(0, math.sin(drop.Age * 4) * 0.22, 0)
			end
		end
		drop.Part.CFrame = CFrame.new(drop.Position) * CFrame.Angles(drop.Age * 3, drop.Age * 5, drop.Age * 2)
	end
end)

task.spawn(MineRenderer.Generate)
if player:GetAttribute("Level") then
	remote:FireServer("GetInventory")
else
	player:GetAttributeChangedSignal("Level"):Once(function()
		remote:FireServer("GetInventory")
	end)
end

return true
