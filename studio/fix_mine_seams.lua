-- Run once in Roblox Studio's Command Bar in Edit mode.
-- Updates only the existing mine walls and rim; preserves colors and materials.
local Config = require(game.ReplicatedStorage.Shared.Config)
local area = workspace:FindFirstChild("MineArea")
assert(area, "Workspace.MineArea is missing")
local half = Config.Width * Config.BlockSize / 2
local bottom = -Config.Depth * Config.BlockSize
local wallTop = -0.5
local wallHeight = wallTop - bottom
local wallCenter = (wallTop + bottom) / 2
local walls = 0
local borderColor = Color3.fromRGB(32, 42, 58)
local borderVariant = ""
local hasRim = false
for _, child in area:GetChildren() do
	if child:IsA("BasePart") and child.Name == "ShaftWall" then
		borderColor = child.Color
		borderVariant = child.MaterialVariant
		local position = child.Position
		if child.Size.X < child.Size.Z then
			child.Size = Vector3.new(2.4, wallHeight, half * 2 + 4)
			child.CFrame = CFrame.new(math.sign(position.X) * (half + 0.9), wallCenter, 0)
		else
			child.Size = Vector3.new(half * 2 + 4, wallHeight, 2.4)
			child.CFrame = CFrame.new(0, wallCenter, math.sign(position.Z) * (half + 0.9))
		end
		walls += 1
	elseif child:IsA("BasePart") and child.Name == "Rim" then
		hasRim = true
		if child.Size.X > child.Size.Z then
			child.Size = Vector3.new(half * 2 + 2, child.Size.Y, child.Size.Z)
		else
			child.Size = Vector3.new(child.Size.X, child.Size.Y, half * 2 + 2)
		end
	end
end
assert(walls == 4, `Expected 4 ShaftWalls, found {walls}`)
local function trim(name, size, position)
	local item = area:FindFirstChild(name)
	if not item or not item:IsA("BasePart") then
		item = Instance.new("Part")
		item.Name = name
		item.Parent = area
	end
	item.Anchored = true
	item.Size = size
	item.Position = position
	item.Color = borderColor
	item.Material = Enum.Material.Plastic
	item.MaterialVariant = borderVariant
	item.TopSurface = borderVariant == "" and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
end
if not hasRim then
	for _, sign in { -1, 1 } do
		local side = sign < 0 and "Negative" or "Positive"
		trim("MineEdgeTrimX" .. side, Vector3.new(1.4, 0.8, half * 2 + 4), Vector3.new(sign * (half + 0.7), -0.1, 0))
		trim("MineEdgeTrimZ" .. side, Vector3.new(half * 2, 0.8, 1.4), Vector3.new(0, -0.1, sign * (half + 0.7)))
	end
end
print("Aligned MineArea shaft walls and rim with the personal ore grid.")
