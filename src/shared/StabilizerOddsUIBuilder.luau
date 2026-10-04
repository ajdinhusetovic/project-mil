local Definitions = require(script.Parent.StabilizerDefinitions)
local Builder = {}
function Builder.Build(parent)
	local existing = parent:FindFirstChild("StabilizerOddsGui")
	if existing then
		local legacy = existing:FindFirstChild("NearbyReturnButton")
		if legacy then legacy:Destroy() end
		return existing
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "StabilizerOddsGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 35
	gui.Parent = parent
	local function text(parentItem, name, value, position, size)
		local item = Instance.new("TextLabel")
		item.Name = name
		item.Text = value
		item.Position = position
		item.Size = size
		item.BackgroundTransparency = 1
		item.Font = Enum.Font.FredokaOne
		item.TextScaled = true
		item.TextColor3 = Color3.new(1, 1, 1)
		item.TextStrokeTransparency = 0
		item.Parent = parentItem
		return item
	end
	local function button(parentItem, name, value, position, size, color)
		local item = Instance.new("TextButton")
		item.Name = name
		item.Text = value
		item.Position = position
		item.Size = size
		item.Font = Enum.Font.FredokaOne
		item.TextScaled = true
		item.TextColor3 = Color3.new(1, 1, 1)
		item.TextStrokeTransparency = 0
		item.BackgroundColor3 = color
		item.Parent = parentItem
		Instance.new("UICorner", item).CornerRadius = UDim.new(0.15, 0)
		local border = Instance.new("UIStroke")
		border.Thickness = 3
		border.Color = Color3.new(0, 0, 0)
		border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		border.Parent = item
		return item
	end
	local blue = Color3.fromRGB(67, 139, 235)
	local nearby = button(gui, "NearbyOddsButton", "VIEW CORE ODDS", UDim2.fromScale(0.37, 0.79), UDim2.fromScale(0.26, 0.08), blue)
	nearby.Visible = false
	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Color3.new(0, 0, 0)
	shade.BackgroundTransparency = 0.4
	shade.Visible = false
	shade.Parent = gui
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.78, 0.76)
	panel.BackgroundColor3 = Color3.fromRGB(30, 17, 52)
	panel.Parent = shade
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(850, 620)
	limit.Parent = panel
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0.035, 0)
	local border = Instance.new("UIStroke")
	border.Color = Color3.new(0, 0, 0)
	border.Thickness = 5
	border.Parent = panel
	text(panel, "TitleLabel", "CORE ODDS", UDim2.fromScale(0.06, 0.03), UDim2.fromScale(0.75, 0.12))
	button(panel, "CloseButton", "X", UDim2.fromScale(0.88, 0.035), UDim2.fromScale(0.08, 0.1), Color3.fromRGB(242, 63, 76))
	button(panel, "CrackedButton", "CRACKED", UDim2.fromScale(0.06, 0.19), UDim2.fromScale(0.42, 0.09), Color3.fromRGB(218, 134, 42))
	button(panel, "ChargedButton", "CHARGED", UDim2.fromScale(0.52, 0.19), UDim2.fromScale(0.42, 0.09), blue)
	local rows = Instance.new("Frame")
	rows.Name = "Rows"
	rows.Position = UDim2.fromScale(0.06, 0.32)
	rows.Size = UDim2.fromScale(0.88, 0.59)
	rows.BackgroundTransparency = 1
	rows.Parent = panel
	for index, key in Definitions.Order do
		local row = Instance.new("Frame")
		row.Name = key
		row.Position = UDim2.fromScale(0, (index - 1) / #Definitions.Order)
		row.Size = UDim2.fromScale(1, 0.11)
		row.BackgroundTransparency = 1
		row.Parent = rows
		local definition = Definitions.Cores[key]
		local name = text(row, "NameLabel", definition.Name .. " • " .. definition.Rarity, UDim2.fromScale(0, 0), UDim2.fromScale(0.77, 1))
		name.TextColor3 = Definitions.Rarities[definition.Rarity]
		name.TextXAlignment = Enum.TextXAlignment.Left
		text(row, "ChanceLabel", "0%", UDim2.fromScale(0.8, 0), UDim2.fromScale(0.2, 1))
	end
	text(panel, "GradeLabel", "CRACKED OUTCOMES", UDim2.fromScale(0.1, 0.93), UDim2.fromScale(0.8, 0.05))
	return gui
end
return Builder
