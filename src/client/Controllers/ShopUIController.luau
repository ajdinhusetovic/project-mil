local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Format = require(ReplicatedStorage:WaitForChild("Shared").NumberFormat)
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Config)
local Overcharge = require(ReplicatedStorage.Shared.OverchargeDefinitions)
local Weapons = require(ReplicatedStorage.Shared.WeaponDefinitions)
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ShopGui", 3)
if not gui then
	warn("ShopGui is missing. Paste studio/build_shop_gui.lua into the Studio Command Bar in Edit mode, then press Play again.")
	return false
end

local shade = gui:WaitForChild("Shade")
local window = shade:WaitForChild("Window")
local header = window:WaitForChild("Header")
local content = window:WaitForChild("Content")
local upgradePage = content:WaitForChild("UpgradesPage")
local weaponPage = content:WaitForChild("WeaponsPage")
local currentShop = nil
local pending = false

local upgradeCards = {
	Storage = upgradePage:FindFirstChild("StorageCard", true),
	Chain = upgradePage:FindFirstChild("ChainCard", true),
	Magnet = upgradePage:FindFirstChild("MagnetCard", true),
}
local weaponCards = {}
for _, weaponName in Config.WeaponOrder do
	local definition = Weapons[weaponName]
	weaponCards[weaponName] = weaponPage:FindFirstChild(definition.CardName, true)
end

local function child(parent, name)
	return parent and parent:FindFirstChild(name)
end

local function refresh()
	local cash = player:GetAttribute("Cash") or 0
	local level = player:GetAttribute("Level") or 1
	local equipped = player:GetAttribute("EquippedWeapon") or "Scrap Zapper"
	header.CashLabel.Text = "$" .. Format.Compact(cash)

	for upgradeName, card in upgradeCards do
		if not card then continue end
		local details = child(card, "DetailLabel")
		local button = child(card, "BuyButton")
		if not details or not button then continue end
		local upgradeLevel, definition
		if upgradeName == "Storage" then
			upgradeLevel = player:GetAttribute("StorageLevel") or 0
			definition = Config.StorageUpgrade
			local capacity = player:GetAttribute("BackpackCapacity") or 50
			details.Text = string.format("BAG CAPACITY  %s  →  %s", Format.Compact(capacity), Format.Compact(capacity + definition.CapacityPerLevel))
		elseif upgradeName == "Chain" then
			upgradeLevel = player:GetAttribute("ChainLevel") or 0
			definition = Config.ChainUpgrade
			local count = player:GetAttribute("BlastCount") or Config.BlastBlocks
			details.Text = string.format("HIT %s  →  %s BLOCKS", Format.Compact(count), Format.Compact(count + 1))
		else
			upgradeLevel = player:GetAttribute("MagnetLevel") or 0
			definition = Config.MagnetUpgrade
			local range = player:GetAttribute("MagnetRange") or Config.CollectionRange
			details.Text = string.format("PICKUP RANGE  %s  →  %s STUDS", Format.Compact(range), Format.Compact(range + definition.RangePerLevel))
		end
		if upgradeLevel >= definition.MaxLevel then
			button.Text = "MAXED"
			button.Active = false
		else
			local price = math.floor(definition.BasePrice * definition.PriceMultiplier ^ upgradeLevel)
			button.Text = string.format("UPGRADE  •  $%s", Format.Compact(price))
			button.Active = true
		end
	end

	for _, weaponName in Config.WeaponOrder do
		local card = weaponCards[weaponName]
		if not card then continue end
		local definition = Weapons[weaponName]
		local details = child(card, "DetailLabel")
		local button = child(card, "BuyButton")
		local status = child(card, "StatusLabel")
		if details then details.Text = string.format("+%s POWER / CLICK  •  LEVEL %s", Overcharge.Number(definition.PowerPerClick * (player:GetAttribute("PowerMultiplier") or 1)), Format.Compact(definition.Level)) end
		local owned = player:GetAttribute("OwnsWeapon_" .. definition.Id) == true or weaponName == "Scrap Zapper"
		if status then status.Text = equipped == weaponName and "EQUIPPED" or "OWNED" end
		if not button then continue end
		if equipped == weaponName then
			button.Text = "EQUIPPED"
			button.Active = false
		elseif owned then
			button.Text = "EQUIP"
			button.Active = true
		elseif level < definition.Level then
			button.Text = string.format("UNLOCK AT LEVEL %s", Format.Compact(definition.Level))
			button.Active = false
		else
			button.Text = string.format("BUY  •  $%s", Format.Compact(definition.Price))
			button.Active = true
		end
	end
end

local function close()
	shade.Visible = false
	currentShop = nil
	pending = false
end

local function open(shopType)
	if shopType ~= "Upgrades" and shopType ~= "Weapons" then return end
	currentShop = shopType
	shade.Visible = true
	upgradePage.Visible = shopType == "Upgrades"
	weaponPage.Visible = shopType == "Weapons"
	header.TitleLabel.Text = shopType == "Upgrades" and "UPGRADES" or "WEAPON SHOP"
	header.BackgroundColor3 = shopType == "Upgrades" and Color3.fromRGB(169, 66, 255) or Color3.fromRGB(255, 158, 34)
	refresh()
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
	if who and who ~= player then return end
	local node = prompt.Parent
	while node and node ~= workspace do
		local kind = node:GetAttribute("ShopType")
		if kind then open(kind) return end
		node = node.Parent
	end
end)

header.CloseButton.Activated:Connect(close)
shade:WaitForChild("ClickAwayButton").Activated:Connect(close)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Escape and shade.Visible then close() end
end)

for upgradeName, card in upgradeCards do
	local button = child(card, "BuyButton")
	if button then
		button.Activated:Connect(function()
			if currentShop ~= "Upgrades" or pending or not button.Active then return end
			pending = true
			remote:FireServer("BuyUpgrade", upgradeName)
		end)
	end
end
for _, weaponName in Config.WeaponOrder do
	local button = child(weaponCards[weaponName], "BuyButton")
	if button then
		button.Activated:Connect(function()
			if currentShop ~= "Weapons" or pending or not button.Active then return end
			pending = true
			remote:FireServer("BuyOrEquipWeapon", weaponName)
		end)
	end
end

remote.OnClientEvent:Connect(function(action)
	if action == "UpgradePurchased" or action == "StoragePurchased" or action == "WeaponShopResult" then
		pending = false
		refresh()
	end
end)
for _, name in { "Cash", "Level", "StorageLevel", "BackpackCapacity", "ChainLevel", "BlastCount", "MagnetLevel", "MagnetRange", "EquippedWeapon", "PowerMultiplier" } do
	player:GetAttributeChangedSignal(name):Connect(refresh)
end
for _, weaponName in Config.WeaponOrder do
	player:GetAttributeChangedSignal("OwnsWeapon_" .. Weapons[weaponName].Id):Connect(refresh)
end
shade.Visible = false
refresh()
return true
