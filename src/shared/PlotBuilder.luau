-- Edit ServerStorage.PlotTemplate; future reactor models may replace the Reactor part.
local Builder = {}
function Builder.Build(parent)
	local existing = parent:FindFirstChild("PlotTemplate")
	if existing then return existing end
	local model = Instance.new("Model")
	model.Name = "PlotTemplate"
	model.Parent = parent
	local function part(name, size, position, color)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Position, p.Color = name, size, position, color
		p.Anchored = true
		p.TopSurface = Enum.SurfaceType.Studs
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = model
		return p
	end
	part("IslandBase", Vector3.new(56, 10, 56), Vector3.new(0, -7, 0), Color3.fromRGB(167, 96, 44))
	part("Grass", Vector3.new(60, 2, 60), Vector3.new(0, -1, 0), Color3.fromRGB(65, 219, 48))
	local spawn = part("PlotSpawn", Vector3.one, Vector3.new(0, 3, 17), Color3.new(1, 1, 1))
	spawn.Transparency = 1
	spawn.CanCollide, spawn.CanQuery, spawn.CanTouch = false, false, false
	local reactor = part("Reactor", Vector3.new(8, 4, 8), Vector3.new(0, 2, -8), Color3.fromRGB(112, 123, 145))
	reactor:SetAttribute("IsReactor", true)
	model.WorldPivot = CFrame.new()
	return model
end
return Builder
