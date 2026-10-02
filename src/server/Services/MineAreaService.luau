local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local MineAreaService = {}

local function ensureTrim(area, name, size, position, color, variant)
	local trim = area:FindFirstChild(name)
	if not trim or not trim:IsA("BasePart") then
		trim = Instance.new("Part")
		trim.Name = name
		trim.Parent = area
	end
	trim.Anchored = true
	trim.Size = size
	trim.Position = position
	trim.Color = color
	trim.Material = Enum.Material.Plastic
	trim.MaterialVariant = variant
	trim.TopSurface = variant == "" and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
	trim.BottomSurface = Enum.SurfaceType.Smooth
end

-- Slightly overlap the outer ore cells and overlap the four wall corners.
-- Client ore parts are 0.06 studs smaller than a grid cell, so a wall whose
-- inside face is exactly at the grid boundary leaves a visible hairline.
function MineAreaService.AlignSeams(area)
	local half = Config.Width * Config.BlockSize / 2
	local bottom = -Config.Depth * Config.BlockSize
	local wallTop = -0.5
	local wallHeight = wallTop - bottom
	local wallCenter = (wallTop + bottom) / 2
	local borderColor = Color3.fromRGB(32, 42, 58)
	local borderVariant = ""
	local hasRim = false
	for _, child in area:GetChildren() do
		if child:IsA("BasePart") and child.Name == "ShaftWall" then
			borderColor = child.Color
			borderVariant = child.MaterialVariant
			local p = child.Position
			if child.Size.X < child.Size.Z then
				child.Size = Vector3.new(2.4, wallHeight, half * 2 + 4)
				child.CFrame = CFrame.new(math.sign(p.X) * (half + 0.9), wallCenter, 0)
			else
				child.Size = Vector3.new(half * 2 + 4, wallHeight, 2.4)
				child.CFrame = CFrame.new(0, wallCenter, math.sign(p.Z) * (half + 0.9))
			end
		elseif child:IsA("BasePart") and child.Name == "Rim" then
			hasRim = true
			if child.Size.X > child.Size.Z then
				child.Size = Vector3.new(half * 2 + 2, child.Size.Y, child.Size.Z)
			else
				child.Size = Vector3.new(child.Size.X, child.Size.Y, half * 2 + 2)
			end
		end
	end
	if not hasRim then
		for _, sign in { -1, 1 } do
			local side = sign < 0 and "Negative" or "Positive"
			ensureTrim(area, "MineEdgeTrimX" .. side, Vector3.new(1.4, 0.8, half * 2 + 4), Vector3.new(sign * (half + 0.7), -0.1, 0), borderColor, borderVariant)
			ensureTrim(area, "MineEdgeTrimZ" .. side, Vector3.new(half * 2, 0.8, 1.4), Vector3.new(0, -0.1, sign * (half + 0.7)), borderColor, borderVariant)
		end
	end
end

-- Only the shared, non-diggable shell belongs here. Ore blocks are rendered
-- separately for each player by MineRenderer and must stay client-owned.
function MineAreaService.Build(parent, makePart)
	local area = Instance.new("Model")
	area.Name = "MineArea"
	area.Parent = parent
	local half = Config.Width * Config.BlockSize / 2
	local bottom = -Config.Depth * Config.BlockSize
	local wallTop = -0.5
	local wallHeight = wallTop - bottom
	local wallCenter = (wallTop + bottom) / 2
	local slate = Color3.fromRGB(32, 42, 58)
	local cyan = Color3.fromRGB(76, 227, 255)

	for _, sign in { -1, 1 } do
		makePart("Deck", Vector3.new(half * 2 + 32, 3, 16), Vector3.new(0, -1.5, sign * (half + 8)), slate, area)
		makePart("Deck", Vector3.new(16, 3, half * 2), Vector3.new(sign * (half + 8), -1.5, 0), slate, area)
		makePart("ShaftWall", Vector3.new(2.4, wallHeight, half * 2 + 4), Vector3.new(sign * (half + 0.9), wallCenter, 0), slate, area)
		makePart("ShaftWall", Vector3.new(half * 2 + 4, wallHeight, 2.4), Vector3.new(0, wallCenter, sign * (half + 0.9)), slate, area)
		makePart("Rim", Vector3.new(half * 2 + 2, 0.2, 0.35), Vector3.new(0, 0.12, sign * (half + 0.3)), cyan, area, Enum.Material.Neon)
		makePart("Rim", Vector3.new(0.35, 0.2, half * 2 + 2), Vector3.new(sign * (half + 0.3), 0.12, 0), cyan, area, Enum.Material.Neon)
	end
	makePart("Bedrock", Vector3.new(half * 2 + 4, 4, half * 2 + 4), Vector3.new(0, bottom - 2, 0), slate, area)
	MineAreaService.AlignSeams(area)
	return area
end

return MineAreaService
