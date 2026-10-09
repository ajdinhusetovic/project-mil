local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)

local Config = require(ReplicatedStorage.Shared.Config)
local Grid = require(ReplicatedStorage.Shared.MineGrid)
local WeaponDefinitions = require(ReplicatedStorage.Shared.WeaponDefinitions)
local Progression = require(ReplicatedStorage.Shared.Progression)
local PlayerDataService = require(script.Services.PlayerDataService)
local WorldService = require(script.Services.WorldService)
local MineService = require(script.Services.MineService)
local CoreService = require(script.Services.CoreService)
local CoreToolService = require(script.Services.CoreToolService)
local StabilizerService = require(script.Services.StabilizerService)
local TrainingService = require(script.Services.TrainingService)
local AFKTrainingService = require(script.Services.AFKTrainingService)
local CoreSaleService = require(script.Services.CoreSaleService)
local OverchargeService = require(script.Services.OverchargeService)
local PlotService = require(script.Services.PlotService)
local ReactorService = require(script.Services.ReactorService)

local remote = Instance.new("RemoteEvent")
remote.Name = "MiningDemo"
remote.Parent = ReplicatedStorage
CoreService.Initialize(remote)
WorldService.Initialize()
AFKTrainingService.Initialize(remote)
PlotService.Initialize()
ReactorService.Initialize(remote)
StabilizerService.Initialize(remote)
CoreSaleService.Initialize(remote)

local pendingDrops = {}
local nextDropId = 0
local lastAttack = {}
local lastAction = {}
local lastReset = {}

OverchargeService.Initialize(remote, function(player)
	CoreSaleService.Release(player)
	TrainingService.Release(player)
	AFKTrainingService.Release(player)
	pendingDrops[player] = {}
	MineService.Reset(player)
	CoreService.Reset(player)
	remote:FireClient(player, "ResetMine")
	remote:FireClient(player, "InventorySnapshot", {})
	WorldService.Surface(player)
	CoreToolService.Sync(player)
	WorldService.GiveEquippedTool(player, player.Character, "Scrap Zapper", false)
end)

local function nearPrompt(player, prompt)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or not prompt or not prompt.Parent then return false end
	local parent = prompt.Parent
	local position
	if parent:IsA("BasePart") then
		position = parent.Position
	elseif parent:IsA("Model") then
		position = parent:GetPivot().Position
	end
	return position ~= nil and (root.Position - position).Magnitude <= prompt.MaxActivationDistance + 3
end

local function setup(player)
	PlayerDataService.Load(player)
	ReactorService.Create(player, PlotService.Create(player))
	StabilizerService.Publish(player)
	MineService.Create(player)
	CoreService.Create(player)
	pendingDrops[player] = {}
	local function giveInventory(character)
		local profile = PlayerDataService.Get(player)
		WorldService.GiveEquippedTool(player, character, profile and profile.EquippedWeapon or "Scrap Zapper", true)
		if character == player.Character then CoreToolService.Sync(player) end
	end
	player.CharacterAdded:Connect(giveInventory)
	if player.Character then
		task.spawn(giveInventory, player.Character)
	end
end

local function createMaterialDrop(player, id)
	nextDropId += 1
	local dropId = nextDropId
	local x, depth, z = Grid.Coordinates(id)
	local origin = Grid.Position(x, depth, z)
	local material = Grid.Material(x, depth, z)
	pendingDrops[player][dropId] = {
		Material = material.Name,
		Position = origin,
		Expires = os.clock() + Config.DropLifetime,
	}
	remote:FireClient(player, "Drop", dropId, origin, material.Color, material.Name)
	task.delay(Config.DropLifetime, function()
		local playerDrops = pendingDrops[player]
		if playerDrops then playerDrops[dropId] = nil end
	end)
end

