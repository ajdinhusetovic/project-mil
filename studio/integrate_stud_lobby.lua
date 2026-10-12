-- Run in Studio Command Bar in Edit mode with Rojo connected.
local lobby=workspace:FindFirstChild("EnergyCoreMining-COLORED") or workspace:FindFirstChild("Lobby")
assert(lobby and lobby:IsA("Model"),"Imported EnergyCoreMining-COLORED Model missing")
if lobby:GetAttribute("StudLobbyConnected") then print("Stud lobby already connected"); return end
local function clean(n) return (n:gsub("%.%d+$","")) end
local function find(n)
 for _,p in lobby:GetDescendants() do if p:IsA("BasePart") and (p.Name==n or clean(p.Name)==clean(n)) then return p end end
 error("Missing landmark "..n)
end
if not lobby:GetAttribute("StudLobbyVersion") then
local rimA,rimB=find("MineEntrance__EndRim-37"),find("MineEntrance__EndRim37")
local path=find("Paths__ForwardToMine")
local factor=rimA.Size.X/72
lobby:ScaleTo(lobby:GetScale()/factor)
local origin=Vector3.new((rimA.Position.X+rimB.Position.X)/2,path.Position.Y-path.Size.Y/2,(rimA.Position.Z+rimB.Position.Z)/2)
lobby:PivotTo(CFrame.Angles(0,math.pi,0)*CFrame.new(-origin)*lobby:GetPivot())
end
local backup=Instance.new("Folder"); backup.Name="LobbyBackup_StudReplacement"; backup.Parent=game.ServerStorage
for _,n in {"Lobby","AFKTrainingStations"} do local old=workspace:FindFirstChild(n); if old and old~=lobby then old.Parent=backup end end
-- Old signs point at archived artwork; keep them in the same reversible backup.
for _,g in game.StarterGui:GetChildren() do
 if g.Name:find("AFKSign_",1,true) or g.Name:find("LobbySign_",1,true) or g.Name:find("LobbyBoard_",1,true) then g.Parent=backup end
end
lobby.Name="Lobby"; lobby:SetAttribute("ImportedLobbyIntegrated",true); lobby:SetAttribute("StudLobbyVersion",true)
local art=lobby:GetDescendants()
local groups={}
local function group(n,parent) local m=Instance.new("Model"); m.Name=n; m.Parent=parent; return m end
for _,p in art do if p:IsA("BasePart") then
 local prefix=clean(p.Name):match("^(.-)__")
 if prefix then
  groups[prefix]=groups[prefix] or lobby:FindFirstChild(prefix) or group(prefix,lobby)
  p.Parent=groups[prefix]
 end
 p.Anchored,p.CanTouch,p.CanCollide,p.CanQuery=true,false,true,true
 local n=p.Name:lower()
 if n:find("stud",1,true) or n:find("tuft",1,true) or n:find("flower",1,true)
   or n:find("hazard",1,true) or n:find("outline",1,true) or n:find("trim",1,true) then
  p.CanCollide,p.CanQuery=false,false
 end
end end
local function invisible(n,size,pos,parent)
 local p=Instance.new("Part"); p.Name,p.Size,p.Position=n,size,pos
 p.Anchored,p.CanCollide,p.CanQuery,p.CanTouch=true,false,false,false
 p.Transparency=1; p.Parent=parent; return p
end
local function text(gui,n,y,h,value,color)
 local t=Instance.new("TextLabel"); t.Name,t.Text=n,value
 t.Position,t.Size=UDim2.fromScale(0,y),UDim2.fromScale(1,h)
 t.BackgroundTransparency,t.TextScaled,t.TextWrapped=1,true,true
 t.Font,t.TextColor3=Enum.Font.FredokaOne,color or Color3.new(1,1,1); t.Parent=gui
 local stroke=Instance.new("UIStroke"); stroke.Thickness=2.5; stroke.Parent=t
 local limit=Instance.new("UITextSizeConstraint"); limit.MinTextSize=8; limit.MaxTextSize=36; limit.Parent=t
 return t
end
local function billboard(n,adornee,size)
 local g=Instance.new("BillboardGui"); g.Name,g.Adornee,g.Size=n,adornee,UDim2.fromScale(size.X,size.Y)
 g.AlwaysOnTop,g.MaxDistance=false,120; g.Parent=game.StarterGui; return g
end
local anchors=lobby:FindFirstChild("GameplayAnchors") or Instance.new("Folder"); anchors.Name="GameplayAnchors"; anchors.Parent=lobby
for _,n in {"WeaponStore","UpgradeStore","SellStore"} do
 local m=groups[n]; assert(m)
 local counter=find(n.."__Counter")
 local rail=find(n.."__CounterWoodRail0.75")
 local front=rail.Position-counter.Position; front=Vector3.new(front.X,0,front.Z).Unit
 counter.Name="Counter"; m.PrimaryPart=counter
 local board=find(n.."__SignPanel")
 local title=n=="WeaponStore" and "WEAPONS" or n=="UpgradeStore" and "UPGRADES" or "SELL ORE"
 local g=billboard("LobbySign_"..n,board,Vector2.new(11,1.8)); g.StudsOffsetWorldSpace=front*.4; text(g,"Title",0,1,title)
 if n~="SellStore" then
  m:SetAttribute("ShopType",n=="WeaponStore" and "Weapons" or "Upgrades")
  local a=Instance.new("Attachment"); a.Name="ShopInteraction"
  a.Position=counter.CFrame:VectorToObjectSpace(front*1.1); a.Parent=counter
  local prompt=Instance.new("ProximityPrompt"); prompt.Name="OpenShop"; prompt.ActionText="Open shop"; prompt.ObjectText=title
  prompt.RequiresLineOfSight,prompt.MaxActivationDistance=false,11; prompt.Parent=a
  invisible(n=="WeaponStore" and "WeaponShop" or "UpgradeShop",Vector3.one,counter.Position,anchors)
 else
  local pos=counter.Position+front*4; pos=Vector3.new(pos.X,0,pos.Z)
  invisible("SellNpc",Vector3.one,pos,anchors)
  local npc=workspace:FindFirstChild("showcase npc"); assert(npc,"Existing sell NPC missing")
  npc:PivotTo(CFrame.lookAt(pos,pos+front))
  local prompt=npc:FindFirstChildOfClass("ProximityPrompt"); assert(prompt)
  prompt.ActionText,prompt.ObjectText,prompt.RequiresLineOfSight="Talk","Ore Buyer",false
 end
