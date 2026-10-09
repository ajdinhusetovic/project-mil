local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Input = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Weapons = require(Shared.WeaponDefinitions)
local Cores = require(Shared.StabilizerDefinitions)
local Visuals = require(Shared.CoreVisuals)
local gui = player:WaitForChild("PlayerGui"):WaitForChild("HotbarGui")
local bar, slots = gui.Bar, gui.Bar.Slots
local ordered, cards, connections = {}, {}, {}
local queued = false

local function disableDefault()
	for _ = 1, 20 do
		if pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false) end) then return end
		task.wait(.2)
	end
	warn("Custom hotbar could not disable Roblox Backpack")
end
task.spawn(disableDefault)

local function equip(tool)
	if not gui.Enabled or not tool.Parent then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	if tool.Parent == character then humanoid:UnequipTools()
	elseif tool.Parent == player:FindFirstChild("Backpack") then humanoid:EquipTool(tool) end
end

local function weaponPreview(viewport, tool)
	local handle = tool:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then return false end
	local model = Instance.new("Model")
	for _, original in tool:GetDescendants() do
		if original:IsA("BasePart") then
			local part = original:Clone()
			for _, item in part:GetDescendants() do
				if item:IsA("LuaSourceContainer") or item:IsA("Constraint") or item:IsA("JointInstance") then item:Destroy() end
			end
			part.Anchored, part.CanCollide = true, false
			part.CFrame = handle.CFrame:ToObjectSpace(original.CFrame)
			part.Parent = model
		end
	end
	model.Parent = viewport
	local center, size = model:GetBoundingBox()
	model:PivotTo(CFrame.Angles(math.rad(-12),math.rad(135),0) * CFrame.new(-center.Position))
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(Vector3.new(0,0,math.max(size.X,size.Y,size.Z)*2),Vector3.zero)
	camera.Parent, viewport.CurrentCamera = viewport, camera
	viewport.Ambient, viewport.LightColor = Color3.new(1,1,1), Color3.new(1,1,1)
	return true
end

local function create(tool)
	local card = gui.SlotTemplate:Clone()
	card.Name, card.Visible = "ToolSlot", true
	card:SetAttribute("CoreId", tool:GetAttribute("CoreId"))
	card:SetAttribute("ToolName", tool.Name)
	card.NameLabel.Text = tool.Name
	local definition = Weapons[tool.Name]
	local coreType = tool:GetAttribute("CoreType")
	local color = Color3.fromRGB(50,65,88)
	card.WeaponIcon.Visible = false
	if definition then
		color = definition.Color:Lerp(Color3.fromRGB(20,28,44),.65)
		card.WeaponIcon.Visible = not weaponPreview(card.Preview, tool)
	elseif coreType and Cores.Cores[coreType] then
		color = Cores.Rarities[Cores.Cores[coreType].Rarity]:Lerp(Color3.fromRGB(20,28,44),.65)
		Visuals.Show(card.Preview, coreType, false, tool:GetAttribute("Mutation"))
	elseif tool:GetAttribute("IsUnknownCore") then
		Visuals.Show(card.Preview, "Unknown", false)
		local grade = tool:GetAttribute("CoreGrade")
		local unknown = require(Shared.CoreDefinitions)[grade]
		if unknown then
			color = unknown.Color:Lerp(Color3.fromRGB(20,28,44),.65)
			for _, part in card.Preview:GetDescendants() do
				if part:IsA("BasePart") then part.Color = unknown.Color end
			end
		end
	elseif tool.TextureId ~= "" then
		card.WeaponIcon.Image, card.WeaponIcon.Visible = tool.TextureId, true
	end
	card.BackgroundColor3 = color
	card.Activated:Connect(function() equip(tool) end)
	card.Parent = slots
	cards[tool] = card
	return card
end

