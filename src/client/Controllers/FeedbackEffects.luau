local Format = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").NumberFormat)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("FeedbackHUD")

local FeedbackEffects = {}
local rng = Random.new()
local orePopups = {}
local pulseTweens = {}
local corePopup

local function makeText(templateName, value, color)
	local template = gui:FindFirstChild(templateName)
	if not template or not template:IsA("TextLabel") then return nil end
	local item = template:Clone()
	item.Name = templateName .. "Effect"
	if templateName == "PowerTemplate" then
		item.Text = ""
		item.AmountLabel.Text = value
	else
		item.Text = value
	end
	if color then item.TextColor3 = color end
	item.TextTransparency = 0
	item.TextStrokeTransparency = (templateName == "SaleTemplate" or templateName == "PowerTemplate") and 1 or 0
	if templateName == "SaleTemplate" then
		local stroke = item:FindFirstChildOfClass("UIStroke")
		if not stroke then
			stroke = Instance.new("UIStroke")
			stroke.Thickness = 3
			stroke.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
			stroke.Color = Color3.new(0, 0, 0)
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
			stroke.Parent = item
		end
		stroke.Transparency = 0
	end
	item.Visible = true
	item.Parent = gui
	local scale = Instance.new("UIScale")
	scale.Name = "EffectScale"
	scale.Scale = 0.65
	scale.Parent = item
	TweenService:Create(scale, TweenInfo.new(0.19, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	return item, scale
end

local function fadeText(item, duration)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(item, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	for _, child in item:GetDescendants() do
		if child:IsA("ImageLabel") then
			TweenService:Create(child, info, { ImageTransparency = 1 }):Play()
		elseif child:IsA("TextLabel") then
			TweenService:Create(child, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		elseif child:IsA("UIStroke") then
			TweenService:Create(child, info, { Transparency = 1 }):Play()
		end
	end
end

function FeedbackEffects.Pulse(target)
	if not target then return end
	local scale = target:FindFirstChild("FeedbackPulse")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Name = "FeedbackPulse"
		scale.Parent = target
	end
	if pulseTweens[target] then pulseTweens[target]:Cancel() end
	scale.Scale = 1.16
	local tween = TweenService:Create(scale, TweenInfo.new(0.31, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
	pulseTweens[target] = tween
	tween.Completed:Once(function()
		if pulseTweens[target] == tween then pulseTweens[target] = nil end
	end)
	tween:Play()
end

function FeedbackEffects.ShowPower(amount)
	if amount <= 0 then return end
	local item = makeText("PowerTemplate", "+" .. Format.Compact(amount))
	if not item then return end
	local x = rng:NextNumber(0.25, 0.75)
	local y = rng:NextNumber(0.32, 0.68)
	item.Position = UDim2.fromScale(x, y)
	item.Rotation = rng:NextInteger(-6, 6)
	TweenService:Create(item, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(x + rng:NextNumber(-0.025, 0.025), y - 0.12),
		Rotation = 0,
	}):Play()
	task.delay(0.32, function()
		if not item.Parent then return end
		fadeText(item, 0.68)
		task.delay(0.7, function() item:Destroy() end)
	end)
end

function FeedbackEffects.ShowOre(materialName, amount, color)
	local popup = orePopups[materialName]
	if not popup then
		local item, scale = makeText("OreTemplate", "", color)
		if not item then return end
		local x = rng:NextNumber(0.33, 0.67)
		local y = rng:NextNumber(0.43, 0.7)
		item.Position = UDim2.fromScale(x, y)
		item.Rotation = rng:NextInteger(-7, 7)
		popup = { Item = item, Scale = scale, Amount = 0, Token = 0, X = x, Y = y }
		orePopups[materialName] = popup
	end
	popup.Amount += amount
	popup.Token += 1
	local token = popup.Token
	popup.Item.Text = string.format("x%s  %s", Format.Compact(popup.Amount), string.upper(materialName))
	popup.Item.TextTransparency = 0
	popup.Item.TextStrokeTransparency = 0
	popup.Scale.Scale = 1.16
	TweenService:Create(popup.Scale, TweenInfo.new(0.17, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	task.delay(0.48, function()
		if orePopups[materialName] ~= popup or popup.Token ~= token then return end
		orePopups[materialName] = nil
		TweenService:Create(popup.Item, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(popup.X + rng:NextNumber(-0.05, 0.05), popup.Y - 0.12),
		}):Play()
		fadeText(popup.Item, 0.6)
		task.delay(0.62, function() popup.Item:Destroy() end)
	end)
end

function FeedbackEffects.ShowCore(text, color)
	if corePopup then corePopup:Destroy() end
	local item = makeText("OreTemplate", text, color)
	if not item then return end
	corePopup = item
	item.Position = UDim2.fromScale(0.5, 0.35)
	item.Size = UDim2.fromScale(0.65, 0.09)
	item.Rotation = 0
	task.delay(1.5, function()
		if not item.Parent then return end
		fadeText(item, 0.5)
		task.delay(0.52, function() item:Destroy() end)
	end)
end

function FeedbackEffects.ShowSale(cash, count, cashTarget, coreName, verb)
	if cash <= 0 then return end
	local label = "+" .. Format.Compact(cash) .. "$"
	local item, scale = makeText("SaleTemplate", label)
	if not item then return end
	item.Position = UDim2.fromScale(0.5, 0.48)
	scale.Scale = 1.2
	TweenService:Create(scale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	task.delay(0.46, function()
		if not item.Parent then return end
		if not cashTarget or not cashTarget.Parent then
			fadeText(item, 0.4)
			local stroke=item:FindFirstChildOfClass("UIStroke")
			if stroke then TweenService:Create(stroke,TweenInfo.new(.4),{Transparency=1}):Play() end
			task.delay(.42,function() item:Destroy() end)
			return
		end
		local center = cashTarget.AbsolutePosition + cashTarget.AbsoluteSize / 2
		local stroke = item:FindFirstChildOfClass("UIStroke")
		if stroke then TweenService:Create(stroke,TweenInfo.new(.72,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Transparency=1}):Play() end
		local tween = TweenService:Create(item, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.fromOffset(center.X, center.Y),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		})
		TweenService:Create(scale, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.25 }):Play()
		tween.Completed:Once(function()
			item:Destroy()
			FeedbackEffects.Pulse(cashTarget)
		end)
		tween:Play()
	end)
end

return FeedbackEffects
