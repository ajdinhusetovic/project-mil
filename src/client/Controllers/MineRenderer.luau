local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Grid = require(ReplicatedStorage.Shared.MineGrid)
local Visuals = require(ReplicatedStorage.Shared.BlockVisuals)
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
-- Compact opaque runs fill buried cells. Otherwise the camera sees through the
-- exposed shell into an empty shaft, even though those cells still exist logically.
local interior = Instance.new("Folder")
interior.Name = "PersonalMineInterior"
interior.Parent = workspace
local columns = {}
local function rebuildColumn(x, z)
	local key = (x - 1) * Config.Width + z
	local previous = columns[key]
	if previous then previous:Destroy() end
	local column = Instance.new("Folder")
	column.Name = tostring(key)
	column.Parent = interior
	columns[key] = column
	local first
	local function finish(last)
		if not first then return end
		local fill = Instance.new("Part")
		fill.Name = "BuriedRock"
		-- Also let Roblox's camera avoid buried rock instead of passing behind the shell.
		fill.Anchored, fill.CanCollide, fill.CanTouch, fill.CanQuery = true, true, false, true
		fill.Size = Vector3.new(Config.BlockSize, (last - first + 1) * Config.BlockSize, Config.BlockSize)
		fill.Position = (Grid.Position(x, first, z) + Grid.Position(x, last, z)) / 2
		fill.Color = Grid.Layer(first).Color
		fill.Material = Enum.Material.SmoothPlastic
		fill.TopSurface, fill.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		fill.Parent = column
		first = nil
	end
	for depth = 1, Config.Depth do
		local id = Grid.Id(x, depth, z)
		if not broken[id] and not byId[id] then
			first = first or depth
		else
			finish(depth - 1)
		end
	end
	finish(Config.Depth)
end
local neighbors = { {1, 0, 0}, {-1, 0, 0}, {0, 1, 0}, {0, -1, 0}, {0, 0, 1}, {0, 0, -1} }

local function reveal(x, depth, z)
	if x < 1 or x > Config.Width or z < 1 or z > Config.Width or depth < 1 or depth > Config.Depth then return end
	local id = Grid.Id(x, depth, z)
	if broken[id] or byId[id] then return end
	local layer = Grid.Layer(depth)
	local block = Instance.new("Part")
	block.Name = "Ore"
	block.Anchored = true
	block.Size = Vector3.one * Config.BlockSize
	block.Position = Grid.Position(x, depth, z)
	local material = Grid.Material(x, depth, z)
	block.Color = material.Color
	block.Material = Enum.Material.SmoothPlastic
	block.TopSurface = Enum.SurfaceType.Smooth
	block.BottomSurface = Enum.SurfaceType.Smooth
	block:SetAttribute("BlockId", id)
	block:SetAttribute("Health", healthById[id] or layer.Health)
	block:SetAttribute("MaxHealth", layer.Health)
	block:SetAttribute("Layer", layer.Name)
	block:SetAttribute("MaterialName", material.Name)
	Visuals.Attach(block, material.Name)
	byId[id] = block
	block.Parent = folder
end

function MineRenderer.Folder()
	return folder
end

function MineRenderer.Generate()
	Impact.Reset()
	folder:ClearAllChildren()
	interior:ClearAllChildren()
	table.clear(columns)
	table.clear(byId)
	table.clear(broken)
	table.clear(healthById)
	for x = 1, Config.Width do
		for z = 1, Config.Width do reveal(x, 1, z) end
	end
	for x = 1, Config.Width do
		for z = 1, Config.Width do rebuildColumn(x, z) end
	end
end

function MineRenderer.SetHealth(id, health)
	if broken[id] then return end
	-- Chain damage can reach buried neighbors; remember it without exposing them.
	healthById[id] = health
	local block = byId[id]
	if block then
		local previous = block:GetAttribute("Health")
		block:SetAttribute("Health", health)
		Impact.Hit(block, health, previous - health)
	end
end

function MineRenderer.Break(id)
	if broken[id] then return end
	broken[id] = true
	healthById[id] = nil
	local block = byId[id]
	byId[id] = nil
	if block then
		Impact.Finish(block)
		Impact.Clear(block)
		block:Destroy()
	end
	local x, depth, z = Grid.Coordinates(id)
	for _, delta in neighbors do reveal(x + delta[1], depth + delta[2], z + delta[3]) end
	rebuildColumn(x, z)
	for _, delta in { {1, 0}, {-1, 0}, {0, 1}, {0, -1} } do
		local nx, nz = x + delta[1], z + delta[2]
		if nx >= 1 and nx <= Config.Width and nz >= 1 and nz <= Config.Width then rebuildColumn(nx, nz) end
	end
end

return MineRenderer
