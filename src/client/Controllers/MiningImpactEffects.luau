local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Impact = {}
local cyan = Color3.fromRGB(115, 240, 255)
local rng = Random.new()
local damaged = {}
local order = {}
local folder = Instance.new("Folder")
folder.Name = "MiningImpactEffects"
folder.Parent = workspace
local shake = 0
local lastRotation = CFrame.identity
local lastCamera
local lastSound = 0

-- Remove our previous offset before Roblox updates its camera, then apply a tiny new one.
RunService:BindToRenderStep("MiningShakeRestore", Enum.RenderPriority.Camera.Value - 1, function()
	if lastCamera and lastCamera == workspace.CurrentCamera then
		lastCamera.CFrame *= lastRotation:Inverse()
	end
	lastCamera = nil
	lastRotation = CFrame.identity
end)
RunService:BindToRenderStep("MiningShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
	shake = math.max(0, shake - dt * 2.8)
	local camera = workspace.CurrentCamera
	if not camera or shake <= 0 then return end
	local angle = math.rad(0.55) * shake
	lastRotation = CFrame.Angles(rng:NextNumber(-angle, angle), rng:NextNumber(-angle, angle), rng:NextNumber(-angle, angle) * 0.4)
	camera.CFrame *= lastRotation
	lastCamera = camera
end)

local function clear(block)
	local entry = damaged[block]
	if not entry then return end
	if entry.Tween then entry.Tween:Cancel() end
	entry.Folder:Destroy()
	damaged[block] = nil
	local index = table.find(order, block)
	if index then table.remove(order, index) end
end

-- Procedural cracks need no uploaded textures. Only the 24 most recently hit blocks keep them.
local points = {
	{0.18, 0.12, 0.42, 0.36}, {0.42, 0.36, 0.36, 0.57},
	{0.36, 0.57, 0.61, 0.73}, {0.61, 0.73, 0.75, 0.93},
	{0.42, 0.36, 0.72, 0.26}, {0.36, 0.57, 0.15, 0.76},
	{0.61, 0.73, 0.84, 0.59},
}
local function makeCracks(block)
	local container = Instance.new("Folder")
	container.Name = "DamageFeedback"
	container.Parent = block
	local lines = {}
	for _, face in Enum.NormalId:GetEnumItems() do
		local surface = Instance.new("SurfaceGui")
		surface.Name = "Cracks" .. face.Name
		surface.Face = face
		surface.Adornee = block
		surface.CanvasSize = Vector2.new(256, 256)
		surface.AlwaysOnTop = false
		surface.LightInfluence = 0
		surface.Parent = container
		for index, path in points do
			local a, b = Vector2.new(path[1], path[2]), Vector2.new(path[3], path[4])
			local delta = b - a
			local line = Instance.new("Frame")
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Position = UDim2.fromScale((a.X + b.X) / 2, (a.Y + b.Y) / 2)
			line.Size = UDim2.new(delta.Magnitude, 0, 0, 3)
			line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
			line.BorderSizePixel = 0
			line.BackgroundColor3 = Color3.fromRGB(18, 33, 40)
			line.Parent = surface
			table.insert(lines, {Line = line, Stage = index})
		end
	end
	local glow = Instance.new("Highlight")
	glow.Adornee = block
	glow.FillColor = cyan
	glow.OutlineColor = cyan
	glow.DepthMode = Enum.HighlightDepthMode.Occluded
	glow.OutlineTransparency = 1
	glow.Parent = container
	local entry = {Folder = container, Lines = lines, Glow = glow}
	damaged[block] = entry
	table.insert(order, block)
	if #order > 24 then clear(order[1]) end
	return entry
end

function Impact.Hit(block, health)
	local entry = damaged[block] or makeCracks(block)
	local damage = math.clamp(1 - health / block:GetAttribute("MaxHealth"), 0, 1)
	for _, crack in entry.Lines do
		crack.Line.Visible = crack.Stage <= math.ceil(damage * #points)
		crack.Line.BackgroundTransparency = 0.35 * (1 - damage)
	end
	if entry.Tween then entry.Tween:Cancel() end
	entry.Glow.FillTransparency = 0.35
	entry.Tween = TweenService:Create(entry.Glow, TweenInfo.new(0.18), {FillTransparency = 1})
	entry.Tween:Play()
end

function Impact.Clear(block)
	clear(block)
end

function Impact.Reset()
	while #order > 0 do clear(order[1]) end
	shake = 0
end

local sparks = {}
for _ = 1, 72 do
	local part = Instance.new("Part")
	part.Name = "ElectricBurst"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Transparency = 1
	part.Parent = folder
	table.insert(sparks, part)
end

function Impact.Burst(position, color)
	local camera = workspace.CurrentCamera
	if not camera then return end
	local distance = (camera.CFrame.Position - position).Magnitude
	if distance > 75 then return end
	shake = math.max(shake, 0.65 * math.clamp(1 - distance / 75, 0, 1))
	for _ = 1, 10 do
		local spark = table.remove(sparks)
		if not spark then break end
		local direction = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1))
		if direction.Magnitude < 0.01 then direction = Vector3.yAxis end
		direction = direction.Unit
		spark.Color = color:Lerp(cyan, 0.85)
		spark.Size = Vector3.new(0.12, 0.12, rng:NextNumber(1.2, 2.4))
		spark.CFrame = CFrame.lookAt(position + direction, position + direction * 2)
		spark.Transparency = 0
		local tween = TweenService:Create(spark, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = spark.CFrame + direction * rng:NextNumber(3, 6), Transparency = 1,
		})
		tween.Completed:Once(function() table.insert(sparks, spark) end)
		tween:Play()
	end
	-- Throttle audio across multi-block blasts. Replace this built-in cue with a custom asset later.
	if os.clock() - lastSound > 0.09 then
		lastSound = os.clock()
		local anchor = Instance.new("Part")
		anchor.Anchored = true
		anchor.CanCollide = false
		anchor.CanTouch = false
		anchor.CanQuery = false
		anchor.Transparency = 1
		anchor.Position = position
		anchor.Parent = folder
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxasset://sounds/impact_explosion_03.mp3"
		sound.Volume = 0.25
		sound.PlaybackSpeed = rng:NextNumber(0.8, 1.05)
		sound.RollOffMaxDistance = 65
		sound.Parent = anchor
		sound:Play()
		Debris:AddItem(anchor, 2)
	end
end

return Impact