local function resize()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local view = camera.ViewportSize
	local scale = math.min(1,view.Y / 650)
	bar.ResponsiveScale.Scale = scale
	local width = math.max(96,math.floor(math.min(590,view.X*.56/scale)/96)*96)
	bar.Size = UDim2.fromOffset(width,100)
	bar.Position = UDim2.new(.5,0,1,-12)
	local contentWidth = #ordered*96
	if contentWidth > 0 then bar.Size = UDim2.fromOffset(math.min(width,contentWidth),100) end
	bar.HintLabel.Text = contentWidth > width and "SWIPE / SCROLL FOR MORE" or "SELECT A WEAPON OR CORE"
	bar.HintLabel.Visible = #ordered > 1
	bar.PreviousButton.Visible = contentWidth > width
	bar.NextButton.Visible = contentWidth > width
	bar.Visible = #ordered > 0
end

local function refresh()
	queued = false
	local available, newTools = {}, {}
	for _, container in {player:FindFirstChild("Backpack"), player.Character} do
		if container then
			for _, tool in container:GetChildren() do
				if tool:IsA("Tool") then available[tool] = true end
			end
		end
	end
	local nextOrder, seen = {}, {}
	for _, tool in ordered do
		if available[tool] then table.insert(nextOrder,tool); seen[tool] = true end
	end
	for tool in available do if not seen[tool] then table.insert(newTools,tool) end end
	table.sort(newTools,function(a,b)
		local aWeapon, bWeapon = Weapons[a.Name] ~= nil, Weapons[b.Name] ~= nil
		if aWeapon ~= bWeapon then return aWeapon end
		return (a.Name .. (a:GetAttribute("CoreId") or "")) < (b.Name .. (b:GetAttribute("CoreId") or ""))
	end)
	for _, tool in newTools do
		if Weapons[tool.Name] then table.insert(nextOrder,1,tool) else table.insert(nextOrder,tool) end
	end
	ordered = nextOrder
	for tool, card in cards do
		if not available[tool] then card:Destroy(); cards[tool] = nil end
	end
	for index, tool in ordered do
		local card = cards[tool] or create(tool)
		card.LayoutOrder = index
		card.KeyLabel.Text = index <= 9 and tostring(index) or ""
		card.KeyLabel.Visible = not Input.TouchEnabled and index <= 9
		local equipped = tool.Parent == player.Character
		card.SelectionStroke.Color = equipped and Color3.fromRGB(111,243,255) or Color3.fromRGB(9,12,20)
		card.SelectionStroke.Thickness = equipped and 3 or 2
		card.SelectedLabel.Visible = equipped
	end
	resize()
end
local function schedule()
	if queued then return end
	queued = true
	task.defer(refresh)
end
local function bind()
	for _, connection in connections do connection:Disconnect() end
	table.clear(connections)
	for _, container in {player:FindFirstChild("Backpack"), player.Character} do
		if container then
			table.insert(connections,container.ChildAdded:Connect(schedule))
			table.insert(connections,container.ChildRemoved:Connect(schedule))
		end
	end
	schedule()
end
local keys = {Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five,Enum.KeyCode.Six,Enum.KeyCode.Seven,Enum.KeyCode.Eight,Enum.KeyCode.Nine}
local function scroll(direction)
	local maximum = math.max(0,slots.AbsoluteCanvasSize.X-slots.AbsoluteWindowSize.X)
	slots.CanvasPosition = Vector2.new(math.clamp(slots.CanvasPosition.X+direction*192,0,maximum),0)
end
bar.PreviousButton.Activated:Connect(function() scroll(-1) end)
bar.NextButton.Activated:Connect(function() scroll(1) end)
slots.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then scroll(-input.Position.Z) end
end)
Input.InputBegan:Connect(function(input,processed)
	if processed or Input:GetFocusedTextBox() or not gui.Enabled then return end
	local index = table.find(keys,input.KeyCode)
	if index and ordered[index] then
		equip(ordered[index])
		slots.CanvasPosition = Vector2.new(math.max(0,(index-1)*96-slots.AbsoluteWindowSize.X/2),0)
	end
end)
player.CharacterAdded:Connect(function() task.spawn(disableDefault); bind() end)
player.ChildAdded:Connect(function(child) if child:IsA("Backpack") then bind() end end)
local viewportConnection
local function bindCamera()
	if viewportConnection then viewportConnection:Disconnect() end
	if workspace.CurrentCamera then viewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
	resize()
end
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
bindCamera()
bind()
require(Shared.MenuLayers).Bind(player.PlayerGui)()
return true
