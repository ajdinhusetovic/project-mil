local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local WeaponDefinitions = require(ReplicatedStorage.Shared.WeaponDefinitions)
local LobbyService = require(script.Parent.LobbyService)
local MineAreaService = require(script.Parent.MineAreaService)

local WorldService = {}
local world
local spawnPart
local storagePrompt
local weaponPrompt

local function makePart(name, size, position, color, parent, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeStore(name, title, action, position, color, parent)
	local store = Instance.new("Model")
	store.Name = name
	store:SetAttribute("ShopType", name == "UpgradeStore" and "Upgrades" or "Weapons")
	store.Parent = parent or world
	local dark = Color3.fromRGB(74, 64, 83)
	makePart("Floor", Vector3.new(21, 0.45, 17), position + Vector3.new(0, 0.22, 0), Color3.fromRGB(255, 216, 72), store).TopSurface = Enum.SurfaceType.Studs
	makePart("BackWall", Vector3.new(21, 7, 1), position + Vector3.new(0, 3.5, -7.8), color, store).FrontSurface = Enum.SurfaceType.Studs
	for _, side in { -1, 1 } do
		makePart("FrontPost", Vector3.new(1.5, 9, 1.5), position + Vector3.new(side * 9.5, 4.5, 7), Color3.fromRGB(184, 104, 43), store).TopSurface = Enum.SurfaceType.Studs
	end
	local roof = makePart("StripedRoof", Vector3.new(22, 1, 18), position + Vector3.new(0, 9.4, 0), color, store)
	for x = -8, 8, 4 do
		makePart("RoofStripe", Vector3.new(2.1, 0.12, 18), position + Vector3.new(x, 10, 0), Color3.fromRGB(255, 241, 101), store)
	end
	local counter = makePart("Counter", Vector3.new(16, 2.2, 2), position + Vector3.new(0, 1.1, 4), dark, store)
	counter:SetAttribute("StoreType", name)
	if name == "WeaponStore" then
		local body = makePart("DisplayZapper", Vector3.new(4.5, 1.5, 1.5), position + Vector3.new(0, 4.3, 0), Color3.fromRGB(42, 58, 92), store)
		body.CanCollide = false
		makePart("DisplayCoil", Vector3.new(1.2, 1.8, 1.8), position + Vector3.new(2.6, 4.3, 0), Color3.fromRGB(91, 225, 255), store, Enum.Material.Neon).CanCollide = false
		makePart("DisplayGrip", Vector3.new(1.1, 2.5, 1.1), position + Vector3.new(-1.5, 2.7, 0), Color3.fromRGB(34, 43, 61), store).CanCollide = false
	else
		makePart("DisplayBag", Vector3.new(4.2, 4.5, 2.2), position + Vector3.new(0, 4.1, 0), Color3.fromRGB(255, 166, 43), store).CanCollide = false
		makePart("BagPocket", Vector3.new(2.8, 1.6, 0.35), position + Vector3.new(0, 3.2, 1.3), Color3.fromRGB(229, 104, 26), store).CanCollide = false
		for _, x in { -1.4, 1.4 } do
			makePart("BagStrap", Vector3.new(0.45, 3.5, 0.4), position + Vector3.new(x, 5, -1.3), Color3.fromRGB(97, 55, 38), store).CanCollide = false
		end
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Interact"
	prompt.ActionText = action
	prompt.ObjectText = title
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = counter
	local sign = Instance.new("BillboardGui")
	sign.Name = "StoreSign"
	sign.Size = UDim2.fromScale(12, 3)
	sign.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
	sign.AlwaysOnTop = true
	sign.MaxDistance = 115
	sign.Parent = roof
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.FredokaOne
	text.TextScaled = true
	text.Text = title
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Parent = sign
	local outline = Instance.new("UIStroke")
	outline.Color = Color3.new(0, 0, 0)
	outline.Thickness = 3
	outline.Parent = text
	return prompt
end

function WorldService.BuildStoreModel(name, title, position, color, parent)
	return makeStore(name, title, "Open shop", position, color, parent)
end

local function findOrCreateShopPrompt(name, title, action)
	local model = workspace:FindFirstChild(name, true)
	if not model or not model:IsA("Model") then return nil end
	local part = model:FindFirstChild("Counter", true) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	if not part or not part:IsA("BasePart") then return nil end
	model:SetAttribute("ShopType", name == "UpgradeStore" and "Upgrades" or "Weapons")
	local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "OpenShop"
		prompt.Parent = part
	end
	prompt.ActionText = "Open shop"
	prompt.ObjectText = title
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	return prompt
end

function WorldService.Initialize()
	local npc = WorldService.GetSellNpc()
	if npc then
		local showcaseScript = npc:FindFirstChild("dialogScript")
		if showcaseScript and (showcaseScript:IsA("Script") or showcaseScript:IsA("LocalScript")) then
			showcaseScript.Enabled = false
		end
	end
	Lighting.ClockTime = 14
	Lighting.Brightness = 3
	Lighting.Ambient = Color3.fromRGB(175, 190, 205)
	Lighting.OutdoorAmbient = Color3.fromRGB(200, 212, 222)
	world = Instance.new("Folder")
	world.Name = "MiningDemo"
	world.Parent = workspace
	local half = Config.Width * Config.BlockSize / 2
	if not workspace:FindFirstChild("MineArea") then
		MineAreaService.Build(world, makePart)
	end
	local authoredLobby = workspace:FindFirstChild("Lobby")
	local lobby = authoredLobby and LobbyService.Positions() or LobbyService.Build(world, makePart, half)
	local oldSpawn = workspace:FindFirstChild("SpawnLocation")
	if oldSpawn and oldSpawn:IsA("SpawnLocation") then
		oldSpawn.Enabled = false
		oldSpawn.Transparency = 1
		oldSpawn.CanCollide = false
	end
	if npc then
		npc:PivotTo(CFrame.new(lobby.SellNpc) * npc:GetPivot().Rotation)
	end
	spawnPart = authoredLobby and authoredLobby:FindFirstChild("LobbySpawn")
	if not spawnPart or not spawnPart:IsA("SpawnLocation") then
		spawnPart = Instance.new("SpawnLocation")
		spawnPart.Name = "Surface"
		spawnPart.Size = Vector3.new(9, 0.3, 9)
		spawnPart.Position = lobby.Spawn
		spawnPart.Anchored = true
		spawnPart.Neutral = true
		spawnPart.Duration = 0
		spawnPart.Color = Color3.fromRGB(77, 231, 255)
		spawnPart.Material = Enum.Material.Neon
		spawnPart.Parent = world
	end
	storagePrompt = findOrCreateShopPrompt("UpgradeStore", "UPGRADES", "Open shop")
		or makeStore("UpgradeStore", "UPGRADES", "Open shop", lobby.UpgradeShop, Color3.fromRGB(174, 79, 255))
	weaponPrompt = findOrCreateShopPrompt("WeaponStore", "WEAPON SHOP", "Open shop")
		or makeStore("WeaponStore", "WEAPON SHOP", "Open shop", lobby.WeaponShop, Color3.fromRGB(255, 167, 43))
end

function WorldService.GetSellNpc()
	return workspace:FindFirstChild("showcase npc")
end

function WorldService.GetStoragePrompt()
	return storagePrompt
end

function WorldService.GetWeaponPrompt()
	return weaponPrompt
end

function WorldService.Surface(player)
	local character = player.Character
	if not character then return end
	character:PivotTo(CFrame.lookAt(spawnPart.Position + Vector3.new(0, 4, 0), Vector3.new(0, 3, 0)))
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then root.AssemblyLinearVelocity = Vector3.zero end
end

function WorldService.GiveEquippedTool(player, character, weaponName, moveToSurface)
	local humanoid = character:WaitForChild("Humanoid")
	local backpack = player:WaitForChild("Backpack")
	local definition = WeaponDefinitions[weaponName]
	if not definition then return end
	for _, container in { backpack, character } do
		for _, child in container:GetChildren() do
			if child:IsA("Tool") and WeaponDefinitions[child.Name] then child:Destroy() end
		end
	end
	local templates = ServerStorage:FindFirstChild("WeaponTools")
	local template = templates and templates:FindFirstChild(weaponName)
	local tool
	local templateHandle = template and template:FindFirstChild("Handle")
	if template and template:IsA("Tool") and templateHandle and templateHandle:IsA("BasePart") then
		tool = template:Clone()
		tool.Name = weaponName
		tool.CanBeDropped = false
		local handle = tool.Handle
		local existingMuzzle = handle:FindFirstChild("Muzzle")
		if existingMuzzle and not existingMuzzle:IsA("Attachment") then
			existingMuzzle.Name = "OldMuzzle"
			existingMuzzle = nil
		end
		if not existingMuzzle then
			local muzzle = Instance.new("Attachment")
			muzzle.Name = "Muzzle"
			muzzle.Position = Vector3.new(0, 0, -handle.Size.Z / 2)
			muzzle.Parent = handle
		end
	else
		-- One simple placeholder shape for every tier until custom Tools are supplied.
		tool = Instance.new("Tool")
		tool.Name = weaponName
		tool.CanBeDropped = false
		tool.Grip = CFrame.new(0, -0.25, 0.3)
		local handle = makePart("Handle", Vector3.new(0.7, 1.1, 2.4), Vector3.zero, Color3.fromRGB(32, 42, 58), tool)
		handle.Anchored = false
		handle.CanCollide = false
		handle.Massless = true
		local tip = makePart("Coil", Vector3.new(0.85, 0.85, 0.5), Vector3.new(0, 0, -1.25), definition.Color, tool, Enum.Material.Neon)
		tip.Anchored = false
		tip.CanCollide = false
		tip.Massless = true
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = tip
		weld.Parent = handle
		local muzzle = Instance.new("Attachment")
		muzzle.Name = "Muzzle"
		muzzle.Position = Vector3.new(0, 0, -1.55)
		muzzle.Parent = handle
	end
	tool.Parent = backpack
	humanoid:EquipTool(tool)
	if moveToSurface then WorldService.Surface(player) end
end

return WorldService
