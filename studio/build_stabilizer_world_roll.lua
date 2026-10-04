-- Paste in the Command Bar in Edit mode. Keeps the old GUI disabled for reference.
local shared = game.ReplicatedStorage.Shared
local old = game.StarterGui:FindFirstChild("StabilizerGui")
if old then old.Enabled = false end
require(shared.WorldUIBuilder).BuildTemplates()
local fresh = shared.StabilizerOddsUIBuilder:Clone()
fresh.Parent = shared
require(fresh).Build(game.StarterGui)
fresh:Destroy()
for _, item in workspace:GetDescendants() do
	if item:IsA("ProximityPrompt") and item:FindFirstAncestor("Stabilizer") and (item.Name:lower():find("odds", 1, true) or item.ActionText:lower():find("odds", 1, true) or item.Name == "ReturnCorePrompt") then
		item.Enabled = false
	end
end
print("World rolling enabled. Edit StarterGui.StabilizerOddsGui for nearby odds UI and ReplicatedStorage.UITemplates.CoreBillboard for reveal labels.")
