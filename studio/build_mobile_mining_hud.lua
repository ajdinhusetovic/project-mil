-- Paste in the Command Bar in Edit mode, then edit StarterGui.MobileMiningHUD.
local gui = game.StarterGui:FindFirstChild("MobileMiningHUD")
local button = gui and gui:FindFirstChild("AttackButton")
if button then button:Destroy() end
require(game.ReplicatedStorage.Shared.MobileMiningUIBuilder).Build(game.StarterGui)
print("MobileMiningHUD ready. Phones mine by tapping/holding blocks; Crosshair remains editable.")
