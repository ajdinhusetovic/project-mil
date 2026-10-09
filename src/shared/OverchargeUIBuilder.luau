local Builder = {}
function Builder.Build(parent)
	local existing = parent:FindFirstChild("OverchargeGui")
	if existing then return existing end
	local gui = Instance.new("ScreenGui")
	gui.Name = "OverchargeGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 50
	gui.Parent = parent
	local function decorate(item, color)
		item.BackgroundColor3 = color
		item.BorderSizePixel = 0
		Instance.new("UICorner", item).CornerRadius = UDim.new(0.08, 0)
		local stroke = Instance.new("UIStroke", item)
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.new(0, 0, 0)
		stroke.Thickness = 3
		local gradient = Instance.new("UIGradient", item)
		gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(167, 143, 195))
		gradient.Rotation = 90
	end
	local function text(parentItem, class, name, value, x, y, w, h, color)
		local item = Instance.new(class)
		item.Name = name
		item.Position = UDim2.fromScale(x, y)
		item.Size = UDim2.fromScale(w, h)
		item.BackgroundTransparency = 1
		item.Font = Enum.Font.FredokaOne
		item.TextScaled = true
		item.TextWrapped = true
		item.TextColor3 = color or Color3.new(1, 1, 1)
		item.TextStrokeTransparency = 0
		item.Text = value
		item.Parent = parentItem
		return item
	end
	local open = Instance.new("ImageButton")
	open.Name = "OverchargeButton"
	open.Position = UDim2.fromScale(0.025, 0.58)
	open.Size = UDim2.fromScale(0.08, 0.13)
	open.ScaleType = Enum.ScaleType.Fit
	open.Parent = gui
	decorate(open, Color3.fromRGB(179, 84, 255))
	Instance.new("UIAspectRatioConstraint", open).AspectRatio = 1
	Instance.new("UISizeConstraint", open).MinSize = Vector2.new(48, 48)
	text(open, "TextLabel", "TitleLabel", "REBIRTH", -0.08, 0.78, 1.16, 0.23)
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
	panel.Size = UDim2.fromScale(0.8, 0.86)
	panel.Active = true
	panel.Parent = shade
	decorate(panel, Color3.fromRGB(36, 20, 55))
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Position = UDim2.fromScale(0.02, 0.02)
	header.Size = UDim2.fromScale(0.96, 0.12)
	header.Parent = panel
	decorate(header, Color3.fromRGB(255, 162, 49))
	text(header, "TextLabel", "TitleLabel", "OVERCHARGE", 0.03, 0.12, 0.72, 0.76)
	local close = text(header, "TextButton", "CloseButton", "X", 0.82, 0.1, 0.15, 0.8)
	close.BackgroundTransparency = 0
	decorate(close, Color3.fromRGB(244, 58, 75))
	Instance.new("UIAspectRatioConstraint", close).AspectRatio = 1
	Instance.new("UISizeConstraint", close).MinSize = Vector2.new(44, 44)
	text(panel, "TextLabel", "CountLabel", "OVERCHARGE 0", 0.04, 0.16, 0.92, 0.045)
	text(panel, "TextLabel", "PowerReward", "POWER 1x → 1.5x", 0.04, 0.225, 0.92, 0.07, Color3.fromRGB(255, 216, 75))
	text(panel, "TextLabel", "CashReward", "CASH 1x → 1.2x", 0.04, 0.305, 0.92, 0.07, Color3.fromRGB(117, 255, 101))
	for index, key in {"Level", "Power", "Cash"} do
		text(panel, "TextLabel", key .. "Requirement", key, 0.06, 0.4 + (index - 1) * 0.055, 0.88, 0.047)
	end
	text(panel, "TextLabel", "ResetLabel", "RESETS: Power, Level, XP, cash, weapons, upgrades, ores and mine", 0.05, 0.58, 0.9, 0.072, Color3.fromRGB(255, 159, 141))
	text(panel, "TextLabel", "KeepLabel", "KEEPS: stored cores, stabilizations, Index and permanent multipliers", 0.05, 0.665, 0.9, 0.064, Color3.fromRGB(128, 255, 163))
	text(panel, "TextLabel", "StatusLabel", "Meet all requirements to Overcharge", 0.05, 0.75, 0.9, 0.045)
	local confirm = text(panel, "TextButton", "ConfirmButton", "OVERCHARGE", 0.08, 0.815, 0.84, 0.13)
	confirm.BackgroundTransparency = 0
	decorate(confirm, Color3.fromRGB(102, 225, 65))
	local celebration = text(gui, "TextLabel", "CelebrationLabel", "OVERCHARGED!", 0.18, 0.34, 0.64, 0.25, Color3.fromRGB(255, 205, 77))
	celebration.Visible = false
	Instance.new("UIScale", celebration)
	require(script.Parent.RebirthMenuStyle).Apply(gui)
	return gui
end
return Builder
