-- Temporary paired LocalScript in StarterPlayerScripts.
local p=game.Players.LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("MiningDemo")
local Grid=require(game.ReplicatedStorage.Shared.MineGrid)
local function respond()
 local phase=p:GetAttribute("LobbyTestPhase")
 if not phase then return end
 task.wait(.3)
 if phase=="Weapon" then remote:FireServer("BuyOrEquipWeapon","Arc Pistol")
 elseif phase=="Upgrade" then remote:FireServer("BuyUpgrade","Storage")
 elseif phase=="Sell" then remote:FireServer("SellFromNpc")
 elseif phase=="Mine" then for _=1,3 do remote:FireServer("Mine",Grid.Id(7,1,12)); task.wait(.5) end
 elseif phase=="PlaceCore" then remote:FireServer("PlaceCore",workspace.Lobby.Stabilizer.CoreMount:GetAttribute("StabilizerId"))
 elseif phase=="ClaimCore" then remote:FireServer("ClaimCore",workspace.Lobby.Stabilizer.CoreMount:GetAttribute("StabilizerId"))
 elseif phase=="Plot" then remote:FireServer("Teleport","Plot")
 elseif phase=="World" then remote:FireServer("Teleport","World") end
end
p:GetAttributeChangedSignal("LobbyTestPhase"):Connect(respond)
respond()
