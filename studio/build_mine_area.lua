-- Run once in Roblox Studio's Command Bar in Edit mode.
-- Creates an editable Workspace.MineArea; personal ore still appears in Play.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Config = require(ReplicatedStorage.Shared.Config)
local MineAreaService = require(ServerScriptService.Server.Services.MineAreaService)

if workspace:FindFirstChild("MineArea") then
	warn("Workspace.MineArea already exists. Edit it in Explorer; nothing was overwritten.")
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

local mineArea = MineAreaService.Build(workspace, makePart)
local lobby = workspace:FindFirstChild("Lobby")
if lobby then
	for _, name in { "MineGatePost", "MineGateLight", "MineGateBeam" } do
		for _, child in lobby:GetChildren() do
			if child.Name == name then child.Parent = mineArea end
		end
	end
end

print(string.format("Created editable Workspace.MineArea for the %d×%d×%d mine shell. Ore blocks stay personal during Play.", Config.Width, Config.Width, Config.Depth))
