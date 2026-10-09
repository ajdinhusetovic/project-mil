local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local FeedbackEffects = require(script.Parent.FeedbackEffects)
local TrainingFeedback = require(script.Parent.TrainingFeedback)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("MiningDemo")

local gui = playerGui:WaitForChild("SurfaceLoopHUD")

local panel = gui:WaitForChild("Counters")
local powerLabel = panel:WaitForChild("PowerBar"):WaitForChild("PowerLabel")
local function findLabel(name)
	local label = panel:FindFirstChild(name, true)
	assert(label and label:IsA("TextLabel"), `SurfaceLoopHUD is missing Counters/{name}`)
	return label
end
local cashLabel = findLabel("CashLabel")
local bagLabel = findLabel("BagLabel")
local toastLabel = gui:FindFirstChild("ToastLabel")

local responsiveScale = panel:FindFirstChild("ResponsiveScale")
if responsiveScale and responsiveScale:IsA("UIScale") then
	local function updateScale()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		responsiveScale.Scale = math.clamp(math.min(viewport.X / 720, viewport.Y / 650), 0.6, 1)
	end
	local function watchCamera()
		local camera = workspace.CurrentCamera
		if camera then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
		end
		updateScale()
	end
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
	watchCamera()
end

local function refresh()
	local power = TrainingFeedback.GetStats()
	local cash = player:GetAttribute("Cash") or 0
	local used = player:GetAttribute("BackpackUsed") or 0
	local capacity = player:GetAttribute("BackpackCapacity") or 50
	cashLabel.Text = "$" .. Format.Compact(cash)
	powerLabel.Text = Format.Compact(power)
	bagLabel.Text = Format.Compact(used) .. " / " .. Format.Compact(capacity)
end

refresh()
TrainingFeedback.Changed.Event:Connect(refresh)
local previousCash = player:GetAttribute("Cash") or 0
local previousUsed = player:GetAttribute("BackpackUsed") or 0
player:GetAttributeChangedSignal("Cash"):Connect(function()
	local cash = player:GetAttribute("Cash") or 0
	if cash > previousCash then FeedbackEffects.Pulse(cashLabel.Parent) end
	previousCash = cash
	refresh()
end)
player:GetAttributeChangedSignal("BackpackUsed"):Connect(function()
	local used = player:GetAttribute("BackpackUsed") or 0
	if used > previousUsed then FeedbackEffects.Pulse(bagLabel.Parent) end
	previousUsed = used
	refresh()
end)
player:GetAttributeChangedSignal("BackpackCapacity"):Connect(function()
	FeedbackEffects.Pulse(bagLabel.Parent)
	refresh()
end)

local toastToken = 0
local function toast(message, success)
	if not toastLabel then return end
	toastToken += 1
	local token = toastToken
	toastLabel.Text = message
	toastLabel.TextColor3 = success and Color3.fromRGB(95, 255, 105) or Color3.fromRGB(255, 225, 110)
	toastLabel.Visible = true
	task.delay(1.8, function()
		if toastToken == token then toastLabel.Visible = false end
	end)
end

remote.OnClientEvent:Connect(function(action, first, second)
	if action == "ReactorCollected" then
		FeedbackEffects.ShowSale(first, 0, cashLabel.Parent, "REACTOR", "COLLECTED")
	elseif action == "Sold" then
		if first > 0 then FeedbackEffects.ShowSale(first, second, cashLabel.Parent)
		else toast("BAG IS EMPTY", false) end
	elseif action == "CoresSold" then
		FeedbackEffects.ShowSale(first, second, cashLabel.Parent, Format.Compact(second) .. " CORES")
	elseif action == "CoreSold" then
		FeedbackEffects.ShowSale(first, 1, cashLabel.Parent, second)
	elseif action == "StoragePurchased" then
		if first then toast(string.format("BAG UPGRADED  -$%s", Format.Compact(second)), true)
		else toast(tostring(second), false) end
	elseif action == "UpgradePurchased" then
		toast(tostring(second), first)
	elseif action == "BackpackFull" then
		toast("BAG FULL • SELL ORE", false)
	elseif action == "WeaponShopResult" then
		toast(tostring(second), first)
	end
end)

return true
