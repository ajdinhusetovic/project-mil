-- Paste in the Command Bar in Edit mode after Rojo sync.
-- Re-running preserves your existing GUI edits.
local fresh = game.ReplicatedStorage.Shared.CoreIndexUIBuilder:Clone()
fresh.Parent = game.ReplicatedStorage.Shared
require(fresh).Build(game.StarterGui)
fresh:Destroy()
print("Core index ready. Edit StarterGui.CoreIndexGui: IndexButton, Shade.Panel and named core cards.")
