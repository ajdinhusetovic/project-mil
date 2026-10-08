-- Paste this whole file into Roblox Studio's Command Bar in Edit mode.
-- Mine-only Depth/Return controls stay editable in StarterGui.
local starterGui = game:GetService("StarterGui")

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

local legacy = starterGui:FindFirstChild("MaterialsHUD")
if legacy then legacy.Parent = nil end
print("Mining UI ready: ProgressHUD.DepthLabel and ProgressHUD.ReturnButton.")
