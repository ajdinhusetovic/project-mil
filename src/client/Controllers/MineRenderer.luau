local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Grid = require(ReplicatedStorage.Shared.MineGrid)
local Impact = require(script.Parent.MiningImpactEffects)

local MineRenderer = {}
local folder = Instance.new("Folder")
folder.Name = "PersonalMineBlocks"
folder.Parent = workspace
local byId = {}
-- Buried cells stay in the logical grid until a neighboring cell is removed.
-- This keeps the initial 360-stud mine at 144 visible parts instead of 8,640.
local broken = {}
local healthById = {}
local neighbors = { {1, 0, 0}, {-1, 0, 0}, {0, 1, 0}, {0, -1, 0}, {0, 0, 1}, {0, 0, -1} }

local function reveal(x, depth, z)
	if x < 1 or x > Config.Width or z < 1 or z > Config.Width or depth < 1 or depth > Config.Depth then return end
	local id = Grid.Id(x, depth, z)
	if broken[id] or byId[id] then return end
	local layer = Grid.Layer(depth)
	local block = Instance.new("Part")
	block.Name = "Ore"
	block.Anchored = true
	block.Size = Vector3.one * (Config.BlockSize - 0.06)
	block.Position = Grid.Position(x, depth, z)
	block.Color = Grid.Color(x, depth, z)
	block.Material = Enum.Material.SmoothPlastic
	block.TopSurface = Enum.SurfaceType.Smooth
	block.BottomSurface = Enum.SurfaceType.Smooth
	block:SetAttribute("BlockId", id)
	block:SetAttribute("Health", healthById[id] or layer.Health)
	block:SetAttribute("MaxHealth", layer.Health)
	block:SetAttribute("Layer", layer.Name)
	byId[id] = block
	block.Parent = folder
end

function MineRenderer.Folder()
	return folder
end

function MineRenderer.Generate()
	Impact.Reset()
	folder:ClearAllChildren()
	table.clear(byId)
	table.clear(broken)
	table.clear(healthById)
	for x = 1, Config.Width do
		for z = 1, Config.Width do reveal(x, 1, z) end
	end
end

function MineRenderer.SetHealth(id, health)
	if broken[id] then return end
	-- Chain damage can reach buried neighbors; remember it without exposing them.
	healthById[id] = health
	local block = byId[id]
	if block then
		block:SetAttribute("Health", health)
		Impact.Hit(block, health)
	end
end

function MineRenderer.Break(id)
	if broken[id] then return end
	broken[id] = true
	healthById[id] = nil
	local block = byId[id]
	byId[id] = nil
	if block then
		Impact.Clear(block)
		block:Destroy()
	end
	local x, depth, z = Grid.Coordinates(id)
	for _, delta in neighbors do reveal(x + delta[1], depth + delta[2], z + delta[3]) end
end

return MineRenderer
