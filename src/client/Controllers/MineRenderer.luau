local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Grid = require(ReplicatedStorage.Shared.MineGrid)
local Impact = require(script.Parent.MiningImpactEffects)

local MineRenderer = {}
local folder = Instance.new("Folder")
folder.Name = "PersonalMineBlocks"
folder.Parent = workspace
local byId = {}
local generation = 0

function MineRenderer.Folder()
	return folder
end

function MineRenderer.Generate()
	generation += 1
	Impact.Reset()
	local thisGeneration = generation
	folder:ClearAllChildren()
	table.clear(byId)
	local made = 0
	for depth = 1, Config.Depth do
		local layer = Grid.Layer(depth)
		for x = 1, Config.Width do
			for z = 1, Config.Width do
				if thisGeneration ~= generation then return end
				local id = Grid.Id(x, depth, z)
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
				block:SetAttribute("Health", layer.Health)
				block:SetAttribute("MaxHealth", layer.Health)
				block:SetAttribute("Layer", layer.Name)
				byId[id] = block
				block.Parent = folder
				made += 1
				if made % 144 == 0 then task.wait() end
			end
		end
	end
end

function MineRenderer.SetHealth(id, health)
	local block = byId[id]
	if block then
		block:SetAttribute("Health", health)
		Impact.Hit(block, health)
	end
end

function MineRenderer.Break(id)
	local block = byId[id]
	if not block then return end
	byId[id] = nil
	Impact.Clear(block)
	block:Destroy()
end

return MineRenderer
