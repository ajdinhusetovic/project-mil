-- Paste into Studio's Command Bar in Edit mode after Rojo sync.
-- Adds an editable Power row without moving or restyling money and bag rows.
local hud = game:GetService("StarterGui"):FindFirstChild("SurfaceLoopHUD")
assert(hud, "StarterGui.SurfaceLoopHUD is missing")
local module = game.ReplicatedStorage.Shared.SurfacePowerHUD:Clone()
module.Parent = game.ReplicatedStorage.Shared
require(module).Ensure(hud)
module:Destroy()
print("Added StarterGui.SurfaceLoopHUD.Counters.PowerBar above money.")
