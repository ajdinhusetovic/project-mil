-- Paste into the Studio Command Bar in Edit mode, with Rojo connected.
-- Move the complete station Models so their Zone parts move with them.
local module = game.ReplicatedStorage.Shared.AFKStationBuilder:Clone()
module.Parent = game.ReplicatedStorage.Shared
local folder = require(module).Build(workspace)
module.Parent = nil
game.Selection:Set({folder})
print("AFK stations ready: Workspace.AFKTrainingStations. Edit StationSign labels or move whole Models.")
