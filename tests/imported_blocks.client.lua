-- Temporary LocalScript in Studio Play; requires the user's BlockModels folder.
task.wait(2)
local shared = game.ReplicatedStorage.Shared
local Config, Grid = require(shared.Config), require(shared.MineGrid)
local Visuals = require(shared.BlockVisuals)
local player = game.Players.LocalPlayer
local Renderer = require(player.PlayerScripts.Client.Controllers.MineRenderer)
local sourceNames = {Stone = "Stone Ore", Copper = "Copper Ore", Quartz = "Quartz Ore", Ion = "Ion Crystal", ChargedQuartz = "Charged Quartz"}
for key, material in sourceNames do
	local original = game.ReplicatedStorage.BlockModels[key]
	local before, pivot = original:GetExtentsSize(), original:GetPivot()
	for _, size in {5.94, 1.1} do
		local model = Visuals.Build(material, size)
		assert(model, key .. " imported")
		local center, bounds = model:GetBoundingBox()
		assert(center.Position.Magnitude < .01 and math.abs(math.max(bounds.X,bounds.Y,bounds.Z)-size)<.01, key .. " normalized")
		for _, item in model:GetDescendants() do
			if item:IsA("BasePart") then
				assert(item.Anchored and not item.CanCollide and not item.CanQuery and not item.CanTouch)
			end
		end
		model:Destroy()
	end
	assert(original:GetExtentsSize()==before and original:GetPivot()==pivot, "source unchanged")
end
assert(Visuals.Build("Plasma Ore",6)==nil and Visuals.Build("Reactor Shard",6)==nil,"fallback")
Renderer.Generate()
assert(#Renderer.Folder():GetChildren()==144,"only exposed surface")
local seen = {}
for _, block in Renderer.Folder():GetChildren() do
	local x,d,z = Grid.Coordinates(block:GetAttribute("BlockId"))
	assert(block:GetAttribute("MaterialName")==Grid.Material(x,d,z).Name,"material matches reward")
	assert(block.Transparency==1 and block:FindFirstChild("BlockVisual"),"import replaces placeholder")
	assert(block.CanCollide and block.CanQuery,"stable collision and aiming")
	local bounds,size=block.BlockVisual:GetBoundingBox()
	assert((bounds.Position-block.Position).Magnitude<.01 and math.max(size.X,size.Y,size.Z)<=Config.BlockSize+.01,"inside cell")
	seen[block:GetAttribute("MaterialName")]=true
end
assert(seen["Stone Ore"] and seen["Copper Ore"],"surface variety")
local block = Renderer.Folder():GetChildren()[1]
local model, id = block.BlockVisual, block:GetAttribute("BlockId")
local scale, position = model:GetScale(), block.Position
Renderer.SetHealth(id, 125)
task.wait(.025)
Renderer.SetHealth(id, 75)
task.wait(.3)
assert(math.abs(model:GetScale()-scale)<.001 and block.Position==position,"hit recoil restores without moving collision")
local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={Renderer.Folder()}
local hit=workspace:Raycast(position+Vector3.new(0,15,0),Vector3.new(0,-20,0),params)
assert(hit and hit.Instance==block,"ray targets collision cell rather than visual mesh")
for depth=1,29 do Renderer.Break(Grid.Id(6,depth,6)) end
local layers={}
for _, cell in Renderer.Folder():GetChildren() do
	layers[cell:GetAttribute("MaterialName")]=true
end
assert(layers["Charged Quartz"] and layers["Quartz Ore"] and layers["Ion Crystal"],"deeper imported ores exposed")
assert(#Renderer.Folder():GetChildren()<350,"exposure budget")
Renderer.Generate()
assert(#Renderer.Folder():GetChildren()==144,"reset with imported meshes")
print("PASS: 5 imported blocks, cell/pickup scale, untouched originals, exact material rewards, ray/collision, recoil, deeper ores, exposure and reset")

for _, key in {"ChargedQuartz", "Quartz", "Ion"} do
 local original=game.ReplicatedStorage.BlockModels[key]
 local originalPart=original:FindFirstChildWhichIsA("MeshPart",true)
 local bounds=original:GetBoundingBox()
 local localBody=originalPart.CFrame:PointToObjectSpace(bounds:PointToWorldSpace(original:GetAttribute("MiningBodyOffset")))
 local model=Visuals.Build(sourceNames[key],Config.BlockSize,true)
 local part=model:FindFirstChildWhichIsA("MeshPart",true)
 local bodyCenter=part.CFrame:PointToWorldSpace(localBody*(part.Size/originalPart.Size))
 assert(bodyCenter.Magnitude<.01,"Rock body centered: "..key)
 local fitted=model:GetAttribute("FittedBodySize")
 assert((fitted-Vector3.one*Config.BlockSize).Magnitude<.01,"Full-size rock body: "..key)
 assert(math.max(model:GetExtentsSize().X,model:GetExtentsSize().Z)>Config.BlockSize,"Crystals may protrude rather than shrink the rock")
 model:Destroy()
end
local removed={}
for depth=1,29 do
 local id=Grid.Id(6,depth,6)
 removed[id]=true
 Renderer.Break(id)
end
local visible={}
for _,cell in Renderer.Folder():GetChildren() do visible[cell:GetAttribute("BlockId")]=true end
local filled=0
for x=1,Config.Width do
 for z=1,Config.Width do
  local column=workspace.PersonalMineInterior[tostring((x-1)*Config.Width+z)]
  local parts=column:GetChildren()
  filled+=#parts
  for depth=1,Config.Depth do
   local id=Grid.Id(x,depth,z)
   local inside=false
   local position=Grid.Position(x,depth,z)
   for _,part in parts do
    assert(part.CanQuery and part.CanCollide and not part.CanTouch,"Interior blocks camera/physics but is not a collectible")
    local point=part.CFrame:PointToObjectSpace(position)
    if math.abs(point.X)<part.Size.X/2 and math.abs(point.Y)<part.Size.Y/2 and math.abs(point.Z)<part.Size.Z/2 then inside=true end
   end
   if removed[id] or visible[id] then assert(not inside,"Interior must leave exposed/tunneled cells open")
   else assert(inside,"Every buried cell must be opaque") end
  end
 end
end
assert(filled<220,"Interior uses compact runs rather than thousands of cells")
Renderer.Generate()
print("PASS: crystal rock bodies full-size and centered; buried interior solid; tunnel open; compact geometry; reset")
