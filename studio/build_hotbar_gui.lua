-- Paste into Studio's Command Bar in Edit mode after Rojo synchronizes.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before building the hotbar")
local module = game.ReplicatedStorage.Shared.HotbarUIBuilder:Clone()
module.Parent = game.ReplicatedStorage.Shared
local gui = require(module).Build(game.StarterGui)
gui.Enabled = true
module.Parent = nil
print("EDITABLE HOTBAR CREATED: StarterGui.HotbarGui; edit Bar and SlotTemplate")
