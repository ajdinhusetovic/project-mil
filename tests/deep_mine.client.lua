-- Run in the client Command Bar during Play. Uses an isolated renderer instance.
local player = game.Players.LocalPlayer
local Config = require(game.ReplicatedStorage.Shared.Config)
local Grid = require(game.ReplicatedStorage.Shared.MineGrid)
local Materials = require(game.ReplicatedStorage.Shared.MaterialDefinitions)
local Renderer = require(player.PlayerScripts.Client.Controllers.MineRenderer)
assert(Config.Depth == 60, "depth")
Renderer.Generate()
assert(#Renderer.Folder():GetChildren() == 144, "initial surface")
local last = 0
for index, layer in Config.Layers do
	assert(layer.EndDepth > last, "ordered layers")
	assert(Grid.LayerIndex(last + 1) == index, "start boundary")
	assert(Grid.LayerIndex(layer.EndDepth) == index, "end boundary")
	local total = 0
	for _, material in layer.Materials do
		assert(Materials[material.Name], "material sell definition")
		total += material.Chance
	end
	assert(total == 100, "material weights")
	assert(layer.CoreChance > 0 and layer.ChargedChance >= 0 and layer.ChargedChance <= 1, "core chances")
	last = layer.EndDepth
end
assert(last == Config.Depth, "layer coverage")
for depth = 1, Config.Depth do
	for x = 1, Config.Width do
		for z = 1, Config.Width do
			local id = Grid.Id(x, depth, z)
			assert(Grid.IdAt(Grid.Position(x, depth, z)) == id, "coordinate roundtrip")
		end
	end
end
for depth = 1, Config.Depth do Renderer.Break(Grid.Id(6, depth, 6)) end
assert(#Renderer.Folder():GetChildren() < 500, "exposed geometry budget")
Renderer.SetHealth(Grid.Id(5, 60, 6), 123)
local found = false
for _, block in Renderer.Folder():GetChildren() do
	if block:GetAttribute("BlockId") == Grid.Id(5, 60, 6) then
		assert(block:GetAttribute("Health") == 123, "health update")
		found = true
	end
end
assert(found, "bottom neighbors exposed")
Renderer.Break(Grid.Id(6, 60, 6))
Renderer.SetHealth(Grid.Id(6, 60, 6), 123)
for _, block in Renderer.Folder():GetChildren() do
	assert(block:GetAttribute("BlockId") ~= Grid.Id(6, 60, 6), "broken cells stay removed")
end
Renderer.Generate()
assert(#Renderer.Folder():GetChildren() == 144, "reset")
assert(math.abs(workspace.MineArea.Bedrock.Position.Y + workspace.MineArea.Bedrock.Size.Y / 2 + 360) < 0.01, "bedrock alignment")
print("DEEP MINE GRID, LAYERS, EXPOSURE, HEALTH, RESET AND BEDROCK PASS")
-- Remove the test renderer so it cannot overlap the running game's parts.
Renderer.Folder():Destroy()
