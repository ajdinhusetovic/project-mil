-- Run once in Roblox Studio's Command Bar while NOT playing.
-- Makes the colorful lobby permanent and editable in Workspace.Lobby.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ReplicatedStorage.Shared.Config)
local services = ServerScriptService.Server.Services
local LobbyService = require(services.LobbyService)
local WorldService = require(services.WorldService)

if workspace:FindFirstChild("Lobby") then
	warn("Workspace.Lobby already exists. Edit that copy in Explorer; nothing was overwritten.")
	return
end

local function makePart(name, size, position, color, parent, material)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.Position = position
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Anchored = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local half = Config.Width * Config.BlockSize / 2
local positions = LobbyService.Build(workspace, makePart, half)
local lobby = workspace.Lobby
WorldService.BuildStoreModel("WeaponStore", "WEAPON SHOP", positions.WeaponShop, Color3.fromRGB(255, 167, 43), lobby)
WorldService.BuildStoreModel("UpgradeStore", "UPGRADES", positions.UpgradeShop, Color3.fromRGB(174, 79, 255), lobby)

local spawn = Instance.new("SpawnLocation")
spawn.Name = "LobbySpawn"
spawn.Size = Vector3.new(9, 0.3, 9)
spawn.Position = positions.Spawn
spawn.Anchored = true
spawn.Neutral = true
spawn.Duration = 0
spawn.Color = Color3.fromRGB(77, 231, 255)
spawn.Material = Enum.Material.Neon
spawn.Parent = lobby

local oldSpawn = workspace:FindFirstChild("SpawnLocation")
if oldSpawn and oldSpawn:IsA("SpawnLocation") then
	oldSpawn.Enabled = false
	oldSpawn.Transparency = 1
	oldSpawn.CanCollide = false
end

local npc = workspace:FindFirstChild("showcase npc")
if npc and npc:IsA("Model") then
	npc:PivotTo(CFrame.new(positions.SellNpc) * npc:GetPivot().Rotation)
	local sample = npc:FindFirstChild("dialogScript")
	if sample and (sample:IsA("Script") or sample:IsA("LocalScript")) then sample.Enabled = false end
	local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.ActionText = "Talk"
		prompt.ObjectText = "Ore Buyer"
		prompt.MaxActivationDistance = 10
	end
	local head = npc:FindFirstChild("Head")
	local board = head and head:FindFirstChild("gui")
	local name = board and board:FindFirstChild("name")
	if name and name:IsA("TextLabel") then name.Text = "ORE BUYER" end
end

print("Created editable Workspace.Lobby with shop stands, sell stand, paths, trees, walls, mine gate, and spawn.")
