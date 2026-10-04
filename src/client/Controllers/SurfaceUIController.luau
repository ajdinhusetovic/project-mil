local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local StarterGui = game:GetService("StarterGui")
local FeedbackEffects = require(script.Parent.FeedbackEffects)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("MiningDemo")

-- Studio-authored SurfaceLoopHUD takes priority. The small fallback keeps
-- Rojo-only playtests usable before the Command Bar builder is pasted.
local gui = playerGui:FindFirstChild("SurfaceLoopHUD") or playerGui:WaitForChild("SurfaceLoopHUD", 3)
if not gui then
	local authored = StarterGui:FindFirstChild("SurfaceLoopHUD")
	if authored then
		gui = authored:Clone()
		gui.Parent = playerGui
	end
end
if not gui then
	gui = Instance.new("ScreenGui")
	gui.Name = "SurfaceLoopHUD"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui
	local panel = Instance.new("Frame")
	panel.Name = "Counters"
	panel.Size = UDim2.fromOffset(260, 82)
	panel.Position = UDim2.fromOffset(18, 325)
	panel.BackgroundColor3 = Color3.fromRGB(18, 27, 40)
	panel.BackgroundTransparency = 0.08
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)
	for index, name in { "CashLabel", "BagLabel" } do
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Size = UDim2.new(1, -16, 0, 34)
		label.Position = UDim2.fromOffset(8, 6 + (index - 1) * 36)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.FredokaOne
		label.TextSize = 18
		label.Parent = panel
	end
	local toast = Instance.new("TextLabel")
	toast.Name = "ToastLabel"
	toast.Size = UDim2.fromOffset(360, 50)
	toast.AnchorPoint = Vector2.new(0.5, 0.5)
	toast.Position = UDim2.fromScale(0.5, 0.38)
	toast.BackgroundColor3 = Color3.fromRGB(16, 30, 22)
	toast.TextColor3 = Color3.new(1, 1, 1)
	toast.Font = Enum.Font.FredokaOne
	toast.TextSize = 24
	toast.Visible = false
	toast.Parent = gui
	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 12)
end

local panel = gui:WaitForChild("Counters")
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
	local cash = player:GetAttribute("Cash") or 0
	local used = player:GetAttribute("BackpackUsed") or 0
	local capacity = player:GetAttribute("BackpackCapacity") or 50
	cashLabel.Text = "$" .. Format.Compact(cash)
	bagLabel.Text = Format.Compact(used) .. " / " .. Format.Compact(capacity)
end

refresh()
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
	if action == "Sold" then
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
