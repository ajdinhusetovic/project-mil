local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

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
-- A typewriter updates Text on every character; scaling would resize each prefix.
local dialogueLabel = dialog.npcGui.dialog
if not dialogueLabel:GetAttribute("FixedDialogueText") then
	dialogueLabel.TextSize = 28
	dialogueLabel:SetAttribute("FixedDialogueText", true)
end
dialogueLabel.TextScaled = false
dialogueLabel.TextWrapped = true
local quote
local pending = false

dialog:addDialog("Welcome, miner! What would you like to sell?", {
	"Sell all my ore",
	"Sell held core",
	"Sell all cores",
	"Not yet",
})
dialog:addDialog("Let me check your core...", {"Sell this core", "Keep it"})

prompt.Triggered:Connect(function(triggeringPlayer)
	if triggeringPlayer ~= player or pending or dialog.active or dialog.talking then return end
	quote = nil
	dialog:triggerDialog(player, 1)
end)

dialog.responded:Connect(function(responseNum, dialogNum)
	if pending then return end
	if dialogNum == 1 then
		if responseNum == 1 then
			dialog:hideGui("Counting your ore...")
			remote:FireServer("SellFromNpc")
		elseif responseNum == 2 then
			pending = true
			dialog:hideGui("Let me check that core...", true)
			remote:FireServer("QuoteHeldCoreSale")
		elseif responseNum == 3 then
			pending = true
			dialog:hideGui("Counting your cores...", true)
			remote:FireServer("QuoteAllCoreSale")
		else
			dialog:hideGui("See you soon!")
		end
	elseif dialogNum == 2 then
		local accepted = quote
		quote = nil
		if responseNum == 1 and accepted then
			pending = true
			dialog:hideGui("Buying your core...", true)
			remote:FireServer(accepted.Mode == "All" and "ConfirmAllCoreSale" or "ConfirmHeldCoreSale", accepted.Token)
		else
			dialog:hideGui("Keep it for later. See you soon!")
		end
	end
end)

remote.OnClientEvent:Connect(function(action, first, second)
	if action == "CoreSaleQuote" then
		pending = false
		quote = first
		local text
		if first.Mode == "All" then
			text = string.format("Sell ALL %s stabilized cores for $%s?\nThis includes your rare cores.", Format.Compact(first.Count), Format.Compact(first.SellValue))
		else
			text = string.format("%s (%s)\nSell: $%s\nSell this core?", first.Name, first.Rarity, Format.Compact(first.SellValue))
		end
		dialog.dialogs[2] = {text = text, responses = {string.format("Sell for $%s", Format.Compact(first.SellValue)), "Keep it"}}
		dialog:triggerDialog(player, 2)
	elseif action == "CoreSaleFailed" then
		pending = false
		quote = nil
		dialog:hideGui(first)
	elseif action == "CoresSold" then
		pending = false
		quote = nil
		dialog:hideGui(string.format("Bought %s cores for $%s!", Format.Compact(second), Format.Compact(first)))
	elseif action == "CoreSold" then
		pending = false
		quote = nil
		dialog:hideGui(string.format("Bought your %s for $%s!", second, Format.Compact(first)))
	end
end)

-- Dialogue number shortcuts must not switch or unequip the core being sold.
local showingDialogue = false
local backpackWasEnabled = true
-- Held-core labels should not cover the buyer's dialogue.
RunService.RenderStepped:Connect(function()
	local label = dialog.npcGui.dialog
	local open = dialog.active or dialog.talking or pending or (label.Visible and label.TextTransparency < 1)
	if player:GetAttribute("NpcDialogueOpen") ~= open then player:SetAttribute("NpcDialogueOpen", open) end
	if showingDialogue ~= open then
		if open then backpackWasEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) end
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not open and backpackWasEnabled)
		showingDialogue = open
	end
end)

return true
