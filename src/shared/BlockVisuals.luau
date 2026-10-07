-- Imported artwork stays untouched. Only exposed cells and active pickups clone it.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = {}
local names = {
	["Stone Ore"] = "Stone", ["Copper Ore"] = "Copper",
	["Quartz Ore"] = "Quartz", ["Ion Crystal"] = "Ion",
	["Charged Quartz"] = "ChargedQuartz",
}
local cache = {}
function Visuals.Build(material, size)
	local key = names[material]
	local folder = ReplicatedStorage:FindFirstChild("BlockModels")
	local template = key and folder and folder:FindFirstChild(key)
	if not template or not template:IsA("Model") then return nil end
	local cached = cache[key]
	if not cached or cached.Template ~= template then
		local model = template:Clone()
		model.PrimaryPart = nil
		for _, item in model:GetDescendants() do
			if item:IsA("BasePart") then
				item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false
			elseif item:IsA("LuaSourceContainer") or item:IsA("JointInstance") or item:IsA("Constraint")
				or item:IsA("Light") or item:IsA("ParticleEmitter") or item:IsA("Beam")
				or item:IsA("Trail") or item:IsA("BillboardGui") or item:IsA("SurfaceGui") then
				item:Destroy()
			end
		end
		if not model:FindFirstChildWhichIsA("BasePart", true) then model:Destroy(); return nil end
		local bounds, extents = model:GetBoundingBox()
		local largest = math.max(extents.X, extents.Y, extents.Z)
		if largest <= 0 then model:Destroy(); return nil end
		model.WorldPivot = CFrame.new(bounds.Position)
		model:PivotTo(CFrame.identity)
		model:ScaleTo(model:GetScale() / largest)
		cached = {Template = template, Model = model}
		if cache[key] then cache[key].Model:Destroy() end
		cache[key] = cached
	end
	local model = cached.Model:Clone()
	model.Name = "BlockVisual"
	model:ScaleTo(model:GetScale() * size)
	return model
end
function Visuals.Attach(block, material)
	local model = Visuals.Build(material, block.Size.X)
	if model then
		model:PivotTo(block.CFrame)
		model.Parent = block
		block.Transparency = 1
	end
	return model
end
return Visuals
