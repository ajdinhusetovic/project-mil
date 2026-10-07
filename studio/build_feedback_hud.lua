-- Paste this whole file into Roblox Studio's Command Bar in Edit mode.
-- Edit the three hidden TextLabels in StarterGui.FeedbackHUD to restyle popups.
local starterGui = game:GetService("StarterGui")
if starterGui:FindFirstChild("FeedbackHUD") then
	warn("FeedbackHUD already exists. Edit its templates in StarterGui; nothing was overwritten.")
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "FeedbackHUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = starterGui

local function template(name, sample, width, color, maxSize)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.AnchorPoint = Vector2.new(0.5, 0.5)
	item.Position = UDim2.fromScale(0.5, 0.5)
	item.Size = UDim2.new(width, 0, 0, 58)
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.FredokaOne
	item.Text = sample
	item.TextColor3 = color
	item.TextScaled = true
	item.TextStrokeColor3 = Color3.new(0, 0, 0)
	item.TextStrokeTransparency = 0
	item.ZIndex = 10
	item.Visible = false
	item.Parent = gui
	local limit = Instance.new("UITextSizeConstraint")
	limit.MinTextSize = 18
	limit.MaxTextSize = maxSize
	limit.Parent = item
end

template("PowerTemplate", "+1 POWER", 0.4, Color3.fromRGB(255, 208, 49), 38)
template("OreTemplate", "x5  COPPER ORE", 0.52, Color3.fromRGB(98, 241, 255), 34)
template("SaleTemplate", "+25$", 0.65, Color3.fromRGB(94, 255, 108), 39)
local sale = gui.SaleTemplate
sale.TextStrokeTransparency = 1
local stroke = Instance.new("UIStroke")
stroke.Thickness, stroke.Color = 3, Color3.new(0,0,0)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
stroke.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
stroke.Parent = sale

print("Created StarterGui.FeedbackHUD with editable Power, Ore, and Sale text templates.")