end
local spawnPad=find("Paths__SmallSpawnInlay")
local spawn=Instance.new("SpawnLocation"); spawn.Name="LobbySpawn"
spawn.Size,spawn.Position=Vector3.new(5,.3,5),spawnPad.Position+Vector3.new(0,.25,0)
spawn.Anchored,spawn.Neutral,spawn.Enabled=true,true,true
spawn.CanCollide,spawn.CanQuery,spawn.CanTouch=false,false,false
spawn.Transparency,spawn.Duration=1,0; spawn.Parent=lobby
invisible("Spawn",Vector3.one,spawn.Position,anchors)
local mount=find("Stabilizer__CoreMount"); mount.Name="CoreMount"
groups.Stabilizer:SetAttribute("IsStabilizer",true); groups.Stabilizer.PrimaryPart=mount
local prompt=Instance.new("ProximityPrompt"); prompt.Name="StabilizerPrompt"; prompt.ActionText="Use stabilizer"; prompt.ObjectText="CORE STABILIZER"
prompt.MaxActivationDistance,prompt.RequiresLineOfSight=11,false; prompt.Parent=mount
local stabilizerSign=invisible("SignAnchor",Vector3.one,mount.Position+Vector3.new(0,4.5,0),groups.Stabilizer)
text(billboard("LobbySign_Stabilizer",stabilizerSign,Vector2.new(13,2)),"Title",0,1,"CORE STABILIZER",Color3.fromRGB(187,130,255))
local mineSign=billboard("LobbySign_Mine",find("MineEntrance__EntranceSignBlank"),Vector2.new(18,2)); mineSign.StudsOffsetWorldSpace=Vector3.new(0,0,1); text(mineSign,"Title",0,1,"ENERGY MINE",Color3.fromRGB(255,226,76))
local afk=Instance.new("Folder"); afk.Name="AFKTrainingStations"; afk.Parent=workspace
local definitions=require(game.ReplicatedStorage.Shared.AFKTrainingDefinitions)
local prefixes={"AFK_1x","AFK_1_5x","AFK_3x","AFK_5x","AFK_8x"}
for i,d in definitions.Stations do for _,suffix in {"","_02"} do
 local prefix=prefixes[i]..suffix
 local m=groups[prefix]; assert(m,"Missing AFK group "..prefix)
 local standing=find(prefix.."__StandingArea")
 local block=find(prefix.."__TrainingBlock")
 local pedestal=find(prefix.."__TrainingBlockMount")
 m.Name=d.Id..suffix; m:SetAttribute("StationId",d.Id); m.Parent=afk; m.PrimaryPart=standing
 block.Name,pedestal.Name="ChargeBlock","Pedestal"
 block.CanCollide,block.CanQuery=false,false
 for _,p in m:GetChildren() do if p:IsA("BasePart") and p.Name:find("__TrainingBlockStuds",1,true) then p.Parent=block end end
 m:SetAttribute("FloatOffset",block.Position-pedestal.Position)
 local a=Instance.new("Attachment"); a.Name="ChargeTarget"; a.Parent=block
 invisible("Zone",Vector3.new(standing.Size.X,7,standing.Size.Z),standing.Position+Vector3.new(0,3.5,0),m)
 local g=billboard("AFKSign_"..m.Name,block,Vector2.new(10,2.4)); g.StudsOffsetWorldSpace=Vector3.new(0,3.5,0); g.MaxDistance=70
 text(g,"Title",0,.5,tostring(d.Multiplier).."× AFK",d.Color)
 text(g,"Requirement",.52,.45,d.Rebirths==0 and "UNLOCKED • STAND HERE" or d.Rebirths.." REBIRTHS",d.Color)
end end
assert(#afk:GetChildren()==10)
local area=workspace:FindFirstChild("MineArea"); assert(area,"Existing full-depth mine shell missing")
area:SetAttribute("HasAuthoredRim",true)
local a,b=find("MineEntrance__EndRim-37"),find("MineEntrance__EndRim37")
assert(((a.Position+b.Position)/2*Vector3.new(1,0,1)).Magnitude<.01,"Mine opening alignment failed")
lobby:SetAttribute("StudLobbyConnected",true)
game.Selection:Set({lobby})
print("STUD LOBBY PLACED: mine at origin, shops, NPC, stabilizer, spawn and ten AFK stations. Signs editable in StarterGui.")
