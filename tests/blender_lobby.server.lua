-- Temporary Studio server Script; run with blender_lobby.client.lua.
local Players=game:GetService("Players")
local Shared=game.ReplicatedStorage.Shared
local Config=require(Shared.Config)
assert(not Config.Persistence.EnableInStudio,"Integration tests require Studio saving disabled")
local Services=game.ServerScriptService.Server.Services
local Data=require(Services.PlayerDataService)
local World=require(Services.WorldService)
local Tools=require(Services.CoreToolService)
local Training=require(Services.TrainingService)
local AFK=require(Services.AFKTrainingService)
local Stabilizer=require(Services.StabilizerService)
local Grid=require(Shared.MineGrid)
local Mine=require(Services.MineService)
local Material=require(Shared.MaterialDefinitions)
local p=Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
repeat task.wait() until Data.Get(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
task.wait(2)
local d=Data.Get(p)
local saved=game.HttpService:JSONDecode(game.HttpService:JSONEncode(d))
local root=p.Character.HumanoidRootPart
local function phase(name,position)
 root.Anchored=true
 if position then root.CFrame=CFrame.new(position) end
 p:SetAttribute("LobbyTestPhase",name)
 task.wait(1.4)
end
local ok,err=pcall(function()
 local lobby=workspace.Lobby
 assert(lobby:GetAttribute("ImportedLobbyIntegrated"))
 assert((root.Position-lobby.GameplayAnchors.Spawn.Position).Magnitude<10,"Spawn must use the new pad")
 assert(#workspace.AFKTrainingStations:GetChildren()==10)
 assert(workspace.MineArea.Bedrock.Position.Y < -Config.Depth*Config.BlockSize)
 assert(not workspace.MineArea:FindFirstChild("Deck"),"No legacy decks overlapping import")
 d.Cash,d.Level,d.Power,d.XP=1000,5,60,0
 d.Materials={["Stone Ore"]=5}
 for _,key in {"Cash","Level","Power","XP"} do p:SetAttribute(key,d[key]) end
 p:SetAttribute("BackpackUsed",5)
 Data.PublishProgress(p)
 local weapon=World.GetWeaponPrompt()
 assert(weapon.Parent:IsA("Attachment"))
 phase("Weapon",weapon.Parent.WorldPosition+Vector3.new(0,0,4))
 assert(d.Weapons["Arc Pistol"] and d.EquippedWeapon=="Arc Pistol" and d.Cash==850,"Buy weapon at imported counter")
 local upgrade=World.GetStoragePrompt()
 phase("Upgrade",upgrade.Parent.WorldPosition+Vector3.new(0,0,4))
 assert(d.Upgrades.Storage==1 and d.BackpackCapacity==saved.BackpackCapacity+Config.StorageUpgrade.CapacityPerLevel and d.Cash==800,"Upgrade at imported counter")
 local payout=Data.GetCashPayout(p,Material["Stone Ore"].SellValue*5)
 phase("Sell",workspace["showcase npc"]:GetPivot().Position+Vector3.new(0,3,5))
 assert(d.Cash==800+payout and next(d.Materials)==nil,"Sell ores through existing NPC")
 print("LOBBY SHOPS PASSED: real remote purchases and NPC sale at new landmarks")
 d.Level,d.XP=1,0
 Data.PublishProgress(p)
 phase("Mine",Vector3.new(3,5,33))
 task.wait(1)
 assert(not Mine.GetHealth(p,Grid.Id(7,1,12)) and d.Power==60+require(Shared.WeaponDefinitions)["Arc Pistol"].PowerPerClick*require(Shared.Progression).MiningMultiplier(1),"Actual mining remains aligned with the imported opening")
 Training.Release(p); AFK.Release(p)
 local before=d.Power
 phase("AFK",workspace.AFKTrainingStations.Starter.Zone.Position)
 assert(d.Power>before and p:GetAttribute("AFKStation")=="Starter","Imported AFK floor awards training")
 before=d.Power
 phase("LockedAFK",workspace.AFKTrainingStations.Charged.Zone.Position)
 assert(d.Power==before and not p:GetAttribute("AFKStation"),"Locked imported AFK floor must not award")
 print("LOBBY MINING/AFK PASSED: mine opening aligned, AFK rewards and locks")
 local secondBefore=d.Power
 phase("AFKSecondRow",workspace.AFKTrainingStations.Starter_02.Zone.Position)
 assert(d.Power>secondBefore and p:GetAttribute("AFKStationModel")=="Starter_02","Second AFK row must train independently")
 local mount=lobby.Stabilizer.CoreMount
 assert(mount:GetAttribute("StabilizerId"),"New mount registered")
 assert(Data.AddUnknownCore(p,{Id="LobbyIntegrationCore",Grade="Cracked"}))
 Tools.Sync(p)
 local core
 for _,t in p.Backpack:GetChildren() do if t:GetAttribute("CoreId")=="LobbyIntegrationCore" then core=t end end
 assert(core)
 p.Character.Humanoid:EquipTool(core)
 phase("PlaceCore",Vector3.new(mount.Position.X,3.5,mount.Position.Z+5))
 assert(d.Stabilizer.Core and d.Stabilizer.FinishAt and d.Stabilizer.FinishAt>os.time(),"Imported stabilizer starts automatically")
 d.Stabilizer.FinishAt=os.time()-1; Stabilizer.Publish(p)
 phase("ClaimCore")
 assert(not d.Stabilizer.Core and #d.StabilizedCores==#saved.StabilizedCores+1,"New stabilizer claims into hotbar")
 print("LOBBY STABILIZER PASSED: placement, automatic start, claim/reveal")
 root.Anchored=false
 phase("Plot")
 assert(p:GetAttribute("CurrentDestination")=="Plot")
 phase("World")
 assert(p:GetAttribute("CurrentDestination")=="World" and (root.Position-lobby.GameplayAnchors.Spawn.Position).Magnitude<10,"World teleport uses new spawn")
 print("LOBBY TELEPORT PASSED: personal plot and return to new lobby")
end)
p:SetAttribute("LobbyTestPhase",nil)
AFK.Release(p)
Training.Release(p)
for key in d do d[key]=nil end
for key,value in saved do d[key]=value end
for _,key in {"Cash","Level","Power","XP"} do p:SetAttribute(key,d[key]) end
Data.PublishProgress(p)
Tools.Sync(p)
World.GiveEquippedTool(p,p.Character,d.EquippedWeapon,false)
root.Anchored=false
World.Surface(p)
assert(ok,err)
print("BLENDER LOBBY INTEGRATION TESTS PASSED")
