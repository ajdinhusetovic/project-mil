local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Definitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Visuals = require(ReplicatedStorage.Shared.CoreVisuals)
local Builder = require(ReplicatedStorage.Shared.CoreIndexUIBuilder)
local player = Players.LocalPlayer
local gui = player.PlayerGui:FindFirstChild("CoreIndexGui") or Builder.Build(player.PlayerGui)
local shade = gui.Shade
local panel = shade.Panel
local displayed = {}
local scale = panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", panel)
local pop, progressTween
local function refresh()
	local discovered = 0
	for _, key in Definitions.Order do
		local known = player:GetAttribute("DiscoveredCore_" .. key) == true
		if known then discovered += 1 end
		local card = panel.Cards[key]
		local definition = Definitions.Cores[key]
		card.NameLabel.Text = known and string.upper(definition.Name) or "???"
		card.IncomeLabel.Text = known and Definitions.IncomeText(key) or "UNDISCOVERED"
		card.IncomeLabel.TextColor3 = known and Color3.fromRGB(133, 255, 117) or Color3.fromRGB(192, 182, 204)
		card.BackgroundColor3 = known and Definitions.Rarities[definition.Rarity]:Lerp(Color3.fromRGB(27, 19, 48), 0.7) or Color3.fromRGB(57, 42, 82)
		if displayed[key] ~= known then
			displayed[key] = known
			Visuals.Show(card.Preview, key, not known)
		end
	end
	panel.CountLabel.Text = string.format("%s / %s DISCOVERED", Format.Compact(discovered), Format.Compact(#Definitions.Order))
	if progressTween then progressTween:Cancel() end
	progressTween = TweenService:Create(panel.ProgressBar.Fill, TweenInfo.new(0.3), {Size = UDim2.fromScale(discovered / #Definitions.Order, 1)})
	progressTween:Play()
end
local function responsive()
	local narrow = panel.Cards.AbsoluteSize.X < 650
	local grid = panel.Cards.CardGrid
	grid.FillDirectionMaxCells = narrow and 2 or 4
	grid.CellSize = UDim2.fromScale(narrow and 0.48 or 0.235, narrow and 0.23 or 0.46)
	grid.CellPadding = UDim2.fromScale(0.018, narrow and 0.0125 or 0.025)
	panel.Cards.CanvasSize = UDim2.fromScale(0, narrow and 2 or 1)
end
panel.Cards:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive)
gui.IndexButton.Activated:Connect(function()
	shade.Visible = not shade.Visible
	if not shade.Visible then return end
	refresh()
	responsive()
	panel.Cards.CanvasPosition = Vector2.zero
	if pop then pop:Cancel() end
	scale.Scale = 0.85
	pop = TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	pop:Play()
end)
panel.Header.CloseButton.Activated:Connect(function() shade.Visible = false end)
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Escape then shade.Visible = false end
end)
for _, key in Definitions.Order do
	player:GetAttributeChangedSignal("DiscoveredCore_" .. key):Connect(refresh)
end
shade.Visible = false
refresh()
responsive()
return true
