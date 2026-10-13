-- Temporary LocalScript in a Studio playtest; requires installed voxel ores.
task.wait(2)
local shared=game.ReplicatedStorage.Shared
local Visuals=require(shared.BlockVisuals)
local Config=require(shared.Config)
local Grid=require(shared.MineGrid)
local Renderer=require(game.Players.LocalPlayer.PlayerScripts.Client.Controllers.MineRenderer)
local names={Stone="Stone Ore",Copper="Copper Ore",Quartz="Quartz Ore",ChargedQuartz="Charged Quartz",Ion="Ion Crystal",Plasma="Plasma Ore",ReactorShard="Reactor Shard",Fusion="Fusion Ore",Antimatter="Antimatter Ore",Singularity="Singularity Ore",Omega="Omega Ore"}
assert(#shared.Parent.BlockModels:GetChildren()==11)
for key,name in names do
 local original=shared.Parent.BlockModels[key]
 assert(original:GetAttribute("VoxelOreVersion")==1 and not original:GetAttribute("MiningBodySize"))
 local before=original:GetExtentsSize()
 assert((before-Vector3.one*6).Magnitude<.01)
 assert(original.Body.Color==Color3.new(1,1,1))
 for _,size in {Config.BlockSize,1.1} do
  local visual=Visuals.Build(name,size,true)
  assert(visual,key.." missing mapping")
  local center,bounds=visual:GetBoundingBox()
  assert(center.Position.Magnitude<.01 and (bounds-Vector3.one*size).Magnitude<.01,key.." incorrect sizing")
  assert(not visual.Body.CanCollide and not visual.Body.CanQuery and not visual.Body.CanTouch)
  visual:Destroy()
 end
 assert(original:GetExtentsSize()==before,"Template must stay unchanged")
end
Renderer.Generate()
assert(#Renderer.Folder():GetChildren()==Config.Width^2)
for _,cell in Renderer.Folder():GetChildren() do
 assert(cell.Transparency==1 and cell.BlockVisual.Body,"Every surface block uses new imported art")
end
for depth=1,Config.Depth do Renderer.Break(Grid.Id(6,depth,6)) end
local found={}
for _,cell in Renderer.Folder():GetChildren() do
 assert(cell:FindFirstChild("BlockVisual"),"A deep layer still uses a placeholder")
 found[cell:GetAttribute("MaterialName")]=true
end
for _,name in Config.MaterialOrder do assert(found[name],"Deep mine missing new material "..name) end
Renderer.Generate()
print("VOXEL ORES TESTS PASSED: all 11 models, cell/pickup fit, deep layers, collision/aim proxies and reset.")
