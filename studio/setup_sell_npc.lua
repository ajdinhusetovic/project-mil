-- Run once from the Roblox Studio Command Bar in Edit mode.
-- Keeps the toolbox model and dialog module, replacing its showcase behavior.
local npc = workspace:FindFirstChild("showcase npc")
assert(npc and npc:IsA("Model"), "Missing Workspace['showcase npc']")
assert(game.ReplicatedStorage:FindFirstChild("DialogModule"), "Missing ReplicatedStorage.DialogModule")
assert(game.StarterGui:FindFirstChild("dialog"), "Missing StarterGui.dialog")

local oldScript = npc:FindFirstChild("dialogScript")
if oldScript and oldScript:IsA("Script") then oldScript.Enabled = false end

-- The model's original feet sit one stud below its pivot. Pivot Y=0 places
-- the feet on the generated surface deck.
npc:PivotTo(CFrame.new(38, 0, 101) * npc:GetPivot().Rotation)
npc:SetAttribute("EnergyCoreSellNpc", true)

local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
assert(prompt, "The NPC needs its original ProximityPrompt")
prompt.ActionText = "Talk"
prompt.ObjectText = "Ore Buyer"
prompt.MaxActivationDistance = 10

local head = npc:FindFirstChild("Head")
local billboard = head and head:FindFirstChild("gui")
local nameLabel = billboard and billboard:FindFirstChild("name")
if nameLabel and nameLabel:IsA("TextLabel") then nameLabel.Text = "ORE BUYER" end

print("Ore Buyer is positioned at the lobby sell stand. Original showcase script disabled.")
