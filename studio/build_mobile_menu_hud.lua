-- Run in the Studio Edit Command Bar after Rojo sync.
local fresh=game.ReplicatedStorage.Shared.HUDMenuLayout:Clone()
fresh.Parent=game.ReplicatedStorage.Shared
local layout=require(fresh)
local gui=layout.Build(game.StarterGui)
layout.Arrange(gui)
fresh.Parent=nil
game.Selection:Set({gui.SafeArea.Buttons})
print("Editable HUD ready: StarterGui.HUDMenuGui.SafeArea.Buttons")
