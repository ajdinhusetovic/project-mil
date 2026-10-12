-- Paste in Studio's Command Bar in EDIT mode with Rojo connected.
-- Preserves the previous lobby in ServerStorage.LegacyLobbyBackup.
local Config = require(game.ReplicatedStorage.Shared.Config)
local Definitions = require(game.ReplicatedStorage.Shared.AFKTrainingDefinitions)
local lobby = workspace:FindFirstChild("EnergyCoreLobby-Colored") or workspace:FindFirstChild("EnergyCoreLobby")
if not lobby then
 local current = workspace:FindFirstChild("Lobby")
 assert(current and current:GetAttribute("ImportedLobbyIntegrated"), "Imported EnergyCoreLobby Model missing")
 print("Imported lobby already integrated")
 return
end
assert(lobby:IsA("Model"), "Lobby import must be a Model")
local function clean(name) return (name:gsub("%.%d+$", "")) end
local function find(name)
 for _,item in lobby:GetDescendants() do
  if item:IsA("BasePart") and clean(item.Name)==name then return item end
 end
 error("Missing imported landmark: "..name)
end
-- Normalize units and apply the import's inverse facing around the mine opening.
local meadow = find("Lobby meadow")
local importedBedrock = find("Bedrock")
local factor = meadow.Size.X / 220
assert(factor > 0, "Invalid imported scale")
lobby:ScaleTo(lobby:GetScale()/factor)
local center = Vector3.new(importedBedrock.Position.X, meadow.Position.Y + meadow.Size.Y/2, importedBedrock.Position.Z)
local transform = CFrame.Angles(0,math.pi,0) * CFrame.new(-center)
lobby:PivotTo(transform * lobby:GetPivot())

local backup = game.ServerStorage:FindFirstChild("LegacyLobbyBackup") or Instance.new("Folder")
backup.Name, backup.Parent = "LegacyLobbyBackup", game.ServerStorage
for _,name in {"Lobby","MineArea","AFKTrainingStations"} do
 local old = workspace:FindFirstChild(name)
 if old and old ~= lobby then old.Name="Old"..name; old.Parent=backup end
end
lobby.Name = "Lobby"
lobby:SetAttribute("ImportedLobbyIntegrated",true)
lobby:SetAttribute("ImportedUnitScale",factor)
local art = lobby:GetDescendants()
for _,p in art do
 if p:IsA("BasePart") then
  p:SetAttribute("ImportedArtName",clean(p.Name))
  p.Anchored, p.CanTouch = true,false
  p.CanCollide, p.CanQuery = true,true
  local name = clean(p.Name)
  if name:find("Label",1,true) or name:find("Subtitle",1,true) or name:find("trim",1,true)
    or name:find("light",1,true) or name:find("seam",1,true) or name:find("crystal",1,true)
    or name:find("Flower",1,true) or name:find("Direction chevron",1,true)
    or name:find("Display",1,true) or name:find("Reveal preview",1,true) then
   p.CanCollide,p.CanQuery=false,false
  end
  if name:find("light",1,true) or name:find("energy ring",1,true) then p.Material=Enum.Material.Neon end
 end
end
local function group(name,parent)
 local m=Instance.new("Model"); m.Name=name; m.Parent=parent; return m
end
local function part(name,size,position,parent)
 local p=Instance.new("Part")
 p.Name,p.Size,p.Position=name,size,position
 p.Anchored,p.CanCollide,p.CanQuery,p.CanTouch=true,false,false,false
 p.Transparency=1; p.Parent=parent
 return p
