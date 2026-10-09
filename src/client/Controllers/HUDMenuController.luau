local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local Layout=require(game.ReplicatedStorage.Shared.HUDMenuLayout)
local player=Players.LocalPlayer
local gui=Layout.Bind(player:WaitForChild("PlayerGui"))
local button=gui.SafeArea.Buttons.OverchargeButton
local function refresh()
	local percent=Layout.Progress({Level=player:GetAttribute("Level"),Power=player:GetAttribute("Power"),Cash=player:GetAttribute("Cash")},player:GetAttribute("Overcharges") or 0)
	button.ProgressLabel.Text=percent.."%"
	button.ProgressTrack.Fill.Size=UDim2.fromScale(percent/100,1)
end
for _,name in {"Level","Power","Cash","Overcharges"} do player:GetAttributeChangedSignal(name):Connect(refresh) end
for _,item in gui.SafeArea.Buttons:GetChildren() do
	if not item:IsA("GuiButton") then continue end
	local scale=Instance.new("UIScale",item)
	local tween
	local function animate(value)
		if tween then tween:Cancel() end
		tween=TweenService:Create(scale,TweenInfo.new(.13,Enum.EasingStyle.Quad),{Scale=value})
		tween:Play()
	end
	item.MouseEnter:Connect(function() animate(1.04) end)
	item.MouseLeave:Connect(function() animate(1) end)
	item.MouseButton1Down:Connect(function() animate(.94) end)
	item.MouseButton1Up:Connect(function() animate(1) end)
end
require(game.ReplicatedStorage.Shared.MenuLayers).Bind(player.PlayerGui)()
refresh()
return true
