-- Paste in the Command Bar in EDIT mode. Adds templates without replacing your UI.
local shared = game.ReplicatedStorage.Shared
require(shared.WorldUIBuilder).BuildTemplates()
-- Command Bar require() caches survive source edits; use a fresh builder copy.
local fresh = shared.StabilizerUIBuilder:Clone()
fresh.Parent = shared
local gui = require(fresh).Build(game.StarterGui)
fresh:Destroy()
local reel = gui.Shade.Panel.Reel
if reel:GetAttribute("CardGapScale") == nil then reel:SetAttribute("CardGapScale", 0.025) end

-- Billboard Scale is measured in studs, so signs stay proportional to the buildings.
-- Run once, then edit Size and the TextLabel in Explorer as you like.
local count = 0
local function convert(board, width, height)
	if board:GetAttribute("UsesStudSizing") then return end
	board.Size = UDim2.fromScale(width, height)
	for _, label in board:GetDescendants() do
		if label:IsA("TextLabel") then
			label.TextScaled = true
			label.TextWrapped = true
		end
	end
	board:SetAttribute("UsesStudSizing", true)
	count += 1
end
local lobby = workspace:FindFirstChild("Lobby")
if lobby then
	for _, board in lobby:GetDescendants() do
		if board:IsA("BillboardGui") and (board.Name == "StoreSign" or board.Name:find("Sign", 1, true)) then
			convert(board, board.Name:find("MINE", 1, true) and 14.4 or 12, 3)
		end
	end
end
local npc = workspace:FindFirstChild("showcase npc")
local head = npc and npc:FindFirstChild("Head")
local board = head and head:FindFirstChild("gui")
if board and board:IsA("BillboardGui") then convert(board, 7, 2.5) end
print("Editable core labels: ReplicatedStorage.UITemplates; reveal earnings: StarterGui.StabilizerGui.Shade.Panel.EarningsLabel. Converted " .. count .. " lobby signs to scale.")
