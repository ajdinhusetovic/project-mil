-- Temporary parts shared by hotbar Tools and reveal ViewportFrames.
-- Your friend can supply a Model in ReplicatedStorage.CoreModels named after the core key.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(script.Parent.StabilizerDefinitions)
local Visuals = {}
function Visuals.Build(key, silhouette)
	local templates = ReplicatedStorage:FindFirstChild("CoreModels")
	local template = templates and templates:FindFirstChild(key)
	local model
	if template and template:IsA("Model") then
		model = template:Clone()
		for _, descendant in model:GetDescendants() do
			if descendant:IsA("LuaSourceContainer") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("Light") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Highlight") then descendant:Destroy() end
		end
	else
		model = Instance.new("Model")
		local definition = Definitions.Cores[key]
		local center = Instance.new("Part")
		center.Shape = definition.Shape == "Ball" and Enum.PartType.Ball or definition.Shape == "Cylinder" and Enum.PartType.Cylinder or Enum.PartType.Block
		center.Size = Vector3.one * 2
		if key == "Lightning" then center.Size = Vector3.new(1.1, 3, 1.1) end
		if definition.Shape == "Diamond" then center.CFrame = CFrame.Angles(0, 0, math.rad(45)) end
		center.Color = definition.Color
		center.Parent = model
		for side = -1, 1, 2 do
			local fin = Instance.new("Part")
			fin.Size = Vector3.new(0.45, key == "Storm" and 2.6 or 1.4, 1.2)
			fin.CFrame = CFrame.new(side * 1.2, 0, 0) * CFrame.Angles(0, 0, side * 0.3)
			fin.Color = definition.Color
			fin.Parent = model
		end
	end
	model.Name = key
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") then
			item.Anchored = true
			item.CanCollide = false
			item.CanTouch = false
			item.CanQuery = false
			if silhouette then
				item.Color = Color3.new(0, 0, 0)
				item.Material = Enum.Material.SmoothPlastic
				item.Reflectance = 0
				item.Transparency = 0
				if item:IsA("MeshPart") then item.TextureID = "" end
			end
		elseif item:IsA("Decal") or item:IsA("Texture") or item:IsA("SurfaceAppearance") then
			if silhouette then item:Destroy() end
		elseif item:IsA("SpecialMesh") and silhouette then item.TextureId = "" end
	end
	local pivot = model:GetBoundingBox()
	model:PivotTo(model:GetPivot() - pivot.Position)
	return model
end
function Visuals.Show(viewport, key, silhouette)
	viewport:ClearAllChildren()
	local model = Visuals.Build(key, silhouette)
	model.Parent = viewport
	model:PivotTo(CFrame.Angles(0, math.rad(-25), 0))
	local _, size = model:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	local distance = math.max(size.X, size.Y, size.Z) * 2.4
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0.3, distance), Vector3.zero)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	viewport.Ambient = silhouette and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
	viewport.LightColor = silhouette and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
end
return Visuals
