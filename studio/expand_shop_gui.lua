-- Paste into Roblox Studio's Command Bar in Edit mode after build_shop_gui.lua.
-- Expands the existing editable shop without replacing its styling or your edits.
local shop = game:GetService("StarterGui"):FindFirstChild("ShopGui")
assert(shop, "StarterGui.ShopGui is missing; run studio/build_shop_gui.lua first")
local content = shop.Shade.Window.Content
local upgrades = content.UpgradesPage
local weapons = content.WeaponsPage

local function catalog(page)
	local list = page:FindFirstChild("Catalog")
	if not list then
		list = Instance.new("ScrollingFrame")
		list.Name = "Catalog"
		list.Position = UDim2.fromScale(0.02, 0.15)
		list.Size = UDim2.fromScale(0.96, 0.83)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 8
		list.ScrollBarImageColor3 = Color3.fromRGB(255, 220, 81)
		list.CanvasSize = UDim2.fromOffset(0, 0)
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.ZIndex = 5
		list.Parent = page
		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 6)
		padding.PaddingBottom = UDim.new(0, 12)
		padding.PaddingLeft = UDim.new(0, 12)
		padding.PaddingRight = UDim.new(0, 18)
		padding.Parent = list
		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 12)
		layout.Parent = list
	end
	return list
end

local upgradeList = catalog(upgrades)
local weaponList = catalog(weapons)
local footer = upgrades:FindFirstChild("FooterLabel")
if footer then footer.Visible = false end

local function place(card, parent, order, height)
	card.Parent = parent
	card.LayoutOrder = order
	card.Size = UDim2.new(1, 0, 0, height)
	card.Position = UDim2.new()
	return card
end

local function tint(card, top, bottom)
	card.BackgroundColor3 = top
	local gradient = card:FindFirstChildWhichIsA("UIGradient")
	if gradient then gradient.Color = ColorSequence.new(top, bottom) end
end

local storage = place(upgrades:FindFirstChild("StorageCard", true), upgradeList, 1, 145)
local chain = upgrades:FindFirstChild("ChainCard", true)
if not chain then
	chain = storage:Clone()
	chain.Name = "ChainCard"
	chain.NameLabel.Text = "CHAIN TARGETS"
	chain.DetailLabel.Text = "BREAK 1  →  2 BLOCKS"
	chain.BuyButton.Text = "UPGRADE  •  $75"
	tint(chain, Color3.fromRGB(255, 167, 74), Color3.fromRGB(211, 76, 36))
end
place(chain, upgradeList, 2, 145)
local magnet = upgrades:FindFirstChild("MagnetCard", true)
if not magnet then
	magnet = storage:Clone()
	magnet.Name = "MagnetCard"
	magnet.NameLabel.Text = "MAGNET RANGE"
	magnet.DetailLabel.Text = "PICKUP RANGE  18  →  24 STUDS"
	magnet.BuyButton.Text = "UPGRADE  •  $100"
	tint(magnet, Color3.fromRGB(72, 225, 255), Color3.fromRGB(42, 110, 216))
end
place(magnet, upgradeList, 3, 145)

local starter = place(weapons:FindFirstChild("StarterCard", true), weaponList, 1, 115)
local starterStatus = starter:FindFirstChild("StatusLabel")
if starterStatus then starterStatus.Visible = false end
if not starter:FindFirstChild("BuyButton") then
	local starterButton = weapons.ArcCard.BuyButton:Clone()
	starterButton.Name = "BuyButton"
	starterButton.Position = UDim2.fromScale(0.62, 0.25)
	starterButton.Size = UDim2.fromScale(0.33, 0.5)
	starterButton.Text = "EQUIPPED"
	starterButton.Parent = starter
end

local arc = place(weapons:FindFirstChild("ArcCard", true), weaponList, 2, 145)
local tiers = {
	{ "TeslaCard", "TESLA RIFLE", "+7 POWER / CLICK  •  LEVEL 5", Color3.fromRGB(71, 216, 255), Color3.fromRGB(28, 91, 174) },
	{ "StormCard", "STORM BLASTER", "+15 POWER / CLICK  •  LEVEL 10", Color3.fromRGB(203, 244, 255), Color3.fromRGB(69, 120, 203) },
	{ "NuclearCard", "NUCLEAR CONDUCTOR", "+35 POWER / CLICK  •  LEVEL 17", Color3.fromRGB(149, 255, 92), Color3.fromRGB(41, 145, 45) },
	{ "PlasmaCard", "PLASMA CANNON", "+80 POWER / CLICK  •  LEVEL 25", Color3.fromRGB(217, 108, 255), Color3.fromRGB(105, 42, 181) },
}
for index, tier in tiers do
	local card = weapons:FindFirstChild(tier[1], true)
	if not card then
		card = arc:Clone()
		card.Name = tier[1]
		card.NameLabel.Text = tier[2]
		card.DetailLabel.Text = tier[3]
		card.BuyButton.Text = "LOCKED"
		tint(card, tier[4], tier[5])
	end
	place(card, weaponList, index + 2, 145)
end

print("Expanded StarterGui.ShopGui: Storage, Chain, Magnet, and six weapon tiers. Edit each Card in Explorer.")
