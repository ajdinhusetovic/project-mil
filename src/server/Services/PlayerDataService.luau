local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local HttpService = game:GetService("HttpService")

local Config = require(ReplicatedStorage.Shared.Config)
local MaterialDefinitions = require(ReplicatedStorage.Shared.MaterialDefinitions)
local WeaponDefinitions = require(ReplicatedStorage.Shared.WeaponDefinitions)
local Template = require(ReplicatedStorage.Shared.PlayerDataTemplate)
local CoreDefinitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Overcharge = require(ReplicatedStorage.Shared.OverchargeDefinitions)
local Progression = require(ReplicatedStorage.Shared.Progression)
local Migration = require(ReplicatedStorage.Shared.EconomyMigration)
local IndexRewards = require(ReplicatedStorage.Shared.IndexRewards)

local PlayerDataService = {}
local profiles = {}
local canSave = {}
local trainingSequences = {}
local progressEpochs = {}
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
	local powerMultiplier, cashMultiplier = Overcharge.Multipliers(data.Overcharges)
	cashMultiplier *= 1 + IndexRewards.Bonus(IndexRewards.Count(data.DiscoveredCores))
	player:SetAttribute("Overcharges", data.Overcharges)
	player:SetAttribute("PowerMultiplier", powerMultiplier)
	player:SetAttribute("CashMultiplier", cashMultiplier)
	player:SetAttribute("IndexDiscoveredCount",IndexRewards.Count(data.DiscoveredCores))
	player:SetAttribute("IndexCashBonus",IndexRewards.Bonus(IndexRewards.Count(data.DiscoveredCores)))
	player:SetAttribute("StabilizedCoreCount", #data.StabilizedCores)
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
		Epoch = progressEpochs[player] or 0, PowerMultiplier = PlayerDataService.GetPowerMultiplier(player),
	}))
end

function PlayerDataService.GetProgressEpoch(player)
	return progressEpochs[player] or 0
end

function PlayerDataService.GetPowerMultiplier(player)
	local data = profiles[player]
	return Overcharge.Multipliers(data and data.Overcharges or 0)
end

function PlayerDataService.GetCashMultiplier(player)
	local data = profiles[player]
	local _, multiplier = Overcharge.Multipliers(data and data.Overcharges or 0)
	return multiplier * (1 + IndexRewards.Bonus(IndexRewards.Count(data and data.DiscoveredCores or {})))
end

function PlayerDataService.GetCashPayout(player, baseValue)
	local multiplier=PlayerDataService.GetCashMultiplier(player)
	return math.floor(baseValue * multiplier + 0.000001)
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
	Migration.Apply(data)
	profiles[player] = data
	-- Backfill existing inventories; discovery remains saved after a core is removed.
	for _, core in data.StabilizedCores do
		if CoreDefinitions.Cores[core.Type] then data.DiscoveredCores[core.Type] = true end
	end
	for _, key in CoreDefinitions.Order do
		player:SetAttribute("DiscoveredCore_" .. key, data.DiscoveredCores[key] == true)
	end
	trainingSequences[player] = 0
	progressEpochs[player] = 0
	publish(player, data)
	return data
end

function PlayerDataService.Get(player)
	return profiles[player]
end

function PlayerDataService.DiscoverCore(player, key)
	local data = profiles[player]
	if not data or not CoreDefinitions.Cores[key] then return false end
	data.DiscoveredCores[key] = true
	player:SetAttribute("DiscoveredCore_" .. key, true)
	local count=IndexRewards.Count(data.DiscoveredCores)
	player:SetAttribute("IndexDiscoveredCount",count)
	player:SetAttribute("IndexCashBonus",IndexRewards.Bonus(count))
	player:SetAttribute("CashMultiplier",PlayerDataService.GetCashMultiplier(player))
	return true
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
	payout = PlayerDataService.GetCashPayout(player, payout)
	data.Materials = {}
	data.Cash += payout
	player:SetAttribute("Cash", data.Cash)
	player:SetAttribute("BackpackUsed", 0)
	return payout, count
end

-- Validate the held Tool against the saved inventory, never its client attributes alone.
function PlayerDataService.GetHeldStabilizedCore(player)
	local data = profiles[player]
	if not data then return nil, "Data not ready." end
	local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
	if tool and tool:GetAttribute("IsUnknownCore") then return nil, "Stabilize this Unknown Core before selling it." end
	if not tool or not tool:GetAttribute("IsStabilizedCore") then return nil, "Hold a stabilized core from your hotbar first." end
	local id = tool:GetAttribute("CoreId")
	for _, core in data.StabilizedCores do
		if core.Id == id and CoreDefinitions.Cores[core.Type] then return core end
	end
	return nil, "That core is no longer in your inventory."
end

