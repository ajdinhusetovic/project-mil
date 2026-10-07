local Definitions = require(script.Parent.StabilizerDefinitions)
local Builder = {}
function Builder.Build(parent)
	local existing = parent:FindFirstChild("CoreIndexGui")
	if existing then return existing end
	local gui = Instance.new("ScreenGui")
	gui.Name = "CoreIndexGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 40
	gui.Parent = parent
	local function rounded(item, color, radius)
		item.BackgroundColor3 = color
		item.BorderSizePixel = 0
		Instance.new("UICorner", item).CornerRadius = UDim.new(radius or 0.06, 0)
		local stroke = Instance.new("UIStroke", item)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.new(0, 0, 0)
		stroke.Thickness = 3
	end
	local function label(parentItem, name, value, position, size, color)
		local item = Instance.new("TextLabel")
		item.Name = name
		item.Position = position
		item.Size = size
		item.BackgroundTransparency = 1
		item.Text = value
		item.Font = Enum.Font.FredokaOne
		item.TextScaled = true
		item.TextColor3 = color or Color3.new(1, 1, 1)
		item.TextStrokeTransparency = 0
		item.Parent = parentItem
		return item
	end
	local button = Instance.new("ImageButton")
	button.Name = "IndexButton"
	button.Position = UDim2.fromScale(0.025, 0.43)
	button.Size = UDim2.fromScale(0.08, 0.13)
	-- 91670004464678 is a Decal; ImageButton uses its underlying image texture.
	button.Image = "rbxassetid://97629410614205"
	button:SetAttribute("SourceDecalId", "91670004464678")
	button.ScaleType = Enum.ScaleType.Fit
	button.Parent = gui
	rounded(button, Color3.fromRGB(140, 87, 236), 0.1)
	Instance.new("UIAspectRatioConstraint", button).AspectRatio = 1
	local gradient = Instance.new("UIGradient", button)
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(174, 132, 225))
	gradient.Rotation = 90
	label(button, "TitleLabel", "INDEX", UDim2.fromScale(-0.05, 0.78), UDim2.fromScale(1.1, 0.28))
	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Color3.new(0, 0, 0)
	shade.BackgroundTransparency = 0.4
	shade.BorderSizePixel = 0
	shade.Active = true
	shade.Visible = false
	shade.Parent = gui
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.86, 0.82)
	panel.Active = true
	panel.Parent = shade
	rounded(panel, Color3.fromRGB(27, 19, 48), 0.035)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Position = UDim2.fromScale(0.015, 0.02)
	header.Size = UDim2.fromScale(0.97, 0.13)
	header.Parent = panel
	rounded(header, Color3.fromRGB(255, 186, 54))
	label(header, "TitleLabel", "CORE INDEX", UDim2.fromScale(0.025, 0.08), UDim2.fromScale(0.64, 0.8))
	local close = Instance.new("TextButton")
	close.Name = "CloseButton"
	close.Position = UDim2.fromScale(0.87, 0.08)
	close.Size = UDim2.fromScale(0.1, 0.8)
	close.Text = "X"
	close.Font = Enum.Font.FredokaOne
	close.TextScaled = true
	close.TextColor3 = Color3.new(1, 1, 1)
	close.TextStrokeTransparency = 0
	close.Parent = header
	rounded(close, Color3.fromRGB(242, 62, 83), 0.15)
	label(panel, "CountLabel", "0 / 8 DISCOVERED", UDim2.fromScale(0.04, 0.17), UDim2.fromScale(0.92, 0.055))
	local progress = Instance.new("Frame")
	progress.Name = "ProgressBar"
	progress.Position = UDim2.fromScale(0.04, 0.24)
	progress.Size = UDim2.fromScale(0.92, 0.025)
	progress.ClipsDescendants = true
	progress.Parent = panel
	rounded(progress, Color3.fromRGB(53, 39, 79), 0.25)
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.fromRGB(122, 255, 109)
	fill.BorderSizePixel = 0
	fill.Parent = progress
	local cards = Instance.new("ScrollingFrame")
	cards.Name = "Cards"
	cards.Position = UDim2.fromScale(0.035, 0.29)
	cards.Size = UDim2.fromScale(0.93, 0.62)
	cards.BackgroundTransparency = 1
	cards.BorderSizePixel = 0
	cards.CanvasSize = UDim2.fromScale(0, 1)
	cards.ScrollBarThickness = 5
	cards.ScrollingDirection = Enum.ScrollingDirection.Y
	cards.Parent = panel
	local grid = Instance.new("UIGridLayout", cards)
	grid.Name = "CardGrid"
	grid.CellPadding = UDim2.fromScale(0.018, 0.025)
	grid.CellSize = UDim2.fromScale(0.235, 0.46)
	grid.FillDirectionMaxCells = 4
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	for index, key in Definitions.Order do
		local definition = Definitions.Cores[key]
		local card = Instance.new("Frame")
		card.Name = key
		card.LayoutOrder = index
		card.Parent = cards
		rounded(card, Color3.fromRGB(57, 42, 82), 0.08)
		label(card, "NameLabel", "???", UDim2.fromScale(0.03, 0.025), UDim2.fromScale(0.94, 0.16))
		local viewport = Instance.new("ViewportFrame")
		viewport.Name = "Preview"
		viewport.Position = UDim2.fromScale(0.06, 0.2)
		viewport.Size = UDim2.fromScale(0.88, 0.53)
		viewport.BackgroundTransparency = 1
		viewport.Parent = card
		label(card, "RarityLabel", string.upper(definition.Rarity), UDim2.fromScale(0.04, 0.73), UDim2.fromScale(0.92, 0.11), Definitions.Rarities[definition.Rarity])
		label(card, "IncomeLabel", "UNDISCOVERED", UDim2.fromScale(0.04, 0.86), UDim2.fromScale(0.92, 0.1))
	end
	label(panel, "HintLabel", "STABILIZE UNKNOWN CORES TO DISCOVER THEM!", UDim2.fromScale(0.04, 0.93), UDim2.fromScale(0.92, 0.045))
	require(script.Parent.IndexMenuStyle).Apply(gui)
	return gui
end
return Builder
