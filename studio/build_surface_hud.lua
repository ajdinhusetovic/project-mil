-- Paste this whole file into Roblox Studio's Command Bar in Edit mode.
-- It creates editable UI under StarterGui and preserves an existing copy.
local starterGui = game:GetService("StarterGui")
if starterGui:FindFirstChild("SurfaceLoopHUD") then
	warn("SurfaceLoopHUD already exists. Edit it in StarterGui; nothing was overwritten.")
	return
end

local function corner(parent, radius)
	local value = Instance.new("UICorner")
	value.CornerRadius = UDim.new(0, radius)
	value.Parent = parent
end

local function stroke(parent, color, thickness)
	local value = Instance.new("UIStroke")
	value.Color = color
	value.Thickness = thickness
	value.Parent = parent
end

local function gradient(parent, top, bottom)
	local value = Instance.new("UIGradient")
	value.Color = ColorSequence.new(top, bottom)
	value.Rotation = 90
	value.Parent = parent
end

local function text(parent, name, value, position, size, color, textSize, align)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.Text = value
	label.TextSize = textSize
	label.TextColor3 = color
	label.TextXAlignment = align or Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	stroke(label, Color3.fromRGB(0, 0, 0), 2.5)
	return label
end

local hud = Instance.new("ScreenGui")
hud.Name = "SurfaceLoopHUD"
hud.ResetOnSpawn = false
hud.IgnoreGuiInset = true
hud.DisplayOrder = 5
hud.Parent = starterGui

local counters = Instance.new("Frame")
counters.Name = "Counters"
counters.AnchorPoint = Vector2.new(0, 1)
counters.Position = UDim2.new(0, 20, 1, -25)
counters.Size = UDim2.fromOffset(276, 170)
counters.BackgroundColor3 = Color3.fromRGB(13, 23, 35)
counters.BackgroundTransparency = 0.1
counters.Parent = hud
corner(counters, 12)
stroke(counters, Color3.fromRGB(0, 0, 0), 4)
local responsiveScale = Instance.new("UIScale")
responsiveScale.Name = "ResponsiveScale"
responsiveScale.Parent = counters

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, -8, 0, 37)
header.Position = UDim2.fromOffset(4, 4)
header.BackgroundColor3 = Color3.fromRGB(253, 177, 48)
header.Parent = counters
corner(header, 7)
gradient(header, Color3.fromRGB(255, 216, 82), Color3.fromRGB(255, 124, 38))
text(header, "HeaderText", "MINING BAG", UDim2.fromOffset(12, 0), UDim2.new(1, -24, 1, 0), Color3.new(1, 1, 1), 22)

local cashBar = Instance.new("Frame")
cashBar.Name = "CashBar"
cashBar.Size = UDim2.new(1, -16, 0, 52)
cashBar.Position = UDim2.fromOffset(8, 48)
cashBar.BackgroundColor3 = Color3.fromRGB(42, 156, 29)
cashBar.Parent = counters
corner(cashBar, 6)
gradient(cashBar, Color3.fromRGB(104, 240, 56), Color3.fromRGB(25, 139, 37))
stroke(cashBar, Color3.fromRGB(0, 0, 0), 2)
local cashIcon = Instance.new("ImageLabel")
cashIcon.Name = "CashIcon"
cashIcon.Image = "rbxassetid://121888644706330"
cashIcon.Position = UDim2.fromScale(0.025, 0.5)
cashIcon.AnchorPoint = Vector2.new(0, 0.5)
cashIcon.Size = UDim2.fromScale(0.25, 0.9)
cashIcon.BackgroundTransparency = 1
cashIcon.ScaleType = Enum.ScaleType.Fit
cashIcon.Parent = cashBar
local cashLabel = text(cashBar, "CashLabel", "$0", UDim2.fromScale(0.29, 0), UDim2.fromScale(0.68, 1), Color3.fromRGB(255, 255, 255), 21)
cashLabel.TextScaled = true
local cashTextSize = Instance.new("UITextSizeConstraint")
cashTextSize.Name = "CounterTextSize"
cashTextSize.MinTextSize = 14
cashTextSize.MaxTextSize = 23
cashTextSize.Parent = cashLabel

local bagBar = Instance.new("Frame")
bagBar.Name = "BagBar"
bagBar.Size = UDim2.new(1, -16, 0, 52)
bagBar.Position = UDim2.fromOffset(8, 106)
bagBar.BackgroundColor3 = Color3.fromRGB(101, 47, 199)
bagBar.Parent = counters
corner(bagBar, 6)
gradient(bagBar, Color3.fromRGB(186, 105, 255), Color3.fromRGB(84, 33, 179))
stroke(bagBar, Color3.fromRGB(0, 0, 0), 2)
local bagIcon = Instance.new("ImageLabel")
bagIcon.Name = "BagIcon"
bagIcon.Image = "rbxasset://textures/ui/TopBar/inventoryOff.png"
bagIcon.Position = UDim2.fromScale(0.025, 0.5)
bagIcon.AnchorPoint = Vector2.new(0, 0.5)
bagIcon.Size = UDim2.fromScale(0.25, 0.9)
bagIcon.BackgroundTransparency = 1
bagIcon.ScaleType = Enum.ScaleType.Fit
bagIcon.Parent = bagBar
local bagLabel = text(bagBar, "BagLabel", "0 / 50", UDim2.fromScale(0.29, 0), UDim2.fromScale(0.68, 1), Color3.new(1, 1, 1), 20)
bagLabel.TextScaled = true
local bagTextSize = Instance.new("UITextSizeConstraint")
bagTextSize.Name = "CounterTextSize"
bagTextSize.MinTextSize = 14
bagTextSize.MaxTextSize = 23
bagTextSize.Parent = bagLabel

local toast = Instance.new("TextLabel")
toast.Name = "ToastLabel"
toast.AnchorPoint = Vector2.new(0.5, 0.5)
toast.Position = UDim2.fromScale(0.5, 0.38)
toast.Size = UDim2.fromOffset(420, 58)
toast.BackgroundColor3 = Color3.fromRGB(17, 29, 23)
toast.BackgroundTransparency = 0.05
toast.Font = Enum.Font.FredokaOne
toast.Text = "SOLD 3 ORE  +$5"
toast.TextSize = 28
toast.TextColor3 = Color3.fromRGB(101, 255, 100)
toast.Visible = false
toast.Parent = hud
corner(toast, 10)
stroke(toast, Color3.fromRGB(0, 0, 0), 4)

print("Created StarterGui.SurfaceLoopHUD. Edit its Frames and labels in Explorer.")
