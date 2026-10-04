-- Current stabilizer UI is odds only; rolling happens above the machine.
local old = game.StarterGui:FindFirstChild("StabilizerGui")
if old then old.Enabled = false end
require(game.ReplicatedStorage.Shared.StabilizerOddsUIBuilder).Build(game.StarterGui)
print("StabilizerOddsGui ready. Edit NearbyOddsButton and Shade.Panel in StarterGui.")
