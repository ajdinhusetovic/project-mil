local Config = require(script.Parent.Config)

local Grid = {}
local size = Config.BlockSize
local half = Config.Width * size / 2

function Grid.Id(x, depth, z)
	return ((depth - 1) * Config.Width + (x - 1)) * Config.Width + z
end

function Grid.Coordinates(id)
	local zero = id - 1
	local z = zero % Config.Width + 1
	local x = math.floor(zero / Config.Width) % Config.Width + 1
	local depth = math.floor(zero / (Config.Width * Config.Width)) + 1
	return x, depth, z
end

function Grid.Position(x, depth, z)
	return Vector3.new((x - 0.5) * size - half, -(depth - 0.5) * size, (z - 0.5) * size - half)
end

function Grid.IdAt(position)
	local x = math.floor((position.X + half) / size) + 1
	local depth = math.floor(-position.Y / size) + 1
	local z = math.floor((position.Z + half) / size) + 1
	if x < 1 or x > Config.Width or z < 1 or z > Config.Width or depth < 1 or depth > Config.Depth then return nil end
	return Grid.Id(x, depth, z)
end

function Grid.Layer(depth)
	return Config.Layers[math.ceil(depth / (Config.Depth / #Config.Layers))]
end

function Grid.Material(x, depth, z)
	local layer = Grid.Layer(depth)
	local roll = (x * 17 + z * 31 + depth * 13) % 100
	local cursor = 0
	for _, material in layer.Materials do
		cursor += material.Chance
		if roll < cursor then return material end
	end
	return layer.Materials[#layer.Materials]
end

function Grid.Color(x, depth, z)
	local layer = Grid.Layer(depth)
	local tint = ((x * 7 + z * 3 + depth) % 5 - 2) * 0.018
	return layer.Color:Lerp(tint > 0 and Color3.new(1, 1, 1) or Color3.new(), math.abs(tint))
end

return Grid
