-- Paste in the Studio Command Bar in Edit mode after Rojo sync.
local shared = game.ReplicatedStorage.Shared
local gui = game.StarterGui:FindFirstChild("CoreIndexGui") or require(shared.CoreIndexUIBuilder).Build(game.StarterGui)
local fresh = shared.IndexMenuStyle:Clone()
fresh.Parent = shared
require(fresh).Apply(gui)
fresh:Destroy()
print("Index styled. Edit StarterGui.CoreIndexGui.Shade.Panel: Header, Cards.Items and Rewards.")
