local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Definitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Visuals = require(ReplicatedStorage.Shared.CoreVisuals)
local Mutations = require(ReplicatedStorage.Shared.MutationDefinitions)
local Reveal = {}
function Reveal.Play(mount, result, parent, template)
	if not mount or not mount:IsDescendantOf(workspace) then return end
	local display = Instance.new("Folder")
	display.Name = "CoreWorldRoll"
	display:SetAttribute("StationId", mount:GetAttribute("StabilizerId"))
	display.Parent = parent
	local function part(name, size, color)
		local item = Instance.new("Part")
		item.Name = name
		item.Size = size
		item.Color = color
		item.Material = Enum.Material.Neon
		item.Anchored = true
		item.CanCollide = false
		item.CanTouch = false
		item.CanQuery = false
		item.CastShadow = false
		item.Parent = display
		return item
	end
	local anchor = part("RevealAnchor", Vector3.one * 0.1, Color3.new(1, 1, 1))
	anchor.Transparency = 1
	anchor.Position = mount.Position + Vector3.new(0, 3.5, 0)
	local board = template:Clone()
	board.Parent = anchor
	board.NameLabel.Text = "???"
	board.IncomeLabel.Visible = false
	local tick = Instance.new("Sound")
	tick.SoundId = "rbxasset://sounds/volume_slider.ogg"
	tick.Volume = 0.2
	tick.Parent = anchor
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(124, 177, 255)
	light.Range = 14
	light.Brightness = 0.3
	light.Parent = anchor
	local scale = Instance.new("NumberValue")
	scale.Name = "PopScale"
	scale.Value = 1
	scale.Parent = display
	local rise = Instance.new("NumberValue")
	rise.Value = 0
	rise.Parent = display
	local model, shownAt = nil, os.clock()
	local modelScale = 1
	local angle, phase = 0, "Cycling"
	local rings = {}
	local function tween(item, duration, properties, style)
		local animation = TweenService:Create(item, TweenInfo.new(duration, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
		animation:Play()
		return animation
	end
	local function ring(color, radius, duration)
		local growth = Instance.new("NumberValue")
		growth.Value = 0.5
		growth.Parent = display
		local fade = Instance.new("NumberValue")
		fade.Value = 0.15
		fade.Parent = display
		local segments = {}
		for i = 1, 24 do segments[i] = part("BurstRing", Vector3.one * 0.12, color) end
		table.insert(rings, {Growth = growth, Fade = fade, Parts = segments})
		tween(growth, duration, {Value = radius})
		tween(fade, duration, {Value = 1})
	end
	local connection = RunService.RenderStepped:Connect(function(dt)
		if not mount:IsDescendantOf(workspace) then return end
		angle += dt * (phase == "Suspense" and 7 or phase == "Revealed" and 0.65 or 1.8)
		local position = mount.Position + Vector3.new(0, 3.5 + rise.Value + math.sin(os.clock() * 3) * 0.14, 0)
		anchor.Position = position
		if model then
			model:PivotTo(CFrame.new(position) * CFrame.Angles(0, angle, phase == "Suspense" and math.sin(os.clock() * 60) * 0.05 or 0))
			local size = phase == "Cycling" and (0.72 + math.min((os.clock() - shownAt) * 6, 0.28)) or scale.Value
			model:ScaleTo(modelScale * math.max(0.05, size))
		end
		for _, wave in rings do
			local center = mount.Position + Vector3.new(0, 2.1, 0)
			for index, segment in wave.Parts do
				local a = (index - 1) * math.pi * 2 / #wave.Parts
				local b = index * math.pi * 2 / #wave.Parts
				local start = center + Vector3.new(math.cos(a), 0, math.sin(a)) * wave.Growth.Value
				local finish = center + Vector3.new(math.cos(b), 0, math.sin(b)) * wave.Growth.Value
				segment.Size = Vector3.new(0.12, 0.12, (finish - start).Magnitude)
				segment.CFrame = CFrame.lookAt((start + finish) / 2, finish)
				segment.Transparency = wave.Fade.Value
			end
		end
	end)
	local function show(key, silhouette)
		if model then model:Destroy() end
		model = Visuals.Build(key, silhouette, not silhouette and result.Mutation or nil)
		modelScale = model:GetScale()
		model.Name = "RollingCore"
		model:SetAttribute("CoreType", key)
		model:SetAttribute("Silhouette", silhouette)
		model.Parent = display
		shownAt = os.clock()
		model:PivotTo(CFrame.new(anchor.Position))
		local definition = Definitions.Cores[key]
		board.RarityLabel.Visible = true
		board.RarityLabel.Text = string.upper(definition.Rarity)
		board.RarityLabel.TextColor3 = Definitions.Rarities[definition.Rarity]
		tick.PlaybackSpeed = silhouette and 1.7 or 0.8
		tick.TimePosition = 0
		tick:Play()
	end
	-- Decorative cycling never chooses the reward; the server already awarded result.
	local ok, err = pcall(function()
		local rng = Random.new()
		for index = 1, 30 do
			if not mount:IsDescendantOf(workspace) then return end
			show(Definitions.Roll(result.Grade, rng), true)
			task.wait(0.045 + 0.32 * (index / 30) ^ 3)
		end
		if not mount:IsDescendantOf(workspace) then return end
		phase = "Suspense"
		show(result.Type, true)
		board.RarityLabel.Text = "STABILIZING..."
		tween(scale, 0.35, {Value = 0.65})
		tween(rise, 0.35, {Value = 0.6})
		tween(light, 0.35, {Brightness = 3, Color = Color3.new(1, 1, 1)})
		task.wait(0.4)
		if not mount:IsDescendantOf(workspace) then return end
		local definition = Definitions.Cores[result.Type]
		local mutation = Mutations.Variants[Mutations.Key(result.Mutation)]
		local color = mutation.Color or Definitions.Rarities[definition.Rarity]
		phase = "Revealed"
		scale.Value = 0.2
		show(result.Type, false)
		display:SetAttribute("Revealed", true)
		board.NameLabel.Text = string.upper(definition.Name)
		board.RarityLabel.Text = Definitions.MutationText(result)
		board.RarityLabel.Visible = board.RarityLabel.Text ~= ""
		board.RarityLabel.TextColor3 = color
		board.IncomeLabel.Text = Definitions.IncomeText(result)
		board.IncomeLabel.Visible = true
		local pop = tween(scale, 0.45, {Value = 1.3}, Enum.EasingStyle.Back)
		tween(rise, 0.55, {Value = 0.2}, Enum.EasingStyle.Back)
		light.Color = color
		light.Brightness = 5
		tween(light, 0.8, {Brightness = 0.8})
		local flash = Instance.new("Highlight")
		flash.FillColor = Color3.new(1, 1, 1)
		flash.FillTransparency = 0
		flash.OutlineColor = color
		flash.OutlineTransparency = 0
		flash.Parent = model
		tween(flash, 0.6, {FillTransparency = 1, OutlineTransparency = 1})
		Debris:AddItem(flash, 0.65)
		local orb = part("RevealFlash", Vector3.one * 0.5, color:Lerp(Color3.new(1, 1, 1), 0.65))
		orb.Shape = Enum.PartType.Ball
		orb.Position = anchor.Position
		orb.Transparency = 0.4
		tween(orb, 0.5, {Size = Vector3.one * 9, Transparency = 1})
		local sparks = Instance.new("ParticleEmitter")
		sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparks.Color = ColorSequence.new(color, Color3.new(1, 1, 1))
		sparks.LightEmission = 1
		sparks.Rate = 0
		sparks.Lifetime = NumberRange.new(0.45, 0.95)
		sparks.Speed = NumberRange.new(9, 16)
		sparks.Drag = 5
		sparks.SpreadAngle = Vector2.new(180, 180)
		sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0)})
		sparks.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
		sparks.Parent = anchor
		sparks:Emit(40)
		ring(color, 5.5, 0.7)
		ring(Color3.new(1, 1, 1), 3.8, 0.5)
		local burst = Instance.new("Sound")
		burst.SoundId = "rbxasset://sounds/volume_slider.ogg"
		burst.Volume = 0.18
		burst.PlaybackSpeed = 0.65
		burst.Parent = anchor
		burst:Play()
		for _, label in {board.NameLabel, board.RarityLabel, board.IncomeLabel} do
			local labelScale = Instance.new("UIScale")
			labelScale.Scale = 1.15
			labelScale.Parent = label
			tween(labelScale, 0.4, {Scale = 1}, Enum.EasingStyle.Back)
		end
		pop.Completed:Wait()
		tween(scale, 0.35, {Value = 1})
		task.wait(2.6)
		phase = "Leaving"
		tween(scale, 0.25, {Value = 0.05}, Enum.EasingStyle.Back)
		for _, label in {board.NameLabel, board.RarityLabel, board.IncomeLabel} do tween(label, 0.25, {TextTransparency = 1, TextStrokeTransparency = 1}) end
		task.wait(0.25)
	end)
	connection:Disconnect()
	display:Destroy()
	if not ok then error(err) end
end
return Reveal