function PlayerDataService.SellHeldCore(player, expectedId, expectedMutation, expectedType)
	local core, reason = PlayerDataService.GetHeldStabilizedCore(player)
	if not core then return false, reason end
	if core.Id ~= expectedId then return false, "Your held core changed. Ask for a new price." end
	if (expectedMutation and CoreDefinitions.MutationKey(core) ~= expectedMutation) or (expectedType and core.Type ~= expectedType) then
		return false, "Your core changed. Ask for a new price."
	end
	local data = profiles[player]
	local index = table.find(data.StabilizedCores, core)
	if not index then return false, "That core is no longer in your inventory." end
	table.remove(data.StabilizedCores, index)
	local payout = PlayerDataService.GetCashPayout(player, CoreDefinitions.SaleValue(core))
	data.Cash += payout
	player:SetAttribute("Cash", data.Cash)
	player:SetAttribute("StabilizedCoreCount", #data.StabilizedCores)
	-- Discovery is permanent even when the last copy is sold.
	PlayerDataService.DiscoverCore(player, core.Type)
	return true, payout, CoreDefinitions.DisplayName(core)
end

function PlayerDataService.GetCoreSaleSummary(player)
	local data = profiles[player]
	if not data then return nil, "Data not ready." end
	local summary = {Cores = {}, Count = 0, SellValue = 0}
	for _, core in data.StabilizedCores do
		local definition = CoreDefinitions.Cores[core.Type]
		if definition then
			table.insert(summary.Cores, {Id = core.Id, Type = core.Type, Mutation = CoreDefinitions.MutationKey(core)})
			summary.Count += 1
			summary.SellValue += CoreDefinitions.SaleValue(core)
		end
	end
	if summary.Count == 0 then return nil, "You have no stabilized cores to sell." end
	summary.SellValue = PlayerDataService.GetCashPayout(player, summary.SellValue)
	return summary
end

function PlayerDataService.SellAllCores(player, expectedCores)
	local summary, reason = PlayerDataService.GetCoreSaleSummary(player)
	if not summary then return false, reason end
	if #summary.Cores ~= #expectedCores then return false, "Your core inventory changed. Ask for a new price." end
	local expected = {}
	for _, core in expectedCores do expected[core.Id] = core end
	for _, core in summary.Cores do
		local record = expected[core.Id]
		if not record or record.Type ~= core.Type or CoreDefinitions.MutationKey(record) ~= core.Mutation then
			return false, "Your core inventory changed. Ask for a new price."
		end
	end
	local data = profiles[player]
	for index = #data.StabilizedCores, 1, -1 do
		local core = data.StabilizedCores[index]
		local record = expected[core.Id]
		if record and record.Type == core.Type and CoreDefinitions.MutationKey(record) == CoreDefinitions.MutationKey(core) then
			table.remove(data.StabilizedCores, index)
			PlayerDataService.DiscoverCore(player, core.Type)
		end
	end
	data.Cash += summary.SellValue
	player:SetAttribute("Cash", data.Cash)
	player:SetAttribute("StabilizedCoreCount", #data.StabilizedCores)
	return true, summary.SellValue, summary.Count
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
	if data.Cash < price then return false, `Need ${Format.Compact(price - data.Cash)} more cash` end
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
	return Progression.XPRequired(level)
end

function PlayerDataService.AwardTraining(player, multiplier, sequence)
	local data = profiles[player]
	if not data then return false end
	local weapon = WeaponDefinitions[data.EquippedWeapon]
	if not weapon then return false end
	local gain = weapon.PowerPerClick * PlayerDataService.GetPowerMultiplier(player) * multiplier
	data.Power += gain
	data.XP += gain
	while data.XP >= PlayerDataService.GetXPToNextLevel(data.Level) do
		data.XP -= PlayerDataService.GetXPToNextLevel(data.Level)
		data.Level += 1
	end
	player:SetAttribute("Power", data.Power)
	player:SetAttribute("XP", data.XP)
	player:SetAttribute("Level", data.Level)
	if sequence then trainingSequences[player] = sequence end
	PlayerDataService.PublishProgress(player)
	return true, gain
end

function PlayerDataService.Train(player, sequence)
	return PlayerDataService.AwardTraining(player, 1, sequence)
end

function PlayerDataService.GetDamage(player)
	local data = profiles[player]
	if not data then return 0 end
	return math.max(0, data.Power)
end

function PlayerDataService.BuyOrEquipWeapon(player, weaponName)
	local data = profiles[player]
	if not data then return false, "Data not ready" end
	local definition = WeaponDefinitions[weaponName]
	if not definition then return false, "Unknown weapon" end
	if not data.Weapons[weaponName] then
		if data.Level < definition.Level then return false, `Reach Level {Format.Compact(definition.Level)} first` end
		if data.Cash < definition.Price then return false, `Need ${Format.Compact(definition.Price - data.Cash)} more cash` end
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

-- Re-check the expected run and requirements on the server. No yielding during the reset.
function PlayerDataService.Overcharge(player, expectedCount)
	local data = profiles[player]
	if not data then return false, "Data not ready" end
	if typeof(expectedCount) ~= "number" or expectedCount ~= data.Overcharges then
		return false, "Your Overcharge changed. Check the new requirements."
	end
	local needed = Overcharge.Requirements(data.Overcharges)
	if data.Level < needed.Level then
		return false, "Reach the required level first."
	end
	data.Overcharges += 1
	for _, field in {"Power", "XP", "Level", "Cash", "Materials", "BackpackCapacity", "EquippedWeapon", "Weapons", "Upgrades", "UnknownCoreCapacity"} do
		data[field] = deepCopy(Template[field])
	end
	progressEpochs[player] = (progressEpochs[player] or 0) + 1
	publish(player, data)
	return true, data.Overcharges
end

-- Retired endpoints reject stale clients instead of generating passive cash.
function PlayerDataService.GetReactorSnapshot(player) return nil end
function PlayerDataService.ChangeReactor(player)
	return false, "Cores are stabilized and sold at the Ore Buyer now."
end
function PlayerDataService.CollectReactor(player)
	return false, "Passive reactor income has been removed. Sell stabilized cores."
end
function PlayerDataService.Save(player)
	local data = profiles[player]
	if canSave[player] == false then return false end
	if not data then return true end
	if not shouldUseDataStore() then return true end
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
	progressEpochs[player] = nil
end

function PlayerDataService.SaveAll()
	for player in profiles do PlayerDataService.Save(player) end
end

return PlayerDataService
