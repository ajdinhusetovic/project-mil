local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Config = require(ReplicatedStorage.Shared.Config)
local MaterialDefinitions = require(ReplicatedStorage.Shared.MaterialDefinitions)
local WeaponDefinitions = require(ReplicatedStorage.Shared.WeaponDefinitions)
local Template = require(ReplicatedStorage.Shared.PlayerDataTemplate)

local PlayerDataService = {}
local profiles = {}
local canSave = {}
local trainingSequences = {}
local store = DataStoreService:GetDataStore(Config.Persistence.StoreName)

local function deepCopy(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, child in value do copy[key] = deepCopy(child) end
	return copy
end

local function reconcile(data, template)
	for key, defaultValue in template do
		if data[key] == nil then
			data[key] = deepCopy(defaultValue)
		elseif type(defaultValue) == "table" and type(data[key]) == "table" then
			reconcile(data[key], defaultValue)
		end
	end
end

local function shouldUseDataStore()
	return not RunService:IsStudio() or Config.Persistence.EnableInStudio
end

local function publish(player, data)
	player:SetAttribute("Power", data.Power)
	player:SetAttribute("XP", data.XP)
	player:SetAttribute("Level", data.Level)
	player:SetAttribute("Cash", data.Cash)
	player:SetAttribute("UnknownCoreCount", #data.UnknownCores)
	player:SetAttribute("UnknownCoreCapacity", data.UnknownCoreCapacity)
	player:SetAttribute("Mined", data.BlocksMined)
	player:SetAttribute("BackpackUsed", PlayerDataService.GetBackpackUsed(player))
	player:SetAttribute("BackpackCapacity", data.BackpackCapacity)
	player:SetAttribute("StorageLevel", data.Upgrades.Storage)
	player:SetAttribute("ChainLevel", data.Upgrades.ChainTargets)
	player:SetAttribute("BlastCount", Config.BlastBlocks + data.Upgrades.ChainTargets)
	player:SetAttribute("MagnetLevel", data.Upgrades.Magnet)
	player:SetAttribute("MagnetRange", Config.CollectionRange + data.Upgrades.Magnet * Config.MagnetUpgrade.RangePerLevel)
	player:SetAttribute("EquippedWeapon", data.EquippedWeapon)
	player:SetAttribute("OwnsArcPistol", data.Weapons["Arc Pistol"] == true)
	for _, weaponName in Config.WeaponOrder do
		local definition = WeaponDefinitions[weaponName]
		player:SetAttribute("OwnsWeapon_" .. definition.Id, data.Weapons[weaponName] == true)
	end
	PlayerDataService.PublishProgress(player)
end

-- One atomic snapshot prevents predicted clicks from double-counting replicated stats.
function PlayerDataService.PublishProgress(player)
	local data = profiles[player]
	if not data then return end
	player:SetAttribute("ProgressSnapshot", HttpService:JSONEncode({
		Power = data.Power, XP = data.XP, Level = data.Level, Sequence = trainingSequences[player] or 0,
	}))
end

function PlayerDataService.GetTrainingSequence(player)
	return trainingSequences[player] or 0
end

function PlayerDataService.AcknowledgeTraining(player, sequence)
	trainingSequences[player] = sequence
	PlayerDataService.PublishProgress(player)
end

function PlayerDataService.Load(player)
	local data = deepCopy(Template)
	canSave[player] = true
	if shouldUseDataStore() then
		local success, saved = pcall(function()
			return store:GetAsync(`Player_{player.UserId}`)
		end)
		if success and type(saved) == "table" then
			data = saved
			reconcile(data, Template)
		elseif not success then
			canSave[player] = false
			warn(`Player data load failed for {player.Name}; using unsaved session data: {saved}`)
		end
	end
	profiles[player] = data
	trainingSequences[player] = 0
	publish(player, data)
	return data
end

function PlayerDataService.Get(player)
	return profiles[player]
end

function PlayerDataService.AddUnknownCore(player, core)
	local data = profiles[player]
	if not data then return false, "Data not ready" end
	if #data.UnknownCores >= data.UnknownCoreCapacity then return false, "Core storage full! This core will wait here for up to 3 minutes." end
	table.insert(data.UnknownCores, core)
	data.HasCollectedCore = true
	player:SetAttribute("UnknownCoreCount", #data.UnknownCores)
	return true
end

function PlayerDataService.GetBackpackUsed(player)
	local data = profiles[player]
	if not data then return 0 end
	local total = 0
	for _, amount in data.Materials do total += amount end
	return total
end

function PlayerDataService.AddMaterial(player, materialName, amount)
	local data = profiles[player]
	if not data then return false, 0 end
	local used = PlayerDataService.GetBackpackUsed(player)
	if used + amount > data.BackpackCapacity then return false, data.Materials[materialName] or 0 end
	data.Materials[materialName] = (data.Materials[materialName] or 0) + amount
	player:SetAttribute("BackpackUsed", used + amount)
	return true, data.Materials[materialName]
end

function PlayerDataService.AddBlocksMined(player, amount)
	local data = profiles[player]
	if not data then return end
	data.BlocksMined += amount
	player:SetAttribute("Mined", data.BlocksMined)
	data.XP += amount * 3
	while data.XP >= PlayerDataService.GetXPToNextLevel(data.Level) do
		data.XP -= PlayerDataService.GetXPToNextLevel(data.Level)
		data.Level += 1
	end
	player:SetAttribute("XP", data.XP)
	player:SetAttribute("Level", data.Level)
	PlayerDataService.PublishProgress(player)
end

function PlayerDataService.SellAllMaterials(player)
	local data = profiles[player]
	if not data then return 0, 0 end
	local payout, count = 0, 0
	for materialName, amount in data.Materials do
		local definition = MaterialDefinitions[materialName]
		if definition and type(amount) == "number" and amount > 0 then
			payout += math.floor(amount) * definition.SellValue
			count += math.floor(amount)
		end
	end
	if count == 0 then return 0, 0 end
	data.Materials = {}
	data.Cash += payout
	player:SetAttribute("Cash", data.Cash)
	player:SetAttribute("BackpackUsed", 0)
	return payout, count
end

function PlayerDataService.GetStoragePrice(player)
	local data = profiles[player]
	if not data or data.Upgrades.Storage >= Config.StorageUpgrade.MaxLevel then return nil end
	return math.floor(Config.StorageUpgrade.BasePrice * Config.StorageUpgrade.PriceMultiplier ^ data.Upgrades.Storage)
end

function PlayerDataService.GetBlastCount(player)
	local data = profiles[player]
	return Config.BlastBlocks + (data and data.Upgrades.ChainTargets or 0)
end

function PlayerDataService.GetCollectionRange(player)
	local data = profiles[player]
	return Config.CollectionRange + (data and data.Upgrades.Magnet or 0) * Config.MagnetUpgrade.RangePerLevel
end

function PlayerDataService.GetUpgradePrice(player, upgradeName)
	local data = profiles[player]
	if not data then return nil end
	local definitions = { Storage = Config.StorageUpgrade, Chain = Config.ChainUpgrade, Magnet = Config.MagnetUpgrade }
	local fields = { Storage = "Storage", Chain = "ChainTargets", Magnet = "Magnet" }
	local definition = definitions[upgradeName]
	if not definition then return nil end
	local level = data.Upgrades[fields[upgradeName]]
	if level >= definition.MaxLevel then return nil end
	return math.floor(definition.BasePrice * definition.PriceMultiplier ^ level)
end

function PlayerDataService.BuyUpgrade(player, upgradeName)
	local data = profiles[player]
	if not data then return false, "Data not ready" end
	local fields = { Storage = "Storage", Chain = "ChainTargets", Magnet = "Magnet" }
	local field = fields[upgradeName]
	if not field then return false, "Unknown upgrade" end
	local price = PlayerDataService.GetUpgradePrice(player, upgradeName)
	if not price then return false, "Upgrade is maxed" end
	if data.Cash < price then return false, `Need ${price - data.Cash} more cash` end
	data.Cash -= price
	data.Upgrades[field] += 1
	player:SetAttribute("Cash", data.Cash)
	if upgradeName == "Storage" then
		data.BackpackCapacity += Config.StorageUpgrade.CapacityPerLevel
		player:SetAttribute("StorageLevel", data.Upgrades.Storage)
		player:SetAttribute("BackpackCapacity", data.BackpackCapacity)
	elseif upgradeName == "Chain" then
		player:SetAttribute("ChainLevel", data.Upgrades.ChainTargets)
		player:SetAttribute("BlastCount", PlayerDataService.GetBlastCount(player))
	elseif upgradeName == "Magnet" then
		player:SetAttribute("MagnetLevel", data.Upgrades.Magnet)
		player:SetAttribute("MagnetRange", PlayerDataService.GetCollectionRange(player))
	end
	return true, price
end

function PlayerDataService.BuyStorage(player)
	return PlayerDataService.BuyUpgrade(player, "Storage")
end

function PlayerDataService.GetXPToNextLevel(level)
	return math.floor(Config.LevelXPBase * level ^ Config.LevelXPExponent)
end

function PlayerDataService.Train(player, sequence)
	local data = profiles[player]
	if not data then return false end
	local weapon = WeaponDefinitions[data.EquippedWeapon]
	if not weapon then return false end
	data.Power += weapon.PowerPerClick
	data.XP += 1
	while data.XP >= PlayerDataService.GetXPToNextLevel(data.Level) do
		data.XP -= PlayerDataService.GetXPToNextLevel(data.Level)
		data.Level += 1
	end
	player:SetAttribute("Power", data.Power)
	player:SetAttribute("XP", data.XP)
	player:SetAttribute("Level", data.Level)
	if sequence then trainingSequences[player] = sequence end
	PlayerDataService.PublishProgress(player)
	return true
end

function PlayerDataService.GetDamage(player)
	local data = profiles[player]
	if not data then return Config.Damage end
	return math.max(Config.Damage, data.Power)
end

function PlayerDataService.BuyOrEquipWeapon(player, weaponName)
	local data = profiles[player]
	if not data then return false, "Data not ready" end
	local definition = WeaponDefinitions[weaponName]
	if not definition then return false, "Unknown weapon" end
	if not data.Weapons[weaponName] then
		if data.Level < definition.Level then return false, `Reach Level {definition.Level} first` end
		if data.Cash < definition.Price then return false, `Need ${definition.Price - data.Cash} more cash` end
		data.Cash -= definition.Price
		data.Weapons[weaponName] = true
		player:SetAttribute("Cash", data.Cash)
		player:SetAttribute("OwnsWeapon_" .. definition.Id, true)
		if weaponName == "Arc Pistol" then player:SetAttribute("OwnsArcPistol", true) end
	end
	data.EquippedWeapon = weaponName
	player:SetAttribute("EquippedWeapon", data.EquippedWeapon)
	return true, weaponName .. " equipped"
end

function PlayerDataService.BuyOrEquipArcPistol(player)
	return PlayerDataService.BuyOrEquipWeapon(player, "Arc Pistol")
end

function PlayerDataService.Save(player)
	local data = profiles[player]
	if canSave[player] == false then return false end
	if not data or not shouldUseDataStore() then return true end
	local success, message = pcall(function()
		store:UpdateAsync(`Player_{player.UserId}`, function()
			return data
		end)
	end)
	if not success then warn(`Player data save failed for {player.Name}: {message}`) end
	return success
end

function PlayerDataService.Release(player)
	PlayerDataService.Save(player)
	profiles[player] = nil
	canSave[player] = nil
	trainingSequences[player] = nil
end

function PlayerDataService.SaveAll()
	for player in profiles do PlayerDataService.Save(player) end
end

return PlayerDataService
