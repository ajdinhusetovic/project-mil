-- Paste into Studio's Command Bar in Edit mode to update the existing, editable HUD.
local hud = game:GetService("StarterGui"):FindFirstChild("SurfaceLoopHUD")
assert(hud, "StarterGui.SurfaceLoopHUD is missing")
local counters = hud:FindFirstChild("Counters")
assert(counters and counters:IsA("Frame"), "SurfaceLoopHUD.Counters is missing")
counters.Size = UDim2.fromOffset(276, 170)

local function arrange(barName, labelName, iconName, defaultImage)
	local bar = counters:FindFirstChild(barName)
	assert(bar and bar:IsA("Frame"), `Counters.{barName} is missing`)
	bar.Position = UDim2.fromOffset(8, barName == "CashBar" and 48 or 106)
	bar.Size = UDim2.new(1, -16, 0, 52)
	local label = bar:FindFirstChild(labelName, true)
	assert(label and label:IsA("TextLabel"), `{barName}.{labelName} is missing`)

	-- Keep any image the player has already placed inside the label.
	local icon = bar:FindFirstChild(iconName) or label:FindFirstChildWhichIsA("ImageLabel", true)
	if not icon then
		icon = Instance.new("ImageLabel")
		icon.Image = defaultImage
	end
	icon.Name = iconName
	icon.Parent = bar
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.Position = UDim2.fromScale(0.025, 0.5)
	icon.Size = UDim2.fromScale(0.25, 0.9)
	icon.BackgroundTransparency = 1
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Visible = true

	label.AnchorPoint = Vector2.new(0, 0)
	label.Position = UDim2.fromScale(0.29, 0)
	label.Size = UDim2.fromScale(0.68, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextScaled = true
	if labelName == "BagLabel" then
		label.Text = label.Text:gsub("%s*BAG%s*$", "")
	end
	local limit = label:FindFirstChild("CounterTextSize") or Instance.new("UITextSizeConstraint")
	limit.Name = "CounterTextSize"
	limit.MinTextSize = 14
	limit.MaxTextSize = 23
	limit.Parent = label
end

arrange("CashBar", "CashLabel", "CashIcon", "rbxassetid://121888644706330")
arrange("BagBar", "BagLabel", "BagIcon", "rbxasset://textures/ui/TopBar/inventoryOff.png")

-- The client updates this scale when the viewport changes.
local scale = counters:FindFirstChild("ResponsiveScale") or Instance.new("UIScale")
scale.Name = "ResponsiveScale"
scale.Parent = counters

print("Updated SurfaceLoopHUD cash and bag icon layout.")
