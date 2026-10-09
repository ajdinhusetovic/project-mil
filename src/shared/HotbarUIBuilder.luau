-- Author in StarterGui through studio/build_hotbar_gui.lua; runtime is a fallback.
local Builder = {}
local function label(parent, name, text, position, size)
	local item = Instance.new("TextLabel")
	item.Name, item.Text, item.Position, item.Size = name, text, position, size
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.FredokaOne
	item.TextScaled, item.TextWrapped = true, true
	item.TextColor3, item.TextStrokeTransparency = Color3.new(1,1,1), 0
	item.ZIndex = 6
	item.Parent = parent
	return item
end
function Builder.Build(parent)
	local existing = parent:FindFirstChild("HotbarGui")
	if existing then Builder.Navigation(existing); return existing end
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "HotbarGui", false, true
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	gui.DisplayOrder = 15
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local root = Instance.new("Frame")
	root.Name = "Bar"
	root.AnchorPoint, root.Position = Vector2.new(.5,1), UDim2.new(.5,0,1,-12)
	root.Size = UDim2.fromOffset(590, 100)
	root.BackgroundTransparency = 1
	root.Parent = gui
	local scale = Instance.new("UIScale", root)
	scale.Name = "ResponsiveScale"
	label(root, "HintLabel", "SELECT A WEAPON OR CORE", UDim2.fromOffset(0,0), UDim2.new(1,0,0,15))
	local slots = Instance.new("ScrollingFrame")
	slots.Name = "Slots"
	slots.Position, slots.Size = UDim2.fromOffset(0,20), UDim2.new(1,0,0,80)
	slots.BackgroundTransparency, slots.BorderSizePixel = 1, 0
	slots.ScrollBarThickness = 3
	slots.ScrollBarImageColor3 = Color3.fromRGB(108,231,255)
	slots.ScrollingDirection = Enum.ScrollingDirection.X
	slots.AutomaticCanvasSize = Enum.AutomaticSize.X
	slots.CanvasSize = UDim2.new()
	slots.Parent = root
	local list = Instance.new("UIListLayout", slots)
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0,8)
	local padding = Instance.new("UIPadding", slots)
	padding.PaddingTop, padding.PaddingLeft, padding.PaddingRight = UDim.new(0,4), UDim.new(0,4), UDim.new(0,4)
	local template = Instance.new("TextButton")
	template.Name, template.Text = "SlotTemplate", ""
	template.Size = UDim2.fromOffset(88,70)
	template.BackgroundColor3 = Color3.fromRGB(25,32,48)
	template.BorderSizePixel, template.AutoButtonColor = 0, false
	template.Visible = false
	template.Parent = gui
	Instance.new("UICorner", template).CornerRadius = UDim.new(0,9)
	local stroke = Instance.new("UIStroke", template)
	stroke.Name, stroke.Thickness, stroke.Color = "SelectionStroke", 2, Color3.fromRGB(9,12,20)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local gradient = Instance.new("UIGradient", template)
	gradient.Color, gradient.Rotation = ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(135,151,183)), 90
	local preview = Instance.new("ViewportFrame")
	preview.Name, preview.Position, preview.Size = "Preview", UDim2.fromScale(.16,.03), UDim2.fromScale(.68,.63)
	preview.BackgroundTransparency = 1
	preview.ZIndex = 3
	preview.Parent = template
	local icon = Instance.new("ImageLabel")
	icon.Name, icon.Position, icon.Size = "WeaponIcon", preview.Position, preview.Size
	icon.BackgroundTransparency, icon.ScaleType = 1, Enum.ScaleType.Fit
	icon.Image = "rbxassetid://71561893600786"
	icon.ZIndex = 3
	icon.Parent = template
	label(template, "KeyLabel", "1", UDim2.fromScale(.06,.04), UDim2.fromScale(.17,.22))
	label(template, "NameLabel", "Scrap Zapper", UDim2.fromScale(.045,.64), UDim2.fromScale(.91,.30))
	local selected = label(template, "SelectedLabel", "●", UDim2.fromScale(.78,.02), UDim2.fromScale(.17,.2))
	selected.TextColor3, selected.Visible = Color3.fromRGB(107,240,255), false
	gui.Parent = parent
	Builder.Navigation(gui)
	return gui
end
function Builder.Navigation(gui)
	for _, entry in {{"PreviousButton", "<", UDim2.new(0,-34,0,24)}, {"NextButton", ">", UDim2.new(1,4,0,24)}} do
		if gui.Bar:FindFirstChild(entry[1]) then continue end
		local button = Instance.new("TextButton")
		button.Name, button.Text, button.Position = entry[1], entry[2], entry[3]
		button.Size = UDim2.fromOffset(28,70)
		button.BackgroundColor3 = Color3.fromRGB(25,32,48)
		button.TextColor3 = Color3.fromRGB(110,240,255)
		button.Font, button.TextSize = Enum.Font.FredokaOne, 28
		button.BorderSizePixel = 0
		button.Visible = false
		Instance.new("UICorner",button).CornerRadius = UDim.new(0,8)
		button.Parent = gui.Bar
	end
end
return Builder
