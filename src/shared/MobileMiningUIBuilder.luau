local Builder = {}
function Builder.Build(parent)
 assert(not game:GetService("RunService"):IsRunning(), "Create UI through Studio Command Bar in Edit mode")
	local existing = parent:FindFirstChild("MobileMiningHUD")
	if existing then
		local button = existing:FindFirstChild("AttackButton")
		if button then button:Destroy() end
		return existing
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "MobileMiningHUD"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 5
	gui.Parent = parent
	local crosshair = Instance.new("TextLabel")
	crosshair.Name = "Crosshair"
	crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
	crosshair.Position = UDim2.fromScale(0.5, 0.5)
	crosshair.Size = UDim2.fromScale(0.035, 0.055)
	crosshair.BackgroundTransparency = 1
	crosshair.Text = "+"
	crosshair.TextScaled = true
	crosshair.TextColor3 = Color3.fromRGB(102, 234, 255)
	crosshair.Font = Enum.Font.GothamBold
	crosshair.TextStrokeTransparency = 0
	crosshair.Visible = false
	crosshair.Parent = gui
	return gui
end
return Builder
