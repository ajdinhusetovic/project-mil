-- Paste this whole file into Roblox Studio's Command Bar in Edit mode.
-- MaterialsHUD and the mine-only Depth/Return controls stay editable in StarterGui.
local starterGui = game:GetService("StarterGui")
local replicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(replicatedStorage.Shared.Config)

local function stroke(parent, color, thickness)
	local item = Instance.new("UIStroke")
	item.Color = color
	item.Thickness = thickness
	item.Parent = parent
end

local progress = starterGui:FindFirstChild("ProgressHUD")
assert(progress, "Build StarterGui.ProgressHUD first with studio/build_progress_hud.lua")
local powerLabel = progress:FindFirstChild("PowerLabel")
assert(powerLabel and powerLabel:IsA("TextLabel"), "ProgressHUD.PowerLabel is missing")

if not progress:FindFirstChild("DepthLabel") then
	local depthLabel = powerLabel:Clone()
	depthLabel.Name = "DepthLabel"
	depthLabel.Text = "DEPTH: 0 STUDS"
	depthLabel.Visible = false
	depthLabel.Parent = progress
end
if not progress:FindFirstChild("ReturnButton") then
	local button = Instance.new("TextButton")
	button.Name = "ReturnButton"
	button.AnchorPoint = Vector2.new(0.5, 0)
	button.Position = UDim2.new(0.5, 0, 0, 174)
	button.Size = UDim2.fromOffset(190, 44)
	button.BackgroundColor3 = Color3.fromRGB(35, 194, 81)
	button.Font = Enum.Font.FredokaOne
	button.Text = "RETURN"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 25
	button.Visible = false
	button.Parent = progress
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)
	stroke(button, Color3.new(0, 0, 0), 3)
end

if not starterGui:FindFirstChild("MaterialsHUD") then
	local gui = Instance.new("ScreenGui")
	gui.Name = "MaterialsHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 5
	gui.Parent = starterGui

	local panel = Instance.new("Frame")
	panel.Name = "MaterialInventory"
	panel.AnchorPoint = Vector2.new(0, 1)
	panel.Position = UDim2.new(0, 18, 1, -220)
	panel.Size = UDim2.fromOffset(254, 42)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = Color3.fromRGB(18, 28, 42)
	panel.BackgroundTransparency = 0.08
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
	stroke(panel, Color3.new(0, 0, 0), 2.5)
	local scale = Instance.new("UIScale")
	scale.Name = "ResponsiveScale"
	scale.Parent = panel
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 5)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 3)
	layout.Parent = panel

	local function makeLabel(name, value, order, color, height, textSize)
		local item = Instance.new("TextLabel")
		item.Name = name
		item.LayoutOrder = order
		item.Size = UDim2.new(1, 0, 0, height)
		item.BackgroundTransparency = 1
		item.Font = Enum.Font.FredokaOne
		item.Text = value
		item.TextColor3 = color
		item.TextSize = textSize
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.Parent = panel
		stroke(item, Color3.new(0, 0, 0), 2)
		return item
	end
	makeLabel("Title", "MATERIALS", 0, Color3.fromRGB(100, 237, 255), 32, 20)
	local colors = {}
	for _, layer in Config.Layers do
		for _, material in layer.Materials do
			colors[material.Name] = material.Color
		end
	end
	for order, materialName in Config.MaterialOrder do
		local row = makeLabel(materialName, "x0  " .. string.upper(materialName), order, colors[materialName] or Color3.new(1, 1, 1), 27, 17)
		row.Visible = false
	end
end

print("Mining UI ready in StarterGui: MaterialsHUD, ProgressHUD.DepthLabel, and ProgressHUD.ReturnButton.")
