local PowerHUD = {}

-- Add only the missing row, inheriting the player's authored cash-row styling.
function PowerHUD.Ensure(gui)
	assert(not game:GetService("RunService"):IsRunning(), "Author the power row through Studio's Edit Command Bar")
	local counters = gui:FindFirstChild("Counters")
	assert(counters, "SurfaceLoopHUD.Counters is missing")
	local existing = counters:FindFirstChild("PowerLabel", true)
	if existing then return existing end
	local cash = counters:FindFirstChild("CashBar")
	local bag = counters:FindFirstChild("BagBar")
	assert(cash and bag, "SurfaceLoopHUD needs CashBar and BagBar")
	local row = cash:Clone()
	row.Name = "PowerBar"
	row.Position = cash.Position - (bag.Position - cash.Position)
	row.LayoutOrder = cash.LayoutOrder - 1
	local label = row:FindFirstChild("CashLabel", true)
	assert(label and label:IsA("TextLabel"), "CashBar.CashLabel is missing")
	label.Name = "PowerLabel"
	label.Text = "0"
	label.TextColor3 = Color3.fromRGB(85, 225, 255)
	local cashIcon = row:FindFirstChild("CashIcon", true)
	local icon = Instance.new("TextLabel")
	icon.Name = "PowerIcon"
	icon.BackgroundTransparency = 1
	icon.AnchorPoint = cashIcon and cashIcon.AnchorPoint or Vector2.new(0, 0.5)
	icon.Position = cashIcon and cashIcon.Position or UDim2.fromScale(0.025, 0.5)
	icon.Size = cashIcon and cashIcon.Size or UDim2.fromScale(0.25, 0.9)
	icon.ZIndex = cashIcon and cashIcon.ZIndex or label.ZIndex
	icon.Text = "⚡"
	icon.TextColor3 = Color3.fromRGB(255, 226, 70)
	icon.Font = Enum.Font.FredokaOne
	icon.TextScaled = true
	icon.Parent = row
	local outline = Instance.new("UIStroke")
	outline.Color = Color3.new(0, 0, 0)
	outline.Thickness = 2.5
	outline.Parent = icon
	if cashIcon then cashIcon:Destroy() end
	-- Existing money and bag rows keep their positions; allow the new row above them.
	counters.ClipsDescendants = false
	row.Parent = counters
	return label
end

return PowerHUD
