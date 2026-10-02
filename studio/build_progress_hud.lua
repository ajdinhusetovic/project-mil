-- Paste into Roblox Studio's Command Bar in Edit mode.
-- Creates an editable top Level/XP/Power HUD. Existing HUD is preserved.
local starterGui = game:GetService("StarterGui")
if starterGui:FindFirstChild("ProgressHUD") then
	warn("ProgressHUD already exists. Edit it in StarterGui; nothing was overwritten.")
	return
end

local function stroke(parent, color, thickness)
	local value = Instance.new("UIStroke")
	value.Color = color
	value.Thickness = thickness
	value.Parent = parent
end

local function label(parent, name, value, position, size, textSize, align)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Text = value
	item.Position = position
	item.Size = size
	item.BackgroundTransparency = 1
	item.TextColor3 = Color3.new(1, 1, 1)
	item.TextSize = textSize
	item.Font = Enum.Font.FredokaOne
	item.TextXAlignment = align
	item.Parent = parent
	stroke(item, Color3.new(0, 0, 0), 3)
	return item
end

local gui = Instance.new("ScreenGui")
gui.Name = "ProgressHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 6
gui.Parent = starterGui

local bar = Instance.new("Frame")
bar.Name = "LevelBar"
bar.AnchorPoint = Vector2.new(0.5, 0)
bar.Position = UDim2.new(0.5, 0, 0, 13)
bar.Size = UDim2.fromOffset(550, 78)
bar.BackgroundColor3 = Color3.fromRGB(8, 34, 62)
bar.ClipsDescendants = true
bar.Parent = gui
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 11)
stroke(bar, Color3.new(0, 0, 0), 5)

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(255, 156, 64)
fill.Parent = bar
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 9)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new(Color3.fromRGB(255, 92, 132), Color3.fromRGB(255, 180, 55))
gradient.Parent = fill

label(bar, "LevelLabel", "LEVEL 1", UDim2.fromOffset(22, 0), UDim2.new(0.55, 0, 1, 0), 37, Enum.TextXAlignment.Left)
label(bar, "XPLabel", "0 / 15 XP", UDim2.new(0.64, 0, 0, 0), UDim2.new(0.34, 0, 1, 0), 29, Enum.TextXAlignment.Right)

local power = label(gui, "PowerLabel", "⚡ 0 POWER     +1 / CLICK", UDim2.new(0.5, 0, 0, 101), UDim2.fromOffset(550, 36), 25, Enum.TextXAlignment.Center)
power.AnchorPoint = Vector2.new(0.5, 0)
power.TextColor3 = Color3.fromRGB(255, 216, 75)

local depth = power:Clone()
depth.Name = "DepthLabel"
depth.Text = "DEPTH: 0 STUDS"
depth.Visible = false
depth.Parent = gui

local returnButton = Instance.new("TextButton")
returnButton.Name = "ReturnButton"
returnButton.AnchorPoint = Vector2.new(0.5, 0)
returnButton.Position = UDim2.new(0.5, 0, 0, 174)
returnButton.Size = UDim2.fromOffset(190, 44)
returnButton.BackgroundColor3 = Color3.fromRGB(35, 194, 81)
returnButton.Font = Enum.Font.FredokaOne
returnButton.Text = "RETURN"
returnButton.TextColor3 = Color3.new(1, 1, 1)
returnButton.TextSize = 25
returnButton.Visible = false
returnButton.Parent = gui
Instance.new("UICorner", returnButton).CornerRadius = UDim.new(0, 9)
stroke(returnButton, Color3.new(0, 0, 0), 3)

print("Created StarterGui.ProgressHUD. Edit colors, layout, and text styling in Explorer.")
