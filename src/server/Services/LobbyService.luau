local LobbyService = {}

local green = Color3.fromRGB(40, 219, 31)
local grassDark = Color3.fromRGB(30, 184, 34)
local orange = Color3.fromRGB(231, 111, 27)
local stone = Color3.fromRGB(112, 132, 164)
local stoneLight = Color3.fromRGB(153, 171, 195)
local wood = Color3.fromRGB(183, 105, 43)

function LobbyService.Positions()
	return {
		Spawn = Vector3.new(0, 0.15, 143),
		WeaponShop = Vector3.new(-45, 0, 91),
		UpgradeShop = Vector3.new(-18, 0, 91),
		SellNpc = Vector3.new(38, 0, 101),
	}
end

local function sign(part, title, offset, width)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = title .. "Sign"
	billboard.Size = UDim2.fromScale((width or 205) / 17, 3)
	billboard.StudsOffsetWorldSpace = offset
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 170
	billboard.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Parent = billboard
	local outline = Instance.new("UIStroke")
	outline.Color = Color3.new(0, 0, 0)
	outline.Thickness = 3
	outline.Parent = label
end

function LobbyService.Build(world, part, half)
	local lobby = Instance.new("Folder")
	lobby.Name = "Lobby"
	lobby.Parent = world

	local lawn = part("GrassPlaza", Vector3.new(160, 3, 112), Vector3.new(0, -1.5, 106), green, lobby)
	lawn.TopSurface = Enum.SurfaceType.Studs
	for _, x in { -61, -38, -14, 14, 38, 61 } do
		for _, z in { 64, 76, 90, 126, 147 } do
			local patch = part("GrassTile", Vector3.new(18, 0.1, 16), Vector3.new(x, 0.06, z), grassDark, lobby)
			patch.TopSurface = Enum.SurfaceType.Studs
		end
	end

	-- A broad stone runway connects the spawn plaza with the existing mine.
	local mainPath = part("MineWalkway", Vector3.new(17, 0.22, 108), Vector3.new(0, 0.13, 106), stone, lobby)
	mainPath.TopSurface = Enum.SurfaceType.Studs
	local crossPath = part("ShopWalkway", Vector3.new(133, 0.22, 17), Vector3.new(0, 0.14, 112), stoneLight, lobby)
	crossPath.TopSurface = Enum.SurfaceType.Studs
	for _, z in { 58, 69, 80, 91, 102, 123, 134, 145 } do
		part("PathSeam", Vector3.new(17, 0.04, 0.22), Vector3.new(0, 0.26, z), Color3.fromRGB(65, 79, 108), lobby)
	end
	for _, x in { -63, -42, -21, 21, 42, 63 } do
		part("CrossPathSeam", Vector3.new(0.2, 0.04, 17), Vector3.new(x, 0.26, 112), Color3.fromRGB(88, 103, 132), lobby)
	end

	-- The red display pad and two raised display plinths echo the reference image.
	local redPad = part("RedDisplayPad", Vector3.new(42, 0.35, 25), Vector3.new(47, 0.21, 65), Color3.fromRGB(221, 30, 57), lobby)
	redPad.TopSurface = Enum.SurfaceType.Studs
	for _, dx in { -21, 21 } do
		part("GoldPadEdge", Vector3.new(1.2, 0.12, 27), Vector3.new(47 + dx, 0.46, 65), Color3.fromRGB(255, 197, 26), lobby)
	end
	for _, dz in { -13, 13 } do
		part("GoldPadEdge", Vector3.new(42, 0.12, 1.2), Vector3.new(47, 0.46, 65 + dz), Color3.fromRGB(255, 197, 26), lobby)
	end
	for _, x in { -54, 55 } do
		local plinth = part("DisplayPlatform", Vector3.new(20, 3, 21), Vector3.new(x, 1.5, 59), stone, lobby)
		plinth.TopSurface = Enum.SurfaceType.Studs
		part("DisplayTrim", Vector3.new(21, 0.45, 22), Vector3.new(x, 3.15, 59), Color3.fromRGB(255, 206, 29), lobby)
	end

	-- Saturated brick walls and a green lip frame the lobby without closing its sky.
	for _, x in { -82, 82 } do
		local wall = part("OrangeSideWall", Vector3.new(4, 24, 116), Vector3.new(x, 12, 106), orange, lobby)
		wall.TopSurface = Enum.SurfaceType.Studs
		wall.FrontSurface = Enum.SurfaceType.Studs
		part("GreenWallCap", Vector3.new(5, 2, 118), Vector3.new(x, 25, 106), green, lobby).TopSurface = Enum.SurfaceType.Studs
	end
	local backWall = part("OrangeBackWall", Vector3.new(168, 24, 4), Vector3.new(0, 12, 164), orange, lobby)
	backWall.TopSurface = Enum.SurfaceType.Studs
	backWall.FrontSurface = Enum.SurfaceType.Studs
	part("GreenBackCap", Vector3.new(168, 2, 5), Vector3.new(0, 25, 164), green, lobby).TopSurface = Enum.SurfaceType.Studs

	-- Chunky trees, low fences and flower dots keep the plaza legible and playful.
	for _, spot in {
		Vector3.new(-70, 0, 66), Vector3.new(-69, 0, 133), Vector3.new(-64, 0, 148),
		Vector3.new(-30, 0, 137), Vector3.new(28, 0, 137), Vector3.new(70, 0, 70),
		Vector3.new(69, 0, 132), Vector3.new(60, 0, 149),
	} do
		part("TreeTrunk", Vector3.new(3.5, 10, 3.5), spot + Vector3.new(0, 5, 0), wood, lobby).TopSurface = Enum.SurfaceType.Studs
		part("TreeLeaf", Vector3.new(11, 6, 11), spot + Vector3.new(0, 12, 0), Color3.fromRGB(27, 196, 26), lobby).TopSurface = Enum.SurfaceType.Studs
		part("TreeLeaf", Vector3.new(8, 5, 8), spot + Vector3.new(0, 17, 0), green, lobby).TopSurface = Enum.SurfaceType.Studs
		part("TreeLeaf", Vector3.new(5, 4, 5), spot + Vector3.new(0, 21, 0), Color3.fromRGB(73, 236, 36), lobby).TopSurface = Enum.SurfaceType.Studs
	end
	for _, x in { -73, -59, 59, 73 } do
		for _, z in { 97, 109 } do
			part("FencePost", Vector3.new(1.1, 5, 1.1), Vector3.new(x, 2.5, z), wood, lobby)
		end
		part("FenceRail", Vector3.new(0.55, 0.75, 12), Vector3.new(x, 3.4, 103), Color3.fromRGB(241, 162, 67), lobby)
	end
	for i = 1, 35 do
		local x = (i * 37 % 138) - 69
		local z = 56 + (i * 53 % 96)
		if math.abs(x) > 12 and math.abs(z - 112) > 12 then
			local color = i % 3 == 0 and Color3.fromRGB(255, 98, 184) or (i % 3 == 1 and Color3.fromRGB(255, 226, 49) or Color3.fromRGB(109, 245, 255))
			part("Flower", Vector3.new(0.85, 0.45, 0.85), Vector3.new(x, 0.4, z), color, lobby, Enum.Material.Neon)
		end
	end

	-- The entrance is a landmark; the space under the beam stays walkable.
	for _, x in { -12, 12 } do
		part("MineGatePost", Vector3.new(2, 13, 2), Vector3.new(x, 6.5, half + 17), Color3.fromRGB(235, 132, 31), lobby).TopSurface = Enum.SurfaceType.Studs
		part("MineGateLight", Vector3.new(2.3, 1.2, 2.3), Vector3.new(x, 12.2, half + 17), Color3.fromRGB(73, 236, 255), lobby, Enum.Material.Neon)
	end
	local beam = part("MineGateBeam", Vector3.new(27, 3, 3), Vector3.new(0, 13, half + 17), Color3.fromRGB(255, 178, 30), lobby)
	sign(beam, "⚡ MINE ⚡", Vector3.new(0, 2.5, 0), 245)

	-- The sell stall belongs to the existing toolbox NPC dialogue model.
	local sell = Instance.new("Model")
	sell.Name = "SellStand"
	sell.Parent = lobby
	local center = Vector3.new(38, 0, 91)
	part("Floor", Vector3.new(20, 0.45, 17), center + Vector3.new(0, 0.22, 0), Color3.fromRGB(255, 213, 55), sell).TopSurface = Enum.SurfaceType.Studs
	part("BackWall", Vector3.new(20, 7, 1), center + Vector3.new(0, 3.5, -7.8), Color3.fromRGB(247, 145, 47), sell).FrontSurface = Enum.SurfaceType.Studs
	for _, x in { -9, 9 } do
		part("FrontPost", Vector3.new(1.5, 9, 1.5), center + Vector3.new(x, 4.5, 7), wood, sell).TopSurface = Enum.SurfaceType.Studs
	end
	local roof = part("StripedRoof", Vector3.new(21, 1, 18), center + Vector3.new(0, 9.4, 0), Color3.fromRGB(255, 236, 64), sell)
	for x = -8, 8, 4 do
		part("RoofStripe", Vector3.new(2.1, 0.12, 18), center + Vector3.new(x, 10, 0), Color3.fromRGB(255, 88, 59), sell)
	end
	sign(roof, "SELL ORE", Vector3.new(0, 3, 0), 205)
	part("Counter", Vector3.new(15, 2.2, 2), center + Vector3.new(0, 1.1, 4), Color3.fromRGB(222, 107, 32), sell)
	for i = -1, 1 do
		part("CashBundle", Vector3.new(1.5, 0.5, 2), center + Vector3.new(i * 2, 2.5, 3.7), Color3.fromRGB(63, 217, 36), sell).CanCollide = false
		part("CashBand", Vector3.new(0.4, 0.55, 2.1), center + Vector3.new(i * 2, 2.55, 3.7), Color3.fromRGB(255, 213, 43), sell).CanCollide = false
	end

	return LobbyService.Positions()
end

return LobbyService
