local Builder = {}
function Builder.EnsureEarnings(panel)
	local existing = panel:FindFirstChild("EarningsLabel")
	if existing then return existing end
	local label = Instance.new("TextLabel")
	label.Name = "EarningsLabel"
	label.Position = UDim2.fromScale(0.04, 0.755)
	label.Size = UDim2.fromScale(0.92, 0.06)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(105, 255, 91)
	label.TextStrokeTransparency = 0
	label.Text = "$2 / SEC IN YOUR REACTOR"
	label.Visible = false
	label.Parent = panel
	-- Make room when upgrading an older authored GUI once; subsequent edits are preserved.
	local result = panel:FindFirstChild("ResultLabel")
	if result then result.Size = UDim2.fromScale(result.Size.X.Scale, 0.06) end
	return label
end
function Builder.Build(parent)
	local existing = parent:FindFirstChild("StabilizerGui")
	if existing then Builder.EnsureEarnings(existing.Shade.Panel); return existing end
	local gui = Instance.new("ScreenGui")
	gui.Name = "StabilizerGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 35
	gui.Parent = parent
	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Color3.new(0, 0, 0)
	shade.BackgroundTransparency = 0.35
	shade.Visible = false
	shade.Parent = gui
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromScale(0.82, 0.68)
	panel.BackgroundColor3 = Color3.fromRGB(28, 16, 51)
	panel.Parent = shade
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(1000, 590)
	limit.Parent = panel
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
	local border = Instance.new("UIStroke")
	border.Color = Color3.new(0, 0, 0)
	border.Thickness = 6
	border.Parent = panel
	local function text(name, value, position, size, parentItem)
		local item = Instance.new("TextLabel")
		item.Name = name
		item.Position = position
		item.Size = size
		item.BackgroundTransparency = 1
		item.Font = Enum.Font.FredokaOne
		item.TextScaled = true
		item.TextColor3 = Color3.new(1, 1, 1)
		item.TextStrokeTransparency = 0
		item.Text = value
		item.Parent = parentItem or panel
		local cap = Instance.new("UITextSizeConstraint")
		cap.MaxTextSize = name == "TitleLabel" and 45 or 28
		cap.MinTextSize = 10
		cap.Parent = item
		return item
	end
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.18)
	header.BackgroundColor3 = Color3.fromRGB(159, 67, 244)
	header.Parent = panel
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.fromRGB(219, 114, 255), Color3.fromRGB(113, 47, 211))
	gradient.Rotation = 90
	gradient.Parent = header
	text("TitleLabel", "CORE STABILIZER", UDim2.fromScale(0.03, 0.08), UDim2.fromScale(0.83, 0.83), header)
	local function button(name, value, position, size, color)
		local item = Instance.new("TextButton")
		item.Name = name
		item.Text = value
		item.Font = Enum.Font.FredokaOne
		item.TextScaled = true
		item.TextColor3 = Color3.new(1, 1, 1)
		item.TextStrokeTransparency = 0
		item.Position = position
		item.Size = size
		item.BackgroundColor3 = color
		item.Parent = panel
		Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
		local outline = Instance.new("UIStroke")
		outline.Thickness = 3
		outline.Color = Color3.new(0, 0, 0)
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.Parent = item
		return item
	end
	button("CloseButton", "X", UDim2.fromScale(0.9, 0.03), UDim2.fromScale(0.075, 0.1), Color3.fromRGB(244, 63, 77))
	text("StatusLabel", "Hold an Unknown Core to place it", UDim2.fromScale(0.04, 0.21), UDim2.fromScale(0.92, 0.1))
	text("TimerLabel", "Equip your weapon and zap the placed core", UDim2.fromScale(0.06, 0.38), UDim2.fromScale(0.88, 0.17))
	text("ResultLabel", "", UDim2.fromScale(0.04, 0.69), UDim2.fromScale(0.92, 0.1))
	button("ActionButton", "PLACE HELD CORE", UDim2.fromScale(0.23, 0.83), UDim2.fromScale(0.54, 0.12), Color3.fromRGB(55, 213, 76))
	button("CancelButton", "RETURN CORE", UDim2.fromScale(0.04, 0.65), UDim2.fromScale(0.28, 0.1), Color3.fromRGB(212, 124, 48)).Visible = false
	button("OddsButton", "VIEW ODDS", UDim2.fromScale(0.69, 0.65), UDim2.fromScale(0.27, 0.1), Color3.fromRGB(77, 128, 236))
	local odds = text("OddsLabel", "", UDim2.fromScale(0.08, 0.32), UDim2.fromScale(0.84, 0.3))
	odds.Visible = false
	odds.TextWrapped = true
	local reel = Instance.new("Frame")
	reel.Name = "Reel"
	reel:SetAttribute("CardGapScale", 0.025)
	reel.Position = UDim2.fromScale(0.03, 0.32)
	reel.Size = UDim2.fromScale(0.94, 0.35)
	reel.BackgroundColor3 = Color3.fromRGB(12, 9, 22)
	reel.ClipsDescendants = true
	reel.Visible = false
	reel.Parent = panel
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.BackgroundTransparency = 1
	track.Size = UDim2.fromScale(1, 1)
	track.Parent = reel
	local pointer = text("Pointer", "▼", UDim2.fromScale(0.46, -0.02), UDim2.fromScale(0.08, 0.19), reel)
	pointer.TextColor3 = Color3.fromRGB(255, 227, 70)
	pointer.ZIndex = 8
	local template = Instance.new("Frame")
	template.Name = "CardTemplate"
	template.Size = UDim2.fromScale(0.23, 0.84)
	template.BackgroundColor3 = Color3.fromRGB(133, 118, 165)
	template.Visible = false
	template.Parent = panel
	Instance.new("UICorner", template).CornerRadius = UDim.new(0, 9)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Parent = template
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "CoreViewport"
	viewport.Position = UDim2.fromScale(0.05, 0.1)
	viewport.Size = UDim2.fromScale(0.9, 0.63)
	viewport.BackgroundTransparency = 1
	viewport.Parent = template
	text("RarityLabel", "COMMON", UDim2.fromScale(0.03, 0.77), UDim2.fromScale(0.94, 0.19), template)
	Builder.EnsureEarnings(panel)
	return gui
end
return Builder
