-- Paste into the Command Bar in Edit mode after Rojo sync.
local template = game.StarterGui:WaitForChild("FeedbackHUD"):WaitForChild("PowerTemplate")
local fresh = game.ReplicatedStorage.Shared.PowerFeedbackStyle:Clone()
fresh.Parent = game.ReplicatedStorage.Shared
require(fresh).Apply(template)
fresh.Parent = nil
game.Selection:Set({template})
print("Power popup ready: edit FeedbackHUD.PowerTemplate.PowerIcon and AmountLabel.")
