-- Run through Studio's EDIT Command Bar after importing the courtyard FBX.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local source=assert(workspace:FindFirstChild("EnergyCore-CourtyardLayout"), "Imported courtyard missing")
assert(source:IsA("Model"), "Courtyard import must be a Model")
local storage=game:GetService("ServerStorage")
assert(not storage:FindFirstChild("OLD_Lobby_BEFORE_COURTYARD_DELETE_WHEN_READY"), "Backup already exists; inspect before reinstalling")
local function clean(name) return (name:gsub("%.%d+$", "")) end
local function find(name)
 for _,p in source:GetDescendants() do
  if p:IsA("BasePart") and clean(p.Name)==name then return p end
 end
 error("Missing imported landmark: "..name)
end
local west,east=find("Mine shaft - west"),find("Mine shaft - east")
local factor=(west.Position-east.Position).Magnitude/74
assert(factor>.001 and factor<1000,"Invalid import scale")
game:GetService("ChangeHistoryService"):SetWaypoint("Before courtyard layout replacement")
source:ScaleTo(source:GetScale()/factor)
west,east=find("Mine shaft - west"),find("Mine shaft - east")
local midpoint=(west.Position+east.Position)/2
local mineCenter=Vector3.new(midpoint.X,west.Position.Y+west.Size.Y/2,midpoint.Z)
-- The FBX importer reverses horizontal axes. Align the authored shaft to the
-- existing gameplay grid at world (0,0,0), preserving the whole map layout.
source:PivotTo(CFrame.Angles(0,math.pi,0)*CFrame.new(-mineCenter)*source:GetPivot())
local art=source:GetDescendants()
local count=0
for _,p in art do
 if p:IsA("BasePart") then
  count+=1
  p.Anchored=true;p.CanCollide=true;p.CanQuery=true;p.CanTouch=false
  p.Material=Enum.Material.SmoothPlastic
  p.Color=Color3.new(1,1,1)
  if p:IsA("MeshPart") then p.CollisionFidelity=Enum.CollisionFidelity.Box end
 end
end
assert(count>750,"Incomplete courtyard import")
local bedrock=find("Mine bedrock")
local center=Vector3.new(bedrock.Position.X,0,bedrock.Position.Z)
assert(center.Magnitude<.01,"Mine failed to align with gameplay grid")
assert(math.abs(find("Mine plaza - north").Size.X-72)<.01,"Mine width must be 72 studs")
for _,key in {"Shop_WeaponBuying","Shop_Upgrade","Shop_Selling","CoreStabilizer"} do find(key.."_Foundation") end
for i=1,10 do find(string.format("AFK_%02d_Foundation",i)) end
for i=1,4 do find(string.format("Leaderboard_%02d_Foundation",i)) end

local backup=Instance.new("Folder")
backup.Name="OLD_Lobby_BEFORE_COURTYARD_DELETE_WHEN_READY";backup.Parent=storage
for _,gui in game.StarterGui:GetChildren() do
 if gui.Name:find("AFKSign_",1,true) or gui.Name:find("LobbySign_",1,true) or gui.Name:find("LobbyBoard_",1,true) then
  gui.Parent=backup
 end
end
for _,name in {"Lobby","MineArea","AFKTrainingStations","showcase npc","SpawnLocation"} do
 local old=workspace:FindFirstChild(name)
 if old and old~=source then old.Name="OLD_"..name;old.Parent=backup end
end
source.Name="Lobby"
source:SetAttribute("ImportedLobbyIntegrated",true)
source:SetAttribute("CourtyardLayoutVersion",2)
source:SetAttribute("LayoutOnly",true)
source:SetAttribute("ImportedUnitScale",factor)
local area=Instance.new("Model");area.Name="MineArea";area:SetAttribute("HasAuthoredRim",true);area.Parent=workspace
for _,p in art do
 if p:IsA("BasePart") then
  local n=clean(p.Name)
  if n:sub(1,13)=="Mine shaft - " or n=="Mine bedrock" then p.Parent=area end
 end
end
bedrock.Name="Bedrock";bedrock.Position=Vector3.new(0,-721,0)
local afk=Instance.new("Folder");afk.Name="AFKTrainingStations";afk.Parent=workspace
local anchors=Instance.new("Folder");anchors.Name="GameplayAnchors";anchors.Parent=source
local spawnPosition=Vector3.new(0,.4,-113)
local function anchor(name,position)
 local p=Instance.new("Part");p.Name=name;p.Size=Vector3.one;p.Position=position
 p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=anchors
 return p
end
anchor("Spawn",spawnPosition)
for name,key in {WeaponShop="Shop_WeaponBuying",UpgradeShop="Shop_Upgrade",SellNpc="Shop_Selling"} do
 local p=find(key.."_Foundation");anchor(name,Vector3.new(p.Position.X,.3,p.Position.Z))
end
local spawn=Instance.new("SpawnLocation")
spawn.Name="LobbySpawn";spawn.Size=Vector3.new(8,.3,8);spawn.Position=spawnPosition
spawn.Transparency=1;spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0
spawn.CanCollide=false;spawn.CanTouch=false;spawn.CanQuery=false;spawn.Parent=source
game.Selection:Set({source})
game:GetService("ChangeHistoryService"):SetWaypoint("Courtyard layout installed")
print("COURTYARD INSTALLED:",count,"imported parts; 224x288 courtyard; 72x72 mine at origin; spawn on main path")
print("OLD MAP BACKUP: ServerStorage.OLD_Lobby_BEFORE_COURTYARD_DELETE_WHEN_READY")
print("LAYOUT ONLY: shops, AFK machines, selling NPC and stabilizer intentionally pending")
