-- Paste in the Command Bar in Edit mode after Rojo sync.
-- Extends the existing shell while keeping its colors and materials.
local area = workspace:FindFirstChild("MineArea")
assert(area, "Create Workspace.MineArea with build_mine_area.lua first")
local shared = game.ReplicatedStorage.Shared
-- Clone dependencies to avoid Command Bar require caches after tuning changes.
local config = shared.Config:Clone()
config.Parent = shared
local service = game.ServerScriptService.Server.Services.MineAreaService:Clone()
service.Source = service.Source:gsub('require%(ReplicatedStorage.Shared.Config%)', 'require(script.Config)')
config.Parent = service
service.Parent = game.ServerScriptService
require(service).AlignSeams(area)
service:Destroy()
print("Mine shell extended to 360 studs.")
