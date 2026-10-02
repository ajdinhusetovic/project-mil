local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local npc = workspace:FindFirstChild("showcase npc")
local dialogModuleScript = ReplicatedStorage:FindFirstChild("DialogModule")
if not npc or not dialogModuleScript then
	warn("Sell NPC setup missing: expected Workspace['showcase npc'] and ReplicatedStorage.DialogModule")
	return false
end

local prompt = npc:WaitForChild("ProximityPrompt")
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local DialogModule = require(dialogModuleScript)
local dialog = DialogModule.new("Ore Buyer", npc, prompt)
dialog:addDialog("Welcome, miner! Want to sell everything in your bag?", {
	"Sell all my ore",
	"Not yet",
})

prompt.Triggered:Connect(function(triggeringPlayer)
	if triggeringPlayer ~= player then return end
	dialog:triggerDialog(player, 1)
end)

dialog.responded:Connect(function(responseNum, dialogNum)
	if dialogNum ~= 1 then return end
	if responseNum == 1 then
		dialog:hideGui("Counting your ore...")
		remote:FireServer("SellFromNpc")
	else
		dialog:hideGui("See you soon!")
	end
end)

return true
