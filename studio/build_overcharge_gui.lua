-- Paste in the Command Bar in Edit mode after Rojo sync.
-- Existing GUI edits are preserved when this is run again.
require(game.ReplicatedStorage.Shared.OverchargeUIBuilder).Build(game.StarterGui)
print("Overcharge ready. Edit StarterGui.OverchargeGui: OverchargeButton, Shade.Panel and CelebrationLabel.")
