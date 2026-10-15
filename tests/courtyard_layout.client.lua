-- Run from the CLIENT Command Bar during a Studio Play test.
local player=assert(game.Players.LocalPlayer,"Run on the client")
local lobby=workspace.Lobby
assert(lobby:GetAttribute("CourtyardLayoutVersion")==2)
assert(lobby:GetAttribute("LayoutOnly")==true)
local root=player.Character.HumanoidRootPart
local humanoid=player.Character.Humanoid
assert(humanoid.Health>0 and root.Position.Y>0,"Character must spawn above the plaza")
local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={lobby,workspace.MineArea}
local points={Vector3.new(0,10,-113),Vector3.new(0,10,-160),Vector3.new(0,10,-212),Vector3.new(0,10,-270),Vector3.new(0,10,-320),Vector3.new(0,10,-43)}
local footprints=0
for _,p in lobby:GetDescendants() do
 if p:IsA("BasePart") and p.Name:find("_Foundation",1,true) then
  footprints+=1
  table.insert(points,Vector3.new(p.Position.X,10,p.Position.Z))
 end
end
assert(footprints==18,"Expected all 18 reserved object foundations")
for _,origin in points do
 local hit=workspace:Raycast(origin,Vector3.new(0,-20,0),params)
 assert(hit and hit.Position.Y>-.1 and hit.Position.Y<1,"Walkable floor missing at "..tostring(origin))
end
assert(not workspace:Raycast(Vector3.new(0,10,0),Vector3.new(0,-50,0),params),"Imported floor must not block mine")
for _,direction in {Vector3.xAxis,-Vector3.xAxis,Vector3.zAxis,-Vector3.zAxis} do
 local hit=workspace:Raycast(Vector3.new(0,-15,0),direction*60,params)
 assert(hit and math.abs(hit.Distance-36)<.1,"Mine shaft wall does not match the 72-stud grid")
end
local blocks=assert(workspace:FindFirstChild("PersonalMineBlocks"),"Mine renderer missing")
assert(#blocks:GetChildren()==144,"Expected a full 12x12 top layer")
assert(#workspace.AFKTrainingStations:GetChildren()==0,"Placeholder AFK machines must not appear")
assert(not workspace.MiningDemo:FindFirstChild("UpgradeStore"),"Placeholder upgrade shop must not appear")
assert(not workspace.MiningDemo:FindFirstChild("WeaponStore"),"Placeholder weapon shop must not appear")
print("COURTYARD PLAY PASS: live spawn, 18 footprints, walkable routes, open 72x72 shaft, 144 top cells, no fallback shops/machines")
task.spawn(function()
 if (player:GetAttribute("Power") or 0)<=0 then
  require(player.PlayerScripts.Client.Controllers.TrainingFeedback).Click(require(game.ReplicatedStorage.Shared.WeaponDefinitions)["Scrap Zapper"])
  task.wait(.4)
  assert((player:GetAttribute("Power") or 0)>0,"Train once before testing mining damage")
 end
 humanoid:MoveTo(Vector3.new(0,3,-30))
 local reached=humanoid.MoveToFinished:Wait()
 assert(reached,"Could not walk from the plaza to the mine entrance")
 local target,distance
 for _,p in blocks:GetChildren() do
  local d=(p.Position-root.Position).Magnitude
  if not distance or d<distance then target,distance=p,d end
 end
 assert(target and distance<45,"Mine must be reachable from its entrance")
 local before=target:GetAttribute("Health")
 game.ReplicatedStorage.MiningDemo:FireServer("Mine",target:GetAttribute("BlockId"))
 task.wait(1)
 assert(not target.Parent or target:GetAttribute("Health")<before,"Mining hit was not accepted")
 print("COURTYARD MINING PASS: character walked to the mine; server accepted hit and updated block health")
end)
