-- Temporary parts shared by hotbar Tools and reveal ViewportFrames.
-- Your friend can supply a Model in ReplicatedStorage.CoreModels named after the core key.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(script.Parent.StabilizerDefinitions)
local Mutations = require(script.Parent.MutationDefinitions)
local Visuals = {}
local function applyMutation(model, key)
	local mutation = Mutations.Variants[Mutations.Key(key)]
	if not mutation.Color then return end
	local center = model:FindFirstChildWhichIsA("BasePart", true)
	if not center then return end
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Color = part.Color:Lerp(mutation.Color, 0.55)
			part.Material = Enum.Material.Neon
		end
	end
	local glow = Instance.new("Highlight")
	glow.Name = "MutationGlow"
	glow.Adornee = center
	glow.FillColor = mutation.Color
	glow.FillTransparency = 0.85
	glow.OutlineColor = mutation.Color
	glow.OutlineTransparency = 0.2
	glow.Parent = center
	local light = Instance.new("PointLight")
	light.Name = "MutationLight"
	light.Color = mutation.Color
	light.Range = 7
	light.Brightness = 0.6
	light.Parent = center
	local sparks = Instance.new("ParticleEmitter")
	sparks.Name = "MutationSparks"
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(mutation.Color, Color3.new(1, 1, 1))
	sparks.LightEmission = 1
	sparks.Rate = mutation.ParticleRate
	sparks.Lifetime = NumberRange.new(0.3, 0.7)
	sparks.Speed = NumberRange.new(0.5, 2)
	sparks.SpreadAngle = Vector2.new(180, 180)
	sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0)})
	sparks.Parent = center
	for index = 1, (key == "Overloaded" and 2 or 1) do
		local a, b = Instance.new("Attachment"), Instance.new("Attachment")
		a.Name, b.Name = "MutationArcStart" .. index, "MutationArcEnd" .. index
		a.Position = Vector3.new(-center.Size.X * 0.65, -0.4, (index - 1) * 0.8)
		b.Position = Vector3.new(center.Size.X * 0.65, 0.4, (index - 1) * 0.8)
		a.Parent, b.Parent = center, center
		local arc = Instance.new("Beam")
		arc.Name = "MutationArc" .. index
		arc.Attachment0, arc.Attachment1 = a, b
		arc.Color = ColorSequence.new(mutation.Color)
		arc.Width0, arc.Width1 = 0.035, 0.035
		arc.CurveSize0, arc.CurveSize1 = 1.4, -1.4
		arc.FaceCamera = true
		arc.LightEmission = 1
		arc.Segments = 8
		arc.Parent = center
	end
end
function Visuals.Build(key, silhouette, mutation)
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
	if not silhouette then applyMutation(model, mutation) end
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
