-- Execute in Studio Edit mode after importing EnergyCore-SpawnCrossroads.fbx.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local source=assert(workspace:FindFirstChild("EnergyCore-SpawnCrossroads"), "Crossroads import missing")
local storage=game:GetService("ServerStorage")
local backupName="OLD_Lobby_BEFORE_CROSSROADS_DELETE_WHEN_READY"
assert(not storage:FindFirstChild(backupName), "Crossroads backup already exists")
local function clean(n) return (n:gsub("%.%d+$", "")) end
local function find(n)
 for _,p in source:GetDescendants() do
  if p:IsA("BasePart") and clean(p.Name)==n then return p end
 end
 error("Missing imported part: "..n)
end
local left,right=find("V3 Mine shaft side -37"),find("V3 Mine shaft side 37")
local factor=(left.Position-right.Position).Magnitude/74
assert(factor>.001 and factor<1000,"Invalid imported scale")
for i=1,10 do find(string.format("AFK_%02d_Foundation",i)) end
for i=1,4 do find(string.format("Leaderboard_%02d_Foundation",i)) end
for _,n in {"WeaponBuying","UpgradeShop","SellingShop","CoreStabilizer"} do find(n.."_Foundation") end
local parts={}
for _,p in source:GetDescendants() do if p:IsA("BasePart") then table.insert(parts,p) end end
assert(#parts==859,"Incomplete crossroads import: "..#parts)
game:GetService("ChangeHistoryService"):SetWaypoint("Before crossroads installation")
source:ScaleTo(source:GetScale()/factor)
left,right=find("V3 Mine shaft side -37"),find("V3 Mine shaft side 37")
local mid=(left.Position+right.Position)/2
local center=Vector3.new(mid.X,left.Position.Y+left.Size.Y/2,mid.Z)
source:PivotTo(CFrame.new(-center)*source:GetPivot())
local plaza=find("V3 Spawn plaza limestone")
local spawnPosition=Vector3.new(plaza.Position.X,plaza.Position.Y+plaza.Size.Y/2,plaza.Position.Z)
assert(math.abs(spawnPosition.X)<.01 and math.abs(spawnPosition.Z+214)<.01,"Unexpected map orientation")
local afk=find("AFK_01_Foundation");local boards=find("Leaderboard_01_Foundation")
assert(afk.Position.X>80 and boards.Position.X < -80,"AFK/leaderboard facing layout is reversed")
for _,p in parts do
 p.Anchored=true;p.CanCollide=true;p.CanQuery=true;p.CanTouch=false
 p.Material=Enum.Material.SmoothPlastic;p.Color=Color3.new(1,1,1)
 if p:IsA("MeshPart") then p.CollisionFidelity=Enum.CollisionFidelity.Box end
end
local bedrock=find("V3 Mine bedrock")
assert(Vector3.new(bedrock.Position.X,0,bedrock.Position.Z).Magnitude<.01,"Mine alignment failed")
local backup=Instance.new("Folder");backup.Name=backupName;backup.Parent=storage
for _,n in {"Lobby","MineArea","AFKTrainingStations","showcase npc","SpawnLocation"} do
 local old=workspace:FindFirstChild(n)
 if old and old~=source then old.Name="OLD_"..n;old.Parent=backup end
end
source.Name="Lobby";source:SetAttribute("LayoutOnly",true)
source:SetAttribute("ImportedLobbyIntegrated",true);source:SetAttribute("CrossroadsLayoutVersion",3)
source:SetAttribute("ImportedUnitScale",factor)
local area=Instance.new("Model");area.Name="MineArea";area:SetAttribute("HasAuthoredRim",true);area.Parent=workspace
for _,p in parts do
 local n=clean(p.Name)
 if n:find("V3 Mine shaft",1,true)==1 or n=="V3 Mine bedrock" then p.Parent=area end
end
bedrock.Name="Bedrock";bedrock.Position=Vector3.new(0,-721,0)
local afkFolder=Instance.new("Folder");afkFolder.Name="AFKTrainingStations";afkFolder.Parent=workspace
local anchors=Instance.new("Folder");anchors.Name="GameplayAnchors";anchors.Parent=source
local function anchor(n,pos)
 local p=Instance.new("Part");p.Name=n;p.Size=Vector3.one;p.Transparency=1;p.Anchored=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CFrame=CFrame.lookAt(pos,Vector3.new(0,pos.Y,0));p.Parent=anchors
 return p
end
anchor("Spawn",spawnPosition)
for n,key in {WeaponShop="WeaponBuying",UpgradeShop="UpgradeShop",SellNpc="SellingShop",CoreStabilizer="CoreStabilizer"} do
 local p=find(key.."_Foundation");anchor(n,Vector3.new(p.Position.X,p.Position.Y+p.Size.Y/2,p.Position.Z))
end
local spawn=Instance.new("SpawnLocation");spawn.Name="LobbySpawn";spawn.Size=Vector3.new(8,.3,8)
spawn.CFrame=CFrame.lookAt(spawnPosition,Vector3.new(0,spawnPosition.Y,0));spawn.Transparency=1;spawn.Anchored=true
spawn.Neutral=true;spawn.Duration=0;spawn.CanCollide=false;spawn.CanTouch=false;spawn.CanQuery=false;spawn.Parent=source
game.Selection:Set({plaza})
game:GetService("ChangeHistoryService"):SetWaypoint("Crossroads installed")
print("CROSSROADS INSTALLED",#parts,"parts; spawn",spawnPosition,"mine at origin; 10 AFK left; 4 leaderboards right")
print("BACKUP",backup:GetFullName(),"Layout-only spaces retained")