end
local function movePrefix(prefix,model)
 for _,p in art do
  if p:IsA("BasePart") and clean(p.Name):sub(1,#prefix)==prefix then p.Parent=model end
 end
end
local anchors=Instance.new("Folder"); anchors.Name="GameplayAnchors"; anchors.Parent=lobby
for _,name in {"WeaponStore","UpgradeStore","SellStore"} do
 local counter=find(name.." Counter")
 local shop=group(name,lobby)
 movePrefix(name.." ",shop)
 shop.PrimaryPart=counter
 counter.Name="Counter"
 if name~="SellStore" then
  shop:SetAttribute("ShopType",name=="WeaponStore" and "Weapons" or "Upgrades")
  -- Attach to the front lip rather than the wide counter's center.
  local attachment=Instance.new("Attachment")
  attachment.Name="ShopInteraction"
  attachment.Position=counter.CFrame:VectorToObjectSpace(Vector3.new(0,0,counter.Size.Z/2+0.4))
  attachment.Parent=counter
  local prompt=Instance.new("ProximityPrompt")
  prompt.Name="OpenShop"; prompt.ActionText="Open shop"
  prompt.ObjectText=name=="WeaponStore" and "WEAPONS" or "UPGRADES"
  prompt.MaxActivationDistance=11; prompt.RequiresLineOfSight=false
  prompt.Parent=attachment
  part(name=="WeaponStore" and "WeaponShop" or "UpgradeShop",Vector3.one,counter.Position,anchors)
 else
  local position=Vector3.new(counter.Position.X,0,counter.Position.Z+10)
  part("SellNpc",Vector3.one,position,anchors)
  local npc=workspace:FindFirstChild("showcase npc")
  assert(npc,"Existing sell NPC missing")
  npc:PivotTo(CFrame.lookAt(position,position+Vector3.new(0,0,1)))
  for _,p in npc:GetDescendants() do if p:IsA("BasePart") then p.Anchored=true end end
  local prompt=npc:FindFirstChildOfClass("ProximityPrompt")
  assert(prompt,"Existing NPC dialogue prompt missing")
  prompt.ActionText,prompt.ObjectText="Talk","Ore Buyer"
  prompt.RequiresLineOfSight=false
  for _,p in art do
   if p:IsA("BasePart") and clean(p.Name):find("Ore Buyer",1,true) then p.Parent=backup end
  end
 end
end
local spawnPad=find("Spawn cyan pad")
part("Spawn",Vector3.one,spawnPad.Position+Vector3.new(0,0.3,0),anchors)
local spawn=Instance.new("SpawnLocation")
spawn.Name="LobbySpawn"; spawn.Size=Vector3.new(8,0.3,8)
spawn.Position=anchors.Spawn.Position
spawn.Anchored,spawn.Neutral,spawn.Enabled=true,true,true
spawn.CanCollide,spawn.CanQuery,spawn.CanTouch=false,false,false
spawn.Transparency,spawn.Duration=1,0
spawn.Parent=lobby

-- Use imported top strata; add a full-depth gameplay shell below the artwork.
importedBedrock.Parent=backup
local area=group("MineArea",workspace)
area:SetAttribute("HasAuthoredRim",true)
local half=Config.Width*Config.BlockSize/2
local bottom=-Config.Depth*Config.BlockSize
local wallTop=-0.5
for _,sign in {-1,1} do
 for _,axis in {"X","Z"} do
  local p=part("ShaftWall",axis=="X" and Vector3.new(2.4,wallTop-bottom,half*2+4) or Vector3.new(half*2+4,wallTop-bottom,2.4),
   axis=="X" and Vector3.new(sign*(half+0.9),(wallTop+bottom)/2,0) or Vector3.new(0,(wallTop+bottom)/2,sign*(half+0.9)),area)
  p.Transparency,p.CanCollide,p.CanQuery=0,true,true
  p.Color=Color3.fromRGB(72,84,110)
 end
end
local bedrock=part("Bedrock",Vector3.new(half*2+4,4,half*2+4),Vector3.new(0,bottom-2,0),area)
bedrock.Transparency,bedrock.CanCollide,bedrock.CanQuery=0,true,true
bedrock.Color=Color3.fromRGB(25,31,47)

local stabilizer=group("Stabilizer",lobby)
stabilizer:SetAttribute("IsStabilizer",true)
for _,p in art do
 if p:IsA("BasePart") then
  local n=clean(p.Name)
  if n:sub(1,10)=="Stabilizer" or n:sub(1,9)=="CoreMount" or n:sub(1,19)=="Reveal preview core"
    or n=="Console screen" or n=="Place prompt" then p.Parent=stabilizer end
 end
end
local mount=find("CoreMount"); mount.Name="CoreMount"; stabilizer.PrimaryPart=mount
local prompt=Instance.new("ProximityPrompt")
prompt.Name="StabilizerPrompt"; prompt.ActionText="Use stabilizer"; prompt.ObjectText="CORE STABILIZER"
prompt.MaxActivationDistance=11; prompt.RequiresLineOfSight=false; prompt.Parent=mount
-- Decorative preview crystals would obscure the real roll.
for _,p in art do if p:IsA("BasePart") and clean(p.Name):sub(1,19)=="Reveal preview core" then p.Parent=backup end end

local afk=Instance.new("Folder"); afk.Name="AFKTrainingStations"; afk.Parent=workspace
local function label(gui,name,y,value,color)
 local t=Instance.new("TextLabel")
 t.Name,t.Text=name,value
 t.Position,t.Size=UDim2.fromScale(0,y),UDim2.fromScale(1,0.45)
 t.BackgroundTransparency,t.Font,t.TextColor3=1,Enum.Font.FredokaOne,color
 t.TextScaled,t.TextWrapped=true,true; t.Parent=gui
 local stroke=Instance.new("UIStroke"); stroke.Thickness=2.5; stroke.Parent=t
 local limit=Instance.new("UITextSizeConstraint"); limit.MinTextSize=8; limit.MaxTextSize=26; limit.Parent=t
end
for _,definition in Definitions.Stations do
 local prefix="AFK "..tostring(definition.Multiplier).."x "
 local model=group(definition.Id,afk); model:SetAttribute("StationId",definition.Id)
 local standing=find(prefix.."Standing area")
 local block=find(prefix.."Floating power cube")
 local pedestal=find(prefix.."Reactor plinth")
 movePrefix(prefix,model)
 model.PrimaryPart=standing
 block.Name,pedestal.Name="ChargeBlock","Pedestal"
 block.CanCollide,block.CanQuery=false,false
 model:SetAttribute("FloatOffset",block.Position-pedestal.Position)
 local target=Instance.new("Attachment"); target.Name="ChargeTarget"; target.Parent=block
 local zone=part("Zone",Vector3.new(standing.Size.X,8,standing.Size.Z),standing.Position+Vector3.new(0,4,0),model)
 for _,p in model:GetChildren() do
  if p:IsA("BasePart") and clean(p.Name):find("Subtitle",1,true) then p.Parent=backup end
 end
 -- The Blender title stays as art; only the requirement changes per player.
 local gui=Instance.new("BillboardGui")
 gui.Name="StationSign"; gui.Size=UDim2.fromScale(26,4)
 gui.StudsOffsetWorldSpace=Vector3.new(0,4.8,0)
 gui.AlwaysOnTop=false; gui.MaxDistance=100; gui.Parent=block
 label(gui,"Requirement",0,definition.Rebirths==0 and "UNLOCKED • STAND HERE" or definition.Rebirths.." REBIRTHS TO UNLOCK",definition.Color)
end
assert(math.abs(find("Lobby meadow").Size.X-220)<0.1,"Ground scale mismatch")
game.Selection:Set({lobby})
print("BLENDER LOBBY INTEGRATED: spawn, two shops, sell NPC, stabilizer, five AFK stations and "..Config.Depth*Config.BlockSize.."-stud mine. Previous map backed up.")
