local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Definitions = require(ReplicatedStorage.Shared.OverchargeDefinitions)
local Builder = require(ReplicatedStorage.Shared.OverchargeUIBuilder)
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:FindFirstChild("OverchargeGui") or Builder.Build(playerGui)
require(ReplicatedStorage.Shared.RebirthMenuStyle).Button(gui)
local shade, panel = gui.Shade, gui.Shade.Panel
local armed, pending, armedCount = false, false, nil
local styled=gui:GetAttribute("ReferenceRebirthStyle")
for _,descendant in panel:GetDescendants() do
	if descendant:IsA("ImageLabel") and descendant:FindFirstChild("FallbackIcon") then
		local function updateIcon() descendant.FallbackIcon.Visible=descendant.Image=="" end
		descendant:GetPropertyChangedSignal("Image"):Connect(updateIcon)
		updateIcon()
	end
end
local green = Color3.fromRGB(128, 255, 121)
local red = Color3.fromRGB(255, 152, 134)
local function refresh()
	local count = player:GetAttribute("Overcharges") or 0
	local required = Definitions.Requirements(count)
	local power, cash = Definitions.Multipliers(count)
	local nextPower, nextCash = Definitions.Multipliers(count + 1)
	local ready = player:GetAttribute("Overcharges") ~= nil
	panel.CountLabel.Text = string.format("%s OVERCHARGES • PERMANENT BONUSES", Format.Compact(count))
	panel.PowerReward.Text = "POWER " .. Definitions.Number(power) .. "x → " .. Definitions.Number(nextPower) .. "x"
	panel.CashReward.Text = "CASH " .. Definitions.Number(cash) .. "x → " .. Definitions.Number(nextCash) .. "x"
	if styled then
		panel.PowerCurrent.ValueLabel.Text=Definitions.Number(power).."x Power"
		panel.PowerNext.ValueLabel.Text=Definitions.Number(nextPower).."x Power"
		panel.CashCurrent.ValueLabel.Text=Definitions.Number(cash).."x Money"
		panel.CashNext.ValueLabel.Text=Definitions.Number(nextCash).."x Money"
	end
	for _, key in {"Level", "Power", "Cash"} do
		local current = player:GetAttribute(key) or (key == "Level" and 1 or 0)
		local met = current >= required[key]
		ready = ready and met
		local prefix = key == "Cash" and "$" or ""
		local label = panel[key .. "Requirement"]
		label.Text = string.upper(key) .. "  " .. prefix .. Definitions.Number(current) .. " / " .. prefix .. Definitions.Number(required[key]) .. (met and "  ✓" or "")
		label.TextColor3 = met and green or red
		if styled then
			label.Text=key..": "..prefix..Definitions.Number(current).." / "..prefix..Definitions.Number(required[key])
			label.TextColor3=Color3.new(1,1,1)
			local gradient=panel[key.."RequirementBar"]:FindFirstChildOfClass("UIGradient")
			gradient.Color=met and ColorSequence.new(Color3.fromRGB(43,210,22),Color3.fromRGB(32,112,11))
				or ColorSequence.new(Color3.fromRGB(217,73,75),Color3.fromRGB(123,30,43))
		end
	end
	if not ready or armedCount ~= count then armed = false end
	panel.ConfirmButton.Text = pending and "OVERCHARGING..." or (armed and "CONFIRM RESET" or (ready and "OVERCHARGE" or "REQUIREMENTS NOT MET"))
	panel.ConfirmButton.BackgroundColor3 = ready and Color3.fromRGB(102, 225, 65) or Color3.fromRGB(112, 102, 127)
	panel.ConfirmButton.Active = ready and not pending
	panel.ConfirmButton.AutoButtonColor = ready and not pending
	panel.StatusLabel.Text = armed and "This resets your current run. Press again to confirm." or "Cash bonus applies to ore and core sales."
	if styled then
		panel.ConfirmButton.ButtonLabel.Text=pending and "Rebirthing..." or armed and "Confirm Rebirth" or "Rebirth"
		panel.ConfirmButton.Text=""
		local gradient=panel.ConfirmButton:FindFirstChildOfClass("UIGradient")
		gradient.Color=ready and ColorSequence.new(Color3.fromRGB(55,245,17),Color3.fromRGB(13,131,4))
			or ColorSequence.new(Color3.fromRGB(135,139,143),Color3.fromRGB(66,70,76))
		panel.StatusLabel.Text=armed and "This resets your run. Press again to confirm." or ready and "Ready to rebirth!" or "Meet all three requirements to rebirth"
	end
	return ready, count
end
local pop
local scale = Instance.new("UIScale", panel)
local function close()
	if pending then return end
	shade.Visible = false
	armed = false
end
gui.OverchargeButton.Activated:Connect(function()
	if pending then return end
	armed = false
	shade.Visible = not shade.Visible
	if not shade.Visible then return end
	refresh()
	if pop then pop:Cancel() end
	scale.Scale = 0.86
	pop = TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	pop:Play()
end)
panel.Header.CloseButton.Activated:Connect(close)
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape then close() end
end)
panel.ConfirmButton.Activated:Connect(function()
	if pending then return end
	local ready, count = refresh()
	if not ready then return end
	if not armed then
		armed, armedCount = true, count
		refresh()
		return
	end
	pending = true
	refresh()
	remote:FireServer("Overcharge", count)
end)
local celebrationId = 0
remote.OnClientEvent:Connect(function(action, success, result)
	if action ~= "OverchargeResult" then return end
	pending, armed = false, false
	refresh()
	if not success then panel.StatusLabel.Text = result return end
	shade.Visible = false
	local power, cash = Definitions.Multipliers(result)
	local label = gui.CelebrationLabel
	label.Text = (styled and "REBIRTH!\n" or "OVERCHARGED!\n") .. Definitions.Number(power) .. "x POWER • " .. Definitions.Number(cash) .. "x CASH"
	label.Visible = true
	label.TextTransparency, label.TextStrokeTransparency = 0, 0
	label.UIScale.Scale = 0.6
	TweenService:Create(label.UIScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	celebrationId += 1
	local id = celebrationId
	task.delay(2.5, function()
		if id ~= celebrationId then return end
		local fade = TweenService:Create(label, TweenInfo.new(0.4), {TextTransparency = 1, TextStrokeTransparency = 1})
		fade:Play()
		fade.Completed:Wait()
		if id == celebrationId then label.Visible = false end
	end)
end)
for _, attribute in {"Power", "Level", "Cash", "Overcharges"} do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
shade.Visible = false
refresh()
return true
