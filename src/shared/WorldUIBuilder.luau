-- Authored templates live in ReplicatedStorage.UITemplates and are cloned unchanged.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Builder = {}
local function label(parent, name, value, y, height, color)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Position = UDim2.fromScale(0, y)
	item.Size = UDim2.fromScale(1, height)
	item.BackgroundTransparency = 1
	item.Font = Enum.Font.FredokaOne
	item.TextScaled = true
	item.TextColor3 = color or Color3.new(1, 1, 1)
	item.TextStrokeTransparency = 0
	item.Text = value
	item.Parent = parent
	return item
end
function Builder.BuildTemplates()
	local folder = ReplicatedStorage:FindFirstChild("UITemplates")
	if not folder then folder = Instance.new("Folder"); folder.Name = "UITemplates"; folder.Parent = ReplicatedStorage end
	if not folder:FindFirstChild("CoreBillboard") then
		local board = Instance.new("BillboardGui")
		board.Name = "CoreBillboard"
		board.Size = UDim2.fromScale(7, 2.8)
		board.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
		board.AlwaysOnTop = true
		board.MaxDistance = 65
		board.Parent = folder
		label(board, "NameLabel", "SPARK CORE", 0, 0.34)
		-- Legacy name retained so authored GUI layouts keep working; this is now the mutation row.
		label(board, "RarityLabel", "", 0.35, 0.23).Visible = false
		label(board, "IncomeLabel", "$150 SELL VALUE", 0.61, 0.39, Color3.fromRGB(105, 255, 91))
	end
	if not folder:FindFirstChild("StabilizerStatusBillboard") then
		local board = Instance.new("BillboardGui")
		board.Name = "StabilizerStatusBillboard"
		board.Size = UDim2.fromScale(12, 2.8)
		board.StudsOffsetWorldSpace = Vector3.new(0, 3.7, 0)
		board.AlwaysOnTop = true
		board.MaxDistance = 65
		board.Parent = folder
		label(board, "TextLabel", "CORE STABILIZER\nHold a core and press E", 0, 1).TextWrapped = true
	end
	return folder
end
return Builder
