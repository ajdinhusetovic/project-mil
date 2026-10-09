local Style = {}

function Style.Apply(template)
	if template:GetAttribute("PowerIconStyle") then return template end
	template:SetAttribute("PowerIconStyle", true)
	template.Text = ""
	template.TextStrokeTransparency = 1
	template.Size = UDim2.fromOffset(180, 64)
	template.BackgroundTransparency = 1
	local icon = Instance.new("ImageLabel")
	icon.Name = "PowerIcon"
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://71561893600786"
	icon.ScaleType = Enum.ScaleType.Fit
	icon.AnchorPoint = Vector2.new(0, .5)
	icon.Position, icon.Size = UDim2.fromScale(.03, .5), UDim2.fromScale(.33, .94)
	icon.ZIndex = template.ZIndex
	icon.Parent = template
	local amount = Instance.new("TextLabel")
	amount.Name = "AmountLabel"
	amount.BackgroundTransparency = 1
	amount.Position, amount.Size = UDim2.fromScale(.39, .08), UDim2.fromScale(.59, .84)
	amount.Text, amount.Font = "+1", Enum.Font.FredokaOne
	amount.TextColor3 = Color3.fromRGB(255, 225, 86)
	amount.TextXAlignment = Enum.TextXAlignment.Left
	amount.TextScaled = true
	amount.ZIndex = template.ZIndex
	amount.Parent = template
	local limit = Instance.new("UITextSizeConstraint")
	limit.MinTextSize, limit.MaxTextSize = 16, 40
	limit.Parent = amount
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color, stroke.Thickness = Color3.new(0, 0, 0), 3
	stroke.Parent = amount
	return template
end

return Style
