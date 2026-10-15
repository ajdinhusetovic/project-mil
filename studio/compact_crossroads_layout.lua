-- Studio Edit Command Bar: compact the authored lobby without shrinking the mine.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local lobby=assert(workspace:FindFirstChild("Lobby"))
assert(lobby:GetAttribute("CrossroadsLayoutVersion")==3,"Expected crossroads V3")
assert(not lobby:GetAttribute("CompactLobbyScale"),"Lobby already compacted")
local storage=game:GetService("ServerStorage")
local backup=Instance.new("Folder");backup.Name="OLD_OversizedCrossroads_DELETE_WHEN_READY";backup.Parent=storage
game:GetService("ChangeHistoryService"):SetWaypoint("Before compact lobby")
lobby:Clone().Parent=backup
local oldSpawn=lobby.GameplayAnchors.Spawn.Position
local newSpawn=Vector3.new(0,oldSpawn.Y*.5,-149)
local scaled,retained=0,0
local function isMine(n)
 return n:find("V3 Forecourt",1,true)==1 or n:find("V3 Mine",1,true)==1
end
for _,p in lobby:GetDescendants() do
 if p:IsA("BasePart") then
  if isMine(p.Name) then retained+=1 else
   local pos=Vector3.new(p.Position.X*.5,p.Position.Y*.5,(p.Position.Z-oldSpawn.Z)*.5+newSpawn.Z)
   p.Size=p.Size*.5
   p.CFrame=CFrame.new(pos)*p.CFrame.Rotation
   scaled+=1
  end
 end
end
-- Existing mine route reaches Z=-48 from the mine forecourt. Extend its far
-- end to the compact courtyard edge at -84; the two floors overlap safely.
local spawn=lobby.GameplayAnchors.Spawn
assert((spawn.Position-newSpawn).Magnitude<.01)
lobby:SetAttribute("CompactLobbyScale",.5)
lobby:SetAttribute("LobbyWidth",180);lobby:SetAttribute("LobbyDepth",130)
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
params.FilterDescendantsInstances={lobby,workspace.MineArea}
local foundations=0
for _,p in lobby:GetDescendants() do
 if p:IsA("BasePart") and p.Name:find("_Foundation",1,true) then
  foundations+=1
  assert(workspace:Raycast(p.Position+Vector3.new(0,10,0),Vector3.new(0,-20,0),params),"Missing foundation "..p.Name)
 end
end
assert(foundations==18)
for z=-149,-43,2 do
 local hit=workspace:Raycast(Vector3.new(0,10,z),Vector3.new(0,-20,0),params)
 assert(hit and hit.Position.Y>-.5,"Path gap at "..z)
end
assert(not workspace:Raycast(Vector3.new(0,10,0),Vector3.new(0,-50,0),params),"Mine blocked")
for _,d in {Vector3.xAxis,-Vector3.xAxis,Vector3.zAxis,-Vector3.zAxis} do
 local hit=workspace:Raycast(Vector3.new(0,-15,0),d*60,params)
 assert(hit and math.abs(hit.Distance-36)<.1,"Mine size changed")
end
game.Selection:Set({lobby})
game:GetService("ChangeHistoryService"):SetWaypoint("Compact 180x130 lobby")
print("COMPACT LOBBY PASS",scaled,"scaled parts;",retained,"mine-court parts retained; 180x130 lobby; 18 reserved spaces; continuous path; mine remains 72x72; spawn",spawn.Position)
print("OVERSIZED BACKUP",backup:GetFullName())