local function blastBlocks(player, id)
	local x, depth, z = Grid.Coordinates(id)
	local center = Grid.Position(x, depth, z)
	local chainDamage = math.max(1, math.floor(PlayerDataService.GetDamage(player) * Config.Mining.ChainDamageMultiplier))
	local victims, damaged = MineService.Blast(player, id, PlayerDataService.GetBlastCount(player), Config.BlastRadius, chainDamage)
	for _, hit in damaged do remote:FireClient(player, "BlockHealth", hit.Id, hit.Health) end
	remote:FireClient(player, "Blast", center, Grid.Color(x, depth, z))
	local trainingMultiplier = 0
	for _, victimId in victims do
		local vx, vd, vz = Grid.Coordinates(victimId)
		trainingMultiplier += Progression.MiningMultiplier(vd) * (victimId == id and 1 or Config.Mining.ChainTrainingMultiplier)
		remote:FireClient(player, "Break", Grid.Position(vx, vd, vz), Grid.Material(vx, vd, vz).Color, victimId)
		createMaterialDrop(player, victimId)
		CoreService.TryDiscover(player, victimId)
	end
	PlayerDataService.AddBlocksMined(player, #victims)
	if trainingMultiplier > 0 then
		local success, gain = PlayerDataService.AwardTraining(player, trainingMultiplier)
		if success then remote:FireClient(player, "MiningTraining", gain) end
	end
end

local function collect(player, dropId)
	if typeof(dropId) ~= "number" then return end
	local playerDrops = pendingDrops[player]
	local drop = playerDrops and playerDrops[dropId]
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not drop or not root or os.clock() > drop.Expires then return end
	if (root.Position - drop.Position).Magnitude > PlayerDataService.GetCollectionRange(player) + 5 then return end
	local added, materialTotal = PlayerDataService.AddMaterial(player, drop.Material, 1)
	if not added then
		remote:FireClient(player, "BackpackFull", dropId)
		return
	end
	playerDrops[dropId] = nil
	remote:FireClient(player, "Inventory", drop.Material, materialTotal, 1, dropId)
end

remote.OnServerEvent:Connect(function(player, action, target)
	local now = os.clock()
	if action == "Teleport" then
		local success, reason = PlotService.Teleport(player, target)
		remote:FireClient(player, "TeleportResult", success, reason)
		return
	end
	if action == "ReactorEquipBest" or action == "ReactorInstall" or action == "ReactorRemove" or action == "ReactorCollect" or action == "ReactorClose" then
		ReactorService.Handle(player, action, target)
		return
	end
	if action == "Overcharge" then OverchargeService.Handle(player, target) return end
	if action == "QuoteHeldCoreSale" or action == "ConfirmHeldCoreSale" or action == "QuoteAllCoreSale" or action == "ConfirmAllCoreSale" then
		CoreSaleService.Handle(player, action, target)
		return
	end
	if action == "PlaceCore" or action == "ClaimCore" then
		StabilizerService.Handle(player, action, target)
		return
	end
	if action == "CollectCore" then CoreService.Collect(player, target) return end
	if action == "GetCoreInventory" then
		if now - (lastAction[player] or -math.huge) < 0.25 then return end
		lastAction[player] = now
		CoreService.SendInventory(player)
		return
	end
	if action == "BuyStorage" then
		if not nearPrompt(player, WorldService.GetStoragePrompt()) then
			remote:FireClient(player, "StoragePurchased", false, "Move closer to the upgrade shop")
			return
		end
		local success, result = PlayerDataService.BuyStorage(player)
		remote:FireClient(player, "StoragePurchased", success, result)
		return
	end
	if action == "BuyUpgrade" then
		if not nearPrompt(player, WorldService.GetStoragePrompt()) then
			remote:FireClient(player, "UpgradePurchased", false, "Move closer to the upgrade shop")
			return
		end
		local success, result = PlayerDataService.BuyUpgrade(player, target)
		local message = success and string.format("%s UPGRADED  -$%s", string.upper(target), Format.Compact(result)) or result
		remote:FireClient(player, "UpgradePurchased", success, message)
		return
	end
	if action == "BuyOrEquipArcPistol" then
		if not nearPrompt(player, WorldService.GetWeaponPrompt()) then
			remote:FireClient(player, "WeaponShopResult", false, "Move closer to the weapon shop")
			return
		end
		local success, message = PlayerDataService.BuyOrEquipArcPistol(player)
		if success and player.Character then
			WorldService.GiveEquippedTool(player, player.Character, "Arc Pistol", false)
		end
		remote:FireClient(player, "WeaponShopResult", success, message)
		return
	end
	if action == "BuyOrEquipWeapon" then
		if not nearPrompt(player, WorldService.GetWeaponPrompt()) then
			remote:FireClient(player, "WeaponShopResult", false, "Move closer to the weapon shop")
			return
		end
		local success, message = PlayerDataService.BuyOrEquipWeapon(player, target)
		if success and player.Character then
			WorldService.GiveEquippedTool(player, player.Character, target, false)
		end
		remote:FireClient(player, "WeaponShopResult", success, message)
		return
	end
	if action == "Train" then
		TrainingService.Handle(player, target)
		return
	end
	if action == "GetInventory" then
		local profile = PlayerDataService.Get(player)
		if profile then remote:FireClient(player, "InventorySnapshot", profile.Materials) end
		return
	end
	if action == "SellFromNpc" then
		local npc = WorldService.GetSellNpc()
		local prompt = npc and npc:FindFirstChildOfClass("ProximityPrompt")
		if not prompt or not nearPrompt(player, prompt) then return end
		local payout, count = PlayerDataService.SellAllMaterials(player)
		remote:FireClient(player, "Sold", payout, count)
		return
	end
	if action == "Collect" then collect(player, target) return end
	if action == "Surface" or action == "Reset" then
		if now - (lastAction[player] or -math.huge) < 1 then return end
		lastAction[player] = now
		if action == "Surface" then WorldService.Surface(player) return end
		if now - (lastReset[player] or -math.huge) < 5 then return end
		lastReset[player] = now
		WorldService.Surface(player)
		pendingDrops[player] = {}
		MineService.Reset(player)
		CoreService.Reset(player)
		remote:FireClient(player, "ResetMine")
		return
	end
	if action ~= "Mine" then return end
	TrainingService.MarkCombat(player)
	if now - (lastAttack[player] or -math.huge) < Config.Mining.HitInterval then return end
	lastAttack[player] = now
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local tool = character and character:FindFirstChildOfClass("Tool")
	local profile = PlayerDataService.Get(player)
	if not root or not humanoid or humanoid.Health <= 0 or not tool or not profile or not WeaponDefinitions[tool.Name] or tool.Name ~= profile.EquippedWeapon then return end
	if not MineService.GetHealth(player, target) then return end
	local x, depth, z = Grid.Coordinates(target)
	local targetPosition = Grid.Position(x, depth, z)
	if (root.Position - targetPosition).Magnitude > Config.Range then return end
	local origin = character:FindFirstChild("Head") or root
	local staticRayParams = RaycastParams.new()
	staticRayParams.FilterType = Enum.RaycastFilterType.Exclude
	staticRayParams.FilterDescendantsInstances = { character }
	if workspace:Raycast(origin.Position, targetPosition - origin.Position, staticRayParams) then return end
	if not MineService.IsAccessible(player, target, origin.Position) then return end
	local damage = PlayerDataService.GetDamage(player)
	if damage <= 0 then return end
	local health = MineService.Damage(player, target, damage)
	if health and health > 0 then
		remote:FireClient(player, "BlockHealth", target, health)
	elseif health == 0 then
		blastBlocks(player, target)
	end
end)

Players.PlayerAdded:Connect(setup)
for _, player in Players:GetPlayers() do setup(player) end
Players.PlayerRemoving:Connect(function(player)
	lastAttack[player] = nil
	TrainingService.Release(player)
	AFKTrainingService.Release(player)
	lastAction[player] = nil
	lastReset[player] = nil
	pendingDrops[player] = nil
	MineService.Release(player)
	CoreService.Release(player)
	StabilizerService.Release(player)
	CoreSaleService.Release(player)
	OverchargeService.Release(player)
	ReactorService.Release(player)
	PlotService.Release(player)
	PlayerDataService.Release(player)
end)
game:BindToClose(function()
	PlayerDataService.SaveAll()
end)

-- Periodic saves also checkpoint reactor earnings for the existing save pipeline.
task.spawn(function()
	while true do task.wait(60); PlayerDataService.SaveAll() end
end)
