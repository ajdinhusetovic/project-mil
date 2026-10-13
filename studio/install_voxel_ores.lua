-- Paste into Roblox Studio's Command Bar in Edit mode after importing all FBXs.
local keys={"Stone","Copper","Quartz","ChargedQuartz","Ion","Plasma","ReactorShard","Fusion","Antimatter","Singularity","Omega"}
-- Validate the whole set before replacing anything.
local imports={}
for _,key in keys do
 local model=workspace:FindFirstChild(key)
 assert(model and model:IsA("Model"),"Missing imported Model: "..key)
 local mesh=model:FindFirstChildWhichIsA("MeshPart",true)
 assert(mesh,"Missing Body MeshPart: "..key)
 assert((mesh.Size-Vector3.one*6).Magnitude<.01,"Expected a 6-stud cube: "..key)
 imports[key]={Model=model,Mesh=mesh}
end
local backup=Instance.new("Folder"); backup.Name="OreModelsBeforeVoxelReplacement"; backup.Parent=game.ServerStorage
local old=game.ReplicatedStorage:FindFirstChild("BlockModels")
if old then old.Parent=backup end
local sources=Instance.new("Folder"); sources.Name="ImportedSources"; sources.Parent=backup
local folder=Instance.new("Folder"); folder.Name="BlockModels"
for _,key in keys do
 local import=imports[key]
 local model=Instance.new("Model"); model.Name=key; model:SetAttribute("VoxelOreVersion",1)
 local mesh=import.Mesh:Clone()
 mesh.Name="Body"; mesh.Anchored=true
 mesh.CanCollide,mesh.CanQuery,mesh.CanTouch=false,false,false
 -- White preserves embedded mesh vertex colours without grey tint multiplication.
 mesh.Color=Color3.new(1,1,1)
 mesh.Material=Enum.Material.SmoothPlastic
 mesh:SetAttribute("MiningBodySize",nil); mesh:SetAttribute("MiningBodyOffset",nil)
 mesh.Parent=model
 model.WorldPivot=CFrame.new(mesh.Position)
 model:PivotTo(CFrame.identity)
 assert((model:GetExtentsSize()-Vector3.one*6).Magnitude<.01,key.." normalization failed")
 model.Parent=folder
 import.Model.Parent=sources
end
folder.Parent=game.ReplicatedStorage
game.Selection:Set({folder})
print("ALL 11 VOXEL ORES INSTALLED: ReplicatedStorage.BlockModels; original imports and old ores backed up in ServerStorage.")
