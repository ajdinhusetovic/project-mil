-- Temporary Script in Studio Play; requires the imported CoreModels folder.
local S = game.ReplicatedStorage.Shared
assert(not require(S.Config).Persistence.EnableInStudio)
local Visuals = require(S.CoreVisuals)
local templates = game.ReplicatedStorage.CoreModels
for _, template in templates:GetChildren() do
	local before = template:GetExtentsSize()
	local model = template.Name == "Unknown" and Visuals.BuildUnknown("Cracked") or Visuals.Build(template.Name, false)
	local count, expected = 0, 0
	for _, part in template:GetDescendants() do if part:IsA("MeshPart") then expected += 1 end end
	for _, part in model:GetDescendants() do
		if part:IsA("MeshPart") then count += 1; assert(part.Anchored and not part.CanCollide) end
	end
	assert(count == expected and count > 0, template.Name .. " imported meshes used")
	local center, size = model:GetBoundingBox()
	assert(center.Position.Magnitude < 0.01 and math.abs(math.max(size.X,size.Y,size.Z)-3)<0.01)
	assert(template:GetExtentsSize() == before, "Original unchanged")
	model:Destroy()
end
for _, key in {"Static", "Lightning"} do assert(Visuals.Build(key,false):FindFirstChildWhichIsA("BasePart",true)) end
local services = game.ServerScriptService.Server.Services
local Data, Tools = require(services.PlayerDataService), require(services.CoreToolService)
local p = game.Players:GetPlayers()[1]
local d = Data.Get(p)
d.UnknownCores = {{Id="import-unknown",Grade="Cracked"}}
d.StabilizedCores = {{Id="import-spark",Type="Spark",Mutation="None"},{Id="import-ion",Type="Ion",Mutation="Overloaded"}}
Tools.Sync(p)
for _, id in {"import-unknown","import-spark","import-ion"} do
	local found
	for _, tool in p.Backpack:GetChildren() do if tool:GetAttribute("CoreId")==id then found=tool end end
	assert(found and found.Handle.Transparency==1)
	local count=0
	for _, part in found:GetChildren() do
		if part:IsA("MeshPart") then count+=1; assert(not part.Anchored and part.Massless and part:FindFirstChildOfClass("WeldConstraint")) end
	end
	assert(count>0)
	if id=="import-unknown" then p.Character.Humanoid:EquipTool(found) end
end
local remote = game.ReplicatedStorage.MiningDemo
local mount = workspace:FindFirstChild("CoreMount",true)
if mount then
	p.Character:PivotTo(CFrame.new(mount.Position+Vector3.new(0,3,7)))
	d.Stabilizer = {Core={Id="import-job",Grade="Charged"},Result="Spark",Mutation="None",FinishAt=os.time()+60,StationId=mount:GetAttribute("StabilizerId")}
	require(services.StabilizerService).Publish(p)
end
remote:FireClient(p,"CoreDiscovered",-100,p.Character.HumanoidRootPart.Position+Vector3.new(4,0,0),"Cracked")
print("PASS: imported one/two mesh models, normalized size/center, unchanged templates, missing-model fallback, unknown/stabilized Tools and mutation welding")
