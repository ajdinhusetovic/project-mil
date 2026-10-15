-- Run in Studio's Edit Command Bar after importing the 11 polished FBXs.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installing ore models")
local keys={"Stone","Copper","ChargedQuartz","Quartz","Ion","Plasma","ReactorShard","Fusion","Antimatter","Singularity","Omega"}
local storage=game:GetService("ServerStorage")
local replicated=game:GetService("ReplicatedStorage")
local old=assert(replicated:FindFirstChild("BlockModels"), "Active BlockModels folder missing")
assert(not storage:FindFirstChild("OLD_BlockModels_DELETE_WHEN_READY"), "An old backup already exists; inspect it before running again")
assert(not storage:FindFirstChild("PolishedOre_ImportedSources"), "Polished import sources already archived")
local imports={}
local replacement=Instance.new("Folder")
replacement.Name="BlockModels"
replacement:SetAttribute("PolishedOreVersion",1)
for _,key in keys do
 local source=assert(workspace:FindFirstChild(key), "Missing imported ore: "..key)
 assert(source:IsA("Model"), key.." import must be a Model")
 local parts={}
 for _,item in source:GetDescendants() do
  if item:IsA("BasePart") then table.insert(parts,item) end
 end
 assert(#parts==1 and parts[1]:IsA("MeshPart"), key.." must contain exactly one ore mesh")
 local original=parts[1]
 local size=original.Size
 assert(math.abs(size.X-size.Y)<.01 and math.abs(size.X-size.Z)<.01, key.." import is not cubic")
 local appearance=original:FindFirstChildOfClass("SurfaceAppearance")
 assert(original.TextureID~="" or (appearance and appearance.ColorMap~=""), key.." is missing its colour texture")
 local model=Instance.new("Model")
 model.Name=key
 model:SetAttribute("PolishedOreVersion",1)
 local mesh=original:Clone()
 mesh.Name="Body"
 mesh.Size=Vector3.one*6
 mesh.CFrame=CFrame.identity
 mesh.Color=Color3.new(1,1,1)
 mesh.Material=Enum.Material.SmoothPlastic
 mesh.Anchored=true
 mesh.CanCollide,mesh.CanTouch,mesh.CanQuery=false,false,false
 mesh:SetAttribute("MiningBodySize",nil)
 mesh:SetAttribute("MiningBodyOffset",nil)
 mesh.Parent=model
 model.WorldPivot=CFrame.identity
 assert((model:GetExtentsSize()-Vector3.one*6).Magnitude<.001, key.." must fill one 6-stud cell")
 model.Parent=replacement
 imports[key]=source
end
-- All imports are validated before touching the current working set.
game:GetService("ChangeHistoryService"):SetWaypoint("Before polished ore replacement")
old.Name="OLD_BlockModels_DELETE_WHEN_READY"
old:SetAttribute("ReplacedBy","ReplicatedStorage.BlockModels (PolishedOreVersion 1)")
old.Parent=storage
for _,model in old:GetChildren() do model.Name="OLD_"..model.Name end
replacement.Parent=replicated
local sources=Instance.new("Folder")
sources.Name="PolishedOre_ImportedSources"
sources.Parent=storage
for _,key in keys do imports[key].Parent=sources end
game:GetService("ChangeHistoryService"):SetWaypoint("Installed all 11 polished ore blocks")
game.Selection:Set({replacement,old})
print("POLISHED ORES INSTALLED: 11 textured 6x6x6 blocks in ReplicatedStorage.BlockModels")
print("OLD SET MARKED: ServerStorage.OLD_BlockModels_DELETE_WHEN_READY; all old model names start OLD_")
print("Original imported sources preserved in ServerStorage.PolishedOre_ImportedSources")
