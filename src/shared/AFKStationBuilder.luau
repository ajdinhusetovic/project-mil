local Definitions = require(script.Parent.AFKTrainingDefinitions)
local Builder = {}

function Builder.Build(parent)
	local existing = parent:FindFirstChild("AFKTrainingStations")
	if existing then return existing end
	local folder = Instance.new("Folder")
	folder.Name = "AFKTrainingStations"
	local function part(model, name, size, position, color, material, collide)
		local item = Instance.new("Part")
		item.Name, item.Size, item.Position = name, size, position
		item.Color, item.Material = color, material or Enum.Material.SmoothPlastic
		item.Anchored, item.CanCollide = true, collide == true
		item.CanTouch, item.CanQuery = false, false
		item.TopSurface = Enum.SurfaceType.Studs
		item.Parent = model
		return item
	end
	local function label(gui, name, y, height, value, color)
		local text = Instance.new("TextLabel")
		text.Name, text.Text = name, value
		text.Position, text.Size = UDim2.fromScale(0, y), UDim2.fromScale(1, height)
		text.BackgroundTransparency = 1
		text.TextColor3, text.Font = color, Enum.Font.FredokaOne
		text.TextScaled, text.TextWrapped = true, true
		text.Parent = gui
		local limit = Instance.new("UITextSizeConstraint")
		limit.MaxTextSize, limit.MinTextSize = name == "Title" and 32 or 22, 8
		limit.Parent = text
		local stroke = Instance.new("UIStroke")
		stroke.Color, stroke.Thickness = Color3.new(0, 0, 0), 3
		stroke.Parent = text
	end
	for index, definition in Definitions.Stations do
		local model = Instance.new("Model")
		model.Name = definition.Id
		model:SetAttribute("StationId", definition.Id)
		local center = Vector3.new(-48 + (index - 1) * 24, 0, 151)
		local base = part(model, "Platform", Vector3.new(18, 0.6, 16), center + Vector3.new(0, 0.3, 0), Color3.fromRGB(38, 45, 66), nil, true)
		model.PrimaryPart = base
		part(model, "TrainingPad", Vector3.new(12, 0.15, 10), center + Vector3.new(0, 0.675, -1), definition.Color, nil, true)
		for _, x in { -8.5, 8.5 } do
			part(model, "NeonTrim", Vector3.new(0.35, 0.15, 15), center + Vector3.new(x, 0.7, 0), definition.Color, Enum.Material.Neon)
		end
		part(model, "Pedestal", Vector3.new(5, 1, 5), center + Vector3.new(0, 1.25, 5), Color3.fromRGB(255, 203, 45), nil, true)
		local block = part(model, "ChargeBlock", Vector3.new(3, 3, 3), center + Vector3.new(0, 3.6, 5), definition.Color)
		block.CFrame *= CFrame.Angles(0, math.rad(25), math.rad(12))
		local attachment = Instance.new("Attachment")
		attachment.Name, attachment.Parent = "ChargeTarget", block
		local zone = part(model, "Zone", Vector3.new(12, 8, 10), center + Vector3.new(0, 4.75, -1), definition.Color)
		zone.Transparency = 1
		local sign = Instance.new("BillboardGui")
		sign.Name, sign.Size = "StationSign", UDim2.fromScale(12, 2.8)
		sign.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
		sign.MaxDistance, sign.AlwaysOnTop = 120, false
		sign.Parent = block
		label(sign, "Title", 0, 0.35, tostring(definition.Multiplier) .. "× AFK TRAINING", definition.Color)
		label(sign, "Requirement", 0.37, 0.27, definition.Rebirths == 0 and "UNLOCKED" or tostring(definition.Rebirths) .. " REBIRTHS", Color3.new(1, 1, 1))
		label(sign, "Rate", 0.69, 0.28, "POWER + XP EVERY SECOND", Color3.fromRGB(255, 226, 94))
		model.Parent = folder
	end
	folder.Parent = parent
	return folder
end

return Builder
