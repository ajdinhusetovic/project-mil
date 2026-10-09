local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Input = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local teleport = player:WaitForChild("PlayerGui"):WaitForChild("TeleportGui")
local panel = teleport.Shade.Panel
local pending = false
for _, button in {panel.WorldButton, panel.PlotButton} do
	local icon = button:FindFirstChild("DestinationIcon")
	if icon and icon:FindFirstChild("FallbackIcon") then
		local function update() icon.FallbackIcon.Visible = icon.Image == "" end
		icon:GetPropertyChangedSignal("Image"):Connect(update)
		update()
	end
end
local function go(destination)
	if pending then return end
	pending = true
	panel.StatusLabel.Text = "Teleporting..."
	remote:FireServer("Teleport", destination)
end
require(ReplicatedStorage.Shared.HUDMenuLayout).Find(player.PlayerGui, "TeleportButton").Activated:Connect(function()
	if pending then return end
	teleport.Shade.Visible = not teleport.Shade.Visible
	panel.StatusLabel.Text = "Choose a destination"
	if teleport.Shade.Visible then
		local scale = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", panel)
		scale.Scale = 0.88
		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end
end)
panel.Header.CloseButton.Activated:Connect(function() teleport.Shade.Visible = false end)
panel.WorldButton.Activated:Connect(function() go("World") end)
panel.PlotButton.Activated:Connect(function() go("Plot") end)
Input.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape then teleport.Shade.Visible = false end
end)
remote.OnClientEvent:Connect(function(action, success, reason)
	if action ~= "TeleportResult" then return end
	pending = false
	if success then teleport.Shade.Visible = false else panel.StatusLabel.Text = reason or "Could not teleport." end
end)
teleport.Shade.Visible = false
return true
