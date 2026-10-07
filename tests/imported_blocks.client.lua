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
	assert((bounds.Position-block.Position).Magnitude<.01 and math.max(size.X,size.Y,size.Z)<=Config.BlockSize,"inside cell")
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
